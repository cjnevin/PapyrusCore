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
    func testMeasureCombos() {
        measureBlock {
            for _ in 0..<100 {
                for n in 2..<8 {
                    ["a", "b", "c", "d", "e", "f", "g"].combos(n)
                }
            }
        }
    }
    
    func testMeasureCombinations() {
        measureBlock {
            for _ in 0..<100 {
                for n in 2..<8 {
                    ["a", "b", "c", "d", "e", "f", "g"].combinations(n)
                }
            }
        }
    }
    
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
    
    func testReplace() {
        var bag = Bag(distribution: SuperScrabbleDistribution())
        XCTAssertEqual(bag.remaining.count, bag.distribution.total)
        bag.replace("A")
        XCTAssertEqual(bag.remaining.count, bag.distribution.total + 1)
    }
    
    func testLetterPoints() {
        let bag = Bag(distribution: SuperScrabbleDistribution())
        XCTAssertEqual(bag.letterPoints, bag.distribution.letterPoints)
    }
    
    func testDraw() {
        var bag = Bag(distribution: SuperScrabbleDistribution())
        var removed = 0
        for _ in 0..<bag.distribution.total {
            XCTAssertNotNil(bag.draw())
            removed += 1
        }
        XCTAssertEqual(removed, bag.distribution.total)
        XCTAssertEqual(bag.remaining.count, 0)
        XCTAssertNil(bag.draw())
    }
}