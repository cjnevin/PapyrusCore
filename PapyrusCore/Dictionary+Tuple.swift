//
//  Dictionary+Tuple.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 3/08/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

internal extension Dictionary {
    init<S: Sequence>(_ seq: S) where S.Iterator.Element == Element {
        self.init()
        for (k, v) in seq {
            self[k] = v
        }
    }
    
    func mapTuple<OutKey: Hashable, OutValue>(_ transform: (Element) throws -> (OutKey, OutValue)) rethrows -> [OutKey: OutValue] {
        return Dictionary<OutKey, OutValue>(try map(transform))
    }
}
