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
    
    internal init?(json: JSON) {
        guard
            let lettersStrings: [String: Int] = JSONConfigKey.letters.in(json),
            let letterPointsStrings: [String: Int] = JSONConfigKey.letterPoints.in(json),
            let vowelsStrings: [String] = JSONConfigKey.vowels.in(json) else {
                return nil
        }
        self.init(vowels: vowelsStrings.map({ Character($0) }),
                  letters: lettersStrings.mapTuple({ (Character($0), $1) }),
                  letterPoints: letterPointsStrings.mapTuple({ (Character($0), $1) }))
    }
    
    internal init(vowels: [Character], letters: [Character: Int], letterPoints: [Character: Int]) {
        self.vowels = vowels
        self.letters = letters
        self.letterPoints = letterPoints
        self.remaining = letters.flatMap({ Array(repeating: $0, count: $1) }).shuffled()
        self.total = remaining.count
    }
    
    mutating public func replace(_ letter: Character) {
        remaining.append(letter)
    }
    
    mutating public func draw() -> Character? {
        return remaining.count > 0 ? remaining.removeFirst() : nil
    }
}
