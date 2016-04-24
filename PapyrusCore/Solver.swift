//
//  Solver.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public typealias Solution = (word: String, x: Int, y: Int, horizontal: Bool, score: Int, intersections: [String])

struct Solver {
    private(set) var board: Board
    private(set) var boardState: BoardState
    let dictionary: Dawg
    private let debug: Bool
    private let maximumWordLength = 10
    
    init(dictionary: Dawg, debug: Bool = false) {
        self.board = Board()
        boardState = BoardState(board: self.board)
        self.debug = debug
        self.dictionary = dictionary
    }
    
    private func charactersAt(x: Int, y: Int, length: Int, horizontal: Bool) -> [Int: (Int, Character?)]? {
        var filled = [Int: (Int, Character?)]()
        var index = 0
        var offset = boardState[horizontal][y][x]
        let getValue = { self.board.letterAt(horizontal ? offset : x, horizontal ? y : offset) }
        let addValue = {
            if offset < self.board.boardSize {
                filled[offset] = (index, getValue())
                index += 1
                offset += 1
            }
        }
        let collect = {
            while offset < self.board.boardSize && getValue() != nil {
                addValue()
            }
        }
        collect()
        (0..<length).forEach{ _ in addValue() }
        collect()
        return filled.count == 0 ? nil : filled
    }
    
    private func wordAt(x: Int, y: Int, string: String, horizontal: Bool) -> (word: String, start: Int, end: Int) {
        assert(!string.isEmpty)
        
        if horizontal && x > 0 && board.isFilledAt(x - 1, y) {
            return wordAt(x - 1, y: y, string: string, horizontal: horizontal)
        } else if !horizontal && y > 0 && board.isFilledAt(x, y - 1) {
            return wordAt(x, y: y - 1, string: string, horizontal: horizontal)
        }
        
        var chars = [Character]()
        let start: Int = boardState[horizontal][y][x]
        var end: Int = start
        var valueFunc: (Int) -> (Character?) = { self.board.letterAt(horizontal ? $0 : x, horizontal ? y : $0) }
        func collect() {
            if end >= board.boardSize { return }
            var char: Character? = valueFunc(end)
            while let value = char {
                chars.append(value)
                end += 1
                char = end < board.boardSize ? valueFunc(end) : nil
            }
        }
        collect()
        for char in string.characters {
            chars.append(char)
            end += 1
            collect()
        }
        return (String(chars), start, end)
    }
    
    private func calculateScore(x: Int, y: Int, word: String, horizontal: Bool) -> Int {
        var tilesUsed = 0
        var score = 0
        var scoreMultiplier = 1
        var intersectionsScore = 0
        
        func wordSum(word: String) -> Int {
            return word.characters.map{ board.letterPoints[$0]! }.reduce(0, combine: +)
        }
        
        func scoreLetter(letter: Character, x: Int, y: Int, horizontal: Bool) {
            let value = board.letterPoints[letter]!
            if board.isFilledAt(x, y) {
                score += value
                return
            }
            let letterMultiplier = board.letterMultipliers[y][x]
            let wordMultiplier = board.wordMultipliers[y][x]
            tilesUsed += 1
            score += value * letterMultiplier
            scoreMultiplier *= wordMultiplier
            let intersectingWord = wordAt(x, y: y, string: String(letter), horizontal: horizontal).word
            if intersectingWord.characters.count > 1 {
                let wordScore = wordSum(intersectingWord) + (value * (letterMultiplier - 1))
                intersectionsScore += wordScore * wordMultiplier
            }
        }
        
        for (i, letter) in word.characters.enumerate() {
            scoreLetter(letter, x: horizontal ? x + i : x, y: horizontal ? y : y + i, horizontal: true)
        }
        
        return (score * scoreMultiplier) + intersectionsScore + (tilesUsed == 7 ? board.allTilesUsedBonus : 0)
    }
    
    mutating func play(solution: Solution) -> [Character] {
        let dropped = board.play(solution)
        boardState = BoardState(board: board)
        return dropped
    }
    
    func solutions(letters: [Character]) -> [Solution]? {
        if letters.count == 0 {
            return nil
        }
        
        var solutions = [Solution]()
        
        func solutionsAt(x x: Int, y: Int, length: Int, horizontal: Bool) {
            if !board.isValidSpot(x, y: y, length: length, horizontal: horizontal) {
                return
            }
            
            // Collect characters that are filled
            guard let characters = charactersAt(x, y: y, length: length, horizontal: horizontal) where characters.count == length else {
                return
            }
            // Convert to be accepted by anagram method
            var filledLettersDict = [Int: Character]()
            characters.filter({ $0.1.1 != nil }).forEach { filledLettersDict[$0.1.0] = $0.1.1! }
            guard let firstOffset = characters.keys.sort().first,
                words = dictionary.anagrams(withLetters: letters, wordLength: length, filledLetters: filledLettersDict) else {
                    return
            }
            
            for word in words {
                var valid = true
                var intersections = [String]()
                if debug {
                    print("Valid main word: \(word)")
                }
                for (index, letter) in Array(word.characters).enumerate() {
                    let offset = firstOffset + index
                    let intersectHorizontally = !horizontal
                    let intersected = wordAt(intersectHorizontally ? x : offset,
                                             y: intersectHorizontally ? offset : y,
                                             string: String(letter),
                                             horizontal: intersectHorizontally)
                    if intersected.word.characters.count > 1 {
                        if dictionary.lookup(intersected.word) {
                            if debug {
                                print("Valid intersecting word: \(intersected)")
                            }
                            intersections.append(intersected.word)
                        } else {
                            if debug {
                                print("Invalid intersecting word: \(intersected)")
                            }
                            valid = false
                            break
                        }
                    }
                }
                if valid {
                    let score = calculateScore(
                        horizontal ? firstOffset : x,
                        y: horizontal ? y : firstOffset,
                        word: word,
                        horizontal: horizontal)
                    solutions.append((word, horizontal ? firstOffset : x, horizontal ? y : firstOffset, horizontal, score, intersections))
                    if !board.isFirstPlay {
                        assert(intersections.count > 0)
                    }
                }
            }
        }
        
        for length in 1...maximumWordLength {
            // Horizontal
            for y in board.boardRange {
                for x in board.boardRange {
                    solutionsAt(x: x, y: y, length: length, horizontal: true)
                }
            }
            
            // Vertical
            for y in 0..<(board.boardSize - length - 1) {
                for x in board.boardRange {
                    solutionsAt(x: x, y: y, length: length, horizontal: false)
                }
            }
        }
        
        return solutions.count == 0 ? nil : solutions
    }
    
    func solve(solutions: [Solution], difficulty: Difficulty = .Hard) -> Solution? {
        let best = solutions.sort({ $0.score < $1.score }).last!
        if difficulty == .Hard {
            return best
        }
        let scaled = Double(best.score) * difficulty.rawValue
        var suitable: (difference: Double, solution: Solution)?
        // Smallest difference = solution to play
        for solution in solutions where Double(solution.score) < scaled {
            let diff = abs(scaled - Double(solution.score))
            if suitable == nil {
                suitable = (diff, solution)
                continue
            }
            if min(abs(suitable!.difference), diff) == diff {
                suitable = (diff, solution)
            }
        }
        return suitable?.solution ?? best
    }
    
    func solve(letters: [Character], difficulty: Difficulty = .Hard) -> Solution? {
        guard let possibilities = solutions(letters), best = solve(possibilities, difficulty: difficulty) else { return nil }
        return best
    }
}

