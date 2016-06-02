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
    
    static func invalid(withWord word: Word) -> ValidationResponse {
        return .InvalidWord(x: word.x, y: word.y, word: word.word)
    }
}

struct Solver {
    private(set) var board: Board
    private(set) var boardState: BoardState
    private(set) var distribution: LetterDistribution
    let anagramDictionary: AnagramDictionary
    let dictionary: Dawg
    private let debug: Bool
    private let maximumWordLength = 15
    private let allTilesUsedBonus = 50
    private let operationQueue = NSOperationQueue()
    
    init(board: Board, anagramDictionary: AnagramDictionary, dictionary: Dawg, distribution: LetterDistribution, debug: Bool = false) {
        self.board = board
        self.distribution = distribution
        boardState = BoardState(board: board)
        self.debug = debug
        self.dictionary = dictionary
        self.anagramDictionary = anagramDictionary
    }
    
    private func charactersAt(x: Int, y: Int, length: Int, horizontal: Bool) -> [Int: Character]? {
        let size = board.config.size
        var fixedLetters = [Int: Character]()
        var index = 0
        var offset = boardState[horizontal][y][x]
       
        func addCharacter(mustExist: Bool, incrementAlways: Bool) -> Bool {
            if offset >= size { return false }
            var didExist = false
            if let value = board[horizontal ? offset : x, horizontal ? y : offset] {
                fixedLetters[index] = value
                didExist = true
            }
            if incrementAlways || didExist {
                index += 1
                offset += 1
            }
            return mustExist == true ? didExist : true
        }

        while addCharacter(true, incrementAlways: false) { }
        for _ in 0..<length { addCharacter(false, incrementAlways: true) }
        while addCharacter(true, incrementAlways: false) { }

        return length != index ? nil : fixedLetters
    }
    
    private func wordAt(x: Int, y: Int, string: String, horizontal: Bool) -> (word: Word, valid: Bool)? {
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
        var valueFunc: (Int) -> (Character?) = { self.board[horizontal ? $0 : x, horizontal ? y : $0] }
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
        if chars.count < 2 {
            return nil
        }
        let word = horizontal ? Word(word: String(chars), x: start, y: y, horizontal: horizontal)
            : Word(word: String(chars), x: x, y: start, horizontal: horizontal)
        return (word, dictionary.lookup(word.word))
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
            if let intersectingWord = wordAt(x, y: y, string: String(letter), horizontal: !word.horizontal) where intersectingWord.1 == true {
                let wordScore = wordSum(intersectingWord.0) + (value * (letterMultiplier - 1))
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
    
    // TODO: Break into smaller methods; improve reuse of 'let word = ... where word.valid == false'
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
            if let word = horizontalWord where word.valid == false {
                return .invalid(withWord: word.word)
            }
            let verticalWord = wordAt(x, y: y, string: String(letter), horizontal: false)
            if let word = verticalWord where word.valid == false {
                return .invalid(withWord: word.word)
            }
            if let word = horizontalWord?.word {
                let score = calculateScore(word, blanks: allBlanks)
                let intersections = verticalWord != nil ? [verticalWord!.word] : []
                return .Valid(solution: Solution(
                    word: word.word,
                    x: word.x, y: y, horizontal: true,
                    score: score,
                    intersections: intersections,
                    blanks: blanks))
            }
            else if let word = verticalWord?.word {
                let score = calculateScore(word, blanks: allBlanks)
                let intersections = horizontalWord != nil ? [horizontalWord!.word] : []
                return .Valid(solution: Solution(
                    word: word.word,
                    x: x, y: word.y, horizontal: false,
                    score: score,
                    intersections: intersections,
                    blanks: blanks))
            }
            return .InvalidArrangement
        }
        else {
            // Determine direction of word
            let horizontalSort = points.sort({ $0.x < $1.x })
            let verticalSort = points.sort({ $0.y < $1.y })
            guard let horizontalFirst = horizontalSort.first, verticalFirst = verticalSort.first else {
                return .InvalidArrangement
            }
            let isHorizontal = horizontalFirst.y == horizontalSort.last?.y
            let isVertical = verticalFirst.x == verticalSort.last?.x
            if !isHorizontal && !isVertical {
                return .InvalidArrangement
            }
            // TODO: Cleanup duplication based on orientation here...
            if isHorizontal {
                let x = horizontalFirst.x
                let y = verticalFirst.y
                guard let horizontalWord = wordAt(x, y: y, string: String(horizontalSort.flatMap {$0.letter}), horizontal: true) else {
                    return .InvalidArrangement
                }
                if horizontalWord.valid == false {
                    return .invalid(withWord: horizontalWord.word)
                }
                var intersections = [Word]()
                for point in points {
                    if let intersectedWord = wordAt(point.x, y: point.y, string: String(point.letter), horizontal: false) {
                        if intersectedWord.valid == false {
                            return .invalid(withWord: intersectedWord.word)
                        } else {
                            intersections.append(intersectedWord.word)
                        }
                    }
                }
                let word = horizontalWord.word
                if word.length() == points.count && intersections.count == 0 && board.isFirstPlay == false {
                    return .InvalidArrangement
                }
                let score = calculateScore(word, blanks: allBlanks)
                return .Valid(solution: Solution(
                    word: word.word,
                    x: word.x, y: y, horizontal: true,
                    score: score, intersections: intersections, blanks: blanks))
            }
            else if isVertical {
                let x = horizontalFirst.x
                let y = verticalFirst.y
                guard let verticalWord = wordAt(x, y: y, string: String(verticalSort.flatMap {$0.letter}), horizontal: false) else {
                    return .InvalidArrangement
                }
                if verticalWord.valid == false {
                    return .invalid(withWord: verticalWord.word)
                }
                var intersections = [Word]()
                for point in points {
                    if let intersectedWord = wordAt(point.x, y: point.y, string: String(point.letter), horizontal: true) {
                        if intersectedWord.valid == false {
                            return .invalid(withWord: intersectedWord.word)
                        } else {
                            intersections.append(intersectedWord.word)
                        }
                    }
                }
                let word = verticalWord.word
                if word.length() == points.count && intersections.count == 0 && board.isFirstPlay == false {
                    return .InvalidArrangement
                }
                let score = calculateScore(word, blanks: allBlanks)
                return .Valid(solution: Solution(
                    word: word.word,
                    x: x, y: word.y, horizontal: false,
                    score: score, intersections: intersections, blanks: blanks))
            }
            return .InvalidArrangement
        }
    }
    
