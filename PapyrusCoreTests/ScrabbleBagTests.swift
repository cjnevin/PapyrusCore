//
//  BagTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class ScrabbleBagTests : XCTestCase {
    var bag: Bag!
    var total: Int!
    
    override func setUp() {
        super.setUp()
        bag = ScrabbleBag()
        total = ScrabbleBag.total
    }
    
    func testBag() {
        XCTAssertEqual(bag.remaining.count, total)
        bag.draw()
        XCTAssertEqual(bag.remaining.count, total - 1)
    }
    
    func testReplace() {
        XCTAssertEqual(bag.remaining.count, total)
        bag.replace("A")
        XCTAssertEqual(bag.remaining.count, total + 1)
    }
    
    func testDraw() {
        var removed = 0
        for _ in 0..<total {
            XCTAssertNotNil(bag.draw())
            removed += 1
        }
        XCTAssertEqual(removed, total)
        XCTAssertEqual(bag.remaining.count, 0)
        XCTAssertNil(bag.draw())
    }
}