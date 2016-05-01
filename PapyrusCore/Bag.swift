//
//  Bag.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public protocol LetterDistribution {
    var letterPoints: [Character: Int] { get }
    var letterCounts: [Character: Int] { get }
    var total: Int { get }
}

public struct ScrabbleDistribution: LetterDistribution {
    public let letterPoints: [Character: Int] = [
        Bag.blankLetter: 0, "a": 1, "b": 3, "c": 3, "d": 2,
        "e": 1, "f": 4, "g": 2, "h": 4, "i": 1,
        "j": 8, "k": 5, "l": 1, "m": 3, "n": 1,
        "o": 1, "p": 3, "q": 10, "r": 1, "s": 1,
        "t": 1, "u": 1, "v": 4, "w": 4, "x": 8,
        "y": 4, "z": 10]
    
    public let letterCounts: [Character: Int] = [
        Bag.blankLetter: 2, "a": 9, "b": 2, "c": 2, "d": 4,
        "e": 12, "f": 2, "g": 3, "h": 2, "i": 9,
        "j": 1, "k": 1, "l": 4, "m": 2, "n": 6,
        "o": 8, "p": 2, "q": 1, "r": 6, "s": 4,
        "t": 6, "u": 4, "v": 2, "w": 2, "x": 1,
        "y": 2, "z": 1]
    
    public let total = 100
}

public struct SuperScrabbleDistribution: LetterDistribution {
    public let letterPoints: [Character: Int] = [
        Bag.blankLetter: 0, "a": 1, "b": 3, "c": 3, "d": 2,
        "e": 1, "f": 4, "g": 2, "h": 4, "i": 1,
        "j": 8, "k": 5, "l": 1, "m": 3, "n": 1,
        "o": 1, "p": 3, "q": 10, "r": 1, "s": 1,
        "t": 1, "u": 1, "v": 4, "w": 4, "x": 8,
        "y": 4, "z": 10]
    
    public let letterCounts: [Character: Int] = [
        Bag.blankLetter: 4, "a": 16, "b": 4, "c": 6, "d": 8,
        "e": 24, "f": 4, "g": 5, "h": 5, "i": 13,
        "j": 2, "k": 2, "l": 7, "m": 6, "n": 13,
        "o": 15, "p": 4, "q": 2, "r": 13, "s": 10,
        "t": 15, "u": 7, "v": 3, "w": 4, "x": 2,
        "y": 4, "z": 2]
    
    public let total = 200
}

public struct Bag {
    public static let blankLetter: Character = "?"
    public static let vowels: [Character] = ["a", "e", "i", "o", "u"]
    
    public var letterPoints: [Character: Int] {
        return distribution.letterPoints
    }
    
    public private(set) var distribution: LetterDistribution
    public private(set) var remaining = [Character]()
    
    public init(distribution: LetterDistribution = ScrabbleDistribution()) {
        self.distribution = distribution
        for (character, i) in distribution.letterCounts {
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
