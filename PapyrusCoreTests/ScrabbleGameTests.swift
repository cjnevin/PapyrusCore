//
//  GameTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import AnagramDictionary
@testable import PapyrusCore

class ScrabbleGameTests: XCTestCase {
    
    var bag: Bag!
    var board: Board!
    var total: Int!
    var gameType: GameType!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        bag = ScrabbleBag()
        board = ScrabbleBoard()
        gameType = .scrabble
        total = ScrabbleBag.total
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        bag = nil
        board = nil
    }
    
    func eventHandler(_ event: GameEvent) {
        
    }
    
    func testBagCount() {
        let computer1 = Computer(difficulty: .hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let computer2 = Computer(difficulty: .easy, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let human1 = Human(rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let game = Game(gameType: gameType, dictionary: AnagramDictionary.singleton!, players: [computer1, computer2, human1], serial: true, eventHandler: eventHandler)
        XCTAssertEqual(game.bag.remaining.count, total - 21)
    }
    
    func testGameCompletes() {
        let computer1 = Computer(difficulty: .hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let computer2 = Computer(difficulty: .easy, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let game = Game(gameType: gameType, dictionary: AnagramDictionary.singleton!, players: [computer1, computer2], serial: true, eventHandler: eventHandler)
        game.start()
    }
    
    func checkBoardEquality(_ lhs: Board, _ rhs: Board) {
        XCTAssertEqual(lhs as? ScrabbleBoard, rhs as? ScrabbleBoard)
    }
    
    func testGameRestores() {
        let computer1 = Computer(difficulty: .hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let computer2 = Computer(difficulty: .easy, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let human1 = Human(rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let game = Game(gameType: gameType, dictionary: AnagramDictionary.singleton!, players: [computer1, computer2, human1], serial: true, eventHandler: eventHandler)
        game.start()
        
        let copiedGame = Game(bag: bag, board: board, dictionary: AnagramDictionary.singleton!, players: game.players,
                                          playerIndex: game.playerIndex, eventHandler: eventHandler)
        XCTAssertEqual(copiedGame.solver.boardState, game.solver.boardState)
        checkBoardEquality(copiedGame.solver.board, game.solver.board)
    }
    
}
