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
        func str(arr: [[Int]]) -> String {
            return arr.map { (line) in
                line.map({ $0 < 10 ? "_\($0)" : "\($0)" }).joinWithSeparator(", ")
                }.joinWithSeparator("\n")
        }
        return "Horizontal: \n\(str(horizontal)) \n\nVertical: \n\(str(vertical))"
    }
    
    init(board: Board) {
        let size = board.config.size
        let range = board.config.boardRange
        var h = Array(count: size, repeatedValue: Array(count: size, repeatedValue: 0))
        var v = Array(count: size, repeatedValue: Array(count: size, repeatedValue: 0))
        func update(first: Int, `while`: (Int) -> Bool) -> Int {
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
                h[y][x] = update(x){ board.board[y][$0] != board.config.empty }
                v[y][x] = update(y){ board.board[$0][x] != board.config.empty }
            }
        }
        horizontal = h
        vertical = v
    }
    
    subscript(isHorizontal: Bool) -> [[Int]] {
        return isHorizontal ? horizontal : vertical
    }
}
