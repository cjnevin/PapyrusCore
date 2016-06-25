//
//  SuperScrabbleBagTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 23/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class WordsWithFriendsBagTests: ScrabbleBagTests {
    override func setUp() {
        super.setUp()
        bag = WordsWithFriendsBag()
        total = WordsWithFriendsBag.total
    }
}
