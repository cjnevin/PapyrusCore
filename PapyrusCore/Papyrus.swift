//
//  Papyrus.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 8/07/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

public let PapyrusDimensions: Int = 15
let PapyrusMiddle: Int = 8

public typealias LifecycleCallback = (Lifecycle) -> ()

public enum Lifecycle {
    case NoGame
    case Preparing
    case Ready
    case ChangedPlayer
    case SkippedTurn
    case EndedTurn(Move)
    case GameOver
    
    func gameComplete() -> Bool {
        if case .GameOver = self {
            return true
        }
        return false
    }
}

public final class Papyrus {
    public var operationQueue: NSOperationQueue {
        struct Static {
            static let instance = NSOperationQueue()
        }
        Static.instance.maxConcurrentOperationCount = 1
        return Static.instance
    }
    public static var dawg: Dawg?
    public var dawg: Dawg? {
        return Papyrus.dawg
    }
    
    let lifecycleCallback: LifecycleCallback
    public internal(set) var lifecycle: Lifecycle {
        didSet {
            lifecycleCallback(lifecycle)
        }
    }
    public internal(set) var inProgress: Bool = false
    public let squares: [[Square]]
    
    lazy var tiles = [Tile]()
    
    public internal(set) lazy var players = [Player]()
    public internal(set) var playerIndex: Int = 0
    public var player: Player? {
        if players.count <= playerIndex { return nil }
        return players[playerIndex]
    }
    
    public init(callback: LifecycleCallback) {
        lifecycle = .NoGame
        lifecycleCallback = callback
        squares = Square.createSquares()
    }
    
    /// Create a new game.
    /// - parameter callback: Callback which will be called throughout all stages of game lifecycle.
    public func newGame() {
        squares.flatten().forEach{ $0.tile = nil }
        inProgress = true
        lifecycle = .Preparing
        tiles.removeAll()
        players.removeAll()
        playerIndex = 0
        tiles.appendContentsOf(Tile.createTiles())
        lifecycle = .Ready
    }
}