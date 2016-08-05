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
        
        let letterPoints: [Character: Int] = ["_": 0, "a": 1, "b": 3, "c": 3, "d": 2,
                            "e": 1, "f": 4, "g": 2, "h": 4, "i": 1,
                            "j": 8, "k": 5, "l": 1, "m": 3, "n": 1,
                            "o": 1, "p": 3, "q": 10, "r": 1, "s": 1,
                            "t": 1, "u": 1, "v": 4, "w": 4, "x": 8,
                            "y": 4, "z": 10]
        
        solver = Solver(allTilesUsedBonus: 50, maximumWordLength: 15, letterPoints: letterPoints,
               board: SolverTests.getBoard(), dictionary: AnagramDictionary.singleton!, debug: false)
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
            let mediumExpectation = Solution(word: "recta", x: 7, y: 10, horizontal: false, score: 30, intersections: [
                Word(word: "er", x: 6, y: 10, horizontal: true),
                Word(word: "de", x: 6, y: 11, horizontal: true)], blanks: [])
            XCTAssertEqual(medium, mediumExpectation)
            
            let easy = self.solver.solve(with: solutions, difficulty: .easy)!
            let easyExpectation = Solution(word: "reacted", x: 5, y: 10, horizontal: true, score: 20, intersections: [
                Word(word: "asked", x: 6, y: 7, horizontal: false)], blanks: [])
            XCTAssertEqual(easy, easyExpectation)
            
            let veryEasy = self.solver.solve(with: solutions, difficulty: .veryEasy)!
            let veryEasyExpectation = Solution(word: "ared", x: 5, y: 11, horizontal: false, score: 10, intersections: [
                Word(word: "ad", x: 5, y: 11, horizontal: true)], blanks: [])
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
            Solution(word: "airts", x: 7, y: 10, horizontal: false, score: 24, intersections: [Word(word: "ea", x: 6, y: 10, horizontal: true), Word(word: "di", x: 6, y: 11, horizontal: true)], blanks: []),
            Solution(word: "breathe", x: 4, y: 10, horizontal: true, score: 48, intersections: [Word(word: "asked", x: 6, y: 7, horizontal: false), Word(word: "airts", x: 7, y: 10, horizontal: false)], blanks: []),
            Solution(word: "celiac", x: 9, y: 9, horizontal: true, score: 33, intersections: [Word(word: "ch", x: 9, y: 9, horizontal: false), Word(word: "ee", x: 10, y: 9, horizontal: false)], blanks: []),
            Solution(word: "zeribas", x: 12, y: 6, horizontal: false, score: 58, intersections: [Word(word: "celiac", x: 9, y: 9, horizontal: true)], blanks: []),
            Solution(word: "queechy", x: 9, y: 5, horizontal: false, score: 51, intersections: [Word(word: "carte", x: 5, y: 7, horizontal: true), Word(word: "celiac", x: 9, y: 9, horizontal: true), Word(word: "breathe", x: 4, y: 10, horizontal: true)], blanks: []),
            Solution(word: "gedacts", x: 14, y: 5, horizontal: false, score: 36, intersections: [Word(word: "celiac", x: 9, y: 9, horizontal: true)], blanks: []),
            Solution(word: "gratin", x: 10, y: 1, horizontal: false, score: 27, intersections: [Word(word: "qi", x: 9, y: 5, horizontal: true), Word(word: "un", x: 9, y: 6, horizontal: true)], blanks: []),
            Solution(word: "tang", x: 11, y: 11, horizontal: false, score: 20, intersections: [Word(word: "ta", x: 11, y: 11, horizontal: true), Word(word: "as", x: 11, y: 12, horizontal: true)], blanks: []),
            Solution(word: "tangi", x: 0, y: 11, horizontal: true, score: 18, intersections: [Word(word: "bi", x: 4, y: 10, horizontal: false)], blanks: []),
            Solution(word: "ta", x: 6, y: 6, horizontal: true, score: 17, intersections: [Word(word: "tasked", x: 6, y: 6, horizontal: false), Word(word: "ar", x: 7, y: 6, horizontal: false)], blanks: [])]
       
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
