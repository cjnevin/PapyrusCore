//
//  Player.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

public let PapyrusRackAmount: Int = 7

public func == (lhs: Player, rhs: Player) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

public enum Difficulty {
    case Human
    case Newbie
    case Average
    case Champion
}

/// An instance of a Player which has a score and can be assigned to tiles.
/// - SeeAlso: Papyrus.player is the current Player.
public final class Player: Equatable {
    public internal(set) var difficulty: Difficulty
    /// Players current score.
    public internal(set) var score: Int = 0
    /// All tiles played by this player.
    public internal(set) lazy var tiles = Set<Tile>()
    /// Current rack tiles.
    public var rackTiles: [Tile] {
        return tiles.filter({$0.placement == Placement.Rack})
    }
    /// Current play tiles, i.e. tiles on the board that haven't been submitted yet.
    public var currentPlayTiles: [Tile] {
        return tiles.filter({$0.placement == Placement.Board})
    }
    /// Currently held tile, i.e. one being dragged around.
    public var heldTile: Tile? {
        let held = tiles.filter({$0.placement == Placement.Held})
        assert(held.count < 2)
        return held.first
    }
    
    internal init(score: Int? = 0, difficulty: Difficulty = .Human) {
        self.score = score!
        self.difficulty = difficulty
    }
    /// Submit a move, drop all tiles on the board and increment score.
    func submit(move: Move) {
        zip(move.word.tiles, move.word.characters).forEach { (tile, character) -> () in
            tile.changeLetter(character)
            assert(tile.letter == character)
        }
        zip(move.word.squares, move.word.tiles).forEach { (square, tile) -> () in
            square.tile = tile
            tile.placement = .Fixed
        }
        score += move.total
    }
    /// Move tiles from a players rack to the bag.
    public func returnTiles(tilesToReturn: [Tile]) {
        tiles.subtractInPlace(tilesToReturn)
        tilesToReturn.forEach({$0.placement = .Bag})
    }
    /// Add tiles to a players rack from the bag.
    /// - returns: Number of tiles able to be drawn for a player.
    func replenishTiles(fromBag bagTiles: [Tile]) -> Int {
        let needed = PapyrusRackAmount - rackTiles.count
        var count = 0
        for i in 0..<bagTiles.count where bagTiles[i].placement == .Bag && count < needed {
            bagTiles[i].placement = .Rack
            tiles.insert(bagTiles[i])
            count++
        }
        return count
    }
}
