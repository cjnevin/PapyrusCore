//
//  WordsWithFriendsSolver.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 25/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation
import Lookup

struct WordsWithFriendsSolver: Solver {
    var bagType: Bag.Type
    var board: Board
    var boardState: BoardState
    var dictionary: Lookup
    var debug: Bool
    let maximumWordLength = 15
    let allTilesUsedBonus = 35
    let operationQueue = OperationQueue()
    
    init(bagType: Bag.Type, board: Board, dictionary: Lookup, debug: Bool = false) {
        self.board = board
        self.bagType = bagType
        boardState = BoardState(board: board)
        self.debug = debug
        self.dictionary = dictionary
    }
}
