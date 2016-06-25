//
//  UpwordsSolver.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 25/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

struct UpwordsSolver: Solver {
    var bagType: Bag.Type
    var board: Board
    var boardState: BoardState
    var lookup: Lookup
    var debug: Bool
    let maximumWordLength = 10
    let allTilesUsedBonus = 50
    let operationQueue = NSOperationQueue()
    
    init(bagType: Bag.Type, board: Board, lookup: Lookup, debug: Bool = false) {
        self.board = board
        self.bagType = bagType
        boardState = BoardState(board: board)
        self.debug = debug
        self.lookup = lookup
    }
}
