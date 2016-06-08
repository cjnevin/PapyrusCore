//
//  LookupSingleton.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 8/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
@testable import PapyrusCore

extension Lookup {
    static let singleton = Lookup(dictionaryFilename: "sowpods",
                                  anagramFilename: "sowpods_anagrams",
                                  bundle: NSBundle(forClass: DawgTests.self))!
}