//
//  Board.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public func == (_ lhs: Board, _ rhs: Board) -> Bool {
    return lhs.layout == rhs.layout
}

private func makePositions(indices: CountableRange<Int>) -> Positions {
    return indices.flatMap({ x in indices.flatMap({ y in Position(x: x, y: y) }) })
}

internal struct Edge: OptionSet {
    let rawValue: Int
    
    static let None = Edge(rawValue: 0)
    static let Left = Edge(rawValue: 1 << 0)
    static let Right = Edge(rawValue: 1 << 1)
    static let Top = Edge(rawValue: 1 << 2)
    static let Bottom = Edge(rawValue: 1 << 3)
    static let LeftAndRight: Edge = [Left, Right]
    static let TopAndBottom: Edge = [Top, Bottom]
}

public protocol BoardType: CustomDebugStringConvertible {
    var empty: Character { get }
    var center: Int { get }
    var size: Int { get }
    var layout: Array2D<Character> { get set }
    var blanks: Positions { get set }
    var isFirstPlay: Bool { get }
    var letterMultipliers: [[Int]] { get }
    var wordMultipliers: [[Int]] { get }
    var emptyPositions: Positions { get }
    var allPositions: Positions { get }
    
    mutating func set<T: PositionType>(letter: Character, at position: T)
    func letter<T: PositionType>(at position: T) -> Character?
    func isEmpty<T: PositionType>(at position: T) -> Bool
    func isFilled<T: PositionType>(at position: T) -> Bool
    func isCenter<T: PositionType>(at position: T) -> Bool
    func isValid(at position: Position, length: Int, horizontal: Bool) -> Bool
    
    func letterMultiplier<T: PositionType>(at position: T) -> Int
    func wordMultiplier<T: PositionType>(at position: T) -> Int
    
    mutating func play(solution: Solution) -> [Character]
}

extension BoardType {
    var centerPosition: Position {
        return Position(x: center, y: center)
    }
    
    public var isFirstPlay: Bool {
        return isEmpty(at: centerPosition)
    }
    
    public var emptyPositions: Positions {
        return allPositions.filter({ isEmpty(at: $0) })
    }
    
    public var debugDescription: String {
        var buffer = ""
        for row in 0..<layout.rows {
            var rowBuffer = [String]()
            for column in 0..<layout.columns {
                let letter = layout[column, row]
                if letter == empty {
                    rowBuffer.append("_")
                } else {
                    rowBuffer.append(String(letter))
                }
            }
            buffer += rowBuffer.joined(separator: ",") + (row < layout.rows - 1 ? "\n" : "")
        }
        return buffer
    }
    
    public func letterMultiplier<T: PositionType>(at position: T) -> Int {
        return letterMultipliers[position.y][position.x]
    }
    
    public func wordMultiplier<T: PositionType>(at position: T) -> Int {
        return wordMultipliers[position.y][position.x]
    }
    
    public mutating func set<T: PositionType>(letter: Character, at position: T) {
        layout[position.y, position.x] = letter
    }
    
    public func letter<T: PositionType>(at position: T) -> Character? {
        let value = layout[position.y, position.x]
        return value == empty ? nil : value
    }
    
    public func isEmpty<T: PositionType>(at position: T) -> Bool {
        return letter(at: position) == nil
    }
    
    public func isFilled<T: PositionType>(at position: T) -> Bool {
        return letter(at: position) != nil
    }
    
    public func isCenter<T: PositionType>(at position: T) -> Bool {
        return position == centerPosition
    }
    
    public func isValid(at position: Position, length: Int, horizontal: Bool) -> Bool {
        guard isEmpty(at: position) else {
            return false
        }
        

        // Too long?
        guard let clampedPosition = restrict(position: position, to: length, horizontal: horizontal) else {
            return false
        }
        
        if isCenter(at: position) && isFirstPlay {
            return true
        }
        
        // Horizontal?
        if horizontal {
            // Touches on left or right (cannot accept prefixed or suffixed spots)
            if touchesHorizontally(at: position, length: length, edges: .LeftAndRight) {
                return false
            }
            // Touches on top or bottom (allowed)
            if touchesHorizontally(at: position, length: length, edges: .TopAndBottom) {
                return true
            }
            // Intersects other letters?
            return clampedPosition.x > position.x + length
        } else {
            // Touches on bottom or top (cannot accept prefixed or suffixed spots)
            if touchesVertically(at: position, length: length, edges: .TopAndBottom) {
                return false
            }
            // Touches on left or right (allowed)
            if touchesVertically(at: position, length: length, edges: .LeftAndRight) {
                return true
            }
            // Intersects other letters?
            return clampedPosition.y > position.y + length
        }
    }
    
