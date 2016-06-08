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
        solver = Solver(board: Board(config: ScrabbleBoardConfig()), lookup: Lookup.singleton, distribution: distribution)
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
    
    func testUnvalidatedWords() {
        measureBlock {
            XCTAssertEqual(self.solver.unvalidatedWords(forLetters: ["a", "r", "c", "h", "o", "n", "s"], fixedLetters: [:], length: 7)!, ["anchors", "archons", "ranchos"])
        }
    }
    
    func testUnvalidatedWordsWithFixedLetter() {
        measureBlock {
            XCTAssertEqual(self.solver.unvalidatedWords(forLetters: ["a", "c", "h", "o", "n", "s"], fixedLetters: [0:"r"], length: 7)!, ["ranchos"])
        }
    }
    
    func testLexicographicalString() {
        let letters: [Character] = ["z", "a", "p", "p", "e", "r"]
        XCTAssertEqual(solver.lexicographicalString(withLetters: letters), "aepprz")
    }
    
    func testBlanks() {
        let rackTiles: [RackTile] = [("a", false), ("c", true), ("r", false), ("o", true), ("n", false), ("h", false)]
        let word = Word(word: "archon", x: 7, y: 7, horizontal: true)
        XCTAssertEqual(solver.blanks(forWord: word, rackLetters: rackTiles).map({ $0.x }), [9, 11])
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
        self.solver.solutions(rack, serial: true) { (solutions) in
            guard let solutions = solutions else { XCTAssert(false); return }
            let hard = self.solver.solve(solutions)!
            let medium = self.solver.solve(solutions, difficulty: .Medium)!
            let easy = self.solver.solve(solutions, difficulty: .Easy)!
            let veryEasy = self.solver.solve(solutions, difficulty: .VeryEasy)!
            
            let hardExpectation = Solution(word: "created", x: 4, y: 10, horizontal: true, score: 40, intersections: [
                Word(word: "asked", x: 6, y: 7, horizontal: false)], blanks: [])
            
            let mediumExpectation = Solution(word: "derat", x: 7, y: 10, horizontal: false, score: 28, intersections: [
                Word(word: "ed", x: 6, y: 10, horizontal: true),
                Word(word: "de", x: 6, y: 11, horizontal: true)], blanks: [])
            
            let easyExpectation = Solution(word: "tacked", x: 3, y: 9, horizontal: true, score: 19, intersections: [
                Word(word: "asked", x: 6, y: 7, horizontal: false)], blanks: [])
            
            let veryEasyExpectation = Solution(word: "tetrad", x: 8, y: 5, horizontal: false, score: 9, intersections: [
                Word(word: "cart", x: 5, y: 7, horizontal: true)], blanks: [])
            
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
            Solution(word: "tiars", x: 7, y: 10, horizontal: false, score: 24, intersections: [Word(word: "et", x: 6, y: 10, horizontal: true), Word(word: "di", x: 6, y: 11, horizontal: true)], blanks: []),
            Solution(word: "abetter", x: 4, y: 10, horizontal: true, score: 36, intersections: [Word(word: "asked", x: 6, y: 7, horizontal: false), Word(word: "tiars", x: 7, y: 10, horizontal: false)], blanks: []),
            Solution(word: "ceil", x: 6, y: 6, horizontal: true, score: 31, intersections: [Word(word: "casked", x: 6, y: 6, horizontal: false), Word(word: "er", x: 7, y: 6, horizontal: false), Word(word: "it", x: 8, y: 6, horizontal: false)], blanks: []),
            Solution(word: "zebra", x: 0, y: 11, horizontal: true, score: 54, intersections: [Word(word: "aa", x: 4, y: 10, horizontal: false)], blanks: []),
            Solution(word: "queyn", x: 1, y: 9, horizontal: false, score: 74, intersections: [Word(word: "zebra", x: 0, y: 11, horizontal: true)], blanks: []),
            Solution(word: "tsade", x: 0, y: 14, horizontal: true, score: 42, intersections: [Word(word: "queyns", x: 1, y: 9, horizontal: false)], blanks: []),
            Solution(word: "gratin", x: 10, y: 2, horizontal: false, score: 21, intersections: [Word(word: "ceili", x: 6, y: 6, horizontal: true)], blanks: []),
            Solution(word: "gant", x: 10, y: 8, horizontal: true, score: 15, intersections: [Word(word: "grating", x: 10, y: 2, horizontal: false)], blanks: []),
            Solution(word: "ngati", x: 2, y: 5, horizontal: false, score: 20, intersections: [Word(word: "qi", x: 1, y: 9, horizontal: true)], blanks: []),
            Solution(word: "cat", x: 8, y: 5, horizontal: true, score: 16, intersections: [Word(word: "cit", x: 8, y: 5, horizontal: false), Word(word: "al", x: 9, y: 5, horizontal: false), Word(word: "grating", x: 10, y: 2, horizontal: false)], blanks: [])]
        
        multipleRacksTest(racks, solutions: expectations)
        
        print(solver.board)
        print(solver.boardState)
    }
}
