//
//  Move.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 17/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

let PapyrusBlankLetter: Character = "?"

public enum ValidationError: ErrorType {
    case UnfilledSquare([Square])
    case InvalidArrangement
    case InsufficientTiles
    case NoCenterIntersection
    case NoIntersection
    case UndefinedWord(String)
    case Message(String)
    case NoPlayer
}

public struct Word {
    public let boundary: Boundary
    
    // Contains only the 'Board' placed tiles.
    public let characters: [Character]
    public let squares: [Square]
    public let tiles: [Tile]
    
    public let word: String
    public let score: Int
    public var length: Int {
        return characters.count
    }
}

public struct Move {
    public let total: Int
    public let word: Word
    public let intersections: [Word]
}

extension Papyrus {
    /// Determine intersections for a given boundary.
    /// - parameter boundary: Boundary to check.
    /// - parameter lexicon: Dictionary to use for validating words.
    /// - returns: Success flag and array of Words.
    private func intersectingWords(forBoundary boundary: Boundary) throws -> [Word] {
        guard let dawg = dawg else { assert(false) }
        
        var intersectingWords = [Word]()
        let intersections = findIntersections(forBoundary: boundary).filter({$0.length > 1})
        
        for intersection in intersections {
            let intersectingSquares = squaresIn(intersection)
            let intersectingTiles = tilesIn(intersectingSquares)
            let intersectingLetters = lettersIn(intersectingTiles)
            let intersectingWord = String(intersectingLetters)
            
            assert(intersectingLetters.count > 1 &&
                intersectingLetters.count == intersection.length)
            
            if dawg.lookup(intersectingWord) {
                var intersectingScore = 0
                if intersectingTiles.all({$0.placement == Placement.Fixed}) == false {
                    intersectingScore = try score(intersection)
                }
                
                let filteredSquares = intersectingSquares.filter({$0.tile?.placement == Placement.Board})
                let filteredTiles = tilesIn(filteredSquares)
                let filteredLetters = lettersIn(filteredTiles)
                
                let intersectingWord = Word(boundary: intersection,
                    characters: filteredLetters,
                    squares: filteredSquares,
                    tiles: filteredTiles,
                    word: intersectingWord,
                    score: intersectingScore)
                
                intersectingWords.append(intersectingWord)
            } else {
                throw ValidationError.UndefinedWord(intersectingWord)
            }
        }
        
        return intersectingWords
    }
    
    private func restoreState(squareTileCharacters: [(Square, Tile, Character)]) {
        // Restore state
        squareTileCharacters.forEach({ (square, tile, _) -> () in
            square.tile = nil
            tile.placement = .Rack
            tile.changeLetter(PapyrusBlankLetter)
        })
    }
    
    /// - parameter boundary: Boundary to check.
    /// - parameter filledIndexes: Indexes of fixed characters in the boundary.
    /// - parameter word: Word to check.
    /// - returns: Returns a Move object for a given word.
    private func possibleAIMove(forBoundary boundary: Boundary,
        filledIndexes: [Int]? = nil,
        word mainWord: String) throws -> Move
    {
        guard let player = player else { throw ValidationError.NoPlayer }
        
        let chars = Array(mainWord.characters)
        let indexes = filledIndexes ?? indexesAndCharacters(forBoundary: boundary).map({$0.0})
        var rackTiles = player.rackTiles
        
        assert(rackTiles.count > 0)
        assert(droppedTiles().count == 0)
        
        // Temporarily place tiles on board so we can find intersecting words
        let squareTileCharacters = boundary.positions().mapFilter({ (position) -> (Square, Tile, Character)? in
            let index = position.iterable - boundary.start.iterable
            if indexes.contains(index) { return nil }
            let char = chars[index]
            guard let rackIndex =
                rackTiles.indexOf({$0.letter == char}) ??
                    rackTiles.indexOf({$0.letter == PapyrusBlankLetter}),
                square = squareAt(position) else {
                    assert(false)
            }
            let tile = rackTiles[rackIndex]
            tile.changeLetter(char)
            assert(square.tile == nil)
            assert(tile.placement == .Rack)
            square.tile = tile
            square.tile?.placement = .Board
            rackTiles.removeAtIndex(rackIndex)
            return (square, tile, tile.letter)
        })
        
        var intersections: [Word]
        var mainScore: Int
        do {
            intersections = try intersectingWords(forBoundary: boundary)
            mainScore = try score(boundary)
            restoreState(squareTileCharacters)
            assert(droppedTiles().count == 0)
        } catch {
            restoreState(squareTileCharacters)
            assert(droppedTiles().count == 0)
            throw error
        }
        
        let word: Word = Word(boundary: boundary,
            characters: squareTileCharacters.map({$0.2}),
            squares: squareTileCharacters.map({$0.0}),
            tiles: squareTileCharacters.map({$0.1}),
            word: mainWord,
            score: mainScore)
        
        let total = word.score + intersections.map({$0.score}).reduce(0, combine: +)
        let move = Move(
            total: total,
            word: word,
            intersections: intersections)
        
        return move
    }
    
    
    /// - parameter boundary: Boundary to check.
    /// - returns: Returns a Move object for a given boundary.
    private func possibleMove(forBoundary boundary: Boundary) throws -> Move
    {
        guard let _ = player else { throw ValidationError.NoPlayer }
        
        let boundarySquares = squaresIn(boundary)
        let boundaryTiles = tilesIn(boundarySquares)
        let boundaryLetters = lettersIn(boundaryTiles)
        let boundaryScore = try score(boundary)
        
        let word: Word = Word(boundary: boundary,
            characters: boundaryLetters,
            squares: boundarySquares,
            tiles: boundaryTiles,
            word: String(boundaryLetters),
            score: boundaryScore)
        
        let intersections = try intersectingWords(forBoundary: boundary)
        let total = word.score + intersections.map({$0.score}).reduce(0, combine: +)
        let move = Move(
            total: total,
            word: word,
            intersections: intersections)
        
        return move
    }
    
