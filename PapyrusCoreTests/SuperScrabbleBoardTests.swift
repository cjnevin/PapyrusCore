//
//  SuperScrabbleBoardTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 10/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class SuperScrabbleBoardTests: ScrabbleBoardTests {
    override func setUp() {
        super.setUp()
        let superScrabbleBoard = SuperScrabbleBoard()
        board = superScrabbleBoard
        secondBoard = SuperScrabbleBoard()
        center = superScrabbleBoard.center
        centerPosition = Position(x: center, y: center)
    }
    
    override func checkEquality(_ expected: Bool = true) {
        if expected {
            XCTAssertEqual(board as? SuperScrabbleBoard, secondBoard as? SuperScrabbleBoard)
        } else {
            XCTAssertNotEqual(board as? SuperScrabbleBoard, secondBoard as? SuperScrabbleBoard)
        }
    }
}
