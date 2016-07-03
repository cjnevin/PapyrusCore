//
//  Player.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public enum Difficulty: Double {
    case veryEasy = 0.25
    case easy = 0.5
    case medium = 0.75
    case hard = 1.0
}

public typealias RackTile = (letter: Character, isBlank: Bool)

public protocol Player {
    /// Unique identifier for player.
    var id: String { get }
    /// Current tiles in rack.
    var rack: [RackTile] { get set }
    /// Current score.
    var score: Int { get set }
    /// Solutions played.
    var solves: [Solution] { get set }
    /// Times skipped in a row.
    var consecutiveSkips: Int { get set }
    /// Add tiles to rack.
    mutating func drew(tiles: [Character])
    /// Add solution to list of `solves`, removing `tiles` from `rack`.
    mutating func played(solution: Solution, tiles: [Character])
    /// Swap out `tiles` in `rack` with `newTiles`.
    mutating func swapped(tiles: [Character], with newTiles: [Character])
    /// Shuffle rack tile order.
    mutating func shuffle()
}

public extension Player {
    mutating func remove(letter: Character) -> (removed: Bool, wasBlank: Bool) {
        for n in 0..<rack.count where rack[n].0 == letter {
            let isBlank = rack[n].isBlank
            rack.remove(at: n)
            return (true, isBlank)
        }
        // Tile must be a blank? Lets check...
        if rack.map({$0.0}).contains(Game.blankLetter) {
            return remove(letter: Game.blankLetter)
        }
        return (false, false)
    }
    
    mutating func shuffle() {
        rack.shuffle()
    }
    
    mutating func played(solution: Solution, tiles: [Character]) {
        score += solution.score
        solves.append(solution)
        tiles.forEach({ assert(remove(letter: $0).removed) })
        consecutiveSkips = 0
    }
    
    mutating func swapped(tiles: [Character], with newTiles: [Character]) {
        tiles.forEach({ assert(remove(letter: $0).removed) })
        drew(tiles: newTiles)
        consecutiveSkips = 0
    }
    
    mutating func drew(tiles: [Character]) {
        for tile in tiles {
            rack.append((tile, tile == Game.blankLetter))
        }
    }
    
    mutating func updateBlank(to newValue: Character) {
        for n in 0..<rack.count where rack[n].letter == Game.blankLetter && rack[n].isBlank == true {
            rack[n] = (newValue, true)
            break
        }
    }
}

public struct Human: Player {
    public let id = UUID().uuidString
    public var rack: [RackTile] = []
    public var score: Int
    public var solves: [Solution]
    public var consecutiveSkips: Int
    public init(rack: [Character] = [], score: Int = 0, solves: [Solution] = [], consecutiveSkips: Int = 0) {
        self.score = score
        self.solves = solves
        self.consecutiveSkips = consecutiveSkips
        self.drew(tiles: rack)
    }
    public init(rackTiles: [RackTile]) {
        self.score = 0
        self.solves = []
        self.consecutiveSkips = 0
        self.rack = rackTiles
    }
}

public struct Computer: Player {
    public let id = UUID().uuidString
    public let difficulty: Difficulty
    public var rack: [RackTile] = []
    public var score: Int
    public var solves: [Solution]
    public var consecutiveSkips: Int
    public init(difficulty: Difficulty = .hard, rack: [Character] = [], score: Int = 0, solves: [Solution] = [], consecutiveSkips: Int = 0) {
        self.difficulty = difficulty
        self.score = score
        self.solves = solves
        self.consecutiveSkips = consecutiveSkips
        self.drew(tiles: rack)
    }
}
