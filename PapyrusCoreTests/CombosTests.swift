//
//  CombosTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 23/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class CombosTests: XCTestCase {
    func testMeasureCombinations() {
        measure {
            for _ in 0..<100 {
                for n in 2..<8 {
                    _ = ["a", "b", "c", "d", "e", "f", "g"].combinations(n)
                }
            }
        }
    }
    
    func testCombinations() {
        XCTAssertEqual(["a", "b", "c", "d"].combinations(3).flatMap({ $0 }),
                       ["a", "b", "c", "a", "b", "d", "a", "c", "d", "b", "c", "d"])
    }
}
