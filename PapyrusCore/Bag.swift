//
//  Bag.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public protocol Bag {
    static var vowels: [Character] { get }
    static var letterPoints: [Character: Int] { get }
    static var letterCounts: [Character: Int] { get }
    static var total: Int { get }
    var remaining: [Character] { get set }
    mutating func replace(letter: Character)
    mutating func draw() -> Character?
}

public extension Bag {
    mutating public func replace(letter: Character) {
        remaining.append(letter)
    }
    
    mutating public func draw() -> Character? {
        if remaining.count == 0 { return nil }
        return remaining.removeFirst()
    }
    
    mutating func prepare() {
        var tiles = [Character]()
        for (character, i) in Self.letterCounts {
            tiles += Array(count: i, repeatedValue: character)
        }
        remaining = tiles.shuffled()
    }
}

public struct ScrabbleBag: Bag {
    public static let vowels: [Character] = ["a", "e", "i", "o", "u"]
    public static let letterPoints: [Character: Int] = [
        Game.blankLetter: 0, "a": 1, "b": 3, "c": 3, "d": 2,
        "e": 1, "f": 4, "g": 2, "h": 4, "i": 1,
        "j": 8, "k": 5, "l": 1, "m": 3, "n": 1,
        "o": 1, "p": 3, "q": 10, "r": 1, "s": 1,
        "t": 1, "u": 1, "v": 4, "w": 4, "x": 8,
        "y": 4, "z": 10]
    public static let letterCounts: [Character: Int] = [
        Game.blankLetter: 2, "a": 9, "b": 2, "c": 2, "d": 4,
        "e": 12, "f": 2, "g": 3, "h": 2, "i": 9,
        "j": 1, "k": 1, "l": 4, "m": 2, "n": 6,
        "o": 8, "p": 2, "q": 1, "r": 6, "s": 4,
        "t": 6, "u": 4, "v": 2, "w": 2, "x": 1,
        "y": 2, "z": 1]
    public static let total = 100
    
    public var remaining = [Character]()
    public init() {
        prepare()
    }
}

public struct SuperScrabbleBag: Bag {
    public static let vowels: [Character] = ["a", "e", "i", "o", "u"]
    public static let total = 200
    public static let letterPoints: [Character: Int] = [
        Game.blankLetter: 0, "a": 1, "b": 3, "c": 3, "d": 2,
        "e": 1, "f": 4, "g": 2, "h": 4, "i": 1,
        "j": 8, "k": 5, "l": 1, "m": 3, "n": 1,
        "o": 1, "p": 3, "q": 10, "r": 1, "s": 1,
        "t": 1, "u": 1, "v": 4, "w": 4, "x": 8,
        "y": 4, "z": 10]
    public static let letterCounts: [Character: Int] = [
        Game.blankLetter: 4, "a": 16, "b": 4, "c": 6, "d": 8,
        "e": 24, "f": 4, "g": 5, "h": 5, "i": 13,
        "j": 2, "k": 2, "l": 7, "m": 6, "n": 13,
        "o": 15, "p": 4, "q": 2, "r": 13, "s": 10,
        "t": 15, "u": 7, "v": 3, "w": 4, "x": 2,
        "y": 4, "z": 2]
    
    public var remaining = [Character]()
    public init() {
        prepare()
    }
}