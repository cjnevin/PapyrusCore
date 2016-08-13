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

public protocol PositionType: Equatable, Hashable {
    var x: Int { get }
    var y: Int { get }
    init(x: Int, y: Int)
    var hashValue: Int { get }
}

extension PositionType {
    public var hashValue: Int {
        return "\(x),\(y)".hash
    }
}

internal enum Direction {
    case vertical
    case horizontal
    case both       // will be true if only 1 element
    case none
    case scattered
}

internal extension Array where Element: PositionType {
    mutating func sortByX() {
        self = sortedByX()
    }
    
    mutating func sortByY() {
        self = sortedByY()
    }
    
    func sortedByX() -> [Element] {
        return sorted(by: { $0.x < $1.x })
    }
    
    func sortedByY() -> [Element] {
        return sorted(by: { $0.y < $1.y })
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
    public static let zero = Position(x: 0, y: 0)
    public let x: Int
    public let y: Int
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init?(json: JSON) {
        guard let x: Int = JSONKey.x.in(json), let y: Int = JSONKey.y.in(json) else {
            return nil
        }
        self.x = x
        self.y = y
    }
    
    var bottom: Position {
        return moveY(amount: 1)
    }
    var right: Position {
        return moveX(amount: 1)
    }
    var top: Position {
        return moveY(amount: -1)
    }
    var left: Position {
        return moveX(amount: -1)
    }
    
    func moveX(amount: Int) -> Position {
        return Position(x: x + amount, y: y)
    }
    
    func moveY(amount: Int) -> Position {
        return Position(x: x, y: y + amount)
    }
    
    func move(amount: Int, horizontal: Bool) -> Position {
        return horizontal ? moveX(amount: amount) : moveY(amount: amount)
    }
    
    func previous(horizontal: Bool) -> Position {
        return horizontal ? moveX(amount: -1) : moveY(amount: -1)
    }
    
    func next(horizontal: Bool) -> Position {
        return horizontal ? moveX(amount: 1) : moveY(amount: 1)
    }
    
    mutating func previousInPlace(horizontal: Bool) {
        self = previous(horizontal: horizontal)
    }
    
    mutating func nextInPlace(horizontal: Bool) {
        self = next(horizontal: horizontal)
    }
    
    func axesFallBelow(maximum: Int) -> Bool {
        return x < maximum && y < maximum
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
    
    public var position: Position {
        return Position(x: x, y: y)
    }
}
