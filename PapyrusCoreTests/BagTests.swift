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
        XCTAssertEqual(bag.remaining.count, bag.distribution.total)
        bag.draw()
        XCTAssertEqual(bag.remaining.count, bag.distribution.total - 1)
    }
    
    func testSuperBag() {
        var bag = Bag(distribution: SuperScrabbleDistribution())
        XCTAssertEqual(bag.remaining.count, bag.distribution.total)
        bag.draw()
        XCTAssertEqual(bag.remaining.count, bag.distribution.total - 1)
    }
}