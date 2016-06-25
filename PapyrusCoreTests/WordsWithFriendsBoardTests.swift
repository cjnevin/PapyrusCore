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
    }
    
    override func checkEquality(expected: Bool = true) {
        if expected {
            XCTAssertEqual(board as? WordsWithFriendsBoard, secondBoard as? WordsWithFriendsBoard)
        } else {
            XCTAssertNotEqual(board as? WordsWithFriendsBoard, secondBoard as? WordsWithFriendsBoard)
        }
    }
}
