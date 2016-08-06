//
//  Array+Combinations.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 27/05/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

internal extension Array {
    
    /// Shuffle array in place.
    mutating func shuffle() {
        self = shuffled()
    }
    
    /// - returns: Shuffled array using elements in array.
    func shuffled() -> Array {
        return sorted(isOrderedBefore: {_, _ in arc4random() % 2 == 0})
    }
    
    // This thread on stack overflow was very helpful:
    // https://stackoverflow.com/questions/127704/algorithm-to-return-all-combinations-of-k-elements-from-n
    func combinations(_ length: Int) -> [[Element]] {
        if length <= 0 || length > count { return [] }
        var buffer = [[Element]]()
        var indexes = (0..<length).map{ $0 }
        var k = length - 1

        while true {
            repeat {
                buffer.append(indexes.map{ self[$0] })
                indexes[k] += 1
            } while indexes[k] != count
            
            if length == 1 { return buffer }
            
            while true {
                let offset = k - 1
                if indexes[offset] == count - (length - offset) {
                    if offset == 0 {
                        return buffer
                    }
                    k = offset
                    continue
                }
                indexes[offset] += 1
                let current = indexes[offset]
                var i = k, j = 1
                while i != length {
                    indexes[i] = current + j
                    i += 1
                    j += 1
                }
                k = length - 1
                break
            }
        }
    }
    
}

