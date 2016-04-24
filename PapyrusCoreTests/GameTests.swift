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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        bag = Bag(withBlanks: false)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        bag = nil
    }
    
    func eventHandler(event: GameEvent) {
        
    }
    
    func testBagCount() {
        let computer1 = Computer(difficulty: .Hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let computer2 = Computer(difficulty: .Easy, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let human1 = Human(rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let game = Game.newGame(Dawg.singleton, bag: bag, players: [computer1, computer2, human1], eventHandler: eventHandler)
        XCTAssertEqual(game.bag.remaining.count, 99 - 21)
    }
    
    func testGameCompletes() {
        let computer1 = Computer(difficulty: .Hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let computer2 = Computer(difficulty: .Easy, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        var game = Game.newGame(Dawg.singleton, bag: Bag(withBlanks: false), players: [computer1, computer2], eventHandler: eventHandler)
        game.start()
    }
    
    func testGameStopsOnHumanTurn() {
        let computer1 = Computer(difficulty: .Hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let computer2 = Computer(difficulty: .Easy, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let human1 = Human(rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let bagTotal = bag.remaining.count
        XCTAssertEqual(bagTotal, 99)
        var game = Game.newGame(Dawg.singleton, bag: bag, players: [computer1, computer2, human1], eventHandler: eventHandler)
        XCTAssertEqual(game.bag.remaining.count, bagTotal - 21)
        game.start()
        XCTAssertTrue(game.player is Human)
    }
    
    func testGameRestores() {
        let computer1 = Computer(difficulty: .Hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let computer2 = Computer(difficulty: .Easy, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let human1 = Human(rack: [], score: 0, solves: [], consecutiveSkips: 0)
        var game = Game.newGame(Dawg.singleton, bag: bag, players: [computer1, computer2, human1], eventHandler: eventHandler)
        game.start()
        
        let copiedGame = Game.restoreGame(game.solver.dictionary, bag: bag, players: game.players, playerIndex: game.playerIndex, eventHandler: eventHandler)
        XCTAssertEqual(copiedGame.solver.boardState, game.solver.boardState)
        XCTAssertEqual(copiedGame.solver.board, game.solver.board)
    }
    
}