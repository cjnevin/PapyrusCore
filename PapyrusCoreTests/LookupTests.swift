//
//  LookupTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 10/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class LookupTests: XCTestCase {
    func testLookupAnagramFilenameValidReturnsObject() {
        XCTAssertNotNil(Lookup(dictionaryFilename: "sowpods", anagramFilename: "sowpods_anagrams", bundle: NSBundle(forClass: LookupTests.self)))
    }
    
    func testLookupAnagramFilenameInvalidReturnsNil() {
        XCTAssertNil(Lookup(dictionaryFilename: "sowpods", anagramFilename: "fake", bundle: NSBundle(forClass: LookupTests.self)))
    }
    
    func testLookupDictionaryFilenameInvalidReturnsNil() {
        XCTAssertNil(Lookup(dictionaryFilename: "fake", anagramFilename: "sowpods_anagrams", bundle: NSBundle(forClass: LookupTests.self)))
    }
}