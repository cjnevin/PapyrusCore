//
//  Player.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public enum Difficulty: Double {
    case VeryEasy = 0.25
    case Easy = 0.5
    case Medium = 0.75
    case Hard = 1.0
}

public typealias RackTile = (letter: Character, isBlank: Bool)

public protocol Player {
    var rack: [RackTile] { get set }
    var score: Int { get set }
    var solves: [Solution] { get set }
    var consecutiveSkips: Int { get set }
    mutating func drew(tiles: [Character])
    mutating func played(solution: Solution, tiles: [Character])
    mutating func swapped(tiles: [Character], newTiles: [Character])
    mutating func shuffle()
}

public extension Player {
    mutating func removeLetter(letter: Character) -> (removed: Bool, wasBlank: Bool) {
        for n in 0..<rack.count where rack[n].0 == letter {
            let isBlank = rack[n].isBlank
            rack.removeAtIndex(n)
            return (true, isBlank)
        }
        // Tile must be a blank? Lets check...
        if rack.map({$0.0}).contains(Game.blankLetter) {
            return removeLetter(Game.blankLetter)
        }
        return (false, false)
    }
    
    mutating func shuffle() {
        rack.shuffle()
    }
    
    mutating func played(solution: Solution, tiles: [Character]) {
        score += solution.score
        solves.append(solution)
        tiles.forEach({ assert(removeLetter($0).removed) })
        consecutiveSkips = 0
    }
    
    mutating func swapped(tiles: [Character], newTiles: [Character]) {
        tiles.forEach({ assert(removeLetter($0).removed) })
        drew(newTiles)
        consecutiveSkips = 0
    }
    
    mutating func drew(tiles: [Character]) {
        for tile in tiles {
            rack.append((tile, tile == Game.blankLetter))
        }
    }
    
    mutating func updateBlank(newValue: Character) {
        for n in 0..<rack.count where rack[n].letter == Game.blankLetter && rack[n].isBlank == true {
            rack[n] = (newValue, true)
            break
        }
    }
}

public struct Human: Player {
    public var rack: [RackTile] = []
    public var score: Int
    public var solves: [Solution]
    public var consecutiveSkips: Int
    public init(rack: [Character] = [], score: Int = 0, solves: [Solution] = [], consecutiveSkips: Int = 0) {
        self.score = score
        self.solves = solves
        self.consecutiveSkips = consecutiveSkips
        self.drew(rack)
    }
    public init(rackTiles: [RackTile]) {
        self.score = 0
        self.solves = []
        self.consecutiveSkips = 0
        self.rack = rackTiles
    }
}

public struct Computer: Player {
    public let difficulty: Difficulty
    public var rack: [RackTile] = []
    public var score: Int
    public var solves: [Solution]
    public var consecutiveSkips: Int
    public init(difficulty: Difficulty = .Hard, rack: [Character] = [], score: Int = 0, solves: [Solution] = [], consecutiveSkips: Int = 0) {
        self.difficulty = difficulty
        self.score = score
        self.solves = solves
        self.consecutiveSkips = consecutiveSkips
        self.drew(rack)
    }
}