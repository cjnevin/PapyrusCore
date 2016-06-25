//
//  AnagramSingleton.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 28/05/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
@testable import PapyrusCore

extension AnagramDictionary {
    static let singleton = AnagramDictionary.deserialize(NSData(contentsOfFile: NSBundle(forClass: SolutionTests.self).pathForResource("sowpods_anagrams", ofType: "bin")!)!)
}