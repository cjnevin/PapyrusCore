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
        config = SuperScrabbleBoardConfig()
        board = Board(config: config)
    }
}
