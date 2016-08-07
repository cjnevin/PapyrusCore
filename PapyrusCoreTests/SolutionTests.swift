//
//  SolutionTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 10/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class SolutionTests : WordTests {
    
    var intersection: PapyrusCore.Word!
    
    override func setUp() {
        super.setUp()
        intersection = Word(word: "CAT", x: 7, y: 4, horizontal: false)
        
        _ = Solution(word: intersection, score: 0, intersections: [], blanks: [])
        
        word = Solution(word: word.word, x: word.x, y: word.y, horizontal: word.horizontal, score: 0, intersections: [intersection], blanks: [])
    }
    
    override func testEqual() {
        let comparison = Solution(word: word.word, x: word.x, y: word.y, horizontal: word.horizontal, score: 0, intersections: [intersection], blanks: [])
        XCTAssertEqual(comparison, (word as! Solution))
    }
    
    override func testNotEqual() {
        let comparison = Solution(word: "RAT", x: word.x, y: word.y, horizontal: word.horizontal, score: 0, intersections: [intersection], blanks: [])
        XCTAssertNotEqual(comparison, (word as! Solution))
    }
    
    func getXs(_ positions: [Position]) -> [Int] {
        return Array(Set(positions.map({ $0.x }))).sorted()
    }
    
    func getYs(_ positions: [Position]) -> [Int] {
        return Array(Set(positions.map({ $0.y }))).sorted()
    }
    
    func testGetPositions() {
        let positions = word.toPositions() + intersection.toPositions()
        let gotPositions = (word as! Solution).getPositions()
        XCTAssertEqual(getXs(positions), getXs(gotPositions))
        XCTAssertEqual(getYs(positions), getYs(gotPositions))
    }
}
