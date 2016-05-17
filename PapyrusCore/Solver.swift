//
//  Solver.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

protocol WordRepresentation {
    var word: String { get }
    var x: Int { get }
    var y: Int { get }
    var horizontal: Bool { get }
    
    func end() -> Int
    func length() -> Int
    func toPoints() -> [(x: Int, y: Int)]
}

extension WordRepresentation {
    func end() -> Int {
        return word.characters.count + (horizontal ? x : y)
    }
    
    func length() -> Int {
        return word.characters.count
    }
    
    func toRange() -> Range<Int> {
        return horizontal ?
            (x..<(x + word.characters.count)) :
            (y..<(y + word.characters.count))
    }
    
    func toPoints() -> [(x: Int, y: Int)] {
        if horizontal {
            return toRange().flatMap({ ($0, y) })
        } else {
            return toRange().flatMap({ (x, $0) })
        }
    }
}

public struct Word: WordRepresentation {
    let word: String
    let x: Int
    let y: Int
    let horizontal: Bool
}

public struct Solution: WordRepresentation {
    let word: String
    let x: Int
    let y: Int
    let horizontal: Bool
    let score: Int
    let intersections: [Word]
    let blanks: [(x: Int, y: Int)]
    
    public func getPoints() -> [(x: Int, y: Int)] {
        var points = toPoints()
        intersections.map({ $0.toPoints() }).forEach({ intersectedPoints in
            intersectedPoints.forEach({ intersectedPoint in
                if !points.contains({ $0.x == intersectedPoint.x && $0.y == intersectedPoint.y }) {
                    points.append(intersectedPoint)
                }
            })
        })
        return points
    }
}

public enum ValidationResponse {
    case InvalidArrangement
    case InvalidWord(x: Int, y: Int, word: String)
    case Valid(solution: Solution)
}

struct Solver {
    private(set) var board: Board
    private(set) var boardState: BoardState
    private(set) var distribution: LetterDistribution
    let dictionary: Dawg
    private let debug: Bool
    private let maximumWordLength = 15
    private let allTilesUsedBonus = 50
    private let operationQueue = NSOperationQueue()
    
