//
//  WordsWithFriendsBoard.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 25/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public func ==(lhs: WordsWithFriendsBoard, rhs: WordsWithFriendsBoard) -> Bool {
    return compareBoards(lhs, rhs)
}

public struct WordsWithFriendsBoard: Board, Equatable {
    public let empty = Character(" ")
    public let centers = [(x: 7, y: 7)]
    public var center: Int {
        return centers.first!.x
    }
    public let size = 15
    public var layout = Array(count: 15, repeatedValue: Array(count: 15, repeatedValue: Character(" ")))
    public var blanks = [(x: Int, y: Int)]()
    public let letterMultipliers = [
        [1,1,1,1,1,1,3,1,3,1,1,1,1,1,1],
        [1,1,2,1,1,1,1,1,1,1,1,1,2,1,1],
        [1,2,1,1,2,1,1,1,1,1,2,1,1,2,1],
        [1,1,1,3,1,1,1,1,1,1,1,3,1,1,1],
        [1,1,2,1,1,1,2,1,2,1,1,1,2,1,1],
        [1,1,1,1,1,3,1,1,1,3,1,1,1,1,1],
        [3,1,1,1,2,1,1,1,1,1,2,1,1,1,3],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [3,1,1,1,2,1,1,1,1,1,2,1,1,1,3],
        [1,1,1,1,1,3,1,1,1,3,1,1,1,1,1],
        [1,1,2,1,1,1,2,1,2,1,1,1,2,1,1],
        [1,1,1,3,1,1,1,1,1,1,1,3,1,1,1],
        [1,2,1,1,2,1,1,1,1,1,2,1,1,2,1],
        [1,1,2,1,1,1,1,1,1,1,1,1,2,1,1],
        [1,1,1,1,1,1,3,1,3,1,1,1,1,1,1]]
    public let wordMultipliers = [
        [1,1,1,3,1,1,1,1,1,1,1,3,1,1,1],
        [1,1,1,1,1,2,1,1,1,2,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [3,1,1,1,1,1,1,2,1,1,1,1,1,1,3],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,2,1,1,1,1,1,1,1,1,1,1,1,2,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,2,1,1,1,1,1,1,1,2,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,2,1,1,1,1,1,1,1,1,1,1,1,2,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [3,1,1,1,1,1,1,2,1,1,1,1,1,1,3],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,2,1,1,1,2,1,1,1,1,1],
        [1,1,1,3,1,1,1,1,1,1,1,3,1,1,1]]
}