    private func anagrams(forLetters letters: [Character], fixedLetters: [Int: Character], length: Int) -> Anagrams {
        // Get all letters that are possible to be used
        let anagramLetters = (letters + fixedLetters.values)
        
        // Calculate permutations, then filter any that are lexicographically equivalent to reduce work of anagram dictionary
        let combinations = Set(anagramLetters.combinations(length).map({ String($0.sort()) }))
        return combinations.flatMap({ anagramDictionary[$0, fixedLetters] }).flatMap({ $0 })
    }
    
    private func solutionsAt(x x: Int, y: Int, letters: [Character], rackLetters: [RackTile], length: Int, horizontal: Bool) -> [Solution]? {
        if !board.isValidSpot(x, y: y, length: length, horizontal: horizontal) {
            return nil
        }
        
        // Collect characters that are filled
        guard let fixedLetters = charactersAt(x, y: y, length: length, horizontal: horizontal) else {
            return nil
        }
        
        let firstOffset = boardState[horizontal][y][x] + (fixedLetters.keys.sort().first ?? 0)
        let currentX = horizontal ? firstOffset : x
        let currentY = horizontal ? y : firstOffset
        
        let words = anagrams(forLetters: letters, fixedLetters: fixedLetters, length: length)
        
        // TODO: Break into smaller methods
        var solves = [Solution]()
        for word in words {
            var valid = true
            var intersections = [Word]()
            if debug {
                print("Valid main word: \(word)")
            }
            var tempPlayer = Human(rackTiles: rackLetters)
            var blanks = [(x: Int, y: Int)]()
            for (index, letter) in Array(word.characters).enumerate() {
                let point = horizontal ? (firstOffset + index, y) : (x, firstOffset + index)
                if let intersected = wordAt(point.0,
                                         y: point.1,
                                         string: String(letter),
                                         horizontal: !horizontal) {
                    if intersected.valid {
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
                    blanks.append(point)
                }
            }
            if valid {
                let mainWord = Word(word: word,
                                    x: currentX,
                                    y: currentY,
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
    
    func solutions(letters: [RackTile], serial: Bool = false, completion: ([Solution]?) -> ()) {
        if letters.count == 0 {
            completion(nil)
            return
        }
        
        let solutionLetters = letters.map({ $0.letter })
        var solutions = [Solution]()
        var count = 0
        let range = board.config.boardRange
        let size = board.config.size
        for length in 2...maximumWordLength {
            count += 1
            if serial {
                for x in range {
                    for y in range {
                        // Horizontal
                        if let solves = solutionsAt(x: x, y: y, letters: solutionLetters, rackLetters: letters, length: length, horizontal: true) {
                            solutions += solves
                        }
                        // Vertical
                        if y < size - length - 1 {
                            if let solves = solutionsAt(x: x, y: y, letters: solutionLetters, rackLetters: letters, length: length, horizontal: false) {
                                solutions += solves
                            }
                        }
                    }
                }
            } else {
                let currentQueue = NSOperationQueue.currentQueue()
                operationQueue.addOperationWithBlock({
                    var innerSolutions = [Solution]()
                    for x in range {
                        for y in range {
                            // Horizontal
                            if let solves = self.solutionsAt(x: x, y: y, letters: solutionLetters, rackLetters: letters, length: length, horizontal: true) {
                                innerSolutions += solves
                            }
                            // Vertical
                            if y < size - length - 1 {
                                if let solves = self.solutionsAt(x: x, y: y, letters: solutionLetters, rackLetters: letters, length: length, horizontal: false) {
                                    innerSolutions += solves
                                }
                            }
                        }
                    }
                    currentQueue?.addOperationWithBlock({
                        solutions += innerSolutions
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

