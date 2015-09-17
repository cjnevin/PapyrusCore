//
//  LexiconTests.swift
//  Papyrus
//
//  Created by Chris Nevin on 13/09/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class LexiconTests: XCTestCase {
    
    var odawg: Dawg?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let array: NSArray = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: NSBundle(forClass: LexiconTests.self).pathForResource("output", ofType: "json")!)!,
            options: NSJSONReadingOptions.AllowFragments) as! NSArray
        var cached = [Int: DawgNode]()
        let root = DawgNode.deserialize(array, cached: &cached)
        odawg = Dawg(withRootNode: root)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAnagrams() {
        var fixedLetters: [(Int, Character)] = []
        var rootPrefix = [Character]()
        var results = [String]()
        let dawg = odawg!
        
        dawg.anagramsOf(Array("CAT".characters), length: 3, prefix: rootPrefix,
            fixedLetters: fixedLetters, fixedCount: 0, root: dawg.rootNode, results: &results)
        XCTAssert(results.mapFilter({$0}).sort() == ["ACT", "CAT"])
        
        fixedLetters.append((2, "R"))
        results.removeAll()
        dawg.anagramsOf(Array("TAC".characters), length: 4, prefix: rootPrefix,
            fixedLetters: fixedLetters, fixedCount: 1, root: dawg.rootNode, results: &results)
        XCTAssert(results.mapFilter({$0}) == ["CART"])
        
        results.removeAll()
        dawg.anagramsOf(Array("TACPOSW".characters), length: 3, prefix: rootPrefix,
            fixedLetters: fixedLetters, fixedCount: 1, root: dawg.rootNode, results: &results)
        XCTAssert(results.mapFilter({$0}).sort() == ["CAR", "COR", "OAR", "PAR", "SAR", "TAR", "TOR", "WAR"])
        
        results.removeAll()
        dawg.anagramsOf(Array("PATIERS".characters), length: 8, prefix: rootPrefix,
            fixedLetters: fixedLetters, fixedCount: 1, root: dawg.rootNode, results: &results)
        XCTAssert(results.mapFilter({$0}) == ["PARTIERS"])
        
        results.removeAll()
        fixedLetters.append((0, "C"))
        dawg.anagramsOf(Array("AEIOU".characters), length: 3, prefix: rootPrefix,
            fixedLetters: fixedLetters, fixedCount: 1, root: dawg.rootNode, results: &results)
        XCTAssert(results.mapFilter({$0}).sort() == ["CAR", "COR", "CUR"])
    }

    func wrappedDefined(str: String) -> Bool {
        return odawg?.lookup(str) == true
    }
    
    func testDefinitions() {
        XCTAssert(!wrappedDefined(""))
        XCTAssert(wrappedDefined("CAT"))
        XCTAssert(!wrappedDefined("CATX"))
        XCTAssert(!wrappedDefined("ACTPER"))
        XCTAssert(wrappedDefined("PERIODONTAL"))
        XCTAssert(wrappedDefined("PARTIER"))
        XCTAssert(!wrappedDefined("SUPERCALIFRAGILISTICEXPIALIDOCIOUS"))
    }
    
}
