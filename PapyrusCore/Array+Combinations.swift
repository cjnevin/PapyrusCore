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
    
    // This method is simpler but it is also several magnitudes slower than the indexed approach below.
    // I actually tried to simplify this using flatMap but the performance was even worse.
    // measured [Time, seconds] average: 0.200, relative standard deviation: 3.684%, values: [0.213552, 0.200878, 0.198138, 0.201444, 0.200035, 0.196813, 0.204596, 0.182647, 0.196244, 0.202394]
    func combos(_ length : Int) -> [[Element]] {
        if length <= 0 { return [[]] }
        
        var buffer = [[Element]]()
        enumerated().forEach { (index, head) in
            Array(self[index + 1..<self.count]).combinations(length - 1).forEach { tail in
                buffer += [[head] + tail]
            }
        }
        
        return buffer
    }
    
    // This thread on stack overflow was very helpful:
    // https://stackoverflow.com/questions/127704/algorithm-to-return-all-combinations-of-k-elements-from-n
    // measured [Time, seconds] average: 0.062, relative standard deviation: 17.142%, values: [0.083717, 0.078753, 0.045193, 0.064347, 0.056260, 0.058302, 0.056251, 0.058372, 0.059811, 0.061267]
    // This method is the faster of the two.
    func combinations(_ length: Int) -> [[Element]] {
        if length <= 0 || length > count { return [] }
        var buffer = [[Element]]()
        var indexes = (0..<length).map{ $0 }
        var k = length - 1

        while true {
            repeat {
                buffer.append(indexes.map{self[$0]})
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

