//
//  Move.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 17/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

public struct Move {
    let boundary: Boundary
    
    // Contains only the 'Board' placed tiles.
    let characters: [Character]
    let squares: [Square]
    let tiles: [Tile]
    
    let word: String
    let definition: String
    let score: Int
}

public struct Possibility {
    let total: Int
    let move: Move
    let intersections: [Move]
}

extension Papyrus {
    
    /// Determine intersections for a given boundary.
    /// - parameter boundary: Boundary to check.
    /// - parameter lexicon: Dictionary to use for validating words.
    /// - returns: Success flag and array of moves.
    private func intersectingMoves(forBoundary boundary: Boundary, dawg: Dawg) -> (Bool, [Move]) {
        var valid = true
        var intersectingMoves = [Move]()
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
                    intersectingScore = score(intersection)
                }
                
                let filteredSquares = intersectingSquares.filter({$0.tile?.placement == Placement.Board})
                let filteredTiles = tilesIn(filteredSquares)
                let filteredLetters = lettersIn(filteredTiles)
                
                let intersectingMove = Move(boundary: intersection,
                    characters: filteredLetters,
                    squares: filteredSquares,
                    tiles: filteredTiles,
                    word: intersectingWord,
                    definition: "",
                    score: intersectingScore)
                
                intersectingMoves.append(intersectingMove)
            } else {
                valid = false
                break
            }
        }
        
        return (valid, intersectingMoves)
    }
    
    /// - parameter player: Player whose tiles we will use to determine viable options.
    /// - parameter lexicon: Dictionary used for validating words and finding anagrams.
    /// - returns: All valid possible moves in the current state of the board.
    public func possibleMoves(forPlayer player: Player, dawg: Dawg) -> [Possibility] {
        let letters = player.rackTiles.map({$0.letter})
        var possibilities = [Possibility]()
        allPlayableBoundaries().forEach { (boundary) in
            let fixedLetters = indexesAndCharacters(forBoundary: boundary)
            var results = [String]()
            dawg.anagramsOf(letters, length: boundary.length,
                prefix: [Character](), filledLetters: fixedLetters, filledCount: fixedLetters.count,
                root: dawg.rootNode, results: &results)
            if (results.count > 0) {
                let indexes = fixedLetters.map({$0.0})
                for mainWord in results {
                    //print("-----\nPLAY: \(mainWord) --- \(fixedLetters)")
                    
                    // Temporarily place them on board for validation
                    let chars = Array(mainWord.characters)
                    var rackTiles = player.rackTiles
                    var temporarySquareTiles = [(Square, Tile, Character)]()
                    
                    boundary.positions().forEach({ (position) -> () in
                        let index = position.iterable - boundary.start.iterable
                        if !indexes.contains(index) {
                            let char = chars[index]
                            guard let rackIndex =
                                rackTiles.indexOf({$0.letter == char}) ??
                                    rackTiles.indexOf({$0.letter == "?"}),
                                square = squareAt(position) else {
                                    assert(false)
                            }
                            let tile = rackTiles[rackIndex]
                            if tile.value == 0 {
                                tile.letter = char
                            }
                            assert(square.tile == nil)
                            assert(tile.placement == .Rack)
                            square.tile = tile
                            square.tile?.placement = .Board
                            rackTiles.removeAtIndex(rackIndex)
                            temporarySquareTiles.append((square, tile, tile.letter))
                        }
                    })
                    
                    //print("## SQUARES: \(temporarySquareTiles)")
                    
                    let mainScore = score(boundary)
                    
                    let (valid, intersectingMoves) =
                    self.intersectingMoves(forBoundary: boundary,
                        dawg: dawg)
                    
                    // Restore state
                    temporarySquareTiles.forEach({ (square, tile, _) -> () in
                        square.tile = nil
                        tile.placement = .Rack
                        if tile.value == 0 {
                            tile.letter = "?"
                        }
                    })
                    
                    if valid {
                        let onBoard = tilesIn(boundary)
                        // Ensure we placed them all back
                        assert(onBoard.count == 0 || (onBoard.count > 0 && onBoard.all({$0.placement == Placement.Fixed})))
                        
                        let move: Move = Move(boundary: boundary,
                            characters: temporarySquareTiles.map({$0.2}),
                            squares: temporarySquareTiles.map({$0.0}),
                            tiles: temporarySquareTiles.map({$0.1}),
                            word: mainWord,
                            definition: "",
                            score: mainScore)
                        
                        let total = move.score + intersectingMoves.map({$0.score}).reduce(0, combine: +)
                        
                        let possibility = Possibility(
                            total: total,
                            move: move,
                            intersections: intersectingMoves)
                        
                        possibilities.append(possibility)
                    }
                }
            }
        }
        return possibilities.sort({$0.total > $1.total})
    }
    
}