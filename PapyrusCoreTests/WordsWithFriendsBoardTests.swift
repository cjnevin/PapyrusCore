//
//  SuperScrabbleBoardTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 10/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class WordsWithFriendsBoardTests: ScrabbleBoardTests {
    override func setUp() {
        super.setUp()
        let wordsWithFriendsBoard = WordsWithFriendsBoard()
        board = wordsWithFriendsBoard
        secondBoard = WordsWithFriendsBoard()
        center = wordsWithFriendsBoard.center
        centerPosition = Position(x: center, y: center)
        bottomEdgePosition = Position(x: board.size - 2, y: board.size - 2)
    }
    
    override func checkEquality(_ expected: Bool = true) {
        if expected {
            XCTAssertEqual(board as? WordsWithFriendsBoard, secondBoard as? WordsWithFriendsBoard)
        } else {
            XCTAssertNotEqual(board as? WordsWithFriendsBoard, secondBoard as? WordsWithFriendsBoard)
        }
    }
}
