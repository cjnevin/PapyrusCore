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
    
    public func isValidSpot(x: Int, y: Int, length: Int, horizontal: Bool) -> Bool {
        if isFilledAt(x, y) {
            return false
        }
        if x == config.center && y == config.center && isFirstPlay {
            return true
        }
        
        let size = config.size
        var currentLength = length
        var currentX = x
        var currentY = y
        
        while currentLength > 0 && (horizontal && currentX < size || !horizontal && currentY < size)  {
            if isEmptyAt(currentX, currentY) {
                currentLength -= 1
            }
            if horizontal {
                currentX += 1
            } else {
                currentY += 1
            }
        }
        
        // Too long
        if currentLength != 0 {
            return false
        }
        
        if horizontal {
            // Touches on left (cannot accept prefixed spots)
            if x > 0 && isFilledAt(x - 1, y) {
                return false
            }
                // Touches on right (cannot accept suffixed spots)
            else if x + length < size && isFilledAt(x + length, y) {
                return false
            }
                // Intersects other letters
            else if currentX > x + length {
                return true
            }
            // Touches on top or bottom
            for i in x..<(x + length) {
                if y > 0 && isFilledAt(i, y - 1) {
                    return true
                }
                else if y < (size - 1) && isFilledAt(i, y + 1) {
                    return true
                }
            }
        } else {
            // Touches on bottom (cannot accept suffixed spots)
            if y + length < size && isFilledAt(x, y + length) {
                return false
            }
                // Touches on top (cannot accept prefixed spots)
            else if y > 0 && isFilledAt(x, y - 1) {
                return false
            }
                // Intersects other letters
            else if currentY > y + length {
                return true
            }
            // Touches on left/right
            for i in y..<(y + length) {
                if x > 0 && isFilledAt(x - 1, i) {
                    return true
                }
                if x < (size - 1) && isFilledAt(x + 1, i) {
                    return true
                }
            }
        }
        return false
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
