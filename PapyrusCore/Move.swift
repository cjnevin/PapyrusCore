//
//  Move.swift
//  Papyrus
//
//  Created by Chris Nevin on 17/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

public struct Move {
    let boundary: Boundary
    let squares: [Square]
    let tiles: [Tile]
    
    let word: String
    let definition: String
    let score: Int
}

public struct Possibility {
    let fixedTiles: [Tile]
    
    let move: Move
    let intersections: [Move]
}

extension Papyrus {
    
    /// - parameter player: Player whose tiles we will use to determine viable options.
    /// - parameter lexicon: Dictionary used for validating words and finding anagrams.
    /// - returns: All valid possible moves in the current state of the board.
    public func possibleMoves(forPlayer player: Player, lexicon: Lexicon) -> [Possibility] {
        let letters = player.rackTiles.map({$0.letter})
        var possibilities = [Possibility]()
        allPlayableBoundaries().forEach { (boundary) in
            let fixedLetters = indexesAndCharacters(forBoundary: boundary)
            var results = [(String, String)]()
            lexicon.anagramsOf(letters, length: boundary.length,
                prefix: "", fixedLetters: fixedLetters, fixedCount: fixedLetters.count,
                root: nil, results: &results)
            if (results.count > 0) {
                let indexes = fixedLetters.map({$0.0})
                for (result, definition) in results {
                    print("-----\nPLAY: \(result) --- \(fixedLetters)")
                    
                    // Temporarily place them on board for validation
                    var chars = Array(result.characters)
                    var rackTiles = player.rackTiles
                    var temporarySquareTiles = [(Square, Tile)]()
                    
                    boundary.positions().forEach({ (position) -> () in
                        let index = position.iterable - boundary.start.iterable
                        if indexes.contains(index) {
                            print("SKIPPED")
                        } else {
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
                            temporarySquareTiles.append((square, tile))
                        }
                    })
                    
                    let mainScore = score(boundary)
                    
                    print("## SQUARES: \(temporarySquareTiles)")
                    
                    var valid = true
                    
                    // Determine intersections
                    var intersectingMoves = [Move]()
                    let intersections = findIntersections(forBoundary: boundary).filter({$0.length > 1})
                    for intersection in intersections {
                        let intersectingSquares = squaresIn(intersection)
                        let intersectingTiles = tilesIn(intersectingSquares)
                        let intersectingLetters = lettersIn(intersectingTiles)
                        let intersectingWord = String(intersectingLetters)
                        
                        assert(intersectingLetters.count > 1 &&
                            intersectingLetters.count == intersection.length)
                        
                        do {
                            let intersectingDefinition = try lexicon.defined(intersectingWord)
                            
                            var intersectingScore = 0
                            if tiles.all({$0.placement == .Fixed}) == false {
                                intersectingScore = score(intersection)
                            }
                            
                            let intersectingMove = Move(boundary: intersection,
                                squares: intersectingSquares,
                                tiles: intersectingTiles,
                                word: intersectingWord,
                                definition: intersectingDefinition,
                                score: intersectingScore)
                            
                            intersectingMoves.append(intersectingMove)
                        } catch {
                            print("## INVALID")
                            valid = false
                            break
                        }
                    }
                    
                    // Restore state
                    temporarySquareTiles.forEach({ (square, tile) -> () in
                        square.tile = nil
                        tile.placement = .Rack
                        if tile.value == 0 {
                            tile.letter = "?"
                        }
                    })
                    
                    if valid {
                        let onBoard = tilesIn(boundary)
                        // Ensure we placed them all back
                        assert(onBoard.all({$0.placement == Placement.Fixed}))
                        
                        let move: Move = Move(boundary: boundary,
                            squares: temporarySquareTiles.map({$0.0}),
                            tiles: temporarySquareTiles.map({$0.1}),
                            word: result,
                            definition: definition,
                            score: mainScore)
                        
                        let possibility = Possibility(fixedTiles: onBoard,
                            move: move, intersections: intersectingMoves)
                        possibilities.append(possibility)
                    }
                }
            }
        }
        return possibilities
    }
    
}