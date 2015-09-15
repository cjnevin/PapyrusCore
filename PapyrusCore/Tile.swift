//
//  Tile.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

public enum Placement {
    case Bag
    case Rack
    case Held
    case Board
    case Fixed
}

public func == (lhs: Tile, rhs: Tile) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

let TileConfiguration: [(Int, Int, Character)] = [(9, 1, "A"), (2, 3, "B"), (2, 3, "C"), (4, 2, "D"), (12, 1, "E"),
    (2, 4, "F"), (3, 2, "G"), (2, 4, "H"), (9, 1, "I"), (1, 8, "J"), (1, 5, "K"),
    (4, 1, "L"), (2, 3, "M"), (6, 1, "N"), (8, 1, "O"), (2, 3, "P"), (1, 10, "Q"),
    (6, 1, "R"), (4, 1, "S"), (6, 1, "T"), (4, 1, "U"), (2, 4, "V"), (2, 4, "W"),
    (2, 4, "Y"), (1, 10, "Z"), (2, 0, "?")]

public final class Tile: CustomDebugStringConvertible, Equatable, Hashable {
    class func createTiles() -> [Tile] {
        return TileConfiguration.flatMap { e in
            (0..<e.0).map({ _ in
                Tile(e.2, e.1)
            })
            }.sort({_, _ in arc4random() % 2 == 0})
    }
    public var letter: Character
    public var placement: Placement
    public let value: Int
    public init(_ letter: Character, _ value: Int) {
        self.letter = letter
        self.value = value
        self.placement = .Bag
    }
    public var debugDescription: String {
        return String(letter)
    }
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

extension Papyrus {
    /// - returns: All tiles in the bag.
    public var bagTiles: [Tile] {
        return tiles.filter({$0.placement == Placement.Bag})
    }
    
    /// - parameter position: Position to check.
    /// - returns: Whether there is a tile at a given position.
    public func emptyAt(position: Position) -> Bool {
        return tileAt(position) == nil
    }
    
    /// - parameter position: Position to check.
    /// - returns: Letter at given position.
    public func letterAt(position: Position?) -> Character? {
        return tileAt(position)?.letter
    }
    
    /// - parameter position: Position to check.
    /// - returns: Tile at a given position.
    public func tileAt(position: Position?) -> Tile? {
        return squareAt(position)?.tile
    }
    
    /// - parameter boundary: Boundary to check.
    /// - returns: All tiles in a given boundary.
    public func tilesIn(boundary: Boundary) -> [Tile] {
        return squaresIn(boundary).mapFilter({$0?.tile})
    }
    
    public func lettersIn(boundary: Boundary) -> [Character] {
        return tilesIn(boundary).mapFilter({$0.letter})
    }
    
    public func allBoundaries() -> [Boundary] {
        var boundaries = [Boundary]()
        (0..<PapyrusDimensions).forEach({ (fixed) in
            if let verticalBoundary = Boundary(
                start: nextWhileEmpty(
                    Position(horizontal: false, iterable: 0, fixed: fixed)
                )?.next(),
                end: previousWhileEmpty(
                    Position(horizontal: false, iterable: PapyrusDimensions - 1, fixed: fixed)
                )?.previous()
                ) {
                    boundaries.append(verticalBoundary)
            }
            if let horizontalBoundary = Boundary(
                start: nextWhileEmpty(
                    Position(horizontal: true, iterable: 0, fixed: fixed)
                )?.next(),
                end: previousWhileEmpty(
                    Position(horizontal: true, iterable: PapyrusDimensions - 1, fixed: fixed)
                )?.previous()
                ) {
                    boundaries.append(horizontalBoundary)
            }
        })
        return boundaries
    }
    
    public func expandedBoundaries(forBoundary boundary: Boundary) -> [Boundary]? {
        guard let newStart = self.previousWhileTilesInRack(boundary.start),
            newEnd = self.nextWhileTilesInRack(boundary.end),
            newBoundary = boundary.stretch(newStart, newEnd: newEnd) else
        {
            return nil
        }
        let rackCount = player!.rackTiles.count
        let boundaryTileCount = tilesIn(boundary).count
        // Get maximum word size, then shift the iterable index
        var maxLength = boundary.length + rackCount
        
        // Adjust for existing tiles on the board
        maxLength += tilesIn(newBoundary).count - boundaryTileCount
        
        let lengthRange = 0..<maxLength
        
        return newBoundary.iterableRange.flatMap({ (startIterable) -> ([Boundary]) in
            lengthRange.mapFilter({ (length) -> (Boundary?) in
                let endIterable = startIterable + length
                guard let stretched = boundary.stretch(startIterable,
                    endIterable: endIterable) else { return nil }
                return stretched
            })
        })
    }
    
    public func allPlayableBoundaries() -> [Boundary] {
        let playable = allBoundaries().mapFilter({ (boundary) -> ([Boundary]?) in
            return expandedBoundaries(forBoundary: boundary)
        })
        return Array(Set(playable.flatMap({$0})))
    }
}