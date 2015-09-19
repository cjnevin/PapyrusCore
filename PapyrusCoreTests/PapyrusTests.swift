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

    var odawg: Dawg?
    let instance = Papyrus()
    //let lexicon: Lexicon = Lexicon(withFilePath: NSBundle(forClass: LexiconTests.self).pathForResource("CSW12", ofType: "plist")!)!
    
    override func setUp() {
        super.setUp()
        
        let array: NSArray = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile:
            NSBundle(forClass: PapyrusTests.self).pathForResource("output", ofType: "json")!)!,
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
        
        instance.createPlayer()
        
        let player = instance.player!
        player.difficulty = .Champion
        
        instance.returnTiles(player.rackTiles, forPlayer: player)
        
        let toDraw: [Character] = ["c", "a", "r", "d", "d", "i", "s"]
        toDraw.forEach { (letter) -> () in
            let tile = instance.bagTiles.filter({$0.letter == letter}).first!
            player.tiles.insert(tile)
            tile.placement = .Rack
        }
        
        let positions: [(Position?, Character)] =
        [
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
            let dawg = odawg!
            
            try instance.play(boundary, submit: true, dawg: dawg)
            XCTAssert(player.rackTiles.count == 3)
            print(player.rackTiles)
            
            let armsToDraw: [Character] = ["a", "r", "m", "s"]
            armsToDraw.forEach { (letter) -> () in
                let tile = instance.bagTiles.filter({$0.letter == letter}).first!
                player.tiles.insert(tile)
                tile.placement = .Rack
            }
            XCTAssert(player.rackTiles.count == 7)
            
            var results = [String]()
            dawg.anagramsOf(instance.lettersIn(player.rackTiles),
                length: player.rackTiles.count, results: &results)
            
            print(player.rackTiles)
            
            if dawg.lookup("disarms") == false { assert(false) }
            XCTAssert(true)
            XCTAssert(results.contains("disarms"))
            
            let possibles = instance.possibleMoves(forPlayer: player, dawg: dawg)
            if let best = possibles.first {
                print("Best: \(best)")
                instance.submitPossibility(best)
                
                XCTAssert(player.rackTiles.count == 0)
                
                print(instance.fixedTiles().mapFilter({$0.letter}).sort())
                var allTiles = (toDraw + armsToDraw).sort()
                XCTAssert(instance.fixedTiles().mapFilter({$0.letter}).sort() == allTiles)
                
                instance.draw(player)
                XCTAssert(player.rackTiles.count == 7)
                instance.returnTiles(player.rackTiles, forPlayer: player)
                XCTAssert(player.rackTiles.count == 0)
                
                let dogToDraw: [Character] = ["d","o","g"]
                dogToDraw.forEach { (letter) -> () in
                    let tile = instance.bagTiles.filter({$0.letter == letter}).first!
                    player.tiles.insert(tile)
                    tile.placement = .Rack
                }
                let dogPossibles = instance.possibleMoves(forPlayer: player, dawg: dawg)
                for possible in dogPossibles {
                    if possible.move.word == "dog" {
                        if possible.intersections.count == 1 {
                            if possible.intersections[0].word == "cards" {
                                instance.submitPossibility(possible)
                                print(possible)
                                allTiles += possible.move.tiles.mapFilter({$0.letter})
                                allTiles.sortInPlace()
                                XCTAssert(instance.fixedTiles().mapFilter({$0.letter}).sort() == allTiles)
                                break
                            }
                        }
                    }
                }
                
            }
        }
        catch {
            XCTFail("Unexpected error")
        }
        
    }
}
