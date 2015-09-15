//
//  Lexicon.swift
//  Papyrus
//
//  Created by Chris Nevin on 11/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

// TODO: Refactor using GADDAG/DAWG or similar approach.

import Foundation

public typealias LexiconType = [String: AnyObject]

public struct Lexicon {
    let DefKey = "Def"
    let dictionary: LexiconType?
    
    public init(withDictionary dictionary: LexiconType) {
        self.dictionary = dictionary
    }
    
    public init?(withFilePath path: String) {
        if let contents = NSDictionary(contentsOfFile: path) as? LexiconType {
            self.dictionary = contents
        } else {
            return nil
        }
    }
    
    /// Determine if a word is defined in the dictionary.
    func defined(word: String) throws -> String {
        var current = dictionary
        var index = word.startIndex
        for char in word.uppercaseString.characters {
            if let inner = current?[String(char)] as? LexiconType {
                index = index.advancedBy(1)
                if index == word.endIndex {
                    if let definition = inner[DefKey] as? String {
                        return definition
                    } else {
                        throw ValidationError.UndefinedWord(word)
                    }
                }
                current = inner
            } else {
                throw ValidationError.UndefinedWord(word)
            }
        }
        throw ValidationError.UndefinedWord(word)
    }
    
    func anagramsOf(letters: [Character], length: Int, prefix: String,
        fixedLetters: [(Int, Character)], fixedCount: Int, root: LexiconType?,
        inout results: [(String, String)])
    {
        let source = root ?? dictionary!
        let prefixLength = prefix.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        if let c = fixedLetters.filter({$0.0 == prefixLength}).map({$0.1}).first, newSource = source[String(c)] as? LexiconType {
            let newPrefix = prefix + String(c)
            let reverseFiltered = fixedLetters.filter({$0.0 != prefixLength})
            anagramsOf(letters, length: length, prefix: newPrefix,
                fixedLetters: reverseFiltered, fixedCount: fixedCount,
                root: newSource, results: &results)
            return
        }
        
        // See if word exists
        if let definition = source[DefKey] as? String where fixedLetters.count == 0 &&
            prefixLength == length && prefixLength > fixedCount {
            results.append((prefix, definition))
        }
        // Before continuing...
        var newLetters = letters
        for (key, value) in source {
            // Search for ? or key
            if (key == DefKey) {
                continue
            }
            if let index = newLetters.indexOf(Character(key)) ?? newLetters.indexOf("?") {
                newLetters.removeAtIndex(index)
                anagramsOf(newLetters, length: length, prefix: prefix + key,
                    fixedLetters: fixedLetters, fixedCount: fixedCount,
                    root: value as? LexiconType, results: &results)
                break
            }
        }
    }
}