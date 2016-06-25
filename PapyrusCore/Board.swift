//
//  Board.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

func compareBoards<T: Board>(lhs: T, _ rhs: T) -> Bool {
    for (left, right) in zip(lhs.layout, rhs.layout) where left != right { return false }
    return true
}

struct Edge: OptionSetType {
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
    var centers: [(x: Int, y: Int)] { get }
    var size: Int { get }
    var boardRange: Range<Int> { get }
    var layout: [[Character]] { get set }
    var blanks: [(x: Int, y: Int)] { get set }
    var isFirstPlay: Bool { get }
    var letterMultipliers: [[Int]] { get }
    var wordMultipliers: [[Int]] { get }
    
    subscript(x: Int, y: Int) -> Character? { get }
    func letterAt(x: Int, _ y: Int) -> Character?
    func isEmptyAt(x: Int, _ y: Int) -> Bool
    func isFilledAt(x: Int, _ y: Int) -> Bool
    func isCenterAt(x: Int, _ y: Int) -> Bool
    func isValidAt(x: Int, _ y: Int, length: Int, horizontal: Bool) -> Bool
    
    mutating func play(solution: Solution) -> [Character]
}

extension Board {
    public var isFirstPlay: Bool {
        for (x, y) in centers {
            if !isEmptyAt(x, y) {
                return false
            }
        }
        return true
    }
    
    public var boardRange: Range<Int> {
        return layout.indices
    }
    
    public var debugDescription: String {
        return layout.map { (line) in
            line.map({ String($0 == empty ? "_" : $0) }).joinWithSeparator(",")
            }.joinWithSeparator("\n")
    }
    
    public subscript(x: Int, y: Int) -> Character? {
        return letterAt(x, y)
    }
    
    public func letterAt(x: Int, _ y: Int) -> Character? {
        let value = layout[y][x]
        return value == empty ? nil : value
    }
    
    public func isEmptyAt(x: Int, _ y: Int) -> Bool {
        return layout[y][x] == empty
    }
    
    public func isFilledAt(x: Int, _ y: Int) -> Bool {
        return layout[y][x] != empty
    }
    
    public func isCenterAt(x: Int, _ y: Int) -> Bool {
        return centers.contains({ $0.x == x && $0.y == y })
    }
    
    public func isValidAt(x: Int, _ y: Int, length: Int, horizontal: Bool) -> Bool {
        if isFilledAt(x, y) {
            return false
        }
        
        // Too long?
        var currentX = x
        var currentY = y
        if exceedsBoundaryAt(&currentX, &currentY, length: length, horizontal: horizontal) {
            return false
        }
        
        if isCenterAt(x, y) && isFirstPlay {
            return true
        }
        
        // Horizontal?
        if horizontal {
            // Touches on left or right (cannot accept prefixed or suffixed spots)
            if horizontallyTouchesAt(x, y, length: length, edges: .LeftAndRight) {
                return false
            }
            // Touches on top or bottom (allowed)
            if horizontallyTouchesAt(x, y, length: length, edges: .TopAndBottom) {
                return true
            }
            // Intersects other letters?
            return currentX > x + length
        } else {
            // Touches on bottom or top (cannot accept prefixed or suffixed spots)
            if verticallyTouchesAt(x, y, length: length, edges: .TopAndBottom) {
                return false
            }
            // Touches on left or right (allowed)
            if verticallyTouchesAt(x, y, length: length, edges: .LeftAndRight) {
                return true
            }
            // Intersects other letters?
            return currentY > y + length
        }
    }
    
    func verticallyTouchesAt(x: Int, _ y: Int, length: Int, edges: Edge) -> Bool {
        if y + length > size {
            return false
        }
        
        if edges.contains(.Top) && y > 0 && isFilledAt(x, y - 1) {
            return true
        }
        else if edges.contains(.Bottom) && y + length < size && isFilledAt(x, y + length) {
            return true
        }
        
        let (left, right) = (edges.contains(.Left), edges.contains(.Right))
        if left || right {
            for i in y..<(y + length) {
                if left && x > 0 && isFilledAt(x - 1, i) {
                    return true
                }
                if right && x < (size - 1) && isFilledAt(x + 1, i) {
                    return true
                }
            }
        }
        return false
    }
    
    func horizontallyTouchesAt(x: Int, _ y: Int, length: Int, edges: Edge) -> Bool {
        if x + length > size {
            return false
        }
        
        if edges.contains(.Left) && x > 0 && isFilledAt(x - 1, y) {
            return true
        }
        else if edges.contains(.Right) && x + length < size && isFilledAt(x + length, y) {
            return true
        }
        
        let (top, bottom) = (edges.contains(.Top), edges.contains(.Bottom))
        if top || bottom {
            for i in x..<(x + length) {
                if top && y > 0 && isFilledAt(i, y - 1) {
                    return true
                }
                else if bottom && y < (size - 1) && isFilledAt(i, y + 1) {
                    return true
                }
            }
        }
        return false
    }
    
    func exceedsBoundaryAt(inout x: Int, inout _ y: Int, length: Int, horizontal: Bool) -> Bool {
        var currentLength = length
        
        while currentLength > 0 && (horizontal && x < size || !horizontal && y < size)  {
            if isEmptyAt(x, y) {
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
        for (i, letter) in solution.word.characters.enumerate() {
            if solution.horizontal {
                if isEmptyAt(solution.x + i, solution.y) {
                    layout[solution.y][solution.x + i] = letter
                    dropped.append(letter)
                }
            } else {
                if isEmptyAt(solution.x, solution.y + i) {
                    layout[solution.y + i][solution.x] = letter
                    dropped.append(letter)
                }
            }
        }
        blanks.appendContentsOf(solution.blanks)
        return dropped
    }
}