    func touchesVertically(at position: Position, length: Int, edges: Edge) -> Bool {
        if position.y + length > size {
            return false
        }
        
        if edges.contains(.Top) && position.y > 0 && isFilled(at: position.top) {
            return true
        }
        else if edges.contains(.Bottom) && position.y + length < size && isFilled(at: position.moveY(amount: length)) {
            return true
        }
        
        let (left, right) = (edges.contains(.Left), edges.contains(.Right))
        guard left || right else {
            return false
        }
        for offset in (0..<length).map({ Position(x: position.x, y: position.y + $0) }) {
            if left && offset.x > 0 && isFilled(at: offset.left) {
                return true
            } else if right && offset.x < (size - 1) && isFilled(at: offset.right) {
                return true
            }
        }
        return false
    }
    
    func touchesHorizontally(at position: Position, length: Int, edges: Edge) -> Bool {
        if position.x + length > size {
            return false
        }
        
        if edges.contains(.Left) && position.x > 0 && isFilled(at: position.left) {
            return true
        }
        else if edges.contains(.Right) && position.x + length < size && isFilled(at: position.moveX(amount: length)) {
            return true
        }
        
        let (top, bottom) = (edges.contains(.Top), edges.contains(.Bottom))
        guard top || bottom else {
            return false
        }
        for offset in (0..<length).map({ Position(x: position.x + $0, y: position.y) }) {
            if top && offset.y > 0 && isFilled(at: offset.top) {
                return true
            } else if bottom && offset.y < (size - 1) && isFilled(at: offset.bottom) {
                return true
            }
        }
        return false
    }

    /// - returns: Nil if position exceeds boundary after adding length, or the new Position after skipping empty spots.
    /// - parameter position: Starting position.
    /// - parameter length: Number of empty spots needed.
    /// - parameter horizontal: Direction to move position.
    func restrict(position: Position, to length: Int, horizontal: Bool) -> Position? {
        var length = length
        var position = position
        // TODO: The position returned actually sits outside of the boundary? (size - 1)
        while length > 0 && ((horizontal && position.x < size) || (!horizontal && position.y < size)) {
            if isEmpty(at: position) {
                length -= 1
            }
            position = horizontal ? position.right : position.bottom
        }
        return length != 0 ? nil : position
    }
    
    mutating public func play(solution: Solution) -> [Character] {
        blanks.append(contentsOf: solution.blanks)
        return solution.toLetterPositions().flatMap { position -> Character? in
            guard isEmpty(at: position) else {
                return nil
            }
            set(letter: position.letter, at: position)
            return position.letter
        }
    }
}

public struct Board: BoardType, Equatable {
    public let empty: Character
    public let center: Int
    public let size: Int
    public let letterMultipliers: [[Int]]
    public let wordMultipliers: [[Int]]
    public let allPositions: Positions
    public var layout: Array2D<Character>
    public var blanks = Positions()
    
    public init?(with config: URL) {
        guard let json = readJSON(from: config) else {
            return nil
        }
        self.init(json: json)
    }
    
    internal init?(json: JSON) {
        guard
            let letterMultipliers: [[Int]] = JSONConfigKey.letterMultipliers.in(json),
            let wordMultipliers: [[Int]] = JSONConfigKey.wordMultipliers.in(json) else {
                return nil
        }
        self.init(letterMultipliers: letterMultipliers, wordMultipliers: wordMultipliers)
    }
    
    internal init(letterMultipliers: [[Int]], wordMultipliers: [[Int]]) {
        empty = Character(" ")
        center = Int(letterMultipliers.count / 2)
        size = letterMultipliers.count
        layout = Array2D(columns: size, rows: size, initialValue: Character(" "))
        
        var positions = [Position]()
        for x in 0..<layout.columns {
            for y in 0..<layout.rows {
                positions.append(Position(x: x, y: y))
            }
        }
        allPositions = positions
        
        self.letterMultipliers = letterMultipliers
        self.wordMultipliers = wordMultipliers
    }
}
