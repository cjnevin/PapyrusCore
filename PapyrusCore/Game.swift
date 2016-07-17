//
//  Game.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public enum GameEvent {
    case over(Game, [Player]?)
    case move(Game, Solution)
    case drewTiles(Game, [Character])
    case swappedTiles(Game)
    case turnBegan(Game)
    case turnEnded(Game)
}

public enum GameType: Int {
    case scrabble = 0
    case superScrabble
    case wordfeud
    case wordsWithFriends
    
    public func bag() -> Bag {
        switch self {
        case .superScrabble:
            return SuperScrabbleBag()
        case .wordfeud:
            return WordfeudBag()
        case .wordsWithFriends:
            return WordsWithFriendsBag()
        default:
            return ScrabbleBag()
        }
    }
    
    public func board() -> Board {
        switch self {
        case .superScrabble:
            return SuperScrabbleBoard()
        case .wordfeud:
            return WordfeudBoard()
        case .wordsWithFriends:
            return WordsWithFriendsBoard()
        default:
            return ScrabbleBoard()
        }
    }
}

let aiCanPlayBlanks = false

public typealias EventHandler = (GameEvent) -> ()
public class Game {
    /// Character used for blank/wildcard tiles.
    public static let blankLetter = Character("_")
    /// Amount of tiles that should be in a players rack when possible.
    public static let rackAmount = 7
    var solver: Solver
    var serial: Bool = false
    private(set) public var ended: Bool = true
    /// Bag where tiles are drawn from.
    public var bag: Bag
    /// All players.
    public private(set) var players: [Player]
    var playerIndex: Int
    /// Player that is having their turn.
    public var player: Player { return players[playerIndex] }
    private var eventHandler: EventHandler
    public var board: Board {
        return solver.board
    }
    var _lastMove: Solution? = nil
    /// Last solution played.
    public var lastMove: Solution? {
        return _lastMove
    }
    private let maximumConsecutiveSkips = 3
    
    /// Create a new game.
    public init(bag: Bag,
         board: Board,
         dictionary: Lookup,
         players: [Player],
         playerIndex: Int = 0,
         serial: Bool = false,
         eventHandler: EventHandler) {
        var solver: Solver!
        if board is WordsWithFriendsBoard {
            solver = WordsWithFriendsSolver(bagType: bag.dynamicType, board: board, dictionary: dictionary)
        } else {
            solver = ScrabbleSolver(bagType: bag.dynamicType, board: board, dictionary: dictionary)
        }
        players.forEach({ $0.solves.forEach({ _ = solver.play(solution: $0) }) })
        self.solver = solver
        self.bag = bag
        self.serial = serial
        self.players = players
        self.playerIndex = playerIndex
        self.eventHandler = eventHandler
    }
    
    /// Create a new game with the default configurations for the given `gameType` (Recommended).
    public convenience init(gameType: GameType = .scrabble, dictionary: Lookup, players: [Player], serial: Bool = false, eventHandler: EventHandler) {
        self.init(bag: gameType.bag(), board: gameType.board(), dictionary: dictionary, players: players, playerIndex: 0, serial: serial, eventHandler: eventHandler)
        for _ in players {
            replenishRack()
            playerIndex += 1
        }
        playerIndex = 0
    }
    
    /// Restore a game from file.
    public convenience init?(from file: URL, dictionary: Lookup, eventHandler: EventHandler) {
        guard let
            json = readJSON(from: file),
            gameTypeInt: Int = JSONKey.gameType.in(json),
            gameType = GameType(rawValue: gameTypeInt),
            bagRemaining: String = JSONKey.bag.in(json),
            playersJson: [JSON] = JSONKey.players.in(json),
            playerIndex: Int = JSONKey.playerIndex.in(json),
            serial: Bool = JSONKey.serial.in(json) else {
                return nil
        }
        var bag = gameType.bag()
        bag.remaining = Array(bagRemaining.characters)
        self.init(bag: bag, board: gameType.board(), dictionary: dictionary, players: makePlayers(using: playersJson), playerIndex: playerIndex, serial: serial, eventHandler: eventHandler)
        guard let lastMoveJson: JSON = JSONKey.lastMove.in(json) else {
            return
        }
        _lastMove = Solution.object(from: lastMoveJson)
    }
    
    /// Returns: Index of given player in players array.
    public func index(of player: Player) -> Int? {
        return players.enumerated().filter({ $1.id == player.id }).first?.offset
    }
    
    /// Save the current state of the game to disk. Can be restored using `Game(from:)`.
    public func save(to file: URL) -> Bool {
        var gameType: GameType!
        if board is SuperScrabbleBoard {
            gameType = .superScrabble
        } else if board is WordsWithFriendsBoard {
            gameType = .wordsWithFriends
        } else if board is WordfeudBoard {
            gameType = .wordfeud
        } else {
            gameType = .scrabble
        }
        let lastMoveJson = _lastMove?.toJSON() ?? NSNull()
        let output = json(from: [.lastMove: lastMoveJson,
                                 .gameType: gameType.rawValue,
                                 .bag: String(bag.remaining),
                                 .players: players.map({ $0.toJSON() }),
                                 .playerIndex: playerIndex,
                                 .serial: serial])
        return writeJSON(output, to: file)
    }
    
    /// Rearrange a tile in your rack.
    public func moveRackTile(from currentIndex: Int, to newIndex: Int) {
        if player is Human {
            players[playerIndex].moveTile(from: currentIndex, to: newIndex)
        }
    }
    
    /// Shuffle the tiles in your rack.
    public func shuffleRack() {
        if player is Human {
            players[playerIndex].shuffle()
        }
    }
    
    /// Start gameplay.
    public func start() {
        ended = false
        turn()
    }
    
    /// End current game prematurely.
    public func stop() {
        gameOver()
    }
    
    /// Skip current players turn.
    public func skip() {
        if ended {
            return
        }
        print("Skipped")
        _lastMove = nil
        players[playerIndex].consecutiveSkips += 1
        guard player.consecutiveSkips < maximumConsecutiveSkips else {
            gameOver()
            return
        }
        nextTurn()
    }
    
    private func gameOver() {
        if ended {
            return
        }
        ended = true
        _lastMove = nil
        var newPlayers = players
        for i in 0..<newPlayers.count {
            newPlayers[i].score -= newPlayers[i].rack
                .filter({ !$0.isBlank })
                .reduce(0){ $0.0 + (bag.dynamicType.letterPoints[$0.1.letter] ?? 0) }
            newPlayers[i].rack = []
        }
        players = newPlayers
        
        // Does not currently handle ties
        let bestScore = players.sorted(isOrderedBefore: { $0.score > $1.score }).first
        let winners = players.filter({ $0.score == bestScore?.score })
        eventHandler(.over(self, winners))
    }
    
    private func turn() {
        if ended {
            return
        }
        if player.rack.count == 0 {
            gameOver()
            return
        }
        eventHandler(.turnBegan(self))
        if player is Computer {
            var ai = player as! Computer
            let vowels = bag.dynamicType.vowels
            let blank = Game.blankLetter
            while aiCanPlayBlanks == false && ai.rack.filter({$0.letter == blank}).count > 0 {
                if Set(ai.rack.map({$0.letter})).intersection(vowels).count == 0 {
                    // If we have no vowels lets pick a random vowel
                    ai.updateBlank(to: vowels[Int(arc4random()) % vowels.count])
                    print("AI set value of blank letter")
                } else {
                    // We have vowels, lets choose 's'
                    ai.updateBlank(to: "s")
                    print("AI set value of blank letter")
                }
            }
            solver.solutions(for: ai.rack, completion: { solutions in
                guard let solutions = solutions, solution = self.solver.solve(with: solutions, difficulty: ai.difficulty) else {
                    // Can't find any solutions, attempt to swap tiles
                    let tiles = Array(ai.rack[0..<min(self.bag.remaining.count, ai.rack.count)])
                    guard self.swap(tiles: tiles.map({ $0.letter })) else {
                        // We're stuck with these tiles, nothing AI can do, lets skip
                        self.skip()
                        return
                    }
                    return
                }
                // Play solution
                self.play(solution: solution)
                self.nextTurn()
            })
        }
    }
    
    /// Call when the player has finished their turn.
    public func nextTurn() {
        if ended {
            return
        }
        eventHandler(.turnEnded(self))
        if player.rack.count == 0 {
            gameOver()
            return
        }
        playerIndex = (playerIndex + 1) % players.count
        turn()
    }
    
    /// Submit a move. Developer is responsible for calling `nextTurn` when ready to progress game.
    public func play(solution: Solution) {
        if ended {
            return
        }
        _lastMove = solution
        let dropped = solver.play(solution: solution)
        assert(dropped.count > 0)
        players[playerIndex].played(solution: solution, tiles: dropped)
        replenishRack()
        eventHandler(.move(self, solution))
    }
    
    private func replenishRack() {
        let amount = min(Game.rackAmount - player.rack.count, bag.remaining.count)
        let newTiles = (0..<amount).flatMap { _ in bag.draw() }
        players[playerIndex].drew(tiles: newTiles)
        eventHandler(.drewTiles(self, newTiles))
    }
    
    /// Request a suggested solution given the users current tiles and the state of the board.
    public func suggestion(completion: (solution: Solution?) -> ()) {
        solver.solutions(for: player.rack, serial: false) { [weak self] solutions in
            guard let solutions = solutions, best = self?.solver.solve(with: solutions, difficulty: .hard) else {
                completion(solution: nil)
                return
            }
            completion(solution: best)
        }
    }
    
    /// Player can only swap tiles if there is a sufficient amount left in the bag.
    public var canSwap: Bool {
        return bag.remaining.count > Game.rackAmount
    }
    
    /// Swap given tiles with new ones from the bag.
    public func swap(tiles oldTiles: [Character]) -> Bool {
        guard canSwap else { return false }
        
        oldTiles.forEach { bag.replace($0) }
        let newTiles = oldTiles.flatMap { _ in bag.draw() }
        players[playerIndex].swapped(tiles: oldTiles, with: newTiles)
        
        print("Swapped \(oldTiles) for \(newTiles)")
        eventHandler(.swappedTiles(self))
        
        // Swap complete, next players turn
        nextTurn()
        return true
    }
    
    /// Validate a move by providing the offsets of the letters that were dropped and the blanks that were included in that move.
    /// If successful you will receive a solution you can pass to the `play` method. 
    /// Solution contains useful information such as the score and the intersected words.
    public func validate(positions: LetterPositions, blanks: Positions) -> ValidationResponse {
        return solver.validate(positions: positions, blanks: blanks)
    }
    
}
