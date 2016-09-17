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

internal struct BoardState: Equatable {
    fileprivate let horizontal: Array2D<Int>
    fileprivate let vertical: Array2D<Int>
    fileprivate let size: Int
    
    init(board: Board) {
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
        
        size = board.size
        
        let count = size * size
        var h = Array2D(columns: count, rows: count, initialValue: 0)
        var v = Array2D(columns: count, rows: count, initialValue: 0)
        
        let range = board.layout.indices
        for x in range {
            for y in range {
                h[y, x] = decrement(from: x, when: { board.isFilled(at: Position(x: $0, y: y)) })
                v[y, x] = decrement(from: y, when: { board.isFilled(at: Position(x: x, y: $0)) })
            }
        }
        
        horizontal = h
        vertical = v
    }
    
    func state(at position: Position, horizontal h: Bool) -> Int {
        return (h ? horizontal : vertical)[position.y, position.x]
    }
}
