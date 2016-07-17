//
//  WordfeudBoardTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 10/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class WordfeudBoardTests: ScrabbleBoardTests {
    override func setUp() {
        super.setUp()
        let wordfeudBoard = WordfeudBoard()
        board = wordfeudBoard
        secondBoard = WordfeudBoard()
        center = wordfeudBoard.center
        centerPosition = Position(x: center, y: center)
    }
    
    override func checkEquality(_ expected: Bool = true) {
        if expected {
            XCTAssertEqual(board as? WordfeudBoard, secondBoard as? WordfeudBoard)
        } else {
            XCTAssertNotEqual(board as? WordfeudBoard, secondBoard as? WordfeudBoard)
        }
    }
}
