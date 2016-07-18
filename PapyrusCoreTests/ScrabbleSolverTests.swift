//
//  SolverTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
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
        _ = solver.play(solution: Solution(word: "cart", x: 5, y: 7, horizontal: true, score: 0, intersections: [], blanks: []))
        _ = solver.play(solution: Solution(word: "asked", x: 6, y: 7, horizontal: false, score: 0, intersections: [intersection], blanks: []))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        solver = nil
    }
    
    // MARK: - Validate (No Letters)
    
    func testValidateWithNoPointsReturnsInvalidArrangement() {
        switch solver.validate(positions: [], blanks: []) {
        case .invalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    // MARK: - Validate (One Letter)
    
    func testValidateWithOnePointOnFirstTurnReturnsInvalidArrangement() {
        switch solver.validate(positions: [LetterPosition(x: 7, y: 7, letter: "a")], blanks: []) {
        case .invalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithOneLetterReturnsValidVerticalWord() {
        dropWords()
        switch solver.validate(positions: [LetterPosition(x: 6, y: 6, letter: "t")], blanks: []) {
        case .valid(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithOneLetterAndNoIntersectionsReturnsInvalidArrangement() {
        dropWords()
        switch solver.validate(positions: [LetterPosition(x: 1, y: 1, letter: "t")], blanks: []) {
        case .invalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithNoCenterIntersectionReturnsInvalidArrangement() {
        switch solver.validate(positions: [LetterPosition(x: 4, y: 6, letter: "s"), LetterPosition(x: 5, y: 6, letter: "h"), LetterPosition(x: 6, y: 6, letter: "e")], blanks: []) {
        case .invalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithOneLetterReturnsValidWords() {
        dropWords()
        solver.board.set(letter: "t", at: Position(x: 6, y: 6))
        switch solver.validate(positions: [LetterPosition(x: 7, y: 6, letter: "a")], blanks: []) {
        case .valid(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithOneLetterReturnsInvalidHorizontalWord() {
        dropWords()
        switch solver.validate(positions: [LetterPosition(x: 5, y: 8, letter: "z")], blanks: []) {
        case .invalidWord(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithOneLetterReturnsInvalidVerticalWord() {
        dropWords()
        switch solver.validate(positions: [LetterPosition(x: 7, y: 8, letter: "t")], blanks: []) {
        case .invalidWord(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    // MARK: - Validate (Multiple Letters)
    
    func testValidateWithTwoLettersReturnsValidHorizontalWord() {
        dropWords()
        switch solver.validate(positions: [LetterPosition(x: 9, y: 7, letter: "e"), LetterPosition(x: 10, y: 7, letter: "d")], blanks: []) {
        case .valid(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithThreeLettersReturnsValidVerticalWord() {
        dropWords()
        switch solver.validate(positions: [LetterPosition(x: 6, y: 4, letter: "u"), LetterPosition(x: 6, y: 5, letter: "n"), LetterPosition(x: 6, y: 6, letter: "m")], blanks: []) {
        case .valid(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithScatteredLettersReturnsInvalidArrangement() {
        dropWords()
        switch solver.validate(positions: [LetterPosition(x: 6, y: 4, letter: "u"), LetterPosition(x: 7, y: 5, letter: "n"), LetterPosition(x: 3, y: 2, letter: "m")], blanks: []) {
        case .invalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithScatteredLettersWithSameXReturnsInvalidArrangement() {
        dropWords()
        switch solver.validate(positions: [LetterPosition(x: 6, y: 4, letter: "u"), LetterPosition(x: 6, y: 10, letter: "n"), LetterPosition(x: 6, y: 12, letter: "m")], blanks: []) {
        case .invalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithScatteredLettersWithSameYReturnsInvalidArrangement() {
        dropWords()
        switch solver.validate(positions: [LetterPosition(x: 4, y: 7, letter: "u"), LetterPosition(x: 10, y: 7, letter: "n"), LetterPosition(x: 12, y: 7, letter: "m")], blanks: []) {
        case .invalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithHorizontalWordReturnsInvalidWord() {
        dropWords()
        switch solver.validate(positions: [LetterPosition(x: 4, y: 7, letter: "u"), LetterPosition(x: 9, y: 7, letter: "n"), LetterPosition(x: 10, y: 7, letter: "m")], blanks: []) {
        case .invalidWord(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithVerticalWordReturnsValidWords() {
        dropWords()
        solver.board.set(letter: "t", at: Position(x: 6, y: 6))
        switch solver.validate(positions: [LetterPosition(x: 7, y: 6, letter: "a"), LetterPosition(x: 7, y: 5, letter: "c")], blanks: []) {
        case .valid(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithHorizontalWordReturnsValidWords() {
        dropWords()
        solver.board.set(letter: "t", at: Position(x: 6, y: 6))
        switch solver.validate(positions: [LetterPosition(x: 7, y: 6, letter: "e"), LetterPosition(x: 8, y: 6, letter: "a")], blanks: []) {
        case .valid(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithNoIntersectionsReturnsInvalidArrangement() {
        dropWords()
        switch solver.validate(positions: [LetterPosition(x: 2, y: 2, letter: "b"), LetterPosition(x: 2, y: 3, letter: "i"), LetterPosition(x: 2, y: 4, letter: "t")], blanks: []) {
        case .invalidArrangement:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithVerticalWordAndInvalidIntersectionsReturnsInvalidWord() {
        dropWords()
        switch solver.validate(positions: [LetterPosition(x: 7, y: 8, letter: "a"), LetterPosition(x: 7, y: 9, letter: "n")], blanks: []) {
        case .invalidWord(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testValidateWithVerticalWordReturnsInvalidWord() {
        dropWords()
        switch solver.validate(positions: [LetterPosition(x: 6, y: 6, letter: "u"), LetterPosition(x: 6, y: 5, letter: "n"), LetterPosition(x: 6, y: 11, letter: "m")], blanks: []) {
        case .invalidWord(_):
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    // MARK: - WordAt
    
    func testWordAt() {
        dropWords()
        let _word = solver.word(startingAt: Position(x: 5, y: 7), horizontal: true, with: [])
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
        let word = solver.word(startingAt: Position(x: 5, y: 7), horizontal: true, with: [])!
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
        let word = solver.word(startingAt: Position(x: 5, y: 7), horizontal: true, with: [])!
        let solution = solver.solution(for: word.word, rackLetters: [])!
        let intersections = solver.intersections(forWord: word.word)
        XCTAssertEqual(solution.horizontal, word.word.horizontal)
        XCTAssertEqual(solution.x, word.word.x)
        XCTAssertEqual(solution.y, word.word.y)
        XCTAssertEqual(solution.intersections, intersections.words)
    }
    
    func testSolutionForWordInvalidIntersection() {
        dropWords()
        solver.board.set(letter: "z", at: Position(x: 6, y: 6))
        let word = solver.word(startingAt: Position(x: 5, y: 7), horizontal: true, with: [])!
        let solution = solver.solution(for: word.word, rackLetters: [])
        XCTAssertNil(solution)
    }
    
    // MARK: - UnvalidatedWords
    
    func testUnvalidatedWords() {
        XCTAssertEqual(self.solver.unvalidatedWords(forLetters: ["a", "r", "c", "h", "o", "n", "s"], fixedLetters: [:], length: 7)!, ["anchors", "archons", "ranchos"])
    }
    
    func testUnvalidatedWordsWithLength() {
        XCTAssertEqual(self.solver.unvalidatedWords(forLetters: ["a", "r", "c", "h", "o", "n", "s"], fixedLetters: [:], length: 6)!.sorted(), ["acorns", "narcos", "racons", "anchor", "archon", "rancho", "anchos", "nachos", "sancho", "sharon", "shoran"].sorted())
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
        let rackTiles: [RackTile] = [RackTile(letter: "a", isBlank: false),
                                     RackTile(letter: "c", isBlank: true),
                                     RackTile(letter: "r", isBlank: false),
                                     RackTile(letter: "o", isBlank: true),
                                     RackTile(letter: "n", isBlank: false),
                                     RackTile(letter: "h", isBlank: false)]
        let word = Word(word: "archon", x: 7, y: 7, horizontal: true)
        XCTAssertEqual(solver.blanks(forWord: word, rackLetters: rackTiles).map({ $0.x }), [9, 11])
    }
    
    // MARK: - Solve
    
    func testSolveWithNoItems() {
        XCTAssertNil(solver.solve(with: []))
    }
    
    func testScaling() {
        dropWords()
        let rack: [RackTile] = toRackTiles(arr: ["c", "a", "r", "t", "e", "d"].map({ ($0, false) }))
        self.solver.solutions(for: rack, serial: true) { (solutions) in
            guard let solutions = solutions else {
                XCTAssert(false)
                return
            }
            
            let hard = self.solver.solve(with: solutions)!
            let hardExpectation = Solution(word: "created", x: 4, y: 10, horizontal: true, score: 40, intersections: [
                Word(word: "asked", x: 6, y: 7, horizontal: false)], blanks: [])
            XCTAssertEqual(hard, hardExpectation)
            
            let medium = self.solver.solve(with: solutions, difficulty: .medium)!
            let mediumExpectation = Solution(word: "aced", x: 7, y: 11, horizontal: false, score: 28, intersections: [
                Word(word: "da", x: 6, y: 11, horizontal: true)], blanks: [])
            XCTAssertEqual(medium, mediumExpectation)
            
            let easy = self.solver.solve(with: solutions, difficulty: .easy)!
            let easyExpectation = Solution(word: "acre", x: 9, y: 4, horizontal: false, score: 19, intersections: [
                Word(word: "carte", x: 5, y: 7, horizontal: true)], blanks: [])
            XCTAssertEqual(easy, easyExpectation)
            
            let veryEasy = self.solver.solve(with: solutions, difficulty: .veryEasy)!
            let veryEasyExpectation = Solution(word: "ace", x: 8, y: 6, horizontal: true, score: 9, intersections: [
                Word(word: "at", x: 8, y: 6, horizontal: false)], blanks: [])
            XCTAssertEqual(veryEasy, veryEasyExpectation)
        }
    }
    
    // MARK: - Solutions
    
    func testZeroTilesSolution() {
        solver.solutions(for: [], serial: true, completion: { (solutions) in
            XCTAssertNil(solutions)
        })
    }
    
    func testBestSolution() {
        dropWords()
        var racks = [[RackTile]]()
        racks.append(toRackTiles(arr: [("a", false), ("r", false), ("t", false), ("i", false), ("s", false), ("t", false)]))
        racks.append(toRackTiles(arr: [("b", false), ("a", false), ("t", false), ("h", false), ("e", false), ("r", false)]))
        racks.append(toRackTiles(arr: [("c", false), ("e", false), ("l", false), ("i", false), ("a", false), ("c", false)]))
        racks.append(toRackTiles(arr: [("z", false), ("e", false), ("b", false), ("r", false), ("a", false), ("s", false)]))
        racks.append(toRackTiles(arr: [("q", false), ("u", false), ("e", false), ("e", false), ("n", false), ("y", false)]))
        racks.append(toRackTiles(arr: [("s", false), ("t", false), ("a", false), ("g", false), ("e", false), ("d", false)]))
        racks.append(toRackTiles(arr: [("r", false), ("a", false), ("t", false), ("i", false), ("n", false), ("g", false)]))
        racks.append(toRackTiles(arr: [(Game.blankLetter, true), ("a", false), ("t", false), (Game.blankLetter, true), ("n", false), ("g", false)]))    // Double wildcard is very slow, CPU should not get two wildcards, if it does lets randomize one of them to a specific value
        racks.append(toRackTiles(arr: [(Game.blankLetter, true), ("a", false), ("t", false), ("i", false), ("n", false), ("g", false)]))    // Single wildcard is also slow, just not as bad
        racks.append(toRackTiles(arr: [("c", false), ("a", false), ("t", false)]))
    
        let expectations = [
            Solution(word: "tiars", x: 7, y: 10, horizontal: false, score: 24, intersections: [Word(word: "et", x: 6, y: 10, horizontal: true), Word(word: "di", x: 6, y: 11, horizontal: true)], blanks: []),
            Solution(word: "abetter", x: 4, y: 10, horizontal: true, score: 36, intersections: [Word(word: "asked", x: 6, y: 7, horizontal: false), Word(word: "tiars", x: 7, y: 10, horizontal: false)], blanks: []),
            Solution(word: "ceil", x: 6, y: 6, horizontal: true, score: 31, intersections: [Word(word: "casked", x: 6, y: 6, horizontal: false), Word(word: "er", x: 7, y: 6, horizontal: false), Word(word: "it", x: 8, y: 6, horizontal: false)], blanks: []),
            Solution(word: "zebra", x: 0, y: 11, horizontal: true, score: 54, intersections: [Word(word: "aa", x: 4, y: 10, horizontal: false)], blanks: []),
            Solution(word: "queyn", x: 1, y: 9, horizontal: false, score: 74, intersections: [Word(word: "zebra", x: 0, y: 11, horizontal: true)], blanks: []),
            Solution(word: "tsade", x: 0, y: 14, horizontal: true, score: 42, intersections: [Word(word: "queyns", x: 1, y: 9, horizontal: false)], blanks: []),
            Solution(word: "gratin", x: 10, y: 2, horizontal: false, score: 21, intersections: [Word(word: "ceili", x: 6, y: 6, horizontal: true)], blanks: []),
            Solution(word: "gant", x: 10, y: 8, horizontal: true, score: 15, intersections: [Word(word: "grating", x: 10, y: 2, horizontal: false)], blanks: []),
            Solution(word: "tangi", x: 2, y: 5, horizontal: false, score: 20, intersections: [Word(word: "qi", x: 1, y: 9, horizontal: true)], blanks: []),
            Solution(word: "cant", x: 0, y: 7, horizontal: true, score: 21, intersections: [Word(word: "tangi", x: 2, y: 5, horizontal: false)], blanks: [])]
       
        for (index, rack) in racks.enumerated() {
            let expectation = expectations[index]
            solver.solutions(for: rack, serial: true, completion: { (solutions) in
                let best = self.solver.solve(with: solutions!)!
                XCTAssertEqual(best, expectation)
                _ = self.solver.play(solution: best)
            })
        }
    }
}
