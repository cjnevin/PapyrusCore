//
//  Papyrus+Boundary.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 19/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    
    /// - returns: All boundaries for filled tiles in both axes.
    public func filledBoundaries() -> [Boundary] {
        func getBoundaries(withHorizontal horizontal: Bool, fixed: Int) -> [Boundary] {
            func iterate(iterable: Int) -> Boundary? {
                let start = nextWhileEmpty(
                    Position(horizontal: horizontal, iterable: iterable, fixed: fixed))?.next()
                let end = nextWhileFilled(start)
                return Boundary(start: start, end: end)
            }
            var i = 0
            var lineBoundaries = [Boundary]()
            while let boundary = iterate(i) {
                lineBoundaries.append(boundary)
                i = boundary.end.iterable + 1
            }
            return lineBoundaries
        }
        var boundaries = Set<Boundary>()
        (0..<PapyrusDimensions).forEach({ (fixed) in
            boundaries.unionInPlace(getBoundaries(withHorizontal: false, fixed: fixed))
            boundaries.unionInPlace(getBoundaries(withHorizontal: true, fixed: fixed))
        })
        return Array(boundaries)
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
    
    /// Calculate score for a given boundary.
    /// - parameter boundary: The boundary you want the score of.
    func score(boundary: Boundary) throws -> Int {
        guard let player = player else { throw ValidationError.NoPlayer }
        let affectedSquares = squaresIn(boundary)
        var value = affectedSquares.mapFilter({$0.letterValue}).reduce(0, combine: +)
        value = affectedSquares.mapFilter({$0.wordMultiplier}).reduce(value, combine: *)
        let dropped = tilesIn(affectedSquares).filter({$0.placement == Placement.Board && player.tiles.contains($0)})
        if dropped.count == PapyrusRackAmount {
            // Add bonus
            value += 50
        }
        return value
    }
    
    // MARK: - Playable
    
    /// - parameter boundary: Find filled tiles then return the index and characters for the boundary.
    /// - returns: Array of indexes and characters.
    func allLetters(inBoundary boundary: Boundary) -> [Int: Character] {
        var positionValues = [Int: Character]()
        boundary.positions().forEach { (position) in
            guard let letter = letterAt(position) else { return }
            positionValues[position.iterable - boundary.start.iterable] = letter
        }
        return positionValues
    }
    
    /// - returns: All possible boundaries we may be able to place tiles in, stemming off of all existing words.
    // FIXME: Seems to not return all possibilities, we should make tiles glow to provide visual
    // while debugging.
    public func allPlayableBoundaries() -> [Boundary] {
        var allBoundaries = Set<Boundary>()
        filledBoundaries().forEach { (boundary) in
            // Main boundary already includes all possible tiles.
            if let mainBoundaries = playableBoundaries(forBoundary: boundary) {
                allBoundaries.unionInPlace(mainBoundaries)
            }
            // Adjacent boundaries do not, so we should pad them.
            if let adjacentPrevious = stretchIfFilled(boundary.previous()),
                adjacentBoundaries = playableBoundaries(forBoundary: adjacentPrevious) {
                    allBoundaries.unionInPlace(adjacentBoundaries)
            }
            if let adjacentNext = stretchIfFilled(boundary.next()),
                adjacentBoundaries = playableBoundaries(forBoundary: adjacentNext) {
                    allBoundaries.unionInPlace(adjacentBoundaries)
            }
        }
        return Array(allBoundaries)
    }
    
    /// - returns: All possible boundaries we may be able to place tiles in, stemming off of a given boundary.
    func playableBoundaries(forBoundary boundary: Boundary) -> [Boundary]? {
        guard let
            newStart = previousWhileTilesInRack(boundary.start),
            newEnd = nextWhileTilesInRack(boundary.end),
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
    
    // MARK:- Stretch
    // These methods favour the greater values of the two (min/max).
    
    /// Stretch in either direction until the start/end postions are not filled.
    public func stretchIfFilled(boundary: Boundary?) -> Boundary? {
        return Boundary(
            start: previousWhileFilled(boundary?.start) ?? boundary?.start,
            end: nextWhileFilled(boundary?.end) ?? boundary?.end)
    }
    
    /// Stretch in either direction while the start/end positions are filled.
    public func stretchWhileFilled(boundary: Boundary?) -> Boundary? {
        guard let
            boundary = boundary,
            adjustedStart = previousWhileFilled(boundary.start),
            adjustedEnd = nextWhileFilled(boundary.end),
            adjustedBoundary = Boundary(start: adjustedStart, end: adjustedEnd) else {
                return nil
        }
        return adjustedBoundary
    }
}
