//
//  Dictionary+Tuple.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 3/08/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

extension Dictionary {
    init<S: Sequence where S.Iterator.Element == Element>(_ seq: S) {
        self.init()
        for (k, v) in seq {
            self[k] = v
        }
    }
    
    func mapTuple<OutKey: Hashable, OutValue>(_ transform: @noescape (Element) throws -> (OutKey, OutValue)) rethrows -> [OutKey: OutValue] {
        return Dictionary<OutKey, OutValue>(try map(transform))
    }
    
    func filterTuple(_ includeElement: @noescape (Element) throws -> Bool) rethrows -> [Key: Value] {
        return Dictionary(try filter(includeElement))
    }
}
