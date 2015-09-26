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
    
    let dawg = Dawg.load(NSBundle(forClass: DawgTests.self).pathForResource("sowpods", ofType: "bin")!)!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func chars(str: String) -> [Character] {
        return Array(str.characters)
    }
    
    func testAnagrams() {
        measureBlock { () -> Void in
            var fixedLetters = [Int: Character]()
            
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("sc?resheets"), wordLength: 11).contains("scoresheets"))
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("cat"), wordLength: 3).sort() == ["act", "cat"])
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("CAT"), wordLength: 3).sort() == ["act", "cat"])
            
            fixedLetters[2] = "r"
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("tac"), wordLength: 4, filledLetters: fixedLetters) == ["cart"])
            
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("tacposw"), wordLength: 3, filledLetters: fixedLetters).sort() ==
                ["car", "cor", "oar", "par", "sar", "tar", "tor", "war"])
            
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("patiers"), wordLength: 8, filledLetters: fixedLetters) == ["partiers"])
            
            fixedLetters[0] = "c"
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("aeiou"), wordLength: 3, filledLetters: fixedLetters).sort() == ["car", "cor", "cur"])
            
            XCTAssert(self.dawg.lookup("cart") == true)
            XCTAssert(self.dawg.lookup("xyza") == false)
            XCTAssert(self.dawg.lookup("CAT") == true)
        }
    }
}
