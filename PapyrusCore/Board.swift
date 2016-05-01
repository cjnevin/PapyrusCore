//
//  Board.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public func == (lhs: Board, rhs: Board) -> Bool {
    for (y, line) in lhs.board.enumerate() {
        for (x, spot) in line.enumerate() {
            if rhs.board[y][x] != spot {
                return false
            }
        }
    }
    return true
}

public struct Board: CustomDebugStringConvertible, Equatable {
    
    public static let letterMultipliers = [
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
    
    public static let wordMultipliers = [
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

    public internal(set) var board = Array(count: 15, repeatedValue: Array(count: 15, repeatedValue: Character(" ")))
    public let boardSize = 15
    public internal(set) var playedBlanks = [(x: Int, y: Int)]()
    let boardRange = 0..<15
    public let center = 7
    public let empty: Character = " "
    let allTilesUsedBonus = 50
    
    var isFirstPlay: Bool {
        return isEmptyAt(center, center)
    }
    
    public var debugDescription: String {
        func str(arr: [[Character]]) -> String {
            return arr.map { (line) in
                line.map({ String($0 == empty ? "_" : $0) }).joinWithSeparator(",")
                }.joinWithSeparator("\n")
        }
        return str(board)
    }
    
    func letterAt(x: Int, _ y: Int) -> Character? {
        let value = board[y][x]
        return value == empty ? nil : value
    }
    
    func isEmptyAt(x: Int, _ y: Int) -> Bool {
        return board[y][x] == empty
    }
    
    func isFilledAt(x: Int, _ y: Int) -> Bool {
        return board[y][x] != empty
    }
    
    func isValidSpot(x: Int, y: Int, length: Int, horizontal: Bool) -> Bool {
        if isFilledAt(x, y) {
            return false
        }
        if x == center && y == center && isFirstPlay {
            return true
        }
        
        var currentLength = length
        var currentX = x
        var currentY = y
        
        while currentLength > 0 && (horizontal && currentX < boardSize || !horizontal && currentY < boardSize)  {
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
            else if x + length < boardSize && isFilledAt(x + length, y) {
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
                else if y < 14 && isFilledAt(i, y + 1) {
                    return true
                }
            }
        } else {
            // Touches on bottom (cannot accept suffixed spots)
            if y + length < boardSize && isFilledAt(x, y + length) {
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
                if x < 14 && isFilledAt(x + 1, i) {
                    return true
                }
            }
        }
        return false
    }
    
    mutating func play(solution: Solution) -> [Character] {
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
