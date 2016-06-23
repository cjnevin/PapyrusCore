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
    
    let dawg = Dawg.singleton

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
            
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("sc\(Game.blankLetter)resheets"), wordLength: 11, blankLetter: Game.blankLetter)!.contains("scoresheets"))
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("cat"), wordLength: 3, blankLetter: Game.blankLetter)!.sort() == ["act", "cat"])
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("CAT"), wordLength: 3, blankLetter: Game.blankLetter)!.sort() == ["act", "cat"])
            
            fixedLetters[2] = "r"
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("tac"), wordLength: 4, filledLetters: fixedLetters, blankLetter: Game.blankLetter)! == ["cart"])
            
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("tacposw"), wordLength: 3, filledLetters: fixedLetters, blankLetter: Game.blankLetter)!.sort() ==
                ["car", "cor", "oar", "par", "sar", "tar", "tor", "war"])
            
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("patiers"), wordLength: 8, filledLetters: fixedLetters, blankLetter: Game.blankLetter)! == ["partiers"])
            
            fixedLetters[0] = "c"
            XCTAssert(self.dawg.anagrams(withLetters: self.chars("aeiou"), wordLength: 3, filledLetters: fixedLetters, blankLetter: Game.blankLetter)!.sort() == ["car", "cor", "cur"])
            
            XCTAssert(self.dawg.lookup("cart") == true)
            XCTAssert(self.dawg.lookup("xyza") == false)
            XCTAssert(self.dawg.lookup("CAT") == true)
            
            //XCTAssert(self.dawg.rootNode == self.dawg.rootNode)
            
            XCTAssert(Dawg.load("") == nil)
            
        }
    }
}
