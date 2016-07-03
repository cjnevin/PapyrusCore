//
//  WordRepresentation.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 10/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

typealias WordPosition = (x: Int, y: Int)

private func matches<T: WordRepresentation>(_ lhs: T, _ rhs: T) -> Bool {
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

protocol WordRepresentation {
    var word: String { get }
    var x: Int { get }
    var y: Int { get }
    var horizontal: Bool { get }
    
    func length() -> Int
    func toPositions() -> [WordPosition]
    func position(forIndex index: Int) -> WordPosition
}

extension WordRepresentation {
    func length() -> Int {
        return word.characters.count
    }
    
    func toPositions() -> [WordPosition] {
        return (0..<word.characters.count).flatMap{ position(forIndex: $0) }
    }
    
    func position(forIndex index: Int) -> WordPosition {
        return (x + (horizontal ? index : 0),
                y + (horizontal ? 0 : index))
    }
}

public struct Word: WordRepresentation, Equatable, JSONSerializable {
    let word: String
    let x: Int
    let y: Int
    let horizontal: Bool
    
    public func toJSON() -> JSON {
        return ["word": word, "x": x, "y": y, "horizontal": horizontal]
    }
    
    public static func object(from json: JSON) -> Word? {
        guard let
            word = json["word"] as? String,
            x = json["x"] as? Int,
            y = json["y"] as? Int,
            horizontal = json["horizontal"] as? Bool else {
            return nil
        }
        return Word(word: word, x: x, y: y, horizontal: horizontal)
    }
}

public struct Solution: WordRepresentation, Equatable, JSONSerializable {
    public let word: String
    public let x: Int
    public let y: Int
    public let horizontal: Bool
    public let score: Int
    let intersections: [Word]
    let blanks: [WordPosition]
    
    init(word: String, x: Int, y: Int, horizontal: Bool, score: Int, intersections: [Word], blanks: [WordPosition]) {
        self.word = word
        self.x = x
        self.y = y
        self.horizontal = horizontal
        
        self.intersections = intersections
        self.score = score
        self.blanks = blanks
    }
    
    init(word: Word, score: Int, intersections: [Word], blanks: [WordPosition]) {
        self.word = word.word
        self.x = word.x
        self.y = word.y
        self.horizontal = word.horizontal
        
        self.intersections = intersections
        self.score = score
        self.blanks = blanks
    }
    
    public func getPositions() -> [(x: Int, y: Int)] {
        var points = toPositions()
        intersections.map({ $0.toPositions() }).forEach({ intersectedPoints in
            intersectedPoints.forEach({ intersectedPoint in
                if !points.contains({ $0.x == intersectedPoint.x && $0.y == intersectedPoint.y }) {
                    points.append(intersectedPoint)
                }
            })
        })
        return points
    }
    
    public func toJSON() -> JSON {
        return ["word": word, "x": x, "y": y,
                "horizontal": horizontal,
                "score": score,
                "blanks": blanks.map({ ["x": $0.x, "y": $0.y] }),
                "intersections": intersections.map({ $0.toJSON() })]
    }
    
    public static func object(from json: JSON) -> Solution? {
        guard let
            word = json["word"] as? String,
            x = json["x"] as? Int,
            y = json["y"] as? Int,
            horizontal = json["horizontal"] as? Bool,
            score = json["score"] as? Int,
            blanksJson = json["blanks"] as? [JSON],
            intersectionsJson = json["intersections"] as? [JSON] else {
                return nil
        }
        let intersections = intersectionsJson.flatMap({ Word.object(from: $0) })
        let blanks: [WordPosition] = blanksJson.map({ ($0["x"] as! Int, $0["y"] as! Int) })
        return Solution(word: word, x: x, y: y, horizontal: horizontal, score: score, intersections: intersections, blanks: blanks)
    }
}
