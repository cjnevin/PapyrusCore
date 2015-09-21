//
//  PapyrusTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 11/09/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class PapyrusTests: XCTestCase {

    let instance = Papyrus()
    var dawg: Dawg {
        if Papyrus.dawg == nil {
            Papyrus.dawg = Dawg.load(NSBundle(forClass: PapyrusTests.self).pathForResource("output", ofType: "json")!)!
        }
        return Papyrus.dawg!
    }
    
    override func setUp() {
        super.setUp()
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
    
    func testPrintBoard() {
        let playedBoundaries = instance.filledBoundaries()
        // Now determine playable boundaries
        for row in 0..<PapyrusDimensions {
            var line = [Character]()
            for col in 0..<PapyrusDimensions {
                var letter: Character = "_"
                for boundary in playedBoundaries {
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
    }
    
    func testPlayerTiles() {
        XCTAssert(instance.squareAt(nil) == nil)
        XCTAssert(instance.squareAt(Position(horizontal: false, iterable: 0, fixed: 0)) != nil)
        
        let totalTiles = TileConfiguration.map({$0.0}).reduce(0, combine: +)
        XCTAssert(instance.tiles.count == totalTiles)
        instance.createPlayer()
        XCTAssert(instance.bagTiles().count == totalTiles - PapyrusRackAmount)
        
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
        XCTAssert(instance.bagTiles().count == totalTiles - (PapyrusRackAmount * 2))
        
        player2.returnTiles(player2.rackTiles)
        XCTAssert(player2.tiles.count == 0, "Expected tiles to be empty")
        XCTAssert(player2.rackTiles.count == 0, "Expected rack to be empty")
        XCTAssert(instance.bagTiles().count == totalTiles - PapyrusRackAmount, "Expected bag to be missing first players rack tiles")
        
        player2.replenishTiles(fromBag: instance.bagTiles())
        XCTAssert(player2.rackTiles.count == PapyrusRackAmount, "Expected rack to contain default amount")
        XCTAssert(instance.bagTiles().count == totalTiles - (PapyrusRackAmount * 2), "Expected bag to be missing both players rack tiles")
        
        instance.nextPlayer()
        XCTAssert(instance.player == player, "Expected to return to first player")
        
        player.returnTiles(player.rackTiles)
        XCTAssert(player.rackTiles.count == 0)
        
        instance.draw(player)
        XCTAssert(player.rackTiles.count == PapyrusRackAmount)
        
        player.returnTiles([player.rackTiles.first!])
        XCTAssert(player.rackTiles.count == PapyrusRackAmount - 1)
    }
    
    func testBoundaryMethods() {
        XCTAssert(instance.previousWhileEmpty(Position(horizontal: true, iterable: 5, fixed: 5))?.iterable == 0)
        XCTAssert(instance.nextWhileEmpty(Position(horizontal: true, iterable: 5, fixed: 5))?.iterable == PapyrusDimensions - 1)
        XCTAssert(instance.previousWhileFilled(Position(horizontal: true, iterable: 5, fixed: 5)) == nil)
        XCTAssert(instance.nextWhileFilled(Position(horizontal: true, iterable: 5, fixed: 5)) == nil)
        
        let tile = instance.bagTiles().first!
        let pos = Position(horizontal: true, iterable: 5, fixed: 5)!
        tile.placement = Placement.Board
        instance.squareAt(pos)?.tile = tile
        XCTAssert(instance.nextWhileFilled(pos) == pos)
        XCTAssert(instance.nextWhileEmpty(pos) == nil)
        XCTAssert(instance.nextWhileEmpty(pos.positionWithIterable(1))?.iterable == 4)
        
        let tile2 = instance.bagTiles().first!
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
        XCTAssert(instance.player?.rackTiles.count == PapyrusRackAmount, "Expected 7 rack tiles")
        XCTAssert(instance.previousWhileTilesInRack(Position(horizontal: true, row: 7, col: 7)!)?.iterable == 1, "Expected (7)-7 to land on square 1")
        XCTAssert(instance.nextWhileTilesInRack(Position(horizontal: true, row: 7, col: 7)!)?.iterable == PapyrusDimensions - 2, "Expected (7)+7 to land on square 13")
    }
    
    func testPlayableBoundariesMethod() {
        /*instance.createPlayer()
        XCTAssert(instance.player?.rackTiles.count == 7, "Expected 7 rack tiles")
        XCTAssert(PapyrusDimensions == 15, "Expected 15")
        
        let expectations = [7, 14, 20, 25, 29, 32, 34, 35,
            34, 32, 29, 25, 20, 14, 7]
        
        (0..<PapyrusDimensions).forEach { (index) -> () in
            let position = Position(horizontal: true, iterable: index, fixed: 7)!
            let tile = Tile("T", 1)
            let boundary = Boundary(start: position, end: position)!
            instance.squareAt(position)!.tile = tile
            
            let boundaries = instance.playableBoundaries(forBoundary: boundary)!
            XCTAssert(boundaries.count == expectations[index],
                "Expected \(expectations[index]) boundaries got \(boundaries.count)")
            
            instance.squareAt(position)!.tile = nil
        }*/
    }
    
    func testCardPlay() {
        dawg
        instance.createPlayer()
        let player = instance.player!
        player.difficulty = .Champion
        player.returnTiles(player.rackTiles)
        
        let toDraw: [Character] = ["c", "a", "r", "d", "d", "i", "s"]
        toDraw.forEach { (letter) -> () in
            let tile = instance.bagTiles().filter({$0.letter == letter}).first!
            player.tiles.insert(tile)
            tile.placement = .Rack
        }
        
        let positions: [(Position?, Character)] = [
            (Position(horizontal: true, iterable: 4, fixed: 7), "c"),
            (Position(horizontal: true, iterable: 5, fixed: 7), "a"),
            (Position(horizontal: true, iterable: 6, fixed: 7), "r"),
            (Position(horizontal: true, iterable: 7, fixed: 7), "d")
        ]
        
        let boundary = Boundary(start: positions.first?.0, end: positions.last?.0)!
        positions.forEach({ (position, character) -> () in
            let tile = player.tiles.filter({$0.letter == character}).first!
            instance.squareAt(position)?.tile = tile
            tile.placement = Placement.Board
        })
        
        do {
            let move = try instance.getMove(forBoundary: boundary)
            player.submit(move)
            XCTAssert(player.rackTiles.count == 3)
            XCTAssert(instance.fixedTiles().count == move.word.characters.count)
            testPrintBoard()
            
            let armsToDraw: [Character] = ["a", "r", "m", "s"]
            armsToDraw.forEach { (letter) -> () in
                let tile = instance.bagTiles().filter({$0.letter == letter}).first!
                player.tiles.insert(tile)
                tile.placement = .Rack
            }
            XCTAssert(player.rackTiles.count == PapyrusRackAmount)
            
            var results = [String]()
            dawg.anagramsOf(instance.lettersIn(player.rackTiles),
                length: player.rackTiles.count, results: &results)
            
            if dawg.lookup("disarms") == false { assert(false) }
            XCTAssert(results.contains("disarms"))
            XCTAssert(true)
            
            let possibles = try instance.getAIMoves()
            if let best = possibles.first {
                XCTAssert(best.word.word == "disarms")
                print("Best: \(best)")
                player.submit(best)
                XCTAssert(player.rackTiles.count == 0)
                testPrintBoard()
                
                var allTiles = (toDraw + armsToDraw).sort()
                XCTAssert(instance.fixedTiles().mapFilter({$0.letter}).sort() == allTiles)
                
                instance.draw(player)
                XCTAssert(player.rackTiles.count == PapyrusRackAmount)
                
                instance.nextPlayer()
                player.returnTiles(player.rackTiles)
                XCTAssert(player.rackTiles.count == 0)
                
                let dogToDraw: [Character] = ["d","o","g"]
                dogToDraw.forEach { (letter) -> () in
                    let tile = instance.bagTiles().filter({$0.letter == letter}).first!
                    player.tiles.insert(tile)
                    tile.placement = .Rack
                }
                
                let dogPossibles = try instance.getAIMoves()
                for possible in dogPossibles {
                    if possible.word.word == "dog" {
                        if possible.intersections.count == 1 {
                            if possible.intersections[0].word == "cards" {
                                player.submit(possible)
                                print("Dog: \(possible)")
                                allTiles += possible.word.tiles.mapFilter({$0.letter})
                                allTiles.sortInPlace()
                                XCTAssert(instance.fixedTiles().mapFilter({$0.letter}).sort() == allTiles)
                                testPrintBoard()
                                return
                            }
                        }
                    }
                }
                XCTFail("Broken possibilities")
            }
        }
        catch {
            XCTFail("Unexpected error \(error)")
        }
        
    }
}
