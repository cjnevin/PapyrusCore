//
//  WordType.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 10/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

private func matches<T: WordType>(_ lhs: T, _ rhs: T) -> Bool {
    return (lhs.horizontal == rhs.horizontal &&
        lhs.word == rhs.word &&
        lhs.x == rhs.x &&
        lhs.y == rhs.y)
}

public func == (lhs: Word, rhs: Word) -> Bool {
    return matches(lhs, rhs)
}

public func == (lhs: Solution, rhs: Solution) -> Bool {
    return (matches(lhs, rhs) && lhs.score == rhs.score &&
        lhs.intersections == rhs.intersections &&
        lhs.blanks.map({ $0.x }) == rhs.blanks.map({ $0.x }) &&
        lhs.blanks.map({ $0.y }) == rhs.blanks.map({ $0.y }))
}

protocol WordType {
    var word: String { get }
    var x: Int { get }
    var y: Int { get }
    var horizontal: Bool { get }
    
    func length() -> Int
    func toPositions() -> [Position]
    func position(forIndex index: Int) -> Position
}

extension WordType {
    /// - returns: Offsets in word that are blank using a players rack tiles.
    func blankPositions(using rackTiles: [RackTile]) -> Positions {
        var tempPlayer = Human(rackTiles: rackTiles)
        return word.characters.enumerated().flatMap({ (index, letter) in
            tempPlayer.remove(letter: letter).wasBlank ? position(forIndex: index) : nil
        })
    }
    
    func length() -> Int {
        return word.characters.count
    }
    
    func toLetterPositions() -> [LetterPosition] {
        return word.characters.enumerated().flatMap { (offset, element) in
            let pos = position(forIndex: offset)
            return LetterPosition(x: pos.x, y: pos.y, letter: element)
        }
    }
    
    func toPositions() -> [Position] {
        return (0..<word.characters.count).flatMap{ position(forIndex: $0) }
    }
    
    func position(forIndex index: Int) -> Position {
        return Position(x: x + (horizontal ? index : 0),
                        y: y + (horizontal ? 0 : index))
    }
}

public struct Word: WordType, Equatable, JSONSerializable {
    public let word: String
    public let x: Int
    public let y: Int
    public let horizontal: Bool
    
    public func toJSON() -> JSON {
        return json(from: [
            .word: word,
            .x: x,
            .y: y,
            .horizontal: horizontal])
    }
    
    public static func object(from json: JSON) -> Word? {
        guard
            let word: String = JSONKey.word.in(json),
            let x: Int = JSONKey.x.in(json),
            let y: Int = JSONKey.y.in(json),
            let horizontal: Bool = JSONKey.horizontal.in(json) else {
                return nil
        }
        return Word(word: word, x: x, y: y, horizontal: horizontal)
    }
}

protocol SolutionType {
    var score: Int { get }
    var intersections: [Word] { get }
    var blanks: [Position] { get }
}

public struct Solution: WordType, SolutionType, Equatable, JSONSerializable {
    public let word: String
    public let x: Int
    public let y: Int
    public let horizontal: Bool
    public let score: Int
    public let intersections: [Word]
    let blanks: [Position]
    
    init(word: String, x: Int, y: Int, horizontal: Bool, score: Int, intersections: [Word], blanks: [Position]) {
        self.word = word
        self.x = x
        self.y = y
        self.horizontal = horizontal
        self.intersections = intersections
        self.score = score
        self.blanks = blanks
    }
    
    init(word: Word, score: Int, intersections: [Word], blanks: [Position]) {
        self.word = word.word
        self.x = word.x
        self.y = word.y
        self.horizontal = word.horizontal
        self.intersections = intersections
        self.score = score
        self.blanks = blanks
    }
    
    public func getPositions() -> Positions {
        return Array(Set(toPositions()).union(intersections.flatMap({ $0.toPositions() })))
    }
    
    public func toJSON() -> JSON {
        return json(from: [
            .word: word,
            .x: x,
            .y: y,
            .horizontal: horizontal,
            .score: score,
            .intersections: intersections.map({ $0.toJSON() }),
            .blank: blanks.map({ json(from: [.x: $0.x, .y: $0.y]) })])
    }
    
    public static func object(from json: JSON) -> Solution? {
        guard
            let word: String = JSONKey.word.in(json),
            let x: Int = JSONKey.x.in(json),
            let y: Int = JSONKey.y.in(json),
            let horizontal: Bool = JSONKey.horizontal.in(json),
            let score: Int = JSONKey.score.in(json),
            let blanksJson: [JSON] = JSONKey.blank.in(json),
            let intersectionsJson: [JSON] = JSONKey.intersections.in(json) else {
                return nil
        }
        let intersections = intersectionsJson.flatMap({ Word.object(from: $0) })
        let blanks: [Position] = blanksJson.flatMap(Position.init)
        return Solution(word: word, x: x, y: y, horizontal: horizontal, score: score, intersections: intersections, blanks: blanks)
    }
}
