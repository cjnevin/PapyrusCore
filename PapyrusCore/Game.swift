//
//  Game.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public enum GameError: Error {
    case initialization
}

public enum GameEvent {
    case over(Game, [Player]?)
    case move(Game, Solution)
    case drewTiles(Game, [Character])
    case swappedTiles(Game)
    case turnBegan(Game)
    case turnEnded(Game)
}

public typealias EventHandler = (GameEvent) -> ()

public class Game {
    /// Character used for blank/wildcard tiles.
    public static let blankLetter = Character("_")
    /// Amount of tiles that should be in a players rack when possible.
    public static let rackAmount = 7
    /// Number of times a user is allowed to skip before forfeiting.
    private static let maximumConsecutiveSkips = 3
    /// True if AI is allowed to figure out the best blank tile, false if it
    /// is automatically set to a default value based on their tiles in their rack.
    private static let aiCanPlayBlanks = false

    private var configJSON: JSON!
    private var eventHandler: EventHandler
    private var solver: Solver
    private var serial: Bool = false
    private var playerIndex: Int
    
    /// True if the game has ended, false if still in progress.
    private(set) public var ended: Bool = true
    /// Bag where tiles are drawn from.
    public var bag: Bag
    /// Player that is having their turn.
    public var player: Player { return players[playerIndex] }
    /// All players.
    public private(set) var players: [Player]
    /// Current representation of the board.
    public var board: BoardType {
        return solver.board
    }
    /// Last solution played.
    public var lastMove: Solution? { return _lastMove }
    private var _lastMove: Solution? = nil
    
    /// Create a new game.
    public init(config file: URL, dictionary: Lookup, players: [Player], serial: Bool = false, eventHandler: @escaping EventHandler) throws {
        guard
            let json = readJSON(from: file),
            let bag = Bag(json: json),
            let solver = Solver(json: json, bag: bag, dictionary: dictionary) else {
                throw GameError.initialization
        }
        self.configJSON = json
        self.serial = serial
        self.eventHandler = eventHandler
        self.bag = bag
        self.players = players.shuffled()
        self.solver = solver
        
        self.playerIndex = 0
        for _ in self.players {
            replenishRack()
            self.playerIndex += 1
        }
        self.playerIndex = 0
    }
    
    /// Restore a game from file.
    public init(restoring file: URL, dictionary: Lookup, eventHandler: @escaping EventHandler) throws {
        guard
            let json = readJSON(from: file),
            let bagRemaining: String = JSONKey.bag.in(json),
            let playersJson: [JSON] = JSONKey.players.in(json),
            let playerIndex: Int = JSONKey.playerIndex.in(json),
            let serial: Bool = JSONKey.serial.in(json),
            let configJson: JSON = JSONKey.config.in(json),
            let bag = Bag(json: configJson),
            let solver = Solver(json: configJson, bag: bag, dictionary: dictionary) else {
                throw GameError.initialization
        }
        
        self.configJSON = configJson
        self.serial = serial
        self.eventHandler = eventHandler
        self.bag = bag
        self.bag.remaining = Array(bagRemaining)
        self.solver = solver
        self.players = makePlayers(using: playersJson)
        self.playerIndex = playerIndex
        self.players.forEach({ $0.solves.forEach({ _ = self.solver.play(solution: $0) }) })
        
        guard let lastMoveJson: JSON = JSONKey.lastMove.in(json) else {
            return
        }
        _lastMove = Solution.object(from: lastMoveJson)
    }
    
    /// Returns: Index of given player in players array.
    public func index(of player: Player) -> Int? {
        return players.enumerated().filter({ $1.id == player.id }).first?.offset
    }
    
    /// Save the current state of the game to disk. Can be restored using `Game(restoring:)`.
    public func save(to file: URL) -> Bool {
        let lastMoveJson: JSONValueType = _lastMove?.toJSON() ?? NSNull()
        let values: [JSONKey: JSONValueType] = [.lastMove: lastMoveJson,
                                                .config: configJSON,
                                                .bag: String(bag.remaining),
                                                .players: players.map({ $0.toJSON() }),
                                                .playerIndex: playerIndex,
                                                .serial: serial]
        let output = json(from: values)
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
        guard player.consecutiveSkips < Game.maximumConsecutiveSkips else {
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
                .reduce(0){ $0.0 + (bag.letterPoints[$0.1.letter] ?? 0) }
            newPlayers[i].rack = []
        }
        players = newPlayers
        
        // Does not currently handle ties
        let bestScore = players.sorted(by: { $0.score > $1.score }).first
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
            let vowels = bag.vowels
            while !Game.aiCanPlayBlanks && ai.rack.filter({$0.letter == Game.blankLetter}).count > 0 {
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
                guard let solution = solutions?.best(forDifficulty: ai.difficulty) else {
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
        precondition(dropped.count > 0, "Unable to play solution, tiles didn't exist in player's rack.")
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
    public func suggestion(completion: @escaping (Solution?) -> ()) {
        solver.solutions(for: player.rack, serial: false) { solutions in
            guard let bestSolution = solutions?.best() else {
                completion(nil)
                return
            }
            completion(bestSolution)
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
