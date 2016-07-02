//
//  AnagramSingleton.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 28/05/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
@testable import AnagramDictionary
@testable import PapyrusCore

extension AnagramDictionary {
    static let singleton = AnagramDictionary.deserialize(try! Data(contentsOf: URL(fileURLWithPath: Bundle(for: SolutionTests.self).pathForResource("sowpods_anagrams", ofType: "bin")!)))
}
