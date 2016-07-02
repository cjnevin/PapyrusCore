//
//  Game.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import Lookup

public enum GameEvent {
    case Over(Player?)
    case Move(Solution)
    case DrewTiles([Character])
    case SwappedTiles
    case TurnStarted
    case TurnEnded
}

public enum GameType: Int {
    case Scrabble = 0
    case SuperScrabble
    case Wordfeud
    case WordsWithFriends
}

let aiCanPlayBlanks = false

public typealias EventHandler = (GameEvent) -> ()
public class Game {
    public static let blankLetter = Character("_")
    public static let rackAmount = 7
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
        players.forEach({ $0.solves.forEach({ solver.play($0) }) })
        self.solver = solver
        self.bag = bag
        self.serial = serial
        self.players = players
        self.playerIndex = playerIndex
        self.eventHandler = eventHandler
    }
    
    public convenience init(gameType: GameType = .Scrabble, dictionary: Lookup, players: [Player], serial: Bool = false, eventHandler: EventHandler) {
        var board: Board!
        var bag: Bag!
        switch gameType {
        case .Scrabble:
            board = ScrabbleBoard()
            bag = ScrabbleBag()
        case .SuperScrabble:
            board = SuperScrabbleBoard()
            bag = SuperScrabbleBag()
        case .Wordfeud:
            board = WordfeudBoard()
            bag = WordfeudBag()
        case .WordsWithFriends:
            board = WordsWithFriendsBoard()
            bag = WordsWithFriendsBag()
        }
        self.init(bag: bag, board: board, dictionary: dictionary, players: players, playerIndex: 0, serial: serial, eventHandler: eventHandler)
        for _ in players {
            replenishRack()
            playerIndex += 1
        }
        playerIndex = 0
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
        guard player.consecutiveSkips < maximumConsecutiveSkips else {
            gameOver()
            return
        }
        nextTurn()
    }
    
    private func gameOver() {
        var newPlayers = players
        for i in 0..<newPlayers.count {
            newPlayers[i].score -= newPlayers[i].rack
                .filter({ !$0.isBlank })
                .reduce(0){ $0.0 + (bag.dynamicType.letterPoints[$0.1.letter] ?? 0) }
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
                guard let solutions = solutions, solution = self.solver.solve(solutions, difficulty: ai.difficulty) else {
                    // Can't find any solutions, attempt to swap tiles
                    let tiles = Array(ai.rack[0..<min(self.bag.remaining.count, ai.rack.count)])
                    guard self.swapTiles(tiles.map({ $0.letter })) else {
                        // We're stuck with these tiles, nothing AI can do, lets skip
                        self.skip()
                        return
                    }
                    return
                }
                // Play solution
                print(ai.rack)
                self.play(solution)
                print(self.solver.board)
                self.nextTurn()
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
        let amount = min(Game.rackAmount - player.rack.count, bag.remaining.count)
        let newTiles = (0..<amount).flatMap { _ in bag.draw() }
        players[playerIndex].drew(newTiles)
        eventHandler(.DrewTiles(newTiles))
    }
    
    public var canSwap: Bool {
        return bag.remaining.count > Game.rackAmount
    }
    
    public func swapTiles(oldTiles: [Character]) -> Bool {
        guard canSwap else { return false }
        
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