//
//  SolverTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class SolverTests: XCTestCase {
    
    var solver: Solver!
    let distribution = ScrabbleDistribution()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        solver = Solver(board: Board(config: ScrabbleBoardConfig()), dictionary: Dawg.singleton, distribution: distribution)
        // Setup default state
        solver.play(Solution(word: "cart", 5, 7, true, 0, [], []))
        solver.play(Solution(word: "asked", 6, 7, false, 0, ["cart"], []))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        solver = nil
    }
    
    func compareSolution(solution: Solution, expected: Solution) {
        XCTAssertEqual(expected.word, solution.word)
        XCTAssertEqual(expected.score, solution.score)
        XCTAssertEqual(expected.horizontal, solution.horizontal)
        XCTAssertEqual(expected.x, solution.x)
        XCTAssertEqual(expected.y, solution.y)
        XCTAssertEqual(expected.intersections, solution.intersections)
    }
    
    func multipleRacksTest(racks: [[RackTile]], solutions: [Solution]) {
        for (index, rack) in racks.enumerate() {
            let expectation = solutions[index]
            solver.solutions(rack, serial: true, completion: { (solutions) in
                let best = self.solver.solve(solutions!)!
                self.compareSolution(best, expected: expectation)
                self.solver.play(best)
            })
        }
    }
    
    func testScaling() {
        let rack: [RackTile] = ["c", "a", "r", "t", "e", "d"].map({ ($0, false) })
        solver.solutions(rack, serial: true) { (solutions) in
            guard let solutions = solutions else { XCTAssert(false); return }
            let hard = self.solver.solve(solutions)!
            let medium = self.solver.solve(solutions, difficulty: .Medium)!
            let easy = self.solver.solve(solutions, difficulty: .Easy)!
            let veryEasy = self.solver.solve(solutions, difficulty: .VeryEasy)!
            self.compareSolution(hard, expected: ("tead", 6, 6, true, 24, ["tasked", "er", "at"], []))
            self.compareSolution(medium, expected: ("acred", 9, 7, false, 17, ["carta"], []))
            self.compareSolution(easy, expected: ("aced", 8, 8, true, 11, ["ta"], []))
            self.compareSolution(veryEasy, expected: ("at", 5, 11, false, 5, ["ad"], []))
        }
        //let solutions = solver.solutions(rack)!
    }
    
    func testZeroTilesSolution() {
        solver.solutions([], serial: true, completion: { (solutions) in
            XCTAssertNil(solutions)
        })
    }
    
    func testBestSolution() {
        var racks = [[RackTile]]()
        racks.append([("a", false), ("r", false), ("t", false), ("i", false), ("s", false), ("t", false)])
        racks.append([("b", false), ("a", false), ("t", false), ("h", false), ("e", false), ("r", false)])
        racks.append([("c", false), ("e", false), ("l", false), ("i", false), ("a", false), ("c", false)])
        racks.append([("z", false), ("e", false), ("b", false), ("r", false), ("a", false), ("s", false)])
        racks.append([("q", false), ("u", false), ("e", false), ("e", false), ("n", false), ("y", false)])
        racks.append([("s", false), ("t", false), ("a", false), ("g", false), ("e", false), ("d", false)])
        racks.append([("r", false), ("a", false), ("t", false), ("i", false), ("n", false), ("g", false)])
        racks.append([("?", true), ("a", false), ("t", false), ("?", true), ("n", false), ("g", false)])    // Double wildcard is very slow, CPU should not get two wildcards, if it does lets randomize one of them to a specific value
        racks.append([("?", true), ("a", false), ("t", false), ("i", false), ("n", false), ("g", false)])    // Single wildcard is also slow, just not as bad
        racks.append([("c", false), ("a", false), ("t", false)])
    
        
        var expectations = [Solution]()
        expectations.append(("taits", 6, 6, true, 24, ["tasked", "ar", "it"], []))
        expectations.append(("thrae", 10, 7, true, 38, ["st"], []))
        expectations.append(("ciel", 8, 5, true, 20, ["cit", "it", "est"], []))
        expectations.append(("zebra", 10, 4, true, 60, ["zest", "el"], []))
        expectations.append(("nye", 9, 8, true, 28, ["zesty", "he"], []))
        expectations.append(("gaed", 11, 3, true, 35, ["gel", "ab", "er", "da"], []))
        expectations.append(("ani", 7, 9, false, 16, ["ka", "en", "di"], []))
        expectations.append(("ag", 5, 9, false, 18, ["aka", "gen"], []))
        expectations.append(("taig", 4, 9, false, 28, ["taka", "agen"], []))
        expectations.append(("act", 4, 13, true, 17, ["taiga"], []))
        
        multipleRacksTest(racks, solutions: expectations)
        
        print(solver.board)
        print(solver.boardState)
    }
}
