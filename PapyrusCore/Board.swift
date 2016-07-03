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
    var blanks: [(x: Int, y: Int)] { get set }
    var isFirstPlay: Bool { get }
    var letterMultipliers: [[Int]] { get }
    var wordMultipliers: [[Int]] { get }
    
    subscript(x: Int, y: Int) -> Character? { get }
    func letter(atX x: Int, y: Int) -> Character?
    func isEmpty(atX x: Int, y: Int) -> Bool
    func isFilled(atX x: Int, y: Int) -> Bool
    func isCenter(atX x: Int, y: Int) -> Bool
    func isValid(atX x: Int, y: Int, length: Int, horizontal: Bool) -> Bool
    
    mutating func play(solution: Solution) -> [Character]
}

extension Board {
    public var isFirstPlay: Bool {
        return isEmpty(atX: center, y: center)
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
    
    public func isEmpty(atX x: Int, y: Int) -> Bool {
        return layout[y][x] == empty
    }
    
    public func isFilled(atX x: Int, y: Int) -> Bool {
        return layout[y][x] != empty
    }
    
    public func isCenter(atX x: Int, y: Int) -> Bool {
        return x == center && y == center
    }
    
    public func isValid(atX x: Int, y: Int, length: Int, horizontal: Bool) -> Bool {
        if isFilled(atX: x, y: y) {
            return false
        }
        
        // Too long?
        var currentX = x
        var currentY = y
        if isBoundaryExceeded(atX: &currentX, y: &currentY, length: length, horizontal: horizontal) {
            return false
        }
        
        if isCenter(atX: x, y: y) && isFirstPlay {
            return true
        }
        
        // Horizontal?
        if horizontal {
            // Touches on left or right (cannot accept prefixed or suffixed spots)
            if touchesHorizontally(atX: x, y: y, length: length, edges: .LeftAndRight) {
                return false
            }
            // Touches on top or bottom (allowed)
            if touchesHorizontally(atX: x, y: y, length: length, edges: .TopAndBottom) {
                return true
            }
            // Intersects other letters?
            return currentX > x + length
        } else {
            // Touches on bottom or top (cannot accept prefixed or suffixed spots)
            if touchesVertically(atX: x, y: y, length: length, edges: .TopAndBottom) {
                return false
            }
            // Touches on left or right (allowed)
            if touchesVertically(atX: x, y: y, length: length, edges: .LeftAndRight) {
                return true
            }
            // Intersects other letters?
            return currentY > y + length
        }
    }
    
    func touchesVertically(atX x: Int, y: Int, length: Int, edges: Edge) -> Bool {
        if y + length > size {
            return false
        }
        
        if edges.contains(.Top) && y > 0 && isFilled(atX: x, y: y - 1) {
            return true
        }
        else if edges.contains(.Bottom) && y + length < size && isFilled(atX: x, y: y + length) {
            return true
        }
        
        let (left, right) = (edges.contains(.Left), edges.contains(.Right))
        if left || right {
            for i in y..<(y + length) {
                if left && x > 0 && isFilled(atX: x - 1, y: i) {
                    return true
                }
                if right && x < (size - 1) && isFilled(atX: x + 1, y: i) {
                    return true
                }
            }
        }
        return false
    }
    
    func touchesHorizontally(atX x: Int, y: Int, length: Int, edges: Edge) -> Bool {
        if x + length > size {
            return false
        }
        
        if edges.contains(.Left) && x > 0 && isFilled(atX: x - 1, y: y) {
            return true
        }
        else if edges.contains(.Right) && x + length < size && isFilled(atX: x + length, y: y) {
            return true
        }
        
        let (top, bottom) = (edges.contains(.Top), edges.contains(.Bottom))
        if top || bottom {
            for i in x..<(x + length) {
                if top && y > 0 && isFilled(atX: i, y: y - 1) {
                    return true
                }
                else if bottom && y < (size - 1) && isFilled(atX: i, y: y + 1) {
                    return true
                }
            }
        }
        return false
    }
    
    func isBoundaryExceeded(atX x: inout Int, y: inout Int, length: Int, horizontal: Bool) -> Bool {
        var currentLength = length
        
        while currentLength > 0 && (horizontal && x < size || !horizontal && y < size)  {
            if isEmpty(atX: x, y: y) {
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
        var dropped = [Character]()
        for (i, letter) in solution.word.characters.enumerated() {
            if solution.horizontal {
                if isEmpty(atX: solution.x + i, y: solution.y) {
                    layout[solution.y][solution.x + i] = letter
                    dropped.append(letter)
                }
            } else {
                if isEmpty(atX: solution.x, y: solution.y + i) {
                    layout[solution.y + i][solution.x] = letter
                    dropped.append(letter)
                }
            }
        }
        blanks.append(contentsOf: solution.blanks)
        return dropped
    }
}
