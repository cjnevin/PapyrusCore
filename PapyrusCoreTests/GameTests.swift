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
    var testConfigurationURL: URL {
        return URL(fileURLWithPath: Bundle(for: self.dynamicType).pathForResource("TestConfiguration", ofType: "json")!)
    }
    
    func eventHandler(_ event: GameEvent) {
        
    }
    
    func testBagCount() {
        let computer1 = Computer(difficulty: .hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let computer2 = Computer(difficulty: .easy, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let human1 = Human(rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let game = try! Game(config: testConfigurationURL,
                        dictionary: AnagramDictionary.singleton!,
                        players: [computer1, computer2, human1], playerIndex: 0, serial: true, eventHandler: eventHandler)
        XCTAssertEqual(game.bag.remaining.count, game.bag.total - 21)
    }
    
    func testGameCompletes() {
        let computer1 = Computer(difficulty: .hard, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let computer2 = Computer(difficulty: .easy, rack: [], score: 0, solves: [], consecutiveSkips: 0)
        let game = try! Game(config: testConfigurationURL,
                             dictionary: AnagramDictionary.singleton!,
                             players: [computer1, computer2], playerIndex: 0, serial: true, eventHandler: eventHandler)
        game.start()
    }
    
    func checkBoardEquality(_ lhs: Board, _ rhs: Board) {
        XCTAssertEqual(lhs, rhs)
    }
    
    func testGameRestores() {
        /*let dictionary = AnagramDictionary.singleton!
        let turnCountExpectation = expectation(withDescription: "GameRestores")
        let game = try! Game(config: testConfigurationURL,
                             dictionary: AnagramDictionary.singleton!,
                             players:  [Computer(), Computer(), Human()], playerIndex: 0, serial: true,
                             eventHandler: { event in
                                switch event {
                                case let .turnBegan(currentGame):
                                    print("Turn Began")
                                    if currentGame.player is Human {
                                        currentGame.stop()
                                    }
                                case .over(_, _):
                                    turnCountExpectation.fulfill()
                                default:
                                    break
                                }
        })
        game.start()
        waitForExpectations(withTimeout: 60, handler: nil)
        
        let copiedGame = Game(bag: bag, board: board, dictionary: AnagramDictionary.singleton!, players: game.players,
                              playerIndex: game.playerIndex, eventHandler: eventHandler)
        XCTAssertEqual(copiedGame.solver.boardState, game.solver.boardState)
        checkBoardEquality(copiedGame.solver.board, game.solver.board)*/
    }
    
    func testGameRestoresFromFile() {
        /*let dictionary = AnagramDictionary.singleton!
        let turnCountExpectation = expectation(withDescription: "GameRestoresFromFile")
        let game = Game(gameType: gameType, dictionary: dictionary, players: [Computer(), Computer(), Human()], serial: true, eventHandler: { event in
            switch event {
            case let .turnBegan(currentGame):
                print("Turn Began")
                if currentGame.player is Human {
                    currentGame.stop()
                }
            case .over(_, _):
                turnCountExpectation.fulfill()
            default:
                break
            }
        })
        game.start()
        waitForExpectations(withTimeout: 60, handler: nil)
        
        let url = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/game.json")
        XCTAssert(game.save(to: url))
        
        guard let loadedGame = Game(from: url, dictionary: dictionary, eventHandler: eventHandler) else {
            XCTFail()
            return
        }
        XCTAssertEqual(String(loadedGame.bag.remaining), String(game.bag.remaining))
        XCTAssertEqual(loadedGame.solver.boardState, game.solver.boardState)
        checkBoardEquality(loadedGame.solver.board, game.solver.board)*/
    }
    
}
