//
//  Bag.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public protocol BagType {
    var vowels: [Character] { get }
    var letterPoints: [Character: Int] { get }
    var letters: [Character: Int] { get }
    var total: Int { get }
    var remaining: [Character] { get set }
    mutating func replace(_ letter: Character)
    mutating func draw() -> Character?
}

public struct Bag: BagType {
    public let letters: [Character: Int]
    public let letterPoints: [Character: Int]
    public let vowels: [Character]
    public let total: Int
    public var remaining: [Character]
    
    init(vowels: [Character], letters: [Character: Int], letterPoints: [Character: Int]) {
        self.vowels = vowels
        self.letters = letters
        self.letterPoints = letterPoints
        
        var tiles = [Character]()
        for (character, i) in letters {
            tiles += Array(repeating: character, count: i)
        }
        self.remaining = tiles.shuffled()
        self.total = tiles.count
    }
    
    mutating public func replace(_ letter: Character) {
        remaining.append(letter)
    }
    
    mutating public func draw() -> Character? {
        if remaining.count == 0 { return nil }
        return remaining.removeFirst()
    }
}
