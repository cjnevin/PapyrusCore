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

struct Human: Player {
    var rack: [Character]
    var score: Int
    var solves: [Solution]
    var consecutiveSkips: Int
}

struct Computer: Player {
    let difficulty: Difficulty
    var rack: [Character]
    var score: Int
    var solves: [Solution]
    var consecutiveSkips: Int
}