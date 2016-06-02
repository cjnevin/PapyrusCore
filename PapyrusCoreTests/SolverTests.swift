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
        solver = Solver(board: Board(config: ScrabbleBoardConfig()), anagramDictionary: AnagramDictionary.singleton, dictionary: Dawg.singleton, distribution: distribution)
        // Setup default state
        let intersection = Word(word: "cart", x: 6, y: 7, horizontal: false)
        solver.play(Solution(word: "cart", x: 5, y: 7, horizontal: true, score: 0, intersections: [], blanks: []))
        solver.play(Solution(word: "asked", x: 6, y: 7, horizontal: false, score: 0, intersections: [intersection], blanks: []))
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
        for (left, right) in zip(solution.intersections, expected.intersections) {
            XCTAssertEqual(left.word, right.word)
            XCTAssertEqual(left.horizontal, right.horizontal)
            XCTAssertEqual(left.x, right.x)
            XCTAssertEqual(left.y, right.y)
            XCTAssertNotEqual(left.horizontal, solution.horizontal)
        }
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
            
            let hardExpectation = Solution(word: "crated", x: 9, y: 5, horizontal: false, score: 24, intersections: [
                Word(word: "carta", x: 5, y: 7, horizontal: true)], blanks: [])
            
            let mediumExpectation = Solution(word: "acted", x: 9, y: 7, horizontal: false, score: 17, intersections: [
                Word(word: "carta", x: 5, y: 7, horizontal: true)], blanks: [])

            let easyExpectation = Solution(word: "ecad", x: 8, y: 8, horizontal: true, score: 11, intersections: [
                Word(word: "te", x: 8, y: 7, horizontal: false)], blanks: [])

            let veryEasyExpectation = Solution(word: "aret", x: 8, y: 7, horizontal: false, score: 5, intersections: [
                Word(word: "carta", x: 5, y: 7, horizontal: true)], blanks: [])

            
            self.compareSolution(hard, expected: hardExpectation)
            self.compareSolution(medium, expected: mediumExpectation)
            self.compareSolution(easy, expected: easyExpectation)
            self.compareSolution(veryEasy, expected: veryEasyExpectation)
        }
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
    
        
        let expectations = [
            Solution(word: "taits", x: 6, y: 6, horizontal: true, score: 24, intersections: [
                Word(word: "tasked", x: 6, y: 6, horizontal: false),
                Word(word: "ar", x: 7, y: 6, horizontal: false),
                Word(word: "it", x: 8, y: 6, horizontal: false)], blanks: []),
            Solution(word: "thrae", x: 10, y: 7, horizontal: true, score: 38, intersections: [
                Word(word: "st", x: 10, y: 6, horizontal: false)], blanks: []),
            Solution(word: "ciel", x: 8, y: 5, horizontal: true, score: 20, intersections: [
                Word(word: "cit", x: 8, y: 5, horizontal: false),
                Word(word: "it", x: 9, y: 5, horizontal: false),
                Word(word: "est", x: 10, y: 5, horizontal: false)], blanks: []),
            Solution(word: "zebra", x: 10, y: 4, horizontal: true, score: 60, intersections: [
                Word(word: "zest", x: 10, y: 4, horizontal: false),
                Word(word: "el", x: 11, y: 4, horizontal: false)], blanks: []),
            Solution(word: "eye", x: 9, y: 8, horizontal: true, score: 28, intersections: [
                Word(word: "zesty", x: 10, y: 4, horizontal: false),
                Word(word: "he", x: 11, y: 7, horizontal: false)], blanks: []),
            Solution(word: "gaed", x: 11, y: 3, horizontal: true, score: 35, intersections: [
                Word(word: "gel", x: 11, y: 3, horizontal: false),
                Word(word: "ab", x: 12, y: 3, horizontal: false),
                Word(word: "er", x: 13, y: 3, horizontal: false),
                Word(word: "da", x: 14, y: 3, horizontal: false)], blanks: []),
            Solution(word: "ani", x: 7, y: 9, horizontal: false, score: 16, intersections: [
                Word(word: "ka", x: 6, y: 9, horizontal: true),
                Word(word: "en", x: 6, y: 10, horizontal: true),
                Word(word: "di", x: 6, y: 11, horizontal: true)], blanks: []),
            Solution(word: "ag", x: 5, y: 9, horizontal: false, score: 18, intersections: [
                Word(word: "aka", x: 5, y: 9, horizontal: true),
                Word(word: "gen", x: 5, y: 10, horizontal: true)], blanks: []),
            Solution(word: "taig", x: 4, y: 9, horizontal: false, score: 28, intersections: [
                Word(word: "taka", x: 4, y: 9, horizontal: true),
                Word(word: "agen", x: 4, y: 10, horizontal: true)], blanks: []),
            Solution(word: "act", x: 4, y: 13, horizontal: true, score: 17, intersections: [
                Word(word: "taiga", x: 4, y: 9, horizontal: false)], blanks: [])]
        
        multipleRacksTest(racks, solutions: expectations)
        
        print(solver.board)
        print(solver.boardState)
    }
}
