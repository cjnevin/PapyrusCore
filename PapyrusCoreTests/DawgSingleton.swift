//
//  DawgSingleton.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

extension Dawg {
    static let singleton = Dawg.load(NSBundle(forClass: DawgTests.self).pathForResource("sowpods", ofType: "bin")!)!
}