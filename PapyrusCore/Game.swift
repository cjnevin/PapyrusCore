//
//  Game.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public enum GameEvent {
    case over(Game, Player?)
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
    
    func bag() -> Bag {
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
    
    func board() -> Board {
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
    public static let blankLetter = Character("_")
    public static let rackAmount = 7
    var solver: Solver
    var serial: Bool = false
    var ended: Bool = true
    public var bag: Bag
    public private(set) var players: [Player]
    var playerIndex: Int
    public var player: Player { return players[playerIndex] }
    private var eventHandler: EventHandler
    public var board: Board {
        return solver.board
    }
    var _lastMove: Solution? = nil
    public var lastMove: Solution? {
        return _lastMove
    }
    private let maximumConsecutiveSkips = 3
    
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
    
    public convenience init(gameType: GameType = .scrabble, dictionary: Lookup, players: [Player], serial: Bool = false, eventHandler: EventHandler) {
        self.init(bag: gameType.bag(), board: gameType.board(), dictionary: dictionary, players: players, playerIndex: 0, serial: serial, eventHandler: eventHandler)
        for _ in players {
            replenishRack()
            playerIndex += 1
        }
        playerIndex = 0
    }
    
    public convenience init?(fromFile file: URL, dictionary: Lookup, eventHandler: EventHandler) {
        guard let
            json = readJSON(from: file),
            gameTypeInt = json["gameType"] as? Int,
            gameType = GameType(rawValue: gameTypeInt),
            bagRemaining = json["bag"] as? String,
            playersJson = json["players"] as? [JSON],
            playerIndex = json["playerIndex"] as? Int,
            serial = json["serial"] as? Bool else {
                return nil
        }
        var bag = gameType.bag()
        bag.remaining = Array(bagRemaining.characters)
        self.init(bag: bag, board: gameType.board(), dictionary: dictionary, players: makePlayers(using: playersJson), playerIndex: playerIndex, serial: serial, eventHandler: eventHandler)
        guard let lastMoveJson = json["lastMove"] as? JSON else {
            return
        }
        _lastMove = Solution.object(from: lastMoveJson)
    }
    
    public func save(toFile file: URL) -> Bool {
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
        let json: JSON = ["lastMove": lastMoveJson, "gameType": gameType.rawValue, "bag": String(bag.remaining), "players": players.map({ $0.toJSON() }), "playerIndex": playerIndex, "serial": serial]
        return writeJSON(json, to: file)
    }
    
    public func shuffleRack() {
        if player is Human {
            players[playerIndex].shuffle()
        }
    }
    
    public func start() {
        ended = false
        turn()
    }
    
    public func stop() {
        gameOver()
    }
    
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
        let winner = players.sorted(isOrderedBefore: { $0.score > $1.score }).first
        eventHandler(.over(self, winner))
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
            while aiCanPlayBlanks == false && ai.rack.filter({$0.0 == blank}).count > 0 {
                if Set(ai.rack.map({$0.0})).intersection(vowels).count == 0 {
                    // If we have no vowels lets pick a random vowel
                    ai.updateBlank(to: vowels[Int(arc4random()) % vowels.count])
                    print("AI set value of blank letter")
                } else {
                    // We have vowels, lets choose 's'
                    ai.updateBlank(to: "s")
                    print("AI set value of blank letter")
                }
            }
            solver.solutions(forLetters: ai.rack, completion: { solutions in
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
    
    public func replenishRack() {
        let amount = min(Game.rackAmount - player.rack.count, bag.remaining.count)
        let newTiles = (0..<amount).flatMap { _ in bag.draw() }
        players[playerIndex].drew(tiles: newTiles)
        eventHandler(.drewTiles(self, newTiles))
    }
    
    public var canSwap: Bool {
        return bag.remaining.count > Game.rackAmount
    }
    
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
    
    public func validate(points: [(x: Int, y: Int, letter: Character)], blanks: [(x: Int, y: Int)]) -> ValidationResponse {
        return solver.validate(points: points, blanks: blanks)
    }
    
    public func getHint(_ completion: (Solution?) -> ()) {
        solver.solutions(forLetters: player.rack, serial: false) { [weak self] solutions in
            guard let solutions = solutions, best = self?.solver.solve(with: solutions, difficulty: .hard) else {
                completion(nil)
                return
            }
            completion(best)
        }
    }
}
