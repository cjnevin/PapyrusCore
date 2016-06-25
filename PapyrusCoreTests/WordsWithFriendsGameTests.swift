//
//  GameTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class WordsWithFriendsGameTests: ScrabbleGameTests {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        bag = WordsWithFriendsBag()
        board = WordsWithFriendsBoard()
        gameType = .WordsWithFriends
        total = WordsWithFriendsBag.total
    }
}
