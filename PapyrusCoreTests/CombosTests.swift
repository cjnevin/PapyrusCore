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
    func testMeasureCombos() {
        measure {
            for _ in 0..<100 {
                for n in 2..<8 {
                    let _ = ["a", "b", "c", "d", "e", "f", "g"].combos(n)
                }
            }
        }
    }
    
    func testMeasureCombinations() {
        measure {
            for _ in 0..<100 {
                for n in 2..<8 {
                    let _ = ["a", "b", "c", "d", "e", "f", "g"].combinations(n)
                }
            }
        }
    }
    
}
