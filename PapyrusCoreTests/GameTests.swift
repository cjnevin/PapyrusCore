//
//  GameTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class GameTests: XCTestCase {
    
    var bag: Bag!
    var board: Board!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        bag = Bag()
        board = Board(config: SuperScrabbleBoardConfig())
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        bag = nil
        board = nil
    }
    
    func eventHandler(event: GameEvent) {
        
    }
    
    func testBagCount() {
        let computer1 = Computer(difficulty: .Hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let computer2 = Computer(difficulty: .Easy, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let human1 = Human(rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let game = Game.newGame(lookup: Lookup.singleton, players: [computer1, computer2, human1], serial: true, eventHandler: eventHandler)
        XCTAssertEqual(game.bag.remaining.count, game.bag.distribution.total - 21)
    }
    
    func testGameCompletes() {
        let computer1 = Computer(difficulty: .Hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let computer2 = Computer(difficulty: .Easy, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let game = Game.newGame(lookup: Lookup.singleton, players: [computer1, computer2], serial: true, eventHandler: eventHandler)
        game.start()
    }
    
    func testGameRestores() {
        let computer1 = Computer(difficulty: .Hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let computer2 = Computer(difficulty: .Easy, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let human1 = Human(rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let game = Game.newGame(.SuperScrabble, lookup: Lookup.singleton, players: [computer1, computer2, human1], serial: true, eventHandler: eventHandler)
        game.start()
        
        let copiedGame = Game.restoreGame(board, bag: bag, lookup: Lookup.singleton, players: game.players,
                                          playerIndex: game.playerIndex, eventHandler: eventHandler)!
        XCTAssertEqual(copiedGame.solver.boardState, game.solver.boardState)
        XCTAssertEqual(copiedGame.solver.board, game.solver.board)
    }
    
}