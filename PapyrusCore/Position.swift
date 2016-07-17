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
