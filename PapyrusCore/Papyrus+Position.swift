//
//  Papyrus+Position.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 19/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    /// Get position array for sprites with axis.
    /// - parameter horizontal: Axis to check.
    /// - returns: Array of positions.
    func droppedPositions() -> [Position] {
        let squares = squaresFor(tiles.placed(.Board))
        let offsets = squares.map { (row: $0.row, col: $0.column) }
        let rows = offsets.sort({$0.row < $1.row})
        let cols = offsets.sort({$0.col < $1.col})
        
        var positions = [Position]()
        if let firstRow = rows.first?.row, lastRow = rows.last?.row where firstRow == lastRow {
            // Horizontal
            positions.appendContentsOf(
                cols.mapFilter { Position(horizontal: true, iterable: $0.col, fixed: $0.row) }
            )
        } else if let firstCol = cols.first?.col, lastCol = cols.last?.col where firstCol == lastCol {
            // Vertical
            positions.appendContentsOf(
                cols.mapFilter{ Position(horizontal: false, iterable: $0.row, fixed: $0.col) }
            )
        }
        return positions
    }
    
    /// - Parameter: Initial position to begin this loop. Fails if initial position is filled.
    /// - returns: Last position with a valid tile.
    func nextWhileEmpty(initial: Position?) -> Position? {
        return initial?.nextWhile { self.emptyAt($0) }
    }
    
    /// - Parameter: Initial position to begin this loop. Fails if initial position is empty.
    /// - returns: Last position with an empty square.
    func nextWhileFilled(initial: Position?) -> Position? {
        return initial?.nextWhile { !self.emptyAt($0) }
    }
    
    /// - Parameter: Initial position to begin this loop.
    /// - returns: Furthest possible position from initial position using PapyrusRackAmount.
    func nextWhileTilesInRack(initial: Position) -> Position? {
        assert(player != nil)
        if initial.iterable == PapyrusDimensions - 1 { return initial }
        var counter = player!.rackTiles.count
        var position: Position? = initial
        while (counter > 0 && position != nil && position?.iterable != PapyrusDimensions - 1) {
            if emptyAt(position!) { counter-- }
            if counter > 0 {
                position?.nextInPlace()
            }
        }
        return nextWhileFilled(position) ?? position
    }
    
    /// - Parameter: Initial position to begin this loop. Fails if initial position is filled.
    /// - returns: Last position with a valid tile.
    func previousWhileEmpty(initial: Position?) -> Position? {
        return initial?.previousWhile { self.emptyAt($0) }
    }
    
    /// - Parameter: Initial position to begin this loop. Fails if initial position is empty.
    /// - returns: Last position with an empty square.
    func previousWhileFilled(initial: Position?) -> Position? {
        return initial?.previousWhile { !self.emptyAt($0) }
    }
    
    /// - Parameter: Initial position to begin this loop.
    /// - returns: Furthest possible position from initial position using PapyrusRackAmount.
    func previousWhileTilesInRack(initial: Position) -> Position? {
        assert(player != nil)
        if initial.iterable == 0 { return initial }
        var counter = player!.rackTiles.count
        var position: Position? = initial
        while (counter > 0 && position != nil && position?.iterable != 0) {
            if emptyAt(position!) { counter-- }
            if counter > 0 {
                position?.previousInPlace()
            }
        }
        return previousWhileFilled(position) ?? position
    }
}