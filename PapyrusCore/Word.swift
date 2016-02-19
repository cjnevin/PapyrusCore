//
//  Word.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 19/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public struct Word {
    public let boundary: Boundary
    
    // Contains only the 'Board' placed tiles.
    public let characters: [Character]
    
    // Contains squares we want to drop a tile on.
    public let squares: [Square]
    
    // Contains tiles we want to place.
    public let tiles: [Tile]
    
    public let word: String
    public let score: Int
}
