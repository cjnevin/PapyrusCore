//
//  Board.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

func compareBoards<T: Board>(_ lhs: T, _ rhs: T) -> Bool {
    for (left, right) in zip(lhs.layout, rhs.layout) where left != right { return false }
    return true
}

struct Edge: OptionSet {
    let rawValue: Int
    
    static let None = Edge(rawValue: 0)
    static let Left = Edge(rawValue: 1 << 0)
    static let Right = Edge(rawValue: 1 << 1)
    static let Top = Edge(rawValue: 1 << 2)
    static let Bottom = Edge(rawValue: 1 << 3)
    static let LeftAndRight: Edge = [Left, Right]
    static let TopAndBottom: Edge = [Top, Bottom]
}

public protocol Board: CustomDebugStringConvertible {
    var empty: Character { get }
    var center: Int { get }
    var size: Int { get }
    var boardRange: CountableRange<Int> { get }
    var layout: [[Character]] { get set }
    var blanks: Positions { get set }
    var isFirstPlay: Bool { get }
    var letterMultipliers: [[Int]] { get }
    var wordMultipliers: [[Int]] { get }
    
    subscript(x: Int, y: Int) -> Character? { get }
    func letter(atX x: Int, y: Int) -> Character?
    func isEmpty<T: PositionType>(at position: T) -> Bool
    func isFilled<T: PositionType>(at position: T) -> Bool
    func isCenter<T: PositionType>(at position: T) -> Bool
    func isValid(at position: Position, length: Int, horizontal: Bool) -> Bool
    
    mutating func play(solution: Solution) -> [Character]
}

extension Board {
    var centerPosition: Position {
        return Position(x: center, y: center)
    }
    
    public var isFirstPlay: Bool {
        return isEmpty(at: centerPosition)
    }
    
    public var boardRange: CountableRange<Int> {
        return layout.indices
    }
    
    public var debugDescription: String {
        return layout.map { (line) in
            line.map({ String($0 == empty ? "_" : $0) }).joined(separator: ",")
            }.joined(separator: "\n")
    }
    
    public subscript(x: Int, y: Int) -> Character? {
        return letter(atX: x, y: y)
    }
    
    public func letter(atX x: Int, y: Int) -> Character? {
        let value = layout[y][x]
        return value == empty ? nil : value
    }
    
    public func isEmpty<T: PositionType>(at position: T) -> Bool {
        return layout[position.y][position.x] == empty
    }
    
    public func isFilled<T: PositionType>(at position: T) -> Bool {
        return layout[position.y][position.x] != empty
    }
    
    public func isCenter<T: PositionType>(at position: T) -> Bool {
        return position == centerPosition
    }
    
    public func isValid(at position: Position, length: Int, horizontal: Bool) -> Bool {
        guard isEmpty(at: position) else {
            return false
        }
        
        // Too long?
        var currentX = position.x
        var currentY = position.y
        if isBoundaryExceeded(atX: &currentX, y: &currentY, length: length, horizontal: horizontal) {
            return false
        }
        
        if isCenter(at: position) && isFirstPlay {
            return true
        }
        
        // Horizontal?
        if horizontal {
            // Touches on left or right (cannot accept prefixed or suffixed spots)
            if touchesHorizontally(at: position, length: length, edges: .LeftAndRight) {
                return false
            }
            // Touches on top or bottom (allowed)
            if touchesHorizontally(at: position, length: length, edges: .TopAndBottom) {
                return true
            }
            // Intersects other letters?
            return currentX > position.x + length
        } else {
            // Touches on bottom or top (cannot accept prefixed or suffixed spots)
            if touchesVertically(at: position, length: length, edges: .TopAndBottom) {
                return false
            }
            // Touches on left or right (allowed)
            if touchesVertically(at: position, length: length, edges: .LeftAndRight) {
                return true
            }
            // Intersects other letters?
            return currentY > position.y + length
        }
    }
    
    func touchesVertically(at position: Position, length: Int, edges: Edge) -> Bool {
        if position.y + length > size {
            return false
        }
        
        if edges.contains(.Top) && position.y > 0 && isFilled(at: position.top) {
            return true
        }
        else if edges.contains(.Bottom) && position.y + length < size && isFilled(at: position.moveY(amount: length)) {
            return true
        }
        
        let (left, right) = (edges.contains(.Left), edges.contains(.Right))
        guard left || right else {
            return false
        }
        for offset in (0..<length).map({ Position(x: position.x, y: position.y + $0) }) {
            if left && offset.x > 0 && isFilled(at: offset.left) {
                return true
            } else if right && offset.x < (size - 1) && isFilled(at: offset.right) {
                return true
            }
        }
        return false
    }
    
    func touchesHorizontally(at position: Position, length: Int, edges: Edge) -> Bool {
        if position.x + length > size {
            return false
        }
        
        if edges.contains(.Left) && position.x > 0 && isFilled(at: position.left) {
            return true
        }
        else if edges.contains(.Right) && position.x + length < size && isFilled(at: position.moveX(amount: length)) {
            return true
        }
        
        let (top, bottom) = (edges.contains(.Top), edges.contains(.Bottom))
        guard top || bottom else {
            return false
        }
        for offset in (0..<length).map({ Position(x: position.x + $0, y: position.y) }) {
            if top && offset.y > 0 && isFilled(at: offset.top) {
                return true
            } else if bottom && offset.y < (size - 1) && isFilled(at: offset.bottom) {
                return true
            }
        }
        return false
    }
    
    func isBoundaryExceeded(atX x: inout Int, y: inout Int, length: Int, horizontal: Bool) -> Bool {
        var currentLength = length
        
        while currentLength > 0 && (horizontal && x < size || !horizontal && y < size)  {
            if isEmpty(at: Position(x: x, y: y)) {
                currentLength -= 1
            }
            if horizontal {
                x += 1
            } else {
                y += 1
            }
        }
        
        return currentLength != 0
    }
    
    mutating public func play(solution: Solution) -> [Character] {
        blanks.append(contentsOf: solution.blanks)
        return solution.toLetterPositions().flatMap { position -> Character? in
            guard isEmpty(at: position) else {
                return nil
            }
            layout[position.y][position.x] = position.letter
            return position.letter
        }
    }
}
