//
//  UpwordsBoard.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 15/06/1016.
//  Copyright © 1016 CJNevin. All rights reserved.
//

import Foundation

public func ==(lhs: UpwordsBoard, rhs: UpwordsBoard) -> Bool {
    return compareBoards(lhs, rhs)
}

public struct UpwordsBoard: Board, Equatable {
    public let empty = Character(" ")
    public let centers = [(x: 4, y: 4), (x: 4, y: 5), (x: 5, y: 4), (x: 5, y: 5)]
    public let size = 10
    public var layout = Array(count: 10, repeatedValue: Array(count: 10, repeatedValue: Character(" ")))
    public var blanks = [(x: Int, y: Int)]()
    public let letterMultipliers = [
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1]]
    public let wordMultipliers = [
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1]]
}
