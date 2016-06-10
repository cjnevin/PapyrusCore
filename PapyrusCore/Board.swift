//
//  Board.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public func == (lhs: Board, rhs: Board) -> Bool {
    for (left, right) in zip(lhs.board, rhs.board) where left != right { return false }
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

public struct Board: Equatable, CustomDebugStringConvertible {
    public let config: BoardConfig
    public internal(set) var board: [[Character]]
    public internal(set) var playedBlanks = [(x: Int, y: Int)]()
    
    subscript(x: Int, y: Int) -> Character? {
        return letterAt(x, y)
    }
    
    public init(config: BoardConfig) {
        self.config = config
        board = config.board
    }
    
    public var isFirstPlay: Bool {
        return isEmptyAt(config.center, config.center)
    }
    
    public var debugDescription: String {
        func str(arr: [[Character]]) -> String {
            return arr.map { (line) in
                line.map({ String($0 == config.empty ? "_" : $0) }).joinWithSeparator(",")
                }.joinWithSeparator("\n")
        }
        return str(board)
    }
    
    public func letterAt(x: Int, _ y: Int) -> Character? {
        let value = board[y][x]
        return value == config.empty ? nil : value
    }
    
    public func isEmptyAt(x: Int, _ y: Int) -> Bool {
        return board[y][x] == config.empty
    }
    
    public func isFilledAt(x: Int, _ y: Int) -> Bool {
        return board[y][x] != config.empty
    }
    
    public func isCenterAt(x: Int, _ y: Int) -> Bool {
        return x == config.center && y == config.center
    }
    
    func verticallyTouchesAt(x: Int, _ y: Int, length: Int, edges: Edge) -> Bool {
        let size = config.size
        
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
        let size = config.size
        
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
        let size = config.size
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
        }
        
        // Otherwise, must be vertical...
        
        // Touches on bottom or top (cannot accept prefixed or suffixed spots)
        if verticallyTouchesAt(x, y, length: length, edges: .TopAndBottom) {
            return false
        }
        // Touches on left or right (allowed)
        if verticallyTouchesAt(x, y, length: length, edges: .LeftAndRight) {
            return true
        }
        
        // Intersects other letters?
        return (currentX > x + length && horizontal ||
            currentY > y + length && !horizontal)
    }
    
    mutating public func play(solution: Solution) -> [Character] {
        var dropped = [Character]()
        for (i, letter) in solution.word.characters.enumerate() {
            if solution.horizontal {
                if isEmptyAt(solution.x + i, solution.y) {
                    board[solution.y][solution.x + i] = letter
                    dropped.append(letter)
                }
            } else {
                if isEmptyAt(solution.x, solution.y + i) {
                    board[solution.y + i][solution.x] = letter
                    dropped.append(letter)
                }
            }
        }
        playedBlanks.appendContentsOf(solution.blanks)
        return dropped
    }
}

public protocol BoardConfig {
    init()
    var empty: Character { get }
    var board: [[Character]] { get }
    var boardRange: Range<Int> { get }
    var size: Int { get }
    var center: Int { get }
    var letterMultipliers: [[Int]] { get }
    var wordMultipliers: [[Int]] { get }
}

extension BoardConfig {
    public var boardRange: Range<Int> {
        return board.indices
    }
    public var size: Int {
        return board.count
    }
}

public struct ScrabbleBoardConfig: BoardConfig {
    public init() { }
    public let empty = Character(" ")
    public let board = Array(count: 15, repeatedValue: Array(count: 15, repeatedValue: Character(" ")))
    public let center = 7
    public let letterMultipliers = [
        [1,1,1,2,1,1,1,1,1,1,1,2,1,1,1],
        [1,1,1,1,1,3,1,1,1,3,1,1,1,1,1],
        [1,1,1,1,1,1,2,1,2,1,1,1,1,1,1],
        [2,1,1,1,1,1,1,2,1,1,1,1,1,1,2],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,3,1,1,1,3,1,1,1,3,1,1,1,3,1],
        [1,1,2,1,1,1,2,1,2,1,1,1,2,1,1],
        [1,1,1,2,1,1,1,1,1,1,1,2,1,1,1],
        [1,1,2,1,1,1,2,1,2,1,1,1,2,1,1],
        [1,3,1,1,1,3,1,1,1,3,1,1,1,3,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [2,1,1,1,1,1,1,2,1,1,1,1,1,1,2],
        [1,1,1,1,1,1,2,1,2,1,1,1,1,1,1],
        [1,1,1,1,1,3,1,1,1,3,1,1,1,1,1],
        [1,1,1,2,1,1,1,1,1,1,1,2,1,1,1]]
    public let wordMultipliers = [
        [3,1,1,1,1,1,1,3,1,1,1,1,1,1,3],
        [1,2,1,1,1,1,1,1,1,1,1,1,1,2,1],
        [1,1,2,1,1,1,1,1,1,1,1,1,2,1,1],
        [1,1,1,2,1,1,1,1,1,1,1,2,1,1,1],
        [1,1,1,1,2,1,1,1,1,1,2,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [3,1,1,1,1,1,1,2,1,1,1,1,1,1,3],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,2,1,1,1,1,1,2,1,1,1,1],
        [1,1,1,2,1,1,1,1,1,1,1,2,1,1,1],
        [1,1,2,1,1,1,1,1,1,1,1,1,2,1,1],
        [1,2,1,1,1,1,1,1,1,1,1,1,1,2,1],
        [3,1,1,1,1,1,1,3,1,1,1,1,1,1,3]]
}

