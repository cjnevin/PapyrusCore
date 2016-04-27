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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        solver = Solver(dictionary: Dawg.singleton)
        // Setup default state
        solver.play(Solution(word: "cart", 5, 7, true, 0, []))
        solver.play(Solution(word: "asked", 6, 7, false, 0, ["cart"]))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        solver = nil
    }
    
    func testSolutionsPerformance() {
        measureBlock {
            self.solver.solve(Array("aecdefs".characters))
        }
    }
    
    func compareSolution(solution: Solution, expected: Solution) {
        XCTAssertEqual(expected.word, solution.word)
        XCTAssertEqual(expected.score, solution.score)
        XCTAssertEqual(expected.horizontal, solution.horizontal)
        XCTAssertEqual(expected.x, solution.x)
        XCTAssertEqual(expected.y, solution.y)
        XCTAssertEqual(expected.intersections, solution.intersections)
    }
    
    func multipleRacksTest(racks: [[Character]], solutions: [Solution]) {
        for (index, rack) in racks.enumerate() {
            let best = solver.solve(rack)!
            let expectation = solutions[index]
            compareSolution(best, expected: expectation)
            solver.play(best)
            print("Played: \(best)")
            
        }
    }
    
    func testScaling() {
        let rack: [Character] = ["c", "a", "r", "t", "e", "d"]
        let solutions = solver.solutions(rack)!
        let hard = solver.solve(solutions)!
        let medium = solver.solve(solutions, difficulty: .Medium)!
        let easy = solver.solve(solutions, difficulty: .Easy)!
        let veryEasy = solver.solve(solutions, difficulty: .VeryEasy)!
        compareSolution(hard, expected: ("crated", 9, 5, false, 24, ["carta"]))
        compareSolution(medium, expected: ("acred", 9, 7, false, 17, ["carta"]))
        compareSolution(easy, expected: ("arced", 8, 8, true, 11, ["ta"]))
        compareSolution(veryEasy, expected: ("aret", 8, 8, true, 5, ["ta"]))
    }
    
    func testZeroTilesSolution() {
        XCTAssertNil(solver.solutions([]))
    }
    
    func testBestSolution() {
        var racks = [[Character]]()
        racks.append(["a", "r", "t", "i", "s", "t"])
        racks.append(["b", "a", "t", "h", "e", "r"])
        racks.append(["c", "e", "l", "i", "a", "c"])
        racks.append(["z", "e", "b", "r", "a", "s"])
        racks.append(["q", "u", "e", "e", "n", "y"])
        racks.append(["s", "t", "a", "g", "e", "d"])
        racks.append(["r", "a", "t", "i", "n", "g"])
        racks.append(["?", "a", "t", "?", "n", "g"])    // Double wildcard is very slow, CPU should not get two wildcards, if it does lets randomize one of them to a specific value
        racks.append(["?", "a", "t", "i", "n", "g"])    // Single wildcard is also slow, just not as bad
        racks.append(["c", "a", "t"])
        
        var expectations = [Solution]()
        expectations.append(("traits", 4, 2, false, 19, ["scart"]))
        expectations.append(("breath", 3, 0, false, 41, ["et", "ar", "ta", "hi"]))
        expectations.append(("cicale", 2, 3, false, 28, ["car", "ita", "chi"]))
        expectations.append(("brazes", 9, 2, false, 45, ["scarts"]))
        expectations.append(("queen", 10, 0, false, 38, ["be", "re", "an"]))
        expectations.append(("staged", 11, 2, false, 34, ["bes", "ret", "ana"]))
        expectations.append(("git", 12, 0, false, 20, ["best"]))
        expectations.append(("tsk", 5, 3, false, 50, ["cart", "itas", "chik"]))
        expectations.append(("nix", 12, 4, false, 42, ["anan", "gi", "ex"]))
        expectations.append(("cat", 13, 3, false, 18, ["anana", "git"]))
        
        multipleRacksTest(racks, solutions: expectations)
        
        print(solver.board)
        print(solver.boardState)
    }
}
