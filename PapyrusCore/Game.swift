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

let aiCanPlayBlanks = false

public typealias EventHandler = (GameEvent) -> ()
public struct Game {
    var solver: Solver
    public var bag: Bag
    var players: [Player]
    var playerIndex: Int
    public var player: Player { return players[playerIndex] }
    private var eventHandler: EventHandler
    public var board: Board {
        return solver.board
    }
    private let maximumConsecutiveSkips = 3
    
    public static func newGame(dictionary: Dawg, bag: Bag, players: [Player], eventHandler: EventHandler) -> Game {
        let solver = Solver(dictionary: dictionary)
        var game = Game(solver: solver, bag: bag, players: players, playerIndex: 0, eventHandler: eventHandler)
        for _ in players {
            game.replenishRack()
            game.playerIndex += 1
        }
        game.playerIndex = 0
        return game
    }
    
    public static func restoreGame(dictionary: Dawg, bag: Bag, players: [Player], playerIndex: Int, eventHandler: EventHandler) -> Game {
        var solver = Solver(dictionary: dictionary)
        for player in players {
            for solution in player.solves {
                solver.play(solution)
            }
        }
        return Game(solver: solver, bag: bag, players: players, playerIndex: playerIndex, eventHandler: eventHandler)
    }
    
    public mutating func shuffleRack() {
        if player is Human {
            players[playerIndex].shuffle()
        }
    }
    
    public mutating func start() {
        turn()
    }
    
    public mutating func skip() {
        players[playerIndex].consecutiveSkips += 1
        if player.consecutiveSkips >= maximumConsecutiveSkips {
            gameOver()
            return
        }
        nextTurn()
    }
    
    private mutating func gameOver() {
        var newPlayers = players
        for i in 0..<newPlayers.count {
            for tile in newPlayers[i].rack {
                if tile.1 == false {
                    newPlayers[i].score -= Bag.letterPoints[tile.0] ?? 0
                }
            }
            newPlayers[i].rack = []
        }
        players = newPlayers
        
        // Does not currently handle ties
        let winner = players.sort({ $0.score > $1.score }).first
        eventHandler(.Over(winner))
    }
    
    private mutating func turn() {
        if player.rack.count == 0 {
            gameOver()
            return
        }
        eventHandler(.TurnStarted)
        if player is Computer {
            var ai = player as! Computer
            while aiCanPlayBlanks == false && ai.rack.filter({$0.0 == Bag.blankLetter}).count > 0 {
                if Set(ai.rack.map({$0.0})).intersect(Bag.vowels).count == 0 {
                    // If we have no vowels lets pick a random vowel
                    ai.updateBlank(Bag.vowels[Int(rand()) % Bag.vowels.count])
                    print("AI set value of blank letter")
                } else {
                    // We have vowels, lets choose 's'
                    ai.updateBlank("s")
                    print("AI set value of blank letter")
                }
            }
            if let solution = solver.solve(ai.rack, difficulty: ai.difficulty) {
                print(ai.rack)
                play(solution)
                print(solver.board)
                nextTurn()
            } else {
                let tiles = Array(ai.rack[0..<min(bag.remaining.count, ai.rack.count)])
                if !swapTiles(tiles.map({ $0.letter })) {
                    // We're stuck with these tiles, nothing AI can do, lets skip
                    skip()
                }
            }
        }
    }
    
    public mutating func nextTurn() {
        eventHandler(.TurnEnded)
        if player.rack.count == 0 {
            gameOver()
            return
        }
        playerIndex = (playerIndex + 1) % players.count
        turn()
    }
    
    public mutating func play(solution: Solution) {
        let dropped = solver.play(solution)
        assert(dropped.count > 0)
        players[playerIndex].played(solution, tiles: dropped)
        replenishRack()
        eventHandler(.Move(solution))
    }
    
    public mutating func replenishRack() {
        let amount = min(rackAmount - player.rack.count, bag.remaining.count)
        let newTiles = (0..<amount).flatMap { _ in bag.draw() }
        players[playerIndex].drew(newTiles)
        eventHandler(.DrewTiles(newTiles))
    }
    
    public let rackAmount = 7
    public var canSwap: Bool { return bag.remaining.count > rackAmount }
    
    public mutating func swapTiles(oldTiles: [Character]) -> Bool {
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
}