//
//  Move.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 17/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

let PapyrusBlankLetter: Character = "?"

public enum ValidationError: ErrorType {
    case UnfilledSquare([Square])
    case InvalidArrangement
    case InsufficientTiles
    case NoCenterIntersection
    case NoMoves
    case NoIntersection
    case UndefinedWord(String)
    case Message(String)
    case NoPlayer
}

public struct Move {
    public let total: Int
    public let word: Word
    public let intersections: [Word]
}
