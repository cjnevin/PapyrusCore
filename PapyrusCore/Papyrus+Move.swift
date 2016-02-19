//
//  Papyrus+Move.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 19/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    /// Determine intersections for a given boundary.
    /// - parameter boundary: Boundary to check.
    /// - parameter lexicon: Dictionary to use for validating words.
    /// - returns: Success flag and array of Words.
    private func intersectingWords(forBoundary boundary: Boundary) throws -> [Word] {
        let dictionary = dawg!
        
        var intersectingWords = [Word]()
        let intersections = findIntersections(forBoundary: boundary).filter({$0.length > 1})
        
        for intersection in intersections {
            let intersectingSquares = squaresIn(intersection)
            let intersectingTiles = tilesIn(intersectingSquares)
            let intersectingLetters = lettersIn(intersectingTiles)
            let intersectingWord = String(intersectingLetters)
            
            assert(intersectingLetters.count > 1 &&
                intersectingLetters.count == intersection.length)
            
            if dictionary.lookup(intersectingWord) {
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
        assert(droppedTiles().count == 0)
    }
    
    /// Temporarily place tiles on board so we can find intersecting words.
    /// - param rackTiles: Tiles currently in player's rack.
    /// - param boundary: Boundary we are trying to play a word in.
    /// - param characters: Characters in the word we are trying to play.
    /// - param filledIndexes: Indexes (of characters) that have already been played on the board.
    private func temporarilyPlaceWord(
        withCharacters chars: [Character],
        andFilledIndexes filledIndexes: [Int],
        inBoundary boundary: Boundary,
        forPlayer player: Player) -> [(Square, Tile, Character)]
    {
        // Create a mutable copy of rack tiles.
        var rackTiles = player.rackTiles
        assert(rackTiles.count > 0)
        assert(droppedTiles().count == 0)
        
        func rackTile(forCharacter char: Character) -> Tile? {
            guard let index = rackTiles.indexOf({$0.letter == char}) else {
                return nil
            }
            let tile = rackTiles.removeAtIndex(index)
            // If blank letter, lets set the character
            tile.changeLetter(char)
            assert(tile.placement == .Rack)
            return tile
        }
        
        return boundary.positions().mapFilter({ (position) -> (Square, Tile, Character)? in
            // Convert location on board to index
            let index = position.iterable - boundary.start.iterable
            // If index is already filled, lets return nil?
            if filledIndexes.contains(index) {
                return nil
            }
            // Get character at given index we are trying to play
            let char = chars[index]
            
            guard let
                tile = rackTile(forCharacter: char) ?? rackTile(forCharacter: PapyrusBlankLetter),
                square = squareAt(position) else {
                    assert(false)
            }
            assert(square.tile == nil)
            square.tile = tile
            square.tile?.placement = .Board
            return (square, tile, tile.letter)
        })
    }
    
    /// - parameter boundary: Boundary to check.
    /// - parameter filledIndexes: Indexes of fixed characters in the boundary.
    /// - parameter word: Word to check.
    /// - returns: Returns a Move object for a given word.
    private func possibleAIMove(
        forBoundary boundary: Boundary,
        filledIndexes: [Int]? = nil,
        word mainWord: String) throws -> Move
    {
        guard let player = player else {
            throw ValidationError.NoPlayer
        }
        
        let chars = Array(mainWord.characters)
        let indexes = filledIndexes ??
            allLetters(inBoundary: boundary).map({$0.0})
        
        // Place word to perform some tests on the updated board.
        let squareTileCharacters = temporarilyPlaceWord(
            withCharacters: chars,
            andFilledIndexes: indexes,
            inBoundary: boundary,
            forPlayer: player)
        
        // Ensure we restore the square/tile states once we finish this method.
        defer {
            restoreState(squareTileCharacters)
        }
        
        // FIXME: Bug
        // There is a bug here where it sometimes doesn't stretch to include all letters
        // just had 'HOEDFAT' instead of 'HOED' played.
        
        // Stretch to ensure it includes the entire boundary
        guard let stretched = stretchIfFilled(boundary) else {
            throw ValidationError.InvalidArrangement
        }
        
        // FIXME: Move?
        // This should probably be moved to the playable boundaries method, only returning boundaries if we
        // hit two consecutive empty squares or an edge of the board.
        let stretchedWord = String(lettersIn(stretched))
        
        // Ensure word exists
        if dawg?.lookup(stretchedWord) == false {
            throw ValidationError.UndefinedWord(stretchedWord)
        }
        
        // Get intersecting words
        let intersections = try intersectingWords(forBoundary: stretched)
        
        // Calculate score of main word
        let mainScore = try score(stretched)
        
        // Create word object from gathered information
        let word: Word = Word(boundary: stretched,
            characters: squareTileCharacters.map({$0.2}),
            squares: squareTileCharacters.map({$0.0}),
            tiles: squareTileCharacters.map({$0.1}),
            word: stretchedWord,
            score: mainScore)
        
        // Calculate total score
        let total = word.score + intersections.map({$0.score}).reduce(0, combine: +)
        
        // Create move object
        return Move(
            total: total,
            word: word,
            intersections: intersections)
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
    internal func getAIMoves() throws -> [Move] {
        guard let player = player, dawg = dawg else { throw ValidationError.NoPlayer }
        assert(player.difficulty != .Human)
        let letters = player.rackTiles.map({$0.letter})
        return allPlayableBoundaries().mapFilter { (boundary) -> ([Move]?) in
            let fixedLetters = allLetters(inBoundary: boundary)
            guard let
                results = dawg.anagrams(
                    withLetters: letters,
                    wordLength: boundary.length,
                    filledLetters: fixedLetters)
                else {
                return nil
            }
            let indexes = fixedLetters.map{ $0.0 }
            return results.mapFilter{
                try? possibleAIMove(forBoundary: boundary, filledIndexes: indexes, word: $0)
            }
        }.flatten().sort({$0.total > $1.total})
    }
    
    /// - returns: Move for player with difficulty.
    internal func getAIMove() throws -> Move {
        if player?.difficulty == .Human {
            throw ValidationError.NoPlayer
        }
        let moves = try getAIMoves()
        var move: Move?
        if player?.difficulty == .Champion {
            move = moves.first
        } else if player?.difficulty == .Newbie {
            move = moves[abs(moves.count / 4)]
        } else {
            move = moves[abs(moves.count / 2)]
        }
        if move == nil {
            throw ValidationError.NoMoves
        }
        return move!
    }
    
    /// - parameter boundary: Boundary to check.
    /// - Throws: If boundary cannot be played you will receive a ValidationError.
    /// - returns: Move containing score and any intersections.
    public func getMove(forBoundary boundary: Boundary) throws -> Move {
        // Throw error if no player...
        guard let player = player, dawg = dawg else { throw ValidationError.NoPlayer }
        
        let isFirstMove = fixedTiles().count == 0
        
        // If no words have been played, this boundary must intersect middle.
        let m = PapyrusMiddle - 1
        if isFirstMove && (boundary.start.fixed != m ||
            boundary.start.iterable > m || boundary.end.iterable < m) {
                throw ValidationError.NoCenterIntersection
        }
        
        // If boundary contains squares that are empty, fail.
        let tiles = tilesIn(boundary)
        if tiles.count != boundary.length {
            throw ValidationError.UnfilledSquare(squaresIn(boundary))
        }
        
        // If no words have been played ensure that tile count is valid.
        if isFirstMove && tiles.count < 2 {
            throw ValidationError.InsufficientTiles
        }
        
        // If all of these tiles are not owned by the current player, fail.
        if player.tiles.filter({tiles.contains($0)}).count == 0 {
            throw ValidationError.InsufficientTiles
        }
        
        // If words have been played, it must intersect one of these played words.
        // Assumption: Previous boundaries have passed validation.
        let intersections = findIntersections(forBoundary: boundary)
        let playedBoundaries = filledBoundaries().filter({$0.length > 1})
        if intersections.count == 0 && playedBoundaries != [boundary] {
            throw ValidationError.NoIntersection
        }
        if intersections.count == 0 && boundary.length < 2 {
            throw ValidationError.InvalidArrangement
        }
        
        // Validate words, will throw if any are invalid...
        let mainWord = String(tiles.mapFilter({$0.letter}))
        if boundary.length > 1 && !dawg.lookup(mainWord) {
            throw ValidationError.UndefinedWord(mainWord)
        }
        
        // Get move for a particular word
        return try possibleMove(forBoundary: boundary)
    }
    
    public func submitAIMove() {
        operationQueue.addOperationWithBlock { [weak self] () -> Void in
            guard let game = self, player = game.player else { return }
            print("Rack: \(player.rackTiles)")
            let move = try? game.getAIMove()
            NSOperationQueue.mainQueue().addOperationWithBlock({ [weak self] () -> Void in
                guard let move = move else {
                    self?.lifecycle = .SkippedTurn
                    self?.nextPlayer()
                    return
                }
                self?.submitMove(move)
                })
        }
    }
    
    public func submitMove(move: Move) {
        player?.submit(move)
        draw(player!)
        lifecycle = .EndedTurn(move)
        nextPlayer()
    }
    
    func moveForPositions(positions: [Position]) throws -> Move {
        guard let boundary = stretchWhileFilled(Boundary(positions: positions)) else {
            throw ValidationError.InvalidArrangement
        }
        return try getMove(forBoundary: boundary)
    }
    
    
    /// Check to see if play is valid.
    public func validate() throws -> Move? {
        let positions = droppedPositions()
        if positions.count < 1 { return nil }
        do {
            return try moveForPositions(positions)
        }
        catch {
            if positions.count > 1 {
                return nil
            }
            let invertedPositions = positions.mapFilter({$0.positionWithHorizontal(!$0.horizontal)})
            return try moveForPositions(invertedPositions)
        }
    }
}