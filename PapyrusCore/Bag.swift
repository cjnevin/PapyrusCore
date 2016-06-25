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