//
//  Papyrus+Tile.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 19/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

extension SequenceType where Generator.Element == Tile {
    /// - returns: Letters for tiles.
    func toLetters() -> [Character] {
        return flatMap{ $0.letter }
    }
    /// - returns: Values for tiles.
    func toValues() -> [Int] {
        return flatMap{ $0.value }
    }
    
    func placed(placement: Placement) -> [Tile] {
        return filter{ $0.placement == placement }
    }
    func containedIn(tiles: [Tile]) -> [Tile] {
        return filter{ tiles.contains($0) }
    }
}

extension Papyrus {
    /// - parameter position: Position to check.
    /// - returns: Whether there is a tile at a given position.
    func emptyAt(position: Position) -> Bool {
        return tileAt(position) == nil
    }
    
    /// - parameter position: Position to check.
    /// - returns: Letter at given position.
    func letterAt(position: Position?) -> Character? {
        return tileAt(position)?.letter
    }
    
    /// - parameter position: Position to check.
    /// - returns: Tile at a given position.
    func tileAt(position: Position?) -> Tile? {
        return squareAt(position)?.tile
    }
    
    /// - parameter boundary: Boundary to check.
    /// - returns: All tiles in a given boundary.
    public func tilesIn(boundary: Boundary) -> [Tile] {
        return squaresIn(boundary).toTiles()
    }
    
    /// - parameter boundary: Boundary to check.
    /// - returns: All letters in a given boundary.
    func lettersIn(boundary: Boundary) -> [Character] {
        return tilesIn(boundary).toLetters()
    }
}