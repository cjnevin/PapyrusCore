//
//  CollectionType+Papyrus.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

extension CollectionType {
    public func mapFilter<T>(@noescape transform: (Self.Generator.Element) throws -> T?) rethrows -> [T] {
        return try map { try transform($0) }.filter{ $0 != nil }.map{ $0! }
    }
    
    func all(@noescape body: (Self.Generator.Element) -> (Bool)) -> Bool {
        return count == 0 ? false : map{ body($0) }.contains(false) == false
    }
}