public struct SuperScrabbleBoardConfig: BoardConfig {
    public init() { }
    public let empty = Character(" ")
    public let board = Array(count: 21, repeatedValue: Array(count: 21, repeatedValue: Character(" ")))
    public let center = 10
    public let letterMultipliers = [
        [1,1,1,2,1,1,1,1,1,1,2,1,1,1,1,1,1,2,1,1,1],
        [1,1,1,1,3,1,1,1,1,1,1,1,1,1,1,1,3,1,1,1,1],
        [1,1,1,1,1,4,1,1,1,1,1,1,1,1,1,4,1,1,1,1,1],
        [2,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,2],
        [1,3,1,1,1,1,1,1,3,1,1,1,3,1,1,1,1,1,1,3,1],
        [1,1,4,1,1,1,1,1,1,2,1,2,1,1,1,1,1,1,4,1,1],
        [1,1,1,2,1,1,1,1,1,1,2,1,1,1,1,1,1,2,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,4,1,1,1,4,1,1,1,4,1,1,1,4,1,1,1,1],
        [1,1,1,1,1,2,1,1,1,2,1,2,1,1,1,2,1,1,1,1,1],
        [2,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,2],
        [1,1,1,1,1,2,1,1,1,2,1,2,1,1,1,2,1,1,1,1,1],
        [1,1,1,1,4,1,1,1,4,1,1,1,4,1,1,1,4,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,2,1,1,1,1,1,1,2,1,1,1,1,1,1,2,1,1,1],
        [1,1,4,1,1,1,1,1,1,2,1,2,1,1,1,1,1,1,4,1,1],
        [1,3,1,1,1,1,1,1,3,1,1,1,3,1,1,1,1,1,1,3,1],
        [2,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,2],
        [1,1,1,1,1,4,1,1,1,1,1,1,1,1,1,4,1,1,1,1,1],
        [1,1,1,1,3,1,1,1,1,1,1,1,1,1,1,1,3,1,1,1,1],
        [1,1,1,2,1,1,1,1,1,1,2,1,1,1,1,1,1,2,1,1,1]]
    public let wordMultipliers = [
        [4,1,1,1,1,1,1,3,1,1,1,1,1,3,1,1,1,1,1,1,4],
        [1,2,1,1,1,1,1,1,2,1,1,1,2,1,1,1,1,1,1,2,1],
        [1,1,2,1,1,1,1,1,1,2,1,2,1,1,1,1,1,1,2,1,1],
        [1,1,1,3,1,1,1,1,1,1,3,1,1,1,1,1,1,3,1,1,1],
        [1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1],
        [1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1],
        [1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1],
        [3,1,1,1,1,1,1,2,1,1,1,1,1,2,1,1,1,1,1,1,3],
        [1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1],
        [1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1],
        [1,1,1,3,1,1,1,1,1,1,2,1,1,1,1,1,1,3,1,1,1],
        [1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1],
        [1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1],
        [3,1,1,1,1,1,1,2,1,1,1,1,1,2,1,1,1,1,1,1,3],
        [1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1],
        [1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1],
        [1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1],
        [1,1,1,3,1,1,1,1,1,1,3,1,1,1,1,1,1,3,1,1,1],
        [1,1,2,1,1,1,1,1,1,2,1,2,1,1,1,1,1,1,2,1,1],
        [1,2,1,1,1,1,1,1,2,1,1,1,2,1,1,1,1,1,1,2,1],
        [4,1,1,1,1,1,1,3,1,1,1,1,1,3,1,1,1,1,1,1,4]]
}
