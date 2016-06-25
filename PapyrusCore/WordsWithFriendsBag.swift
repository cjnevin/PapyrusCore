//
//  WordsWithFriendsBag.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 25/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public struct WordsWithFriendsBag: Bag {
    public static let vowels: [Character] = ["a", "e", "i", "o", "u"]
    public static let letterPoints: [Character: Int] = [
        Game.blankLetter: 0, "a": 1, "b": 4, "c": 4, "d": 2,
        "e": 1, "f": 4, "g": 3, "h": 3, "i": 1,
        "j": 10, "k": 5, "l": 2, "m": 4, "n": 2,
        "o": 1, "p": 4, "q": 10, "r": 1, "s": 1,
        "t": 1, "u": 2, "v": 5, "w": 4, "x": 8,
        "y": 3, "z": 10]
    public static let letterCounts: [Character: Int] = [
        Game.blankLetter: 2, "a": 9, "b": 2, "c": 2, "d": 5,
        "e": 13, "f": 2, "g": 3, "h": 4, "i": 8,
        "j": 1, "k": 1, "l": 4, "m": 2, "n": 5,
        "o": 8, "p": 2, "q": 1, "r": 6, "s": 5,
        "t": 7, "u": 4, "v": 2, "w": 2, "x": 1,
        "y": 2, "z": 1]
    public static let total = 104
    
    public var remaining = [Character]()
    public init() {
        prepare()
    }
}