//
//  SolverTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import AnagramDictionary
@testable import PapyrusCore

class ScrabbleSolverTests: XCTestCase {
    var solver: Solver!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        solver = ScrabbleSolver(bagType: ScrabbleBag.self, board: ScrabbleBoard(), dictionary: AnagramDictionary.singleton!)
    }
    
    func dropWords() {
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
    
    // MARK: - Validate (No Letters)
    
    func testValidateWithNoPointsReturnsInvalidArrangement() {
        switch solver.validate([], blanks: []) {
        case .InvalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    // MARK: - Validate (One Letter)
    
    func testValidateWithOnePointOnFirstTurnReturnsInvalidArrangement() {
        switch solver.validate([(7, 7, "a")], blanks: []) {
        case .InvalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithOneLetterReturnsValidVerticalWord() {
        dropWords()
        switch solver.validate([(6, 6, "t")], blanks: []) {
        case .Valid(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithOneLetterAndNoIntersectionsReturnsInvalidArrangement() {
        dropWords()
        switch solver.validate([(1, 1, "t")], blanks: []) {
        case .InvalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithNoCenterIntersectionReturnsInvalidArrangement() {
        switch solver.validate([(4, 6, "s"), (5, 6, "h"), (6, 6, "e")], blanks: []) {
        case .InvalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithOneLetterReturnsValidWords() {
        dropWords()
        solver.board.layout[6][6] = "t"
        switch solver.validate([(7, 6, "a")], blanks: []) {
        case .Valid(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithOneLetterReturnsInvalidHorizontalWord() {
        dropWords()
        switch solver.validate([(5, 8, "z")], blanks: []) {
        case .InvalidWord(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithOneLetterReturnsInvalidVerticalWord() {
        dropWords()
        switch solver.validate([(7, 8, "t")], blanks: []) {
        case .InvalidWord(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    // MARK: - Validate (Multiple Letters)
    
    func testValidateWithTwoLettersReturnsValidHorizontalWord() {
        dropWords()
        switch solver.validate([(9, 7, "e"), (10, 7, "d")], blanks: []) {
        case .Valid(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithThreeLettersReturnsValidVerticalWord() {
        dropWords()
        switch solver.validate([(6, 4, "u"), (6, 5, "n"), (6, 6, "m")], blanks: []) {
        case .Valid(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithScatteredLettersReturnsInvalidArrangement() {
        dropWords()
        switch solver.validate([(6, 4, "u"), (7, 5, "n"), (3, 2, "m")], blanks: []) {
        case .InvalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithScatteredLettersWithSameXReturnsInvalidArrangement() {
        dropWords()
        switch solver.validate([(6, 4, "u"), (6, 10, "n"), (6, 12, "m")], blanks: []) {
        case .InvalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithScatteredLettersWithSameYReturnsInvalidArrangement() {
        dropWords()
        switch solver.validate([(4, 7, "u"), (10, 7, "n"), (12, 7, "m")], blanks: []) {
        case .InvalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithHorizontalWordReturnsInvalidWord() {
        dropWords()
        switch solver.validate([(4, 7, "u"), (9, 7, "n"), (10, 7, "m")], blanks: []) {
        case .InvalidWord(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithVerticalWordReturnsValidWords() {
        dropWords()
        solver.board.layout[6][6] = "t"
        switch solver.validate([(7, 6, "a"), (7, 5, "c")], blanks: []) {
        case .Valid(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithHorizontalWordReturnsValidWords() {
        dropWords()
        solver.board.layout[6][6] = "t"
        switch solver.validate([(7, 6, "e"), (8, 6, "a")], blanks: []) {
        case .Valid(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithNoIntersectionsReturnsInvalidArrangement() {
        dropWords()
        switch solver.validate([(2, 2, "b"), (2, 3, "i"), (2, 4, "t")], blanks: []) {
        case .InvalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithVerticalWordAndInvalidIntersectionsReturnsInvalidWord() {
        dropWords()
        switch solver.validate([(7, 8, "a"), (7, 9, "n")], blanks: []) {
        case .InvalidWord(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithVerticalWordReturnsInvalidWord() {
        dropWords()
        switch solver.validate([(6, 6, "u"), (6, 5, "n"), (6, 11, "m")], blanks: []) {
        case .InvalidWord(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    // MARK: - WordAt
    
    func testWordAt() {
        dropWords()
        let _word = solver.wordAt(5, 7, points: [], horizontal: true)
        XCTAssertNotNil(_word)
        let word = _word!
        XCTAssertEqual(word.word.word, "cart")
        XCTAssertTrue(word.valid)
        XCTAssertTrue(word.word.horizontal)
        XCTAssertEqual(word.word.x, 5)
        XCTAssertEqual(word.word.y, 7)
        XCTAssertEqual(word.word.length(), 4)
    }
    
    // MARK: - IntersectionsAt
    
    func testIntersectionsAt() {
        dropWords()
        let word = solver.wordAt(5, 7, points: [], horizontal: true)!
        let intersections = solver.intersections(forWord: word.word)
        XCTAssertEqual(intersections.words.count, 1)
        XCTAssertEqual(intersections.words.first!.word, "asked")
        XCTAssertEqual(intersections.words.first!.x, 6)
        XCTAssertEqual(intersections.words.first!.y, 7)
        XCTAssertFalse(intersections.words.first!.horizontal)
    }
    
    // MARK: - SolutionForWord
    
    func testSolutionForWord() {
        dropWords()
        let word = solver.wordAt(5, 7, points: [], horizontal: true)!
        let solution = solver.solution(forWord: word.word, rackLetters: [])!
        let intersections = solver.intersections(forWord: word.word)
        XCTAssertEqual(solution.horizontal, word.word.horizontal)
        XCTAssertEqual(solution.x, word.word.x)
        XCTAssertEqual(solution.y, word.word.y)
        XCTAssertEqual(solution.intersections, intersections.words)
    }
    
    func testSolutionForWordInvalidIntersection() {
        dropWords()
        solver.board.layout[6][6] = "z"
        let word = solver.wordAt(5, 7, points: [], horizontal: true)!
        let solution = solver.solution(forWord: word.word, rackLetters: [])
        XCTAssertNil(solution)
    }
    
    // MARK: - UnvalidatedWords
    
    func testUnvalidatedWords() {
        XCTAssertEqual(self.solver.unvalidatedWords(forLetters: ["a", "r", "c", "h", "o", "n", "s"], fixedLetters: [:], length: 7)!, ["anchors", "archons", "ranchos"])
    }
    
    func testUnvalidatedWordsWithLength() {
        XCTAssertEqual(self.solver.unvalidatedWords(forLetters: ["a", "r", "c", "h", "o", "n", "s"], fixedLetters: [:], length: 6)!, ["acorns", "narcos", "racons", "anchor", "archon", "rancho", "anchos", "nachos", "sancho", "sharon", "shoran"])
    }
    
    func testUnvalidatedWordsWithFixedLetter() {
        XCTAssertEqual(self.solver.unvalidatedWords(forLetters: ["a", "c", "h", "o", "n", "s"], fixedLetters: [0:"r"], length: 7)!, ["ranchos"])
    }
    
    // MARK: - LexicographicalString
    
    func testLexicographicalString() {
        let letters: [Character] = ["z", "a", "p", "p", "e", "r"]
        XCTAssertEqual(solver.lexicographicalString(withLetters: letters), "aepprz")
    }
    
    // MARK: - Blanks
    
    func testBlanks() {
        let rackTiles: [RackTile] = [("a", false), ("c", true), ("r", false), ("o", true), ("n", false), ("h", false)]
        let word = Word(word: "archon", x: 7, y: 7, horizontal: true)
        XCTAssertEqual(solver.blanks(forWord: word, rackLetters: rackTiles).map({ $0.x }), [9, 11])
    }
    
    // MARK: - Solve
    
    func testSolveWithNoItems() {
        XCTAssertNil(solver.solve([]))
    }
    
    func testScaling() {
        dropWords()
        let rack: [RackTile] = ["c", "a", "r", "t", "e", "d"].map({ ($0, false) })
        self.solver.solutions(rack, serial: true) { (solutions) in
            guard let solutions = solutions else {
                XCTAssert(false)
                return
            }
            
            let hard = self.solver.solve(solutions)!
            let hardExpectation = Solution(word: "created", x: 4, y: 10, horizontal: true, score: 40, intersections: [
                Word(word: "asked", x: 6, y: 7, horizontal: false)], blanks: [])
            XCTAssertEqual(hard, hardExpectation)
            
            let medium = self.solver.solve(solutions, difficulty: .Medium)!
            let mediumExpectation = Solution(word: "derat", x: 7, y: 10, horizontal: false, score: 28, intersections: [
                Word(word: "ed", x: 6, y: 10, horizontal: true),
                Word(word: "de", x: 6, y: 11, horizontal: true)], blanks: [])
            XCTAssertEqual(medium, mediumExpectation)
            
            let easy = self.solver.solve(solutions, difficulty: .Easy)!
            let easyExpectation = Solution(word: "tacked", x: 3, y: 9, horizontal: true, score: 19, intersections: [
                Word(word: "asked", x: 6, y: 7, horizontal: false)], blanks: [])
            XCTAssertEqual(easy, easyExpectation)
            
            let veryEasy = self.solver.solve(solutions, difficulty: .VeryEasy)!
            let veryEasyExpectation = Solution(word: "tetrad", x: 8, y: 5, horizontal: false, score: 9, intersections: [
                Word(word: "cart", x: 5, y: 7, horizontal: true)], blanks: [])
            XCTAssertEqual(veryEasy, veryEasyExpectation)
        }
    }
    
    // MARK: - Solutions
    
    func testZeroTilesSolution() {
        solver.solutions([], serial: true, completion: { (solutions) in
            XCTAssertNil(solutions)
        })
    }
    
    func testBestSolution() {
        dropWords()
        var racks = [[RackTile]]()
        racks.append([("a", false), ("r", false), ("t", false), ("i", false), ("s", false), ("t", false)])
        racks.append([("b", false), ("a", false), ("t", false), ("h", false), ("e", false), ("r", false)])
        racks.append([("c", false), ("e", false), ("l", false), ("i", false), ("a", false), ("c", false)])
        racks.append([("z", false), ("e", false), ("b", false), ("r", false), ("a", false), ("s", false)])
        racks.append([("q", false), ("u", false), ("e", false), ("e", false), ("n", false), ("y", false)])
        racks.append([("s", false), ("t", false), ("a", false), ("g", false), ("e", false), ("d", false)])
        racks.append([("r", false), ("a", false), ("t", false), ("i", false), ("n", false), ("g", false)])
        racks.append([(Game.blankLetter, true), ("a", false), ("t", false), (Game.blankLetter, true), ("n", false), ("g", false)])    // Double wildcard is very slow, CPU should not get two wildcards, if it does lets randomize one of them to a specific value
        racks.append([(Game.blankLetter, true), ("a", false), ("t", false), ("i", false), ("n", false), ("g", false)])    // Single wildcard is also slow, just not as bad
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
       
        for (index, rack) in racks.enumerate() {
            let expectation = expectations[index]
            solver.solutions(rack, serial: true, completion: { (solutions) in
                let best = self.solver.solve(solutions!)!
                XCTAssertEqual(best, expectation)
                self.solver.play(best)
            })
        }
    }
}
