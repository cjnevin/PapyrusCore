//
//  Solver.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public struct Word {
    let word: String
    let start: Int
    let end: Int
    
    var length: Int {
        return end - start
    }
}

public typealias Solution = (word: String, x: Int, y: Int, horizontal: Bool, score: Int, intersections: [String], blanks: [(x: Int, y: Int)])

public enum ValidationResponse {
    case InvalidArrangement
    case InvalidWord(x: Int, y: Int, word: String)
    case Valid(solution: Solution)
}

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
    
    
    typealias OffsetIndexValueMap = [Int: (index: Int, value: Character?)]
    private func charactersAt(x: Int, y: Int, length: Int, horizontal: Bool) -> OffsetIndexValueMap? {
        var filled = OffsetIndexValueMap()
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
    
    private func wordAt(x: Int, y: Int, string: String, horizontal: Bool) -> Word {
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
        return Word(word: String(chars), start: start, end: end)
    }
    
    private func calculateScore(x: Int, y: Int, word: String, horizontal: Bool, blanks: [(x: Int, y: Int)]) -> Int {
        var tilesUsed = 0
        var score = 0
        var scoreMultiplier = 1
        var intersectionsScore = 0
        
        func isBlankAt(x: Int, y: Int) -> Bool {
            return blanks.contains({ $0.x == x && $0.y == y})
        }
        
        func wordSum(word: Word, x: Int, y: Int, horizontal: Bool) -> Int {
            var points = 0
            for i in word.start..<word.end {
                let wx = horizontal ? i : x
                let wy = horizontal ? y : i
                let n = i - word.start
                if !isBlankAt(wx, y: wy) {
                    points += Bag.letterPoints[Array(word.word.characters)[n]]!
                }
            }
            return points
        }
        
        func scoreLetter(letter: Character, x: Int, y: Int, horizontal: Bool) {
            let value = isBlankAt(x, y: y) ? 0 : Bag.letterPoints[letter]!
            if board.isFilledAt(x, y) {
                score += value
                return
            }
            let letterMultiplier = Board.letterMultipliers[y][x]
            let wordMultiplier = Board.wordMultipliers[y][x]
            tilesUsed += 1
            score += value * letterMultiplier
            scoreMultiplier *= wordMultiplier
            let intersectingWord = wordAt(x, y: y, string: String(letter), horizontal: !horizontal)
            if intersectingWord.word.characters.count > 1 {
                let wordScore = wordSum(intersectingWord, x: x, y: y, horizontal: !horizontal) + (value * (letterMultiplier - 1))
                intersectionsScore += wordScore * wordMultiplier
            }
        }
        
        for (i, letter) in word.characters.enumerate() {
            scoreLetter(letter, x: horizontal ? x + i : x, y: horizontal ? y : y + i, horizontal: horizontal)
        }
        
        return (score * scoreMultiplier) + intersectionsScore + (tilesUsed == 7 ? board.allTilesUsedBonus : 0)
    }
    
    mutating func play(solution: Solution) -> [Character] {
        let dropped = board.play(solution)
        boardState = BoardState(board: board)
        return dropped
    }
    
    func validate(points: [(x: Int, y: Int, letter: Character)], blanks: [(x: Int, y: Int)]) -> ValidationResponse {
        let allBlanks = board.playedBlanks + blanks
        if points.count == 0 {
            return .InvalidArrangement
        }
        else if points.count == 1 {
            if board.isFirstPlay {
                return .InvalidArrangement
            }
            let x = points.first!.x
            let y = points.first!.y
            let letter = points.first!.letter
            let horizontalWord = wordAt(x, y: y, string: String(letter), horizontal: true)
            if horizontalWord.length > 1 {
                if !dictionary.lookup(horizontalWord.word) {
                    return .InvalidWord(x: horizontalWord.start, y: y, word: horizontalWord.word)
                }
            }
            let verticalWord = wordAt(x, y: y, string: String(letter), horizontal: false)
            if verticalWord.length > 1 {
                if !dictionary.lookup(verticalWord.word) {
                    return .InvalidWord(x: x, y: verticalWord.start, word: verticalWord.word)
                }
            }
            if verticalWord.length > 1 {
                let score = calculateScore(x, y: verticalWord.start, word: verticalWord.word, horizontal: false, blanks: allBlanks)
                return .Valid(solution: Solution(
                    word: verticalWord.word,
                    x: x, y: verticalWord.start, horizontal: false,
                    score: score,
                    intersections: (horizontalWord.length > 1 ? [horizontalWord.word] : []),
                    blanks: blanks))
            } else if horizontalWord.length > 1 {
                let score = calculateScore(horizontalWord.start, y: y, word: horizontalWord.word, horizontal: true, blanks: allBlanks)
                return .Valid(solution: Solution(
                    word: horizontalWord.word,
                    x: horizontalWord.start, y: y, horizontal: true,
                    score: score,
                    intersections: (verticalWord.length > 1 ? [verticalWord.word] : []),
                    blanks: blanks))
            }
            return .InvalidArrangement
        }
        else {
            // Determine direction of word
            let horizontalSort = points.sort({ $0.x < $1.x })
            let verticalSort = points.sort({ $0.y < $1.y })
            let isHorizontal = horizontalSort.first?.y == horizontalSort.last?.y
            let isVertical = verticalSort.first?.x == verticalSort.last?.x
            if !isHorizontal && !isVertical {
                return .InvalidArrangement
            }
            if isHorizontal {
                let x = horizontalSort.first!.x
                let y = verticalSort.first!.y
                let horizontalWord = wordAt(x, y: y, string: String(horizontalSort.flatMap {$0.letter}), horizontal: true)
                let horizontalLength = horizontalWord.end - horizontalWord.start
                if horizontalLength > 1 {
                    if !dictionary.lookup(horizontalWord.word) {
                        return .InvalidWord(x: horizontalWord.start, y: y, word: horizontalWord.word)
                    }
                }
                var intersections = [String]()
                for point in points {
                    let intersectedWord = wordAt(point.x, y: point.y, string: String(point.letter), horizontal: false)
                    let intersectedLength = intersectedWord.end - intersectedWord.start
                    if intersectedLength > 1 {
                        if !dictionary.lookup(intersectedWord.word) {
                            return .InvalidWord(x: x, y: intersectedWord.start, word: intersectedWord.word)
                        } else {
                            intersections.append(intersectedWord.word)
                        }
                    }
                }
                if horizontalWord.length == points.count && intersections.count == 0 && board.isFirstPlay == false {
                    return .InvalidArrangement
                }
                let score = calculateScore(horizontalWord.start, y: y, word: horizontalWord.word, horizontal: true, blanks: allBlanks)
                return .Valid(solution: Solution(
                    word: horizontalWord.word,
                    x: horizontalWord.start, y: y, horizontal: true,
                    score: score, intersections: intersections, blanks: blanks))
            }
            else if isVertical {
                let x = horizontalSort.first!.x
                let y = verticalSort.first!.y
                let verticalWord = wordAt(x, y: y, string: String(verticalSort.flatMap {$0.letter}), horizontal: false)
                if verticalWord.length > 1 {
                    if !dictionary.lookup(verticalWord.word) {
                        return .InvalidWord(x: x, y: verticalWord.start, word: verticalWord.word)
                    }
                }
                var intersections = [String]()
                for point in points {
                    let intersectedWord = wordAt(point.x, y: point.y, string: String(point.letter), horizontal: true)
                    if intersectedWord.length > 1 {
                        if !dictionary.lookup(intersectedWord.word) {
                            return .InvalidWord(x: intersectedWord.start, y: y, word: intersectedWord.word)
                        } else {
                            intersections.append(intersectedWord.word)
                        }
                    }
                }
                if verticalWord.length == points.count && intersections.count == 0 && board.isFirstPlay == false {
                    return .InvalidArrangement
                }
                let score = calculateScore(x, y: verticalWord.start, word: verticalWord.word, horizontal: false, blanks: allBlanks)
                return .Valid(solution: Solution(
                    word: verticalWord.word,
                    x: x, y: verticalWord.start, horizontal: false,
                    score: score, intersections: intersections, blanks: blanks))
            }
            return .InvalidArrangement
        }
    }
    
    func solutions(letters: [RackTile]) -> [Solution]? {
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
            characters.filter({ $1.value != nil }).forEach { filledLettersDict[$0.1.0] = $0.1.1! }
            guard let firstOffset = characters.keys.sort().first,
                words = dictionary.anagrams(withLetters: letters.map({$0.0}), wordLength: length, filledLetters: filledLettersDict) else {
                    return
            }
            
            for word in words {
                var valid = true
                var intersections = [String]()
                if debug {
                    print("Valid main word: \(word)")
                }
                var tempPlayer = Human(rackTiles: letters)
                var blanks = [(x: Int, y: Int)]()
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
                    // Possible improvement here could be to find the most valuable spot to play a `real` letter
                    // and use the blank in the least valuable spot.
                    if tempPlayer.removeLetter(letter).wasBlank {
                        if horizontal {
                            blanks.append((offset, y))
                        } else {
                            blanks.append((x, offset))
                        }
                    }
                }
                if valid {
                    let score = calculateScore(
                        horizontal ? firstOffset : x,
                        y: horizontal ? y : firstOffset,
                        word: word,
                        horizontal: horizontal,
                        blanks: blanks)
                    solutions.append((word, horizontal ? firstOffset : x, horizontal ? y : firstOffset, horizontal, score, intersections, blanks))
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
    
    func solve(letters: [RackTile], difficulty: Difficulty = .Hard) -> Solution? {
        guard let possibilities = solutions(letters), best = solve(possibilities, difficulty: difficulty) else { return nil }
        return best
    }
}

