//
//  WordTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 10/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class WordTests : XCTestCase {
    
    var word: WordRepresentation!
    
    override func setUp() {
        super.setUp()
        word = Word(word: "TEST", x: 4, y: 6, horizontal: true)
    }
    
    override func tearDown() {
        super.tearDown()
        word = nil
    }
    
    func testHorizontal() {
        XCTAssertEqual(word.horizontal, true)
    }
    
    func testX() {
        XCTAssertEqual(word.x, 4)
    }
    
    func testY() {
        XCTAssertEqual(word.y, 6)
    }
    
    func testWord() {
        XCTAssertEqual(word.word, "TEST")
    }
    
    func testLength() {
        XCTAssertEqual(word.length(), 4)
    }
    
    func testToPositions() {
        let positions: [WordPosition] = [(4, 6), (5, 6), (6, 6), (7, 6)]
        XCTAssertEqual(word.toPositions().map({ $0.x }), positions.map({ $0.x }))
        XCTAssertEqual(word.toPositions().map({ $0.y }), positions.map({ $0.y }))
    }
    
    func testPositionForIndex() {
        XCTAssertEqual(word.position(forIndex: 3).x, 7)
        XCTAssertEqual(word.position(forIndex: 3).y, 6)
    }
    
}
