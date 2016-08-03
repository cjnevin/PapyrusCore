//
//  BoardState.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

internal func == (lhs: BoardState, rhs: BoardState) -> Bool {
    return lhs.horizontal == rhs.horizontal && lhs.vertical == rhs.vertical
}

internal struct BoardState: CustomDebugStringConvertible, Equatable {
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
        let range = board.layout.indices
        var h = Array(repeating: Array(repeating: 0, count: size), count: size)
        var v = Array(repeating: Array(repeating: 0, count: size), count: size)
        
        func decrement(from index: Int, when passing: (Int) -> Bool) -> Int {
            var start = index
            while start > 0 && passing(start) {
                guard passing(start - 1) else {
                    break
                }
                start -= 1
            }
            return start
        }
        
        for x in range {
            for y in range {
                h[y][x] = decrement(from: x, when: { board.isFilled(at: Position(x: $0, y: y)) })
                v[y][x] = decrement(from: y, when: { board.isFilled(at: Position(x: x, y: $0)) })
            }
        }
        
        horizontal = h
        vertical = v
    }
    
    func state(at position: Position, horizontal h: Bool) -> Int {
        return (h ? horizontal : vertical)[position.y][position.x]
    }
}
