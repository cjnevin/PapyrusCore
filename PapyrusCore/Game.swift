//
//  Game.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public enum GameEvent {
    case Over(Player?)
    case Move(Solution)
    case DrewTiles([Character])
    case SwappedTiles
    case TurnStarted
    case TurnEnded
}

public enum GameType {
    case Scrabble
    case SuperScrabble
}


let aiCanPlayBlanks = false

public typealias EventHandler = (GameEvent) -> ()
public class Game {
    public static let blankLetter = Character(" ")
    var solver: Solver
    var serial: Bool = false
    public var bag: Bag
    public private(set) var players: [Player]
    var playerIndex: Int
    public var player: Player { return players[playerIndex] }
    private var eventHandler: EventHandler
    public var board: Board {
        return solver.board
    }
    private let maximumConsecutiveSkips = 3
    
    init(bag: Bag,
         board: Board,
         lookup: Lookup,
         players: [Player],
         playerIndex: Int,
         serial: Bool = false,
         eventHandler: EventHandler) {
        var solver = Solver(bagType: bag.dynamicType, board: board, lookup: lookup)
        for player in players {
            for solution in player.solves {
                solver.play(solution)
            }
        }
        self.solver = solver
        self.bag = bag
        self.serial = serial
        self.players = players
        self.playerIndex = playerIndex
        self.eventHandler = eventHandler
    }
    
    public static func newGame(gameType: GameType = .Scrabble, lookup: Lookup, players: [Player], serial: Bool = false, eventHandler: EventHandler) -> Game {
        let board: Board = gameType == .Scrabble ? ScrabbleBoard() : SuperScrabbleBoard()
        let bag: Bag = gameType == .Scrabble ? ScrabbleBag() : SuperScrabbleBag()
        let game = Game(bag: bag, board: board, lookup: lookup, players: players, playerIndex: 0, serial: serial, eventHandler: eventHandler)
        for _ in players {
            game.replenishRack()
            game.playerIndex += 1
        }
        game.playerIndex = 0
        return game
    }
    
    public static func restoreGame(board: Board, bag: Bag, lookup: Lookup, players: [Player], playerIndex: Int, eventHandler: EventHandler) -> Game? {
        return Game(bag: bag, board: board, lookup: lookup, players: players, playerIndex: playerIndex, eventHandler: eventHandler)
    }
    
    public func shuffleRack() {
        if player is Human {
            players[playerIndex].shuffle()
        }
    }
    
    public func start() {
        turn()
    }
    
    public func skip() {
        print("Skipped")
        players[playerIndex].consecutiveSkips += 1
        if player.consecutiveSkips >= maximumConsecutiveSkips {
            gameOver()
            return
        }
        nextTurn()
    }
    
    private func gameOver() {
        var newPlayers = players
        for i in 0..<newPlayers.count {
            for tile in newPlayers[i].rack {
                if tile.1 == false {
                    newPlayers[i].score -= bag.dynamicType.letterPoints[tile.0] ?? 0
                }
            }
            newPlayers[i].rack = []
        }
        players = newPlayers
        
        // Does not currently handle ties
        let winner = players.sort({ $0.score > $1.score }).first
        eventHandler(.Over(winner))
    }
    
    private func turn() {
        if player.rack.count == 0 {
            gameOver()
            return
        }
        eventHandler(.TurnStarted)
        if player is Computer {
            var ai = player as! Computer
            let vowels = bag.dynamicType.vowels
            let blank = Game.blankLetter
            while aiCanPlayBlanks == false && ai.rack.filter({$0.0 == blank}).count > 0 {
                if Set(ai.rack.map({$0.0})).intersect(vowels).count == 0 {
                    // If we have no vowels lets pick a random vowel
                    ai.updateBlank(vowels[Int(rand()) % vowels.count])
                    print("AI set value of blank letter")
                } else {
                    // We have vowels, lets choose 's'
                    ai.updateBlank("s")
                    print("AI set value of blank letter")
                }
            }
            solver.solutions(ai.rack, completion: { solutions in
                if let solutions = solutions, solution = self.solver.solve(solutions, difficulty: ai.difficulty) {
                    print(ai.rack)
                    self.play(solution)
                    print(self.solver.board)
                    self.nextTurn()
                } else {
                    let tiles = Array(ai.rack[0..<min(self.bag.remaining.count, ai.rack.count)])
                    if !self.swapTiles(tiles.map({ $0.letter })) {
                        // We're stuck with these tiles, nothing AI can do, lets skip
                        self.skip()
                    }
                }
            })
        }
    }
    
    public func nextTurn() {
        eventHandler(.TurnEnded)
        if player.rack.count == 0 {
            gameOver()
            return
        }
        playerIndex = (playerIndex + 1) % players.count
        print("Next Turn")
        turn()
    }
    
    public func play(solution: Solution) {
        let dropped = solver.play(solution)
        assert(dropped.count > 0)
        players[playerIndex].played(solution, tiles: dropped)
        replenishRack()
        eventHandler(.Move(solution))
    }
    
    public func replenishRack() {
        let amount = min(rackAmount - player.rack.count, bag.remaining.count)
        let newTiles = (0..<amount).flatMap { _ in bag.draw() }
        players[playerIndex].drew(newTiles)
        eventHandler(.DrewTiles(newTiles))
    }
    
    public let rackAmount = 7
    public var canSwap: Bool { return bag.remaining.count > rackAmount }
    
    public func swapTiles(oldTiles: [Character]) -> Bool {
        if !canSwap { return false }
        
        oldTiles.forEach { bag.replace($0) }
        let newTiles = oldTiles.flatMap { _ in bag.draw() }
        players[playerIndex].swapped(oldTiles, newTiles: newTiles)
        
        print("Swapped \(oldTiles) for \(newTiles)")
        eventHandler(.SwappedTiles)
        
        // Swap complete, next players turn
        nextTurn()
        return true
    }
    
    public func validate(points: [(x: Int, y: Int, letter: Character)], blanks: [(x: Int, y: Int)]) -> ValidationResponse {
        return solver.validate(points, blanks: blanks)
    }
    
    public func getHint(completion: (Solution?) -> ()) {
        solver.solutions(player.rack, serial: false) { [weak self] solutions in
            guard let solutions = solutions, best = self?.solver.solve(solutions, difficulty: .Hard) else {
                completion(nil)
                return
            }
            completion(best)
        }
    }
}