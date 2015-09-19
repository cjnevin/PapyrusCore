//
//  Papyrus.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

public let PapyrusRackAmount: Int = 7
public let PapyrusDimensions: Int = 15
let PapyrusMiddle: Int = 8

public typealias LifecycleCallback = (Lifecycle, Papyrus) -> ()

public enum Lifecycle {
    case Cleanup
    case Preparing
    case Ready
    case ChangedPlayer
    case Completed
}

public final class Papyrus {
    var lifecycleCallback: LifecycleCallback?
    public internal(set) var inProgress: Bool = false
    public let squares: [[Square]]
    let innerOperations = NSOperationQueue()
    let wordOperations = NSOperationQueue()
    
    var dawg: Dawg?
    lazy var tiles = [Tile]()
    
    lazy var players = [Player]()
    public internal(set) var playerIndex: Int = 0
    public var player: Player? {
        if players.count <= playerIndex { return nil }
        return players[playerIndex]
    }
    
    public init() {
        squares = Square.createSquares()
    }
    
    /// Create a new game.
    /// - parameter callback: Callback which will be called throughout all stages of game lifecycle.
    public func newGame(dawg: Dawg, callback: LifecycleCallback) {
        squares.flatMap({$0}).forEach({$0.tile = nil})
        inProgress = true
        self.dawg = dawg
        lifecycleCallback?(.Cleanup, self)
        lifecycleCallback = callback
        lifecycleCallback?(.Preparing, self)
        tiles.removeAll()
        players.removeAll()
        playerIndex = 0
        tiles.appendContentsOf(Tile.createTiles())
        lifecycleCallback?(.Ready, self)
    }
}