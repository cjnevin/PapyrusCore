//
//  Player+Papyrus.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 19/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

extension Papyrus {
    /// - returns: A new player with their rack pre-filled. Or an error if refill fails.
    public func createPlayer(difficulty: Difficulty = .Human) -> Player? {
        if players.count == 4 {
            return nil
        }
        let newPlayer = Player(difficulty: difficulty)
        draw(newPlayer)
        players.append(newPlayer)
        return newPlayer
    }
    
    /// Advances to next player's turn.
    func nextPlayer() {
        playerIndex++
        if playerIndex >= players.count {
            playerIndex = 0
        }
        lifecycle = .ChangedPlayer
        if player?.difficulty != .Human {
            submitAIMove()
        }
    }
    
    /// Draw tiles from the bag.
    /// - parameter player: Player's rack to fill.
    public func draw(player: Player) {
        // If we have no tiles left in the bag complete game.
        // This call will also fill the players rack.
        if player.replenishTiles(fromBag: tiles.placed(.Bag)) == 0 &&
            player.rackTiles.count == 0 &&
            lifecycle.gameComplete()
        {
            // Subtract remaining tiles in racks
            players.forEach { (player) in
                player.score = player.rackTiles.toValues().reduce(player.score, combine: -)
            }
            // Complete the game
            lifecycle = .GameOver
        }
    }
}