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

public protocol Player {
    var rack: [Character] { get set }
    var score: Int { get set }
    var solves: [Solution] { get set }
    var consecutiveSkips: Int { get set }
    mutating func drew(tiles: [Character])
    mutating func played(solution: Solution, tiles: [Character])
    mutating func swapped(tiles: [Character], newTiles: [Character])
}

public extension Player {
    mutating func removeLetter(letter: Character) -> Bool {
        for n in 0..<rack.count where rack[n] == letter {
            rack.removeAtIndex(n)
            return true
        }
        // Not the best way of handling this, but it'll have to do for now.
        // Should refactor in solver
        if rack.contains("?") {
            return removeLetter("?")
        }
        return false
    }
    
    mutating func played(solution: Solution, tiles: [Character]) {
        score += solution.score
        solves.append(solution)
        tiles.forEach({ assert(removeLetter($0)) })
        consecutiveSkips = 0
    }
    
    mutating func swapped(tiles: [Character], newTiles: [Character]) {
        tiles.forEach({ assert(removeLetter($0)) })
        drew(newTiles)
        consecutiveSkips = 0
    }
    
    mutating func drew(tiles: [Character]) {
        rack += tiles
    }
}

public struct Human: Player {
    public var rack: [Character]
    public var score: Int
    public var solves: [Solution]
    public var consecutiveSkips: Int
    public init(rack: [Character], score: Int = 0, solves: [Solution] = [], consecutiveSkips: Int = 0) {
        self.rack = rack
        self.score = score
        self.solves = solves
        self.consecutiveSkips = consecutiveSkips
    }
}

public struct Computer: Player {
    public let difficulty: Difficulty
    public var rack: [Character]
    public var score: Int
    public var solves: [Solution]
    public var consecutiveSkips: Int
    public init(difficulty: Difficulty, rack: [Character], score: Int = 0, solves: [Solution] = [], consecutiveSkips: Int = 0) {
        self.difficulty = difficulty
        self.rack = rack
        self.score = score
        self.solves = solves
        self.consecutiveSkips = consecutiveSkips
    }
}