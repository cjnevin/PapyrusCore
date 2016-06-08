//
//  Lookup.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 8/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public struct Lookup {
    let anagrams: AnagramDictionary
    let dictionary: Dawg
    
    public init?(dictionaryFilename: String, anagramFilename: String, type: String = "bin", bundle: NSBundle = .mainBundle()) {
        guard let
            dawgPath = bundle.pathForResource(dictionaryFilename, ofType: type),
            dawg = Dawg.load(dawgPath),
            anagramPath = bundle.pathForResource(anagramFilename, ofType: type),
            anagramDictionary = AnagramDictionary.load(anagramPath) else {
                return nil
        }
        self.anagrams = anagramDictionary
        self.dictionary = dawg
    }
}