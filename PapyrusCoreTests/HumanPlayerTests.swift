//
//  PlayerTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 10/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class HumanPlayerTests : XCTestCase {
    
    var player: Player!
    let board = ScrabbleBoard()

    func rackTiles() -> [RackTile] {
        return [(Game.blankLetter, true), ("A", false), ("B", false), ("C", false), ("D", false), ("E", false), ("F", false)]
    }
    
    override func setUp() {
        super.setUp()
        player = Human(rackTiles: rackTiles())
        _ = Human(rack: [], score: 0, solves: [], consecutiveSkips: 0)
    }
    
    override func tearDown() {
        super.tearDown()
        player = nil
    }
    
    func testBlank() {
        // Sorting only works if blank is _
        XCTAssertEqual(Game.blankLetter, "_")
    }
    
    func sortRack(_ rack: [RackTile]) -> [RackTile] {
        return rack.sorted(isOrderedBefore: { $0.letter < $1.letter })
    }
    
    func charactersForRack(_ rack: [RackTile]) -> [Character] {
        return rack.map({ $0.letter })
    }
    
    func sortedCharactersForRack(_ rack: [RackTile]) -> [Character] {
        return sortRack(rack).map({ $0.letter })
    }
    
    func testRack() {
        XCTAssertEqual(sortedCharactersForRack(player.rack), sortedCharactersForRack(rackTiles()))
    }
    
    func testScoreIsZero() {
        XCTAssertEqual(player.score, 0)
    }
    
    func testSolvesIsEmpty() {
        XCTAssertTrue(player.solves.isEmpty)
    }
    
    func testConsecutiveSkips() {
        XCTAssertEqual(player.consecutiveSkips, 0)
    }
    
    func testShuffle() {
        let originalRack = charactersForRack(player.rack)
        while charactersForRack(player.rack) == originalRack {
            player.shuffle()
        }
        XCTAssertTrue(true)
    }
    
    func testSwapped() {
        player.swapped(tiles: ["A"], with: ["G"])
        XCTAssertEqual(sortedCharactersForRack(player.rack)[5], "G")
    }
    
    func testUpdateBlank() {
        player.updateBlank(to: "Z")
        XCTAssertEqual(sortedCharactersForRack(player.rack)[6], "Z")
    }
    
    func testRemoveLetter() {
        let (removed, blank) = player.remove(letter: "F")
        XCTAssert(removed)
        XCTAssertFalse(blank)
        XCTAssertEqual(player.rack.count, 6)
        XCTAssertEqual(sortedCharactersForRack(player.rack)[4], "E")
    }
    
    func testRemoveBlank() {
        let (removed, blank) = player.remove(letter: "Z")
        XCTAssert(removed)
        XCTAssert(blank)
        XCTAssertEqual(player.rack.count, 6)
        XCTAssertEqual(sortedCharactersForRack(player.rack).last, "F")
    }
    
    func testPlayed() {
        let solution = Solution(word: "BEAT", x: board.center, y: board.center, horizontal: true, score: 6, intersections: [], blanks: [])
        player.played(solution: solution, tiles: ["B", "E", "A"])
        XCTAssertEqual(player.rack.count, 4)
        XCTAssertEqual(player.score, 6)
    }
}
