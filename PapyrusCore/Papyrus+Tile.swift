//
//  Papyrus+Tile.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 19/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    /// - returns: All tiles in the bag.
    func bagTiles() -> [Tile] {
        return tiles.filter({$0.placement == Placement.Bag})
    }
    
    /// - returns: All tiles currently dropped on the board.
    func droppedTiles() -> [Tile] {
        return tiles.filter({$0.placement == Placement.Board})
    }
    
    /// - returns: All tiles currently fixed on the board.
    func fixedTiles() -> [Tile] {
        return tiles.filter({$0.placement == Placement.Fixed})
    }
    
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
    
    /// - parameter squares: Squares to check.
    /// - returns: All tiles for given squares.
    public func tilesIn(squares: [Square]) -> [Tile] {
        return squares.mapFilter({$0.tile})
    }
    
    /// - parameter boundary: Boundary to check.
    /// - returns: All tiles in a given boundary.
    public func tilesIn(boundary: Boundary) -> [Tile] {
        return squaresIn(boundary).mapFilter({$0.tile})
    }
    
    /// - parameter tiles: Tiles to get the letter values of.
    /// - returns: All letters for given tiles.
    func lettersIn(tiles: [Tile]) -> [Character] {
        return tiles.mapFilter({$0.letter})
    }
    
    /// - parameter boundary: Boundary to check.
    /// - returns: All letters in a given boundary.
    func lettersIn(boundary: Boundary) -> [Character] {
        return tilesIn(boundary).mapFilter({$0.letter})
    }
}