//
//  Boundary.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

public func == (lhs: Boundary, rhs: Boundary) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public struct Boundary: CustomDebugStringConvertible, Equatable, Hashable {
    public let start: Position
    public let end: Position
    public var horizontal: Bool {
        return start.horizontal
    }
    public var length: Int {
        return iterableRange.endIndex - iterableRange.startIndex
    }
    public var iterableRange: Range<Int> {
        return start.iterable...end.iterable
    }
    public var hashValue: Int {
        return debugDescription.hashValue
    }
    public var debugDescription: String {
        let h = start.horizontal ? "H" : "V"
        return "[\(start.iterable),\(start.fixed) - \(end.iterable),\(end.fixed) - \(h)]"
    }
    
    public init?(start: Position?, end: Position?) {
        if start == nil || end == nil { return nil }
        self.start = start!
        self.end = end!
        if !isValid { return nil }
    }
    
    public init?(positions: [Position]) {
        guard let first = positions.first, last = positions.last else { return nil }
        self.start = first
        self.end = last
        if !isValid { return nil }
    }
    
    /// - returns: Inverted positions for this boundary.
    public func invertedPositions() -> [Position] {
        return iterableRange.mapFilter { (index) -> (Position?) in
            Position(horizontal: !horizontal, iterable: start.fixed, fixed: index)
        }
    }
    
    /// - returns: All positions for this boundary.
    public func positions() -> [Position] {
        return iterableRange.mapFilter { (index) -> (Position?) in
            Position(horizontal: horizontal, iterable: index, fixed: start.fixed)
        }
    }
    
    /// - returns: Whether this boundary appears to contain valid positions.
    private var isValid: Bool {
        let valid = start.fixed == end.fixed &&
            start.iterable <= end.iterable &&
            start.horizontal == end.horizontal
        return valid
    }
    
    /// - returns: True if the axis and fixed values match and the iterable value intersects the given boundary.
    public func containedIn(boundary: Boundary) -> Bool {
        return boundary.contains(self)
    }
    
    /// - returns: True if the given boundary is contained in this boundary.
    public func contains(boundary: Boundary) -> Bool {
        // Check if same axis and same fixed value.
        if boundary.horizontal == horizontal && boundary.start.fixed == start.fixed {
            // If they coexist on the same fixed line, check if there is any iterable intersection.
            return
                start.iterable <= boundary.start.iterable &&
                end.iterable >= boundary.end.iterable
        }
        return false
    }
    
    /// - returns: True if position is within this boundary's range.
    public func contains(position: Position) -> Bool {
        // If different axis, swap
        if position.horizontal != horizontal {
            return contains(position.positionWithHorizontal(horizontal)!)
        }
        // If different fixed position it cannot be contained
        if position.fixed != start.fixed { return false }
        return iterableRange.contains(position.iterable)
    }
    
    /// - returns: True if boundary intersects another boundary on opposite axis.
    public func intersects(boundary: Boundary) -> Bool {
        // Check if different axis
        if horizontal == boundary.start.horizontal { return false }
        // FIXME: Check if same fixed value ??
        if start.fixed != boundary.start.fixed { return false }
        // Check if iterable value intersects on either range
        return iterableRange.contains({boundary.iterableRange.contains($0)}) ||
            boundary.iterableRange.contains({iterableRange.contains($0)})
    }
    
    /// Currently unused.
    /// - returns: Boundary at previous fixed index or nil.
    public func previous() -> Boundary? {
        return Boundary(start: start.positionWithFixed(start.fixed - 1),
            end: end.positionWithFixed(end.fixed - 1))
    }
    
    /// Currently unused.
    /// - returns: Boundary at next fixed index or nil.
    public func next() -> Boundary? {
        return Boundary(start: start.positionWithFixed(start.fixed + 1),
            end: end.positionWithFixed(end.fixed + 1))
    }
    
    /// - returns: True if on adjacent fixed value and iterable seems to be in the same range.
    /// i.e. At least end position of the given boundary falls within the start-end range of this
    /// boundary. Or the start position of the given boundary falls within the start-end range
    /// of this boundary.
    public func adjacentTo(boundary: Boundary) -> Bool {
        if boundary.start.horizontal == start.horizontal &&
            ((boundary.start.fixed + 1) == start.fixed ||
                (boundary.start.fixed - 1) == start.fixed) {
            return
                (boundary.start.iterable >= start.iterable &&
                    boundary.start.iterable <= end.iterable) ||
                (boundary.end.iterable > start.iterable &&
                    boundary.start.iterable <= start.iterable)
        }
        return false
    }
    
    // MARK: Shrink
    // These methods favour the lesser values of the two (min/max).
    
    /// - returns: New boundary encompassing the new start and end iterable values.
    public func shrink(startIterable: Int, endIterable: Int) -> Boundary? {
        if startIterable == start.iterable && endIterable == end.iterable { return self }
        return Boundary(
            start: start.positionWithMaxIterable(startIterable),
            end: end.positionWithMinIterable(endIterable))
    }
    
    /// Shrinks the current Boundary to encompass the given start and end iterable values.
    public mutating func shrinkInPlace(startIterable: Int, endIterable: Int) {
        if let newBoundary = shrink(startIterable, endIterable: endIterable) {
            self = newBoundary
        }
    }
    
    /// - returns: New boundary encompassing the new start and end positions.
    public func shrink(newStart: Position, newEnd: Position) -> Boundary? {
        return shrink(newStart.iterable, endIterable: newEnd.iterable)
    }
    
    /// Shrinks the current Boundary to encompass the given start and end positions.
    public mutating func shrinkInPlace(newStart: Position, newEnd: Position) {
        if let newBoundary = shrink(newStart, newEnd: newEnd) {
            self = newBoundary
        }
    }
    
    // MARK: Stretch
    // These methods favour the greater values of the two (min/max).
    
    /// - returns: New boundary encompassing the new start and end iterable values.
    public func stretch(startIterable: Int, endIterable: Int) -> Boundary? {
        if startIterable == start.iterable && endIterable == end.iterable { return self }
        return Boundary(
            start: start.positionWithMinIterable(startIterable),
            end: end.positionWithMaxIterable(endIterable))
    }
    
    /// Stretches the current Boundary to encompass the given start and end iterable values.
    public mutating func stretchInPlace(startIterable: Int, endIterable: Int) {
        if let newBoundary = stretch(startIterable, endIterable: endIterable) {
            self = newBoundary
        }
    }
    
    /// - returns: New boundary encompassing the new start and end positions.
    public func stretch(newStart: Position, newEnd: Position) -> Boundary? {
        return stretch(newStart.iterable, endIterable: newEnd.iterable)
    }
    
    /// Stretches the current Boundary to encompass the given start and end positions.
    public mutating func stretchInPlace(newStart: Position, newEnd: Position) {
        if let newBoundary = stretch(newStart, newEnd: newEnd) {
            self = newBoundary
        }
    }
}

extension Papyrus {
    /// - parameter boundary: Find filled tiles then return the index and characters for the boundary.
    /// - returns: Array of indexes and characters.
    func indexesAndCharacters(forBoundary boundary: Boundary) -> [(Int, Character)] {
        return boundary.positions().mapFilter { (position) -> (Int, Character)? in
            guard let letter = letterAt(position) else { return nil }
            return (position.iterable - boundary.start.iterable, letter)
        }
    }
    
    /// - parameter boundary: Boundary containing tiles that have been dropped on the board.
    /// - returns: Array of word boundaries that intersect the supplied boundary.
    func findIntersections(forBoundary boundary: Boundary) -> [Boundary] {
        return boundary.invertedPositions().mapFilter({ (position) -> (Boundary?) in
            guard let wordStart = previousWhileFilled(position),
                wordEnd = nextWhileFilled(position),
                wordBoundary = Boundary(start: wordStart, end: wordEnd) else { return nil }
            return wordBoundary
        })
    }
    
    /// Curried function for checking if an empty position is playable.
    /// We need to check previous item to see if it's empty otherwise
    /// next item must be empty (i.e. 2 squares must be free).
    private func validEmpty(position: Position,
        first: Position -> () -> Position?,
        second: Position -> () -> Position?) -> Bool {
        // Current position must be empty
        assert(emptyAt(position))
            // Check next index (or previous if at end) is empty
            if let startNext = first(position)() where emptyAt(startNext) {
                return true
            } else {
                // Check previous index (or next if at end) is empty or edge of board
                if let startPrevious = second(position)() {
                    return emptyAt(startPrevious)
                }
            }
            return true
    }
    
    /// Calculate score for a given boundary.
    /// - parameter boundary: The boundary you want the score of.
    func score(boundary: Boundary) -> Int {
        guard let player = player else { return 0 }
        let affectedSquares = squaresIn(boundary)
        var value = affectedSquares.mapFilter({$0?.letterValue}).reduce(0, combine: +)
        value = affectedSquares.mapFilter({$0?.wordMultiplier}).reduce(value, combine: *)
        if affectedSquares.mapFilter({ $0?.tile }).filter({player.tiles.contains($0)}).count == 7 {
            // Add bonus
            value += 50
        }
        return value
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
