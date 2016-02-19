//
//  Square.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

public enum Modifier {
    case None, Letterx2, Letterx3, Center, Wordx2, Wordx3
    /// - returns: Word multiplier for this square.
    var wordMultiplier: Int {
        switch (self) {
        case .Center, .Wordx2: return 2
        case .Wordx3: return 3
        default: return 1
        }
    }
    /// - returns: Letter multiplier for this square.
    var letterMultiplier: Int {
        switch (self) {
        case .Letterx2: return 2
        case .Letterx3: return 3
        default: return 1
        }
    }
}

public func == (lhs: Square, rhs: Square) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

public final class Square: CustomDebugStringConvertible, Equatable, Hashable {
    /// - returns: Square array.
    class func createSquares() -> [[Square]] {
        let m = PapyrusMiddle
        let range = 1...PapyrusDimensions
        return range.map { (row) -> [Square] in
            range.map({ (col) -> Square in
                var mod: Modifier = .None
                func plusMinus(offset: Int, _ n: Int) -> Bool {
                    return offset == m - n || offset == m + n
                }
                func tuples(arr: [(Int, Int)]) -> Bool {
                    return arr.contains { (x, y) in
                        (plusMinus(row, x) && plusMinus(col, y)) || (plusMinus(col, x) && plusMinus(row, y))
                    }
                }
                func numbers(arr: [Int]) -> Bool {
                    return arr.contains { (n) in
                        plusMinus(row, n) && plusMinus(col, n)
                    }
                }
                if row == PapyrusMiddle && col == PapyrusMiddle {
                    mod = .Center
                } else if numbers([3,4,5,6]) {
                    mod = .Wordx2
                } else if numbers([2]) || tuples([(2,6)]) {
                    mod = .Letterx3
                } else if numbers([1]) || tuples([(1,5), (0,4), (m-1, 4)]) {
                    mod = .Letterx2
                } else if numbers([m-1]) || tuples([(0, m-1)]) {
                    mod = .Wordx3
                }
                return Square(mod, row: row - 1, column: col - 1)
            })
        }
    }
    public let row: Int
    public let column: Int
    public let type: Modifier
    public var tile: Tile?
    internal init(_ type: Modifier, row: Int, column: Int) {
        self.type = type
        self.row = row
        self.column = column
    }
    public var debugDescription: String {
        return String("\(row),\(column)")
    }
    /// - returns: Letter multiplier for this tile.
    public var letterValue: Int {
        guard let tile = tile else { return 0 }
        return (tile.placement == .Fixed ? 1 : type.letterMultiplier) * tile.value
    }
    /// - returns: Word multiplier for this tile.
    public var wordMultiplier: Int {
        guard let tile = tile else { return 0 }
        return (tile.placement == .Fixed ? 1 : type.wordMultiplier)
    }
    
    public var hashValue: Int {
        return "\(row),\(column)".hashValue
    }
}
