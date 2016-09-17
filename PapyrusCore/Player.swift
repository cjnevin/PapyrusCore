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

public func == (lhs: RackTile, rhs: RackTile) -> Bool {
    return lhs.id == rhs.id
}

public struct RackTile: Equatable {
    fileprivate let id = UUID().uuidString
    public let letter: Character
    public let isBlank: Bool
    public init(letter: Character, isBlank: Bool) {
        self.letter = letter
        self.isBlank = isBlank
    }
}

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
    /// Move a tile in your rack.
    mutating func moveTile(from index: Int, to newIndex: Int)
}

public extension Player {
    mutating func remove(letter: Character) -> (removed: Bool, wasBlank: Bool) {
        for i in 0..<rack.count where rack[i].letter == letter {
            return (true, rack.remove(at: i).isBlank)
        }
        // Tile must be a blank? Lets check...
        if rack.map({ $0.letter }).contains(Game.blankLetter) {
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
        tiles.forEach({ precondition(remove(letter: $0).removed, "Could not remove tile. Play cannot continue.") })
        consecutiveSkips = 0
    }
    
    mutating func swapped(tiles: [Character], with newTiles: [Character]) {
        tiles.forEach({ precondition(remove(letter: $0).removed, "Could not swap tile. Play cannot continue.") })
        drew(tiles: newTiles)
        consecutiveSkips = 0
    }
    
    mutating func drew(tiles: [Character]) {
        rack += tiles.map({ RackTile(letter: $0, isBlank: $0 == Game.blankLetter) })
    }
    
    mutating func updateBlank(to newValue: Character) {
        for i in 0..<rack.count where rack[i].letter == Game.blankLetter && rack[i].isBlank {
            rack[i] = RackTile(letter: newValue, isBlank: true)
            break
        }
    }
    
    mutating func moveTile(from currentIndex: Int, to newIndex: Int) {
        guard rack.indices.contains(currentIndex) && rack.indices.contains(newIndex) && currentIndex != newIndex else {
            return
        }
        let obj = rack[currentIndex]
        rack.remove(at: currentIndex)
        rack.insert(obj, at: newIndex)
    }
}

private func makePlayers(using values: [JSON], mapping: (JSON) -> Player?) -> [Player] {
    return values.flatMap{ mapping($0) }
}

func makePlayers(using JSONSerializables: [JSON]) -> [Player] {
    return makePlayers(using: JSONSerializables.filter({ $0[JSONKey.difficulty.rawValue] != nil }), mapping: Computer.object) +
        makePlayers(using: JSONSerializables.filter({ $0[JSONKey.difficulty.rawValue] == nil }), mapping: Human.object)
}

private func json<T: Player>(forPlayer player: T) -> JSON {
    let rackJson: [JSON] = player.rack.map({ json(from: [.letter: String($0.letter), .blank: $0.isBlank]) })
    let solvesJson = player.solves.map({ $0.toJSON() })
    return json(from: [.score: player.score, .rack: rackJson, .solves: solvesJson])
}

private func parameters(from json: JSON) -> (rack: [Character], solves: [Solution], score: Int)? {
    guard
        let rackJson: [JSON] = JSONKey.rack.in(json),
        let solvesJson: [JSON] = JSONKey.solves.in(json),
        let score: Int = JSONKey.score.in(json) else {
        return nil
    }
    func letter(from json: JSON) -> Character {
        let blank: Bool = JSONKey.blank.in(json)!
        let char: String = JSONKey.letter.in(json)!
        return blank ? Game.blankLetter : Character(char)
    }
    let solves = solvesJson.flatMap({ Solution.object(from: $0) })
    let rack = rackJson.map(letter)
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
        buffer[JSONKey.difficulty.rawValue] = NSNumber(value: difficulty.rawValue)
        return buffer
    }
    
    public static func object(from json: JSON) -> Computer? {
        guard
            let diff: Double = JSONKey.difficulty.in(json),
            let difficulty = Difficulty(rawValue: diff),
            let (rack, solves, score) = parameters(from: json) else {
            return nil
        }
        return Computer(difficulty: difficulty, rack: rack, score: score, solves: solves, consecutiveSkips: 0)
    }
}
