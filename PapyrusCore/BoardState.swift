//
//  BoardState.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

func == (lhs: BoardState, rhs: BoardState) -> Bool {
    return lhs.horizontal == rhs.horizontal && lhs.vertical == rhs.vertical
}

struct BoardState: CustomDebugStringConvertible, Equatable {
    private let horizontal: [[Int]]
    private let vertical: [[Int]]
    
    var debugDescription: String {
        func str(_ arr: [[Int]]) -> String {
            return arr.map { (line) in
                line.map({ $0 < 10 ? "_\($0)" : "\($0)" }).joined(separator: ", ")
                }.joined(separator: "\n")
        }
        return "Horizontal: \n\(str(horizontal)) \n\nVertical: \n\(str(vertical))"
    }
    
    init(board: Board) {
        let size = board.size
        let range = board.boardRange
        var h = Array(repeating: Array(repeating: 0, count: size), count: size)
        var v = Array(repeating: Array(repeating: 0, count: size), count: size)
        func update(_ first: Int, while: (Int) -> Bool) -> Int {
            var start = first
            var escape = false
            while start > 0 && `while`(start) && !escape {
                if `while`(start - 1) {
                    start -= 1
                } else {
                    escape = true
                }
            }
            return start
        }
        for x in range {
            for y in range {
                h[y][x] = update(x){ board.isFilledAt($0, y) }
                v[y][x] = update(y){ board.isFilledAt(x, $0) }
            }
        }
        horizontal = h
        vertical = v
    }
    
    subscript(isHorizontal: Bool, y: Int, x: Int) -> Int {
        return self[isHorizontal][y][x]
    }
    
    subscript(isHorizontal: Bool) -> [[Int]] {
        return isHorizontal ? horizontal : vertical
    }
}
