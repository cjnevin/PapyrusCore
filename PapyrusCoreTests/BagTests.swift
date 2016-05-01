//
//  BagTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class BagTests : XCTestCase {
    func testBag() {
        var bag = Bag()
        XCTAssertEqual(bag.remaining.count, 100)
        bag.draw()
        XCTAssertEqual(bag.remaining.count, 99)
    }
}