//
//  Position.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 17/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public typealias Positions = [Position]
public typealias LetterPositions = [LetterPosition]

public func ==<L: PositionType, R: PositionType>(lhs: L, rhs: R) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

public func ==(lhs: LetterPosition, rhs: LetterPosition) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.letter == rhs.letter
}

public protocol PositionType: Equatable {
    var x: Int { get }
    var y: Int { get }
    init(x: Int, y: Int)
}

enum Direction {
    case vertical
    case horizontal
    case both       // will be true if only 1 element
    case none
    case scattered
}

extension Array where Element: PositionType {
    mutating func sortByX() {
        self = sortedByX()
    }
    
    mutating func sortByY() {
        self = sortedByY()
    }
    
    func sortedByX() -> [Element] {
        return self.sorted(isOrderedBefore: { $0.x < $1.x })
    }
    
    func sortedByY() -> [Element] {
        return self.sorted(isOrderedBefore: { $0.y < $1.y })
    }
    
    var direction: Direction {
        if count == 1 { return .both }
        if count < 1 { return .none }
        if hasIdenticalXValues {
            return .vertical
        } else if hasIdenticalYValues {
            return .horizontal
        }
        return .scattered
    }
    
    var hasIdenticalXValues: Bool {
        let sorted = sortedByX()
        return sorted.count > 0 && sorted.first?.x == sorted.last?.x
    }
    
    var hasIdenticalYValues: Bool {
        let sorted = sortedByY()
        return sorted.count > 0 && sorted.first?.y == sorted.last?.y
    }
}

public struct Position: PositionType {
    public let x: Int
    public let y: Int
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init?(json: JSON) {
        guard let x: Int = JSONKey.x.in(json), y: Int = JSONKey.y.in(json) else {
            return nil
        }
        self.x = x
        self.y = y
    }
    
    var bottom: Position {
        return Position(x: x, y: y + 1)
    }
    var top: Position {
        return Position(x: x, y: y - 1)
    }
    var left: Position {
        return Position(x: x - 1, y: y)
    }
    var right: Position {
        return Position(x: x + 1, y: y)
    }
}

public struct LetterPosition: PositionType {
    public let x: Int
    public let y: Int
    public let letter: Character
    
    public init(x: Int, y: Int) {
        fatalError()
    }
    
    public init(x: Int, y: Int, letter: Character) {
        self.x = x
        self.y = y
        self.letter = letter
    }
}
