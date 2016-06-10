//
//  PlayerTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 10/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class ComputerPlayerTests : HumanPlayerTests {
    override func setUp() {
        super.setUp()
        player = Computer(difficulty: .Easy, rack: charactersForRack(rackTiles()), score: 0, solves: [], consecutiveSkips: 0)
    }
    
    func testDifficulty() {
        XCTAssertEqual((player as! Computer).difficulty, Difficulty.Easy)
    }
}