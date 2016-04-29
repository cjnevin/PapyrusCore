//
//  Bag.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public struct Bag {
    public static let blankLetter: Character = "?"
    
    public static let vowels: [Character] = ["a", "e", "i", "o", "u"]
    
    public static let letterPoints: [Character: Int] = [
        Bag.blankLetter: 0, "a": 1, "b": 3, "c": 3, "d": 2,
        "e": 1, "f": 4, "g": 2, "h": 4, "i": 1,
        "j": 8, "k": 5, "l": 1, "m": 3, "n": 1,
        "o": 1, "p": 3, "q": 10, "r": 1, "s": 1,
        "t": 1, "u": 1, "v": 4, "w": 4, "x": 8,
        "y": 4, "z": 10]
    
    private let letterCounts: [Character: Int] = [
        Bag.blankLetter: 2, "a": 9, "b": 2, "c": 2, "d": 4,
        "e": 12, "f": 2, "g": 3, "h": 2, "i": 9,
        "j": 1, "k": 1, "l": 4, "m": 2, "n": 6,
        "o": 9, "p": 2, "q": 1, "r": 6, "s": 4,
        "t": 6, "u": 4, "v": 2, "w": 2, "x": 1,
        "y": 2, "z": 1]
    
    public private(set) var remaining = [Character]()
    
    public init(withBlanks blanks: Bool = true) {
        for (character, i) in letterCounts {
            if blanks == false && character == Bag.blankLetter {
                continue
            }
            remaining += Array(count: i, repeatedValue: character)
        }
        remaining.sortInPlace {_, _ in arc4random() % 2 == 0}
    }
    
    mutating func replace(letter: Character) {
        remaining.append(letter)
    }
    
    mutating func draw() -> Character? {
        if remaining.count == 0 { return nil }
        return remaining.removeFirst()
    }
}
