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
        
        dawg.anagramsOf(Array("cat".characters), length: 3, prefix: rootPrefix,
            fixedLetters: fixedLetters, fixedCount: 0, root: dawg.rootNode, results: &results)
        XCTAssert(results.mapFilter({$0}).sort() == ["act", "cat"])
        
        fixedLetters.append((2, "r"))
        results.removeAll()
        dawg.anagramsOf(Array("tac".characters), length: 4, prefix: rootPrefix,
            fixedLetters: fixedLetters, fixedCount: 1, root: dawg.rootNode, results: &results)
        XCTAssert(results.mapFilter({$0}) == ["cart"])
        
        results.removeAll()
        dawg.anagramsOf(Array("tacposw".characters), length: 3, prefix: rootPrefix,
            fixedLetters: fixedLetters, fixedCount: 1, root: dawg.rootNode, results: &results)
        XCTAssert(results.mapFilter({$0}).sort() == ["car", "cor", "oar", "par", "sar", "tar", "tor", "war"])
        
        results.removeAll()
        dawg.anagramsOf(Array("patiers".characters), length: 8, prefix: rootPrefix,
            fixedLetters: fixedLetters, fixedCount: 1, root: dawg.rootNode, results: &results)
        XCTAssert(results.mapFilter({$0}) == ["partiers"])
        
        results.removeAll()
        fixedLetters.append((0, "c"))
        dawg.anagramsOf(Array("aeiou".characters), length: 3, prefix: rootPrefix,
            fixedLetters: fixedLetters, fixedCount: 1, root: dawg.rootNode, results: &results)
        XCTAssert(results.mapFilter({$0}).sort() == ["car", "cor", "cur"])
        
        XCTAssert(!dawg.lookup(""))
        XCTAssert(dawg.lookup("cat"))
        XCTAssert(!dawg.lookup("catx"))
        XCTAssert(!dawg.lookup("actper"))
        XCTAssert(dawg.lookup("periodontal"))
        XCTAssert(dawg.lookup("partier"))
        XCTAssert(!dawg.lookup("SUPERCALIFRAGILISTICEXPIALIDOCIOUS"))
    }
}
