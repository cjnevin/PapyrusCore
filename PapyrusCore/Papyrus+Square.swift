//
//  Papyrus+Square.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 19/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    /// - parameter position: Position to check.
    /// - returns: Square at given position.
    func squareAt(position: Position?) -> Square? {
        guard let pos = position else { return nil }
        if pos.horizontal {
            return squares[pos.fixed][pos.iterable]
        } else {
            return squares[pos.iterable][pos.fixed]
        }
    }
    
    /// - parameter boundary: Boundary to check.
    /// - returns: All squares in a given boundary.
    func squaresIn(boundary: Boundary) -> [Square] {
        return boundary.positions().mapFilter({ squareAt($0) })
    }
    
    /// - returns: All squares for a given set of tiles.
    public func squaresFor(tiles: [Tile]) -> [Square] {
        return squares.flatten().mapFilter({ (square) -> (Square?) in
            if let tile = square.tile where tiles.contains(tile) {
                return square
            }
            return nil
        })
    }
}