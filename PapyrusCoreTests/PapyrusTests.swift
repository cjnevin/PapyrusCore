//
//  PapyrusTests.swift
//  Papyrus
//
//  Created by Chris Nevin on 11/09/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class PapyrusTests: XCTestCase {

    var odawg: Dawg?
    let instance = Papyrus()
    //let lexicon: Lexicon = Lexicon(withFilePath: NSBundle(forClass: LexiconTests.self).pathForResource("CSW12", ofType: "plist")!)!
    
    override func setUp() {
        super.setUp()
        
        let array: NSArray = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: NSBundle(forClass: LexiconTests.self).pathForResource("output", ofType: "json")!)!,
            options: NSJSONReadingOptions.AllowFragments) as! NSArray
        var cached = [Int: DawgNode]()
        let root = DawgNode.deserialize(array, cached: &cached)
        odawg = Dawg(withRootNode: root)
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        instance.newGame { (state, game) -> () in
            switch state {
            case .Cleanup:
                print("Cleanup")
            case .Preparing:
                print("Preparing")
            case .Ready:
                print("Ready")
            case .ChangedPlayer:
                print("Player changed")
            case .Completed:
                print("Completed")
            }
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBagAndRack() {
        XCTAssert(instance.squareAt(nil) == nil)
        XCTAssert(instance.squareAt(Position(horizontal: false, iterable: 0, fixed: 0)) != nil)
        
        let totalTiles = TileConfiguration.map({$0.0}).reduce(0, combine: +)
        XCTAssert(instance.tiles.count == totalTiles)
        instance.createPlayer()
        XCTAssert(instance.bagTiles.count == totalTiles - PapyrusRackAmount)
        
        let player = instance.player!
        XCTAssert(player.rackTiles.count == PapyrusRackAmount)
        XCTAssert(player.currentPlayTiles.count == 0)
        XCTAssert(player.heldTile == nil)
        XCTAssert(player.tiles.count == player.rackTiles.count)
        
        instance.createPlayer()
        
        instance.nextPlayer()
        
        let player2 = instance.player!
        XCTAssert(player != player2)
        XCTAssert(player2.rackTiles.count == PapyrusRackAmount)
        XCTAssert(player2.tiles.count == player2.rackTiles.count)
        XCTAssert(instance.bagTiles.count == totalTiles - (PapyrusRackAmount * 2))
        
        instance.returnTiles(player2.rackTiles, forPlayer: player2)
        XCTAssert(player2.tiles.count == 0, "Expected tiles to be empty")
        XCTAssert(player2.rackTiles.count == 0, "Expected rack to be empty")
        XCTAssert(instance.bagTiles.count == totalTiles - PapyrusRackAmount, "Expected bag to be missing first players rack tiles")
        
        instance.replenishRack(player2)
        XCTAssert(player2.rackTiles.count == PapyrusRackAmount, "Expected rack to contain default amount")
        XCTAssert(instance.bagTiles.count == totalTiles - (PapyrusRackAmount * 2), "Expected bag to be missing both players rack tiles")
        
        instance.nextPlayer()
        XCTAssert(instance.player == player, "Expected to return to first player")
    }
    
    func testInstanceBoundaryMethods() {
        XCTAssert(instance.previousWhileEmpty(Position(horizontal: true, iterable: 5, fixed: 5))?.iterable == 0)
        XCTAssert(instance.nextWhileEmpty(Position(horizontal: true, iterable: 5, fixed: 5))?.iterable == PapyrusDimensions - 1)
        XCTAssert(instance.previousWhileFilled(Position(horizontal: true, iterable: 5, fixed: 5)) == nil)
        XCTAssert(instance.nextWhileFilled(Position(horizontal: true, iterable: 5, fixed: 5)) == nil)
        
        let tile = instance.bagTiles.first!
        let pos = Position(horizontal: true, iterable: 5, fixed: 5)!
        tile.placement = Placement.Board
        instance.squareAt(pos)?.tile = tile
        XCTAssert(instance.nextWhileFilled(pos) == pos)
        XCTAssert(instance.nextWhileEmpty(pos) == nil)
        XCTAssert(instance.nextWhileEmpty(pos.positionWithIterable(1))?.iterable == 4)
        
        let tile2 = instance.bagTiles.first!
        let pos2 = Position(horizontal: true, iterable: 4, fixed: 5)!
        tile.placement = Placement.Board
        let emptyPos = pos2.positionWithIterable(3)
        instance.squareAt(pos2)?.tile = tile2
        XCTAssert(instance.nextWhileFilled(pos2) == pos, "Expected pos")
        XCTAssert(instance.nextWhileEmpty(emptyPos) == emptyPos, "Expected emptyPos")
        XCTAssert(instance.previousWhileFilled(pos) == pos2, "Expected pos2")
        //XCTAssert(instance.readable(Boundary(positions: [pos2, pos])!) == "\(tile2.letter)\(tile.letter)", "Expected readable string from tile letters")
    }
    
    func testWhileMethods() {
        instance.createPlayer()
        XCTAssert(instance.player?.rackTiles.count == 7, "Expected 7 rack tiles")
        XCTAssert(instance.previousWhileTilesInRack(Position(horizontal: true, row: 7, col: 7)!)?.iterable == 1, "Expected (7)-7 to land on square 1")
        XCTAssert(instance.nextWhileTilesInRack(Position(horizontal: true, row: 7, col: 7)!)?.iterable == PapyrusDimensions - 2, "Expected (7)+7 to land on square 13")
    }
    
    func testPlayableBoundariesMethod() {
        instance.createPlayer()
        XCTAssert(instance.player?.rackTiles.count == 7, "Expected 7 rack tiles")
        XCTAssert(PapyrusDimensions == 15, "Expected 15")
        
        let expectations = [7, 14, 20, 25, 29, 32, 34, 35,
            34, 32, 29, 25, 20, 14, 7]
        
        (0..<PapyrusDimensions).forEach { (index) -> () in
            let position = Position(horizontal: true, iterable: index, fixed: 7)!
            let tile = Tile("T", 1)
            let boundary = Boundary(start: position, end: position)!
            instance.squareAt(position)!.tile = tile
            
            //let boundaries = instance.playableBoundaries(forBoundary: boundary)
            //XCTAssert(boundaries.count == expectations[index], "Expected \(expectations[index]) boundaries")
            
            instance.squareAt(position)!.tile = nil
        }
        /*
        let word: [(char: Character, position: Position)] = [
            ("T", Position(horizontal: true, iterable: 0, fixed: 7)!),
            ("E", Position(horizontal: true, iterable: 5, fixed: 7)!),
            ("S", Position(horizontal: true, iterable: 6, fixed: 7)!),
            ("T", Position(horizontal: true, iterable: 7, fixed: 7)!)]
        let boundary = Boundary(start: word.first?.position, end: word.last?.position)!
        word.forEach({ instance.squareAt($0.position)!.tile = Tile($0.char, 1) })
        
        let boundaries = instance.playableBoundaries(forBoundary: boundary)!
        print(boundaries.count)
        XCTAssert(boundaries.count == 54, "Expected 39 boundaries")
        
        var start = PapyrusDimensions, end = 0
        for boundary in boundaries {
            start = min(start, boundary.start.iterable)
            end = max(end, boundary.end.iterable)
        }
        XCTAssert(start == 0, "Expected start to be 0")
        XCTAssert(end == PapyrusDimensions - 1, "Expected end to be 14")
        
        print(instance.playableBoundaries(forBoundary: boundary))*/
    }
    
    func testCardPlay() {
        
        instance.createPlayer()
        
        let player = instance.player!
        
        instance.returnTiles(player.rackTiles, forPlayer: player)
        
        let toDraw: [Character] = ["C", "A", "R", "D", "D", "I", "S"]
        toDraw.forEach { (letter) -> () in
            let tile = instance.bagTiles.filter({$0.letter == letter}).first!
            player.tiles.insert(tile)
            tile.placement = .Rack
        }
        
        let positions: [(Position?, Character)] =
        [
            (Position(horizontal: true, iterable: 4, fixed: 7), "C"),
            (Position(horizontal: true, iterable: 5, fixed: 7), "A"),
            (Position(horizontal: true, iterable: 6, fixed: 7), "R"),
            (Position(horizontal: true, iterable: 7, fixed: 7), "D")
        ]
        
        var boundary = Boundary(start: positions.first?.0, end: positions.last?.0)!
        positions.forEach({ (position, character) -> () in
            let tile = player.tiles.filter({$0.letter == character}).first!
            instance.squareAt(position)?.tile = tile
            tile.placement = Placement.Board
        })/*
        do {
            try instance.play(boundary, submit: false, lexicon: lexicon)
        }
        catch ValidationError.NoCenterIntersection {
            XCTAssert(true)
            positions.forEach({
                let tile = instance.squareAt($0.0)!.tile!
                instance.squareAt($0.0)!.tile = nil
                tile.placement = Placement.Rack
            })
        }
        catch {
            XCTFail("Unexpected error")
        }

        // Move tiles and try again
        positions.forEach({ (position, character) -> () in
            let tile = player.tiles.filter({$0.letter == character}).first!
            let shifted = position!.positionWithFixed(position!.fixed - 1)!
            instance.squareAt(shifted)?.tile = tile
            tile.placement = Placement.Board
        })
        boundary = boundary.previous()!
        */
        // TODO: Rethink boundaries
        
        do {
            //let score = try instance.play(boundary, submit: false, lexicon: lexicon)
            //XCTAssert(score == 14)
            
            let dawg = odawg!
            
            try instance.play(boundary, submit: true, dawg: dawg)
            
            //instance.draw()
            
            //instance.returnTiles(player.rackTiles.filter({$0.letter != "D" && $0.letter != "I" && $0.letter != "S"}), forPlayer: player)
           
            //XCTAssert(player.rackTiles.count == 3)
            XCTAssert(player.rackTiles.count == 3)
            print(player.rackTiles)
            
            let armsToDraw: [Character] = ["A", "R", "M", "S"]
            armsToDraw.forEach { (letter) -> () in
                let tile = instance.bagTiles.filter({$0.letter == letter}).first!
                player.tiles.insert(tile)
                tile.placement = .Rack
            }
            XCTAssert(player.rackTiles.count == 7)
            
            let fixedLetters: [(Int, Character)] = []
            var results = [String]()
            dawg.anagramsOf(instance.lettersIn(player.rackTiles),
                length: player.rackTiles.count, prefix: [Character](), fixedLetters: fixedLetters,
                fixedCount: 0, root: dawg.rootNode, results: &results)
            
            print(player.rackTiles)
            
            if dawg.lookup("disarms") == false { assert(false) }
            XCTAssert(true)
            XCTAssert(results.contains("disarms"))
            
            let possibles = instance.possibleMoves(forPlayer: player, dawg: dawg)
            
            print("Best: \(possibles.first)")
        }
        catch {
            XCTFail("Unexpected error")
        }
        
    }
    
    func testFindPlayableBoundaries() {
        
        instance.createPlayer()
        
        instance.returnTiles(instance.player!.rackTiles, forPlayer: instance.player!)
        
        let toDraw: [Character] = ["D", "I", "S", "L", "Y", "S", "P"]
        toDraw.forEach { (letter) -> () in
            let tile = instance.bagTiles.filter({$0.letter == letter}).first!
            instance.player?.tiles.insert(tile)
            tile.placement = .Rack
        }
        
        let items: [[(Position?, Character)]] = [
            [
                (Position(horizontal: true, iterable: 2, fixed: 9), "R"),
                (Position(horizontal: true, iterable: 3, fixed: 9), "E"),
                (Position(horizontal: true, iterable: 4, fixed: 9), "S"),
                (Position(horizontal: true, iterable: 5, fixed: 9), "U"),
                (Position(horizontal: true, iterable: 6, fixed: 9), "M"),
                (Position(horizontal: true, iterable: 7, fixed: 9), "E"),
                (Position(horizontal: true, iterable: 8, fixed: 9), "S")
            ],/* [
                (Position(horizontal: false, iterable: 5, fixed: 7), "A"),
                (Position(horizontal: false, iterable: 6, fixed: 7), "R"),
                (Position(horizontal: false, iterable: 7, fixed: 7), "C"),
                (Position(horizontal: false, iterable: 8, fixed: 7), "H"),
                (Position(horizontal: false, iterable: 9, fixed: 7), "E"),
                (Position(horizontal: false, iterable: 10, fixed: 7), "R"),
                (Position(horizontal: false, iterable: 11, fixed: 7), "S"),
            ], [
                (Position(horizontal: true, iterable: 7, fixed: 7), "C"),
                (Position(horizontal: true, iterable: 8, fixed: 7), "A"),
                (Position(horizontal: true, iterable: 9, fixed: 7), "R"),
                (Position(horizontal: true, iterable: 10, fixed: 7), "D"),
            ],*/ [
                (Position(horizontal: false, iterable: 4, fixed: 10), "D"),
                (Position(horizontal: false, iterable: 5, fixed: 10), "E"),
                (Position(horizontal: false, iterable: 6, fixed: 10), "A"),
                (Position(horizontal: false, iterable: 7, fixed: 10), "D"),
                (Position(horizontal: false, iterable: 8, fixed: 10), "E"),
                (Position(horizontal: false, iterable: 9, fixed: 10), "R"),
            ]/*, [
                (Position(horizontal: true, iterable: 7, fixed: 5), "A"),
                (Position(horizontal: true, iterable: 8, fixed: 5), "R"),
                (Position(horizontal: true, iterable: 9, fixed: 5), "I"),
                (Position(horizontal: true, iterable: 10, fixed: 5), "E"),
            ]*/
        ]
        
        for positions in items {
            let boundary = Boundary(start: positions.first?.0, end: positions.last?.0)!
            positions.forEach({
                let tile = Tile($0.1, 1)
                instance.squareAt($0.0)?.tile = tile
                tile.placement = Placement.Fixed
            })
            let intersections = instance.findIntersections(forBoundary: boundary)
            XCTAssert(intersections.count == boundary.length)
            //instance.playedBoundaries.appendContentsOf(intersections)
            //instance.playedBoundaries.append(boundary)
        }
        let playableBoundaries = [Boundary]()// instance.findPlayableBoundaries(instance.playedBoundaries)
        XCTAssert(playableBoundaries.count > 0)
        
        // Now determine playable boundaries
        for row in 0..<PapyrusDimensions {
            var line = [Character]()
            for col in 0..<PapyrusDimensions {
                var letter: Character = "_"
                for boundary in playableBoundaries {
                    let position = Position(horizontal: boundary.horizontal, row: row, col: col)!
                    if boundary.contains(position) {
                        letter = instance.letterAt(position) ?? "#"
                        break
                    }
                }
                line.append(letter)
            }
            print(line)
        }
        print(playableBoundaries.count)
        
        let letters = instance.player!.rackTiles.map({$0.letter})
        
        playableBoundaries.forEach {
            let fixedLetters = instance.indexesAndCharacters(forBoundary: $0)
            var results = [String]()
            for length in 0..<letters.count {
                odawg!.anagramsOf(Array(letters[0...length]), length: length,
                    prefix: [Character](), fixedLetters: fixedLetters, fixedCount: fixedLetters.count,
                    root: odawg!.rootNode, results: &results)
            }
            if (results.count > 0) {
                print("\(fixedLetters):  \(results)")
            }
        }
        
        //XCTAssert(playableBoundaries.count == 100)
    }
}