    /// - returns: All valid possible moves in the current state of the board.
    public func getAIMoves() throws -> [Move] {
        guard let player = player, dawg = dawg else { throw ValidationError.NoPlayer }
        assert(player.difficulty != .Human)
        let letters = player.rackTiles.map({$0.letter})
        return allPlayableBoundaries().mapFilter { (boundary) -> ([Move]?) in
            let fixedLetters = indexesAndCharacters(forBoundary: boundary)
            var results = [String]()
            dawg.anagramsOf(letters,
                length: boundary.length,
                filledLetters: fixedLetters,
                results: &results)
            if results.count == 0 { return nil }
            let indexes = fixedLetters.map({$0.0})
            return results.mapFilter({
                try? possibleAIMove(forBoundary: boundary, filledIndexes: indexes, word: $0)
            })
        }.flatten().sort({$0.total > $1.total})
    }
    
    /// - parameter boundary: Boundary to check.
    /// - Throws: If boundary cannot be played you will receive a ValidationError.
    /// - returns: Move containing score and any intersections.
    public func getMove(forBoundary boundary: Boundary) throws -> Move {
        // Throw error if no player...
        guard let player = player, dawg = dawg else { throw ValidationError.NoPlayer }
        let playedBoundaries = filledBoundaries()
        
        // If no words have been played, this boundary must intersect middle.
        let m = PapyrusMiddle - 1
        if playedBoundaries.count == 0 && (boundary.start.fixed != m ||
            boundary.start.iterable > m || boundary.end.iterable < m) {
                throw ValidationError.NoCenterIntersection
        }
        
        // If boundary contains squares that are empty, fail.
        let tiles = tilesIn(boundary)
        if tiles.count != boundary.length {
            throw ValidationError.UnfilledSquare(squaresIn(boundary))
        }
        
        // If no words have been played ensure that tile count is valid.
        if playedBoundaries.count == 0 && tiles.count < 2 {
            throw ValidationError.InsufficientTiles
        }
        
        // If all of these tiles are not owned by the current player, fail.
        if player.tiles.filter({tiles.contains($0)}).count == 0 {
            throw ValidationError.InsufficientTiles
        }
        
        // If words have been played, it must intersect one of these played words.
        // Assumption: Previous boundaries have passed validation.
        let intersections = findIntersections(forBoundary: boundary)
        if playedBoundaries.count > 0 && intersections.count == 0 {
            throw ValidationError.NoIntersection
        }
        
        // Validate words, will throw if any are invalid...
        let mainWord = String(tiles.mapFilter({$0.letter}))
        if !dawg.lookup(mainWord) {
            throw ValidationError.UndefinedWord(mainWord)
        }
        
        // Get move for a particular word
        return try possibleMove(forBoundary: boundary)
    }
}