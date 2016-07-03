//
//  Lookup.swift
//  Lookup
//
//  Created by Chris Nevin on 26/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public typealias Anagrams = [String]
public typealias Words = [String: Anagrams]
public typealias FixedLetters = [Int: Character]

public protocol Lookup {
    /// - letters: Letters to use in anagrams (including fixed letters).
    /// - returns: Anagrams for provided the letters.
    subscript(letters: String) -> Anagrams? { get }
    /// - letters: Letters to use in anagrams (including fixed letters).
    /// - fixedLetters: Index-Character dictionary for all spots that are currently filled.
    /// - returns: Anagrams for provided the letters where fixed letters match and remaining letters.
    subscript(letters: String, fixedLetters: FixedLetters) -> Anagrams? { get }
    /// - letters: Letters to use in anagrams (including fixed letters).
    /// - returns: Anagrams for provided the letters.
    subscript(letters: [Character]) -> Anagrams? { get }
    /// - letters: Letters to use in anagrams (including fixed letters).
    /// - fixedLetters: Index-Character dictionary for all spots that are currently filled.
    /// - returns: Anagrams for provided the letters where fixed letters match and remaining letters.
    subscript(letters: [Character], fixedLetters: FixedLetters) -> Anagrams? { get }
    /// - parameter word: Word to check validity of.
    /// - returns: True if word is valid.
    func lookup(word: String) -> Bool
}

public extension Lookup {
    public subscript(letters: String) -> Anagrams? {
        return self[Array(letters.characters)]
    }
    public subscript(letters: String, fixedLetters: FixedLetters) -> Anagrams? {
        return self[Array(letters.characters), fixedLetters]
    }
    public subscript(letters: [Character], fixedLetters: FixedLetters) -> Anagrams? {
        return self[letters]?.filter({ word in
            var remainingForWord = letters
            for (index, char) in Array(word.characters).enumerated() {
                if let fixed = fixedLetters[index] where char != fixed {
                    return false
                }
                if let firstIndex = remainingForWord.index(of: char) {
                    // Remove from pool, word still appears to be valid
                    remainingForWord.remove(at: firstIndex)
                } else {
                    // We ran out of viable letters for this word
                    return false
                }
            }
            return true
        })
    }
}
