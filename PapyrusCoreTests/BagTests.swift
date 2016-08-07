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
    var bag: Bag!
    var total: Int!
    
    override func setUp() {
        super.setUp()
        bag = Bag(vowels: ["a", "e", "i", "o", "u"],
                  letters: ["_": 2, "a": 9, "b": 2, "c": 2, "d": 4,
                            "e": 12, "f": 2, "g": 3, "h": 2, "i": 9,
                            "j": 1, "k": 1, "l": 4, "m": 2, "n": 6,
                            "o": 8, "p": 2, "q": 1, "r": 6, "s": 4,
                            "t": 6, "u": 4, "v": 2, "w": 2, "x": 1,
                            "y": 2, "z": 1],
                  letterPoints: ["_": 0, "a": 1, "b": 3, "c": 3, "d": 2,
                                 "e": 1, "f": 4, "g": 2, "h": 4, "i": 1,
                                 "j": 8, "k": 5, "l": 1, "m": 3, "n": 1,
                                 "o": 1, "p": 3, "q": 10, "r": 1, "s": 1,
                                 "t": 1, "u": 1, "v": 4, "w": 4, "x": 8,
                                 "y": 4, "z": 10])
        total = bag.total
    }
    
    func testBag() {
        XCTAssertEqual(bag.remaining.count, total)
        XCTAssertNotNil(bag.draw())
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
