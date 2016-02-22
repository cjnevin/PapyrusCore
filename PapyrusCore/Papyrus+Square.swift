//
//  Papyrus+Square.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 19/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

extension SequenceType where Generator.Element == Square {
    /// - returns: All tiles for given squares.
    func toTiles() -> [Tile] {
        return flatMap{ $0.tile }
    }
    /// - returns: Letter values for squares.
    func toLetterValues() -> [Int] {
        return flatMap{ $0.letterValue }
    }
    /// - returns: Word multipliers for square types.
    func toWordMultipliers() -> [Int] {
        return flatMap{ $0.wordMultiplier }
    }
    
    func returnIf(inTiles tiles: [Tile]) -> [Square] {
        return filter{ $0.tile != nil }.filter{ tiles.contains($0.tile!) }
    }
}

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
        return squares.flatten().returnIf(inTiles: tiles)
    }
}