    init(board: Board, dictionary: Dawg, distribution: LetterDistribution, debug: Bool = false) {
        self.board = board
        self.distribution = distribution
        boardState = BoardState(board: board)
        self.debug = debug
        self.dictionary = dictionary
    }
    
    
    typealias OffsetIndexValueMap = [Int: (index: Int, value: Character?)]
    private func charactersAt(x: Int, y: Int, length: Int, horizontal: Bool) -> OffsetIndexValueMap? {
        let size = board.config.size
        var filled = OffsetIndexValueMap()
        var index = 0
        var offset = boardState[horizontal][y][x]
        let getValue = { self.board.letterAt(horizontal ? offset : x, horizontal ? y : offset) }
        let addValue = {
            if offset < size {
                filled[offset] = (index, getValue())
                index += 1
                offset += 1
            }
        }
        let collect = {
            while offset < size && getValue() != nil {
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
        
        let size = board.config.size
        var chars = [Character]()
        let start: Int = boardState[horizontal][y][x]
        var end: Int = start
        var valueFunc: (Int) -> (Character?) = { self.board.letterAt(horizontal ? $0 : x, horizontal ? y : $0) }
        func collect() {
            if end >= size { return }
            var char: Character? = valueFunc(end)
            while let value = char {
                chars.append(value)
                end += 1
                char = end < size ? valueFunc(end) : nil
            }
        }
        collect()
        for char in string.characters {
            chars.append(char)
            end += 1
            collect()
        }
        if horizontal {
            return Word(word: String(chars), x: start, y: y, horizontal: horizontal)
        } else {
            return Word(word: String(chars), x: x, y: start, horizontal: horizontal)
        }
    }
    
    private func calculateScore(word: WordRepresentation, blanks: [(x: Int, y: Int)]) -> Int {
        var tilesUsed = 0
        var score = 0
        var scoreMultiplier = 1
        var intersectionsScore = 0
        
        func isBlankAt(x: Int, y: Int) -> Bool {
            return blanks.contains({ $0.x == x && $0.y == y})
        }
        
        func wordSum(word: Word) -> Int {
            var score = 0
            for (index, point) in word.toPoints().enumerate() {
                if !isBlankAt(point.x, y: point.y) {
                    score += distribution.letterPoints[Array(word.word.characters)[index]]!
                }
            }
            return score
        }
        
        func scoreLetter(letter: Character, x: Int, y: Int) {
            let value = isBlankAt(x, y: y) ? 0 : distribution.letterPoints[letter]!
            if board.isFilledAt(x, y) {
                score += value
                return
            }
            let letterMultiplier = board.config.letterMultipliers[y][x]
            let wordMultiplier = board.config.wordMultipliers[y][x]
            tilesUsed += 1
            score += value * letterMultiplier
            scoreMultiplier *= wordMultiplier
            let intersectingWord = wordAt(x, y: y, string: String(letter), horizontal: !word.horizontal)
            if intersectingWord.word.characters.count > 1 {
                let wordScore = wordSum(intersectingWord) + (value * (letterMultiplier - 1))
                intersectionsScore += wordScore * wordMultiplier
            }
        }
        
        for (i, letter) in word.word.characters.enumerate() {
            scoreLetter(letter, x: word.horizontal ? word.x + i : word.x, y: word.horizontal ? word.y : word.y + i)
        }
        
        return (score * scoreMultiplier) + intersectionsScore + (tilesUsed == 7 ? allTilesUsedBonus : 0)
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
            if horizontalWord.length() > 1 {
                if !dictionary.lookup(horizontalWord.word) {
                    return .InvalidWord(x: horizontalWord.x, y: horizontalWord.y, word: horizontalWord.word)
                }
            }
            let verticalWord = wordAt(x, y: y, string: String(letter), horizontal: false)
            if verticalWord.length() > 1 {
                if !dictionary.lookup(verticalWord.word) {
                    return .InvalidWord(x: verticalWord.x, y: verticalWord.y, word: verticalWord.word)
                }
            }
            if verticalWord.length() > 1 {
                let score = calculateScore(verticalWord, blanks: allBlanks)
                return .Valid(solution: Solution(
                    word: verticalWord.word,
                    x: x, y: verticalWord.y, horizontal: false,
                    score: score,
                    intersections: (horizontalWord.length() > 1 ? [horizontalWord] : []),
                    blanks: blanks))
            } else if horizontalWord.length() > 1 {
                let score = calculateScore(horizontalWord, blanks: allBlanks)
                return .Valid(solution: Solution(
                    word: horizontalWord.word,
                    x: horizontalWord.x, y: y, horizontal: true,
                    score: score,
                    intersections: (verticalWord.length() > 1 ? [verticalWord] : []),
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
                if horizontalWord.length() > 1 {
                    if !dictionary.lookup(horizontalWord.word) {
                        return .InvalidWord(x: horizontalWord.x, y: y, word: horizontalWord.word)
                    }
                }
                var intersections = [Word]()
                for point in points {
                    let intersectedWord = wordAt(point.x, y: point.y, string: String(point.letter), horizontal: false)
                    if intersectedWord.length() > 1 {
                        if !dictionary.lookup(intersectedWord.word) {
                            return .InvalidWord(x: x, y: intersectedWord.y, word: intersectedWord.word)
                        } else {
                            intersections.append(intersectedWord)
                        }
                    }
                }
                if horizontalWord.length() == points.count && intersections.count == 0 && board.isFirstPlay == false {
                    return .InvalidArrangement
                }
                let score = calculateScore(horizontalWord, blanks: allBlanks)
                return .Valid(solution: Solution(
                    word: horizontalWord.word,
                    x: horizontalWord.x, y: y, horizontal: true,
                    score: score, intersections: intersections, blanks: blanks))
            }
            else if isVertical {
                let x = horizontalSort.first!.x
                let y = verticalSort.first!.y
                let verticalWord = wordAt(x, y: y, string: String(verticalSort.flatMap {$0.letter}), horizontal: false)
                if verticalWord.length() > 1 {
                    if !dictionary.lookup(verticalWord.word) {
                        return .InvalidWord(x: x, y: verticalWord.y, word: verticalWord.word)
                    }
                }
                var intersections = [Word]()
                for point in points {
                    let intersectedWord = wordAt(point.x, y: point.y, string: String(point.letter), horizontal: true)
                    if intersectedWord.length() > 1 {
                        if !dictionary.lookup(intersectedWord.word) {
                            return .InvalidWord(x: intersectedWord.x, y: y, word: intersectedWord.word)
                        } else {
                            intersections.append(intersectedWord)
                        }
                    }
                }
                if verticalWord.length() == points.count && intersections.count == 0 && board.isFirstPlay == false {
                    return .InvalidArrangement
                }
                let score = calculateScore(verticalWord, blanks: allBlanks)
                return .Valid(solution: Solution(
                    word: verticalWord.word,
                    x: x, y: verticalWord.y, horizontal: false,
                    score: score, intersections: intersections, blanks: blanks))
            }
            return .InvalidArrangement
        }
    }
    
    func solutions(letters: [RackTile], serial: Bool = false, completion: ([Solution]?) -> ()) {
        if letters.count == 0 {
            completion(nil)
            return
        }
        
        func solutionsAt(x x: Int, y: Int, length: Int, horizontal: Bool) -> [Solution]? {
            if !board.isValidSpot(x, y: y, length: length, horizontal: horizontal) {
                return nil
            }
            
            // Collect characters that are filled, return if word is longer than the one we are currently trying to check
            guard let characters = charactersAt(x, y: y, length: length, horizontal: horizontal) where characters.count == length else {
                return nil
            }
            // Convert to be accepted by anagram method
            var filledLettersDict = [Int: Character]()
            characters.filter({ $1.value != nil }).forEach { filledLettersDict[$0.1.0] = $0.1.1! }
            guard let firstOffset = characters.keys.sort().first,
                words = dictionary.anagrams(withLetters: letters.map({$0.0}), wordLength: length, filledLetters: filledLettersDict) else {
                    return nil
            }
            
            var solves = [Solution]()
            for word in words {
                var valid = true
                var intersections = [Word]()
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
                            intersections.append(intersected)
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
                    let mainWord = Word(word: word,
                                    x: horizontal ? firstOffset : x,
                                    y: horizontal ? y : firstOffset,
                                    horizontal: horizontal)
                    solves.append(Solution(word: mainWord.word,
                        x: mainWord.x,
                        y: mainWord.y,
                        horizontal: mainWord.horizontal,
                        score: calculateScore(mainWord, blanks: blanks),
                        intersections: intersections,
                        blanks: blanks))
                    if !board.isFirstPlay {
                        assert(intersections.count > 0)
                    }
                }
            }
            return solves
        }
        
        var solutions = [Solution]()
        let currentQueue = NSOperationQueue.currentQueue()
        var count = 0
        let range = board.config.boardRange
        let size = board.config.size
        for length in 2...maximumWordLength {
            count += 1
            if serial {
                for x in range {
                    for y in range {
                        // Horizontal
                        if let solves = solutionsAt(x: x, y: y, length: length, horizontal: true) {
                            solutions.appendContentsOf(solves)
                        }
                        // Vertical
                        if y < size - length - 1 {
                            if let solves = solutionsAt(x: x, y: y, length: length, horizontal: false) {
                                solutions.appendContentsOf(solves)
                            }
                        }
                    }
                }
            } else {
                operationQueue.addOperationWithBlock({
                    var innerSolutions = [Solution]()
                    for x in range {
                        for y in range {
                            // Horizontal
                            if let solves = solutionsAt(x: x, y: y, length: length, horizontal: true) {
                                innerSolutions.appendContentsOf(solves)
                            }
                            // Vertical
                            if y < size - length - 1 {
                                if let solves = solutionsAt(x: x, y: y, length: length, horizontal: false) {
                                    innerSolutions.appendContentsOf(solves)
                                }
                            }
                        }
                    }
                    currentQueue?.addOperationWithBlock({
                        solutions.appendContentsOf(innerSolutions)
                        count -= 1
                        if count == 0 {
                            completion(solutions)
                        }
                    })
                })
            }
        }
        
        if serial {
            completion(solutions.count > 0 ? solutions : nil)
        }
    }
    
    func solve(solutions: [Solution], difficulty: Difficulty = .Hard) -> Solution? {
        if solutions.count == 0 {
            return nil
        }
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
}

