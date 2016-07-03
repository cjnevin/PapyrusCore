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

public protocol Player: JSONSerializable {
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

private func makePlayers(using values: [JSON], f: (from: JSON) -> Player?) -> [Player] {
    return values.flatMap({ f(from: $0) })
}

func makePlayers(using JSONSerializables: [JSON]) -> [Player] {
    return makePlayers(using: JSONSerializables.filter({ $0["difficulty"] != nil }), f: Computer.object) +
        makePlayers(using: JSONSerializables.filter({ $0["difficulty"] == nil }), f: Human.object)
}

private func json<T: Player>(forPlayer player: T) -> JSON {
    let rackJson: [JSON] = player.rack.map({ ["letter": String($0.letter), "blank": $0.isBlank] })
    let solvesJson = player.solves.map({ $0.toJSON() })
    return ["score": player.score, "rack": rackJson, "solves": solvesJson]
}

private func parameters(from json: JSON) -> (rack: [Character], solves: [Solution], score: Int)? {
    guard let
        rackJson = json["rack"] as? [JSON],
        solvesJson = json["solves"] as? [JSON],
        score = json["score"] as? Int else {
        return nil
    }
    let solves = solvesJson.flatMap({ Solution.object(from: $0) })
    let rack = rackJson.map({ $0["blank"] as! Bool ? Game.blankLetter : Character($0["letter"] as! String) })
    return (rack, solves, score)
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
    
    public func toJSON() -> JSON {
        return json(forPlayer: self)
    }
    
    public static func object(from json: JSON) -> Human? {
        guard let (rack, solves, score) = parameters(from: json) else {
            return nil
        }
        return Human(rack: rack, score: score, solves: solves, consecutiveSkips: 0)
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
    
    public func toJSON() -> JSON {
        var buffer = json(forPlayer: self)
        buffer["difficulty"] = difficulty.rawValue
        return buffer
    }
    
    public static func object(from json: JSON) -> Computer? {
        guard let diff = json["difficulty"] as? Double, difficulty = Difficulty(rawValue: diff), (rack, solves, score) = parameters(from: json) else {
            return nil
        }
        return Computer(difficulty: difficulty, rack: rack, score: score, solves: solves, consecutiveSkips: 0)
    }
}
