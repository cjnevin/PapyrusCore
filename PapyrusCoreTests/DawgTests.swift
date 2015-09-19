//
//  DawgTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 16/09/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class DawgTests: XCTestCase {
    
    var odawg: Dawg?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let path = NSBundle(forClass: DawgTests.self).pathForResource("output", ofType: "json")!
        self.odawg = Dawg.load(path)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAnagrams() {
        let dawg = odawg!
        
        measureBlock { () -> Void in
            var fixedLetters = [Int: Character]()
            var results = [String]()
            
            dawg.anagramsOf(Array("cat".characters), length: 3,
                results: &results)
            XCTAssert(results.mapFilter({$0}).sort() == ["act", "cat"])
            
            fixedLetters[2] = "r"
            results.removeAll()
            dawg.anagramsOf(Array("tac".characters), length: 4,
                filledLetters: fixedLetters, results: &results)
            XCTAssert(results == ["cart"])
            
            results.removeAll()
            dawg.anagramsOf(Array("tacposw".characters), length: 3,
                filledLetters: fixedLetters, results: &results)
            XCTAssert(results.sort() == ["car", "cor", "oar", "par", "sar", "tar", "tor", "war"])
            
            results.removeAll()
            dawg.anagramsOf(Array("patiers".characters), length: 8,
                filledLetters: fixedLetters, results: &results)
            XCTAssert(results == ["partiers"])
            
            results.removeAll()
            fixedLetters[0] = "c"
            dawg.anagramsOf(Array("aeiou".characters), length: 3,
                filledLetters: fixedLetters, results: &results)
            XCTAssert(results.sort() == ["car", "cor", "cur"])
            
            XCTAssert(dawg.lookup("cart") == true)
            XCTAssert(dawg.lookup("xyza") == false)
            XCTAssert(dawg.lookup("CAT") == true)
        }
    }
}
