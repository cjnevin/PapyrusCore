//
//  Solver.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public enum ValidationResponse {
    case invalidArrangement
    case invalidWord(Word)
    case valid(solution: Solution)
}

protocol Solver {
    var bagType: Bag.Type { get set }
    var board: Board { get set }
    var boardState: BoardState { get set }
    var dictionary: Lookup { get set }
    var debug: Bool { get set }
    var maximumWordLength: Int { get }
    var allTilesUsedBonus: Int { get }
    var operationQueue: OperationQueue { get }
    
    init(bagType: Bag.Type, board: Board, dictionary: Lookup, debug: Bool)
    
    func characters(atX x: Int, y: Int, length: Int, horizontal: Bool) -> [Int: Character]?
    func getWord(atX x: Int, y: Int, points: [(x: Int, y: Int, letter: Character)], horizontal: Bool) -> (word: Word, valid: Bool)?
    func validate(points: [(x: Int, y: Int, letter: Character)], blanks: [(x: Int, y: Int)]) -> ValidationResponse
    func lexicographicalString(withLetters letters: [Character]) -> String
    func unvalidatedWords(forLetters letters: [Character], fixedLetters: [Int: Character], length: Int) -> Anagrams?
    func intersections<T: WordRepresentation>(forWord word: T) -> (valid: Bool, words: [Word])
    func solution(forWord word: Word, rackLetters: [RackTile]) -> Solution?
    func solve(with solutions: [Solution], difficulty: Difficulty) -> Solution?
    func solutions(forLetters letters: [RackTile], serial: Bool, completion: ([Solution]?) -> ())
    mutating func play(solution: Solution) -> [Character]
}


// Characters

extension Solver {
    func lexicographicalString(withLetters letters: [Character]) -> String {
        return String(letters.sorted())
    }
    
    func characters(atX x: Int, y: Int, length: Int, horizontal: Bool) -> [Int: Character]? {
        let size = board.size
        var fixedLetters = [Int: Character]()
        var index = 0
        var offset = boardState.state(atX: x, y: y, horizontal: horizontal)
        
        func addCharacter(_ mustExist: Bool, alwaysIncrement: Bool) -> Bool {
            if offset >= size { return false }
            var didExist = false
            if let value = board[horizontal ? offset : x, horizontal ? y : offset] {
                fixedLetters[index] = value
                didExist = true
            }
            // Only increment if alwaysIncrement is set or we found a value.
            if alwaysIncrement || didExist {
                index += 1
                offset += 1
            }
            return mustExist == true ? didExist : true
        }
        
        while addCharacter(true, alwaysIncrement: false) { }
        for _ in 0..<length { let _ = addCharacter(false, alwaysIncrement: true) }
        while addCharacter(true, alwaysIncrement: false) { }
        
        return length != index ? nil : fixedLetters
    }
    
    func validate(points: [(x: Int, y: Int, letter: Character)], blanks: [(x: Int, y: Int)]) -> ValidationResponse {
        if points.count == 0 || (points.count == 1 && board.isFirstPlay) {
            return .invalidArrangement
        }
        
        let allBlanks = board.blanks + blanks
        
        if points.count == 1 {
            let x = points.first!.x
            let y = points.first!.y
            let horizontalWord = getWord(atX: x, y: y, points: points, horizontal: true)
            if let word = horizontalWord where word.valid == false {
                return .invalidWord(word.word)
            }
            let verticalWord = getWord(atX: x, y: y, points: points, horizontal: false)
            if let word = verticalWord where word.valid == false {
                return .invalidWord(word.word)
            }
            if let word = horizontalWord?.word {
                let intersections = verticalWord != nil ? [verticalWord!.word] : []
                let score = calculateScore(word, intersectedWords: intersections, blanks: allBlanks)
                let solution = Solution(word: word, score: score, intersections: intersections, blanks: blanks)
                return .valid(solution:solution)
            }
            else if let word = verticalWord?.word {
                let score = calculateScore(word, intersectedWords: [], blanks: allBlanks)
                let solution = Solution(word: word, score: score, intersections: [], blanks: blanks)
                return .valid(solution: solution)
            }
            return .invalidArrangement
        }
        
        // Determine direction of word
        let horizontalSort = points.sorted(isOrderedBefore: { $0.x < $1.x })
        let verticalSort = points.sorted(isOrderedBefore: { $0.y < $1.y })
        
        let horizontalFirst = horizontalSort.first!
        let verticalFirst = verticalSort.first!
        let isHorizontal = horizontalFirst.y == horizontalSort.last!.y
        let isVertical = verticalFirst.x == verticalSort.last!.x
        if !isHorizontal && !isVertical {
            return .invalidArrangement
        }
        
        guard let (word, valid) = getWord(atX: horizontalFirst.x, y: verticalFirst.y, points: isHorizontal ? horizontalSort : verticalSort, horizontal: isHorizontal) else {
            return .invalidArrangement
        }
        guard valid else {
            return .invalidWord(word)
        }
        
        // Collect intersections for this word, if any are invalid lets return
        let (intersectionsValid, intersectedWords) = intersections(forWord: word)
        guard intersectionsValid else {
            // If we get here we will have an intersected word (it will be the invalid one).
            return .invalidWord(intersectedWords.first!)
        }
        
        // First turn is only one that cannot intersect a word other plays must intersect
        if !board.isFirstPlay && intersectedWords.count == 0 {
            return .invalidArrangement
        }
        else if board.isFirstPlay && !word.toPositions().contains({ board.isCenter(atX: $0.x, y: $0.y) }) {
            return .invalidArrangement
        }
        
        // Calculate score and return solution
        let score = calculateScore(word, intersectedWords: intersectedWords, blanks: allBlanks)
        let solution = Solution(word: word, score: score, intersections: intersectedWords, blanks: blanks)
        return .valid(solution: solution)
    }
}

// Word
extension Solver {
    /// - returns: Offsets in word that are blank using a players rack tiles.
    func blanks(forWord word: Word, rackLetters: [RackTile]) -> [(x: Int, y: Int)] {
        var tempPlayer = Human(rackTiles: rackLetters)
        return word.word.characters.enumerated().flatMap({ (index, letter) in
            tempPlayer.remove(letter: letter).wasBlank ? word.position(forIndex: index) : nil
        })
    }
    // TODO: Possible Improvement
    // Scores could be weighted under the following circumstances:
    // - Triple/Quadruple squares should get higher weighting (opportunistic instead of highest score)
    // - All Tile Bonus could get higher weighting
    // - If bag is empty using highest number of letters possible might be better (to end game sooner)
    //
    // This would make it more difficult for human players to compete against AI
    // while also emptying the bag/rack faster (to achieve victory sooner)
    private func calculateScore<T: WordRepresentation>(_ word: T, intersectedWords: [Word], blanks: [(x: Int, y: Int)]) -> Int {
        var tilesUsed = 0
        var score = 0
        var scoreMultiplier = 1
        var intersectionsScore = 0
        
        func isBlankAt(_ x: Int, y: Int) -> Bool {
            return blanks.contains({ $0.x == x && $0.y == y})
        }
        
        func letterPoints(_ letter: Character, atX x: Int, y: Int) -> Int {
            return isBlankAt(x, y: y) ? 0 : bagType.letterPoints[letter]!
        }
        
        func scoreWord(_ word: Word) -> Int {
            let chars = Array(word.word.characters)
            return word.toPositions().enumerated()
                .flatMap({ letterPoints(chars[$0], atX: $1.x, y: $1.y) })
                .reduce(0, combine: +)
        }
        
        func scoreLetter(_ letter: Character, x: Int, y: Int) {
            let value = letterPoints(letter, atX: x, y: y)
            if board.isFilled(atX: x, y: y) {
                score += value
                return
            }
            let letterMultiplier = board.letterMultipliers[y][x]
            let wordMultiplier = board.wordMultipliers[y][x]
            tilesUsed += 1
            score += value * letterMultiplier
            scoreMultiplier *= wordMultiplier
            
            if let intersectingWord = intersectedWords.filter({ word.horizontal ? $0.x == x : $0.y == y }).first {
                // scoreWord method will score this letter once, so lets just add the remaining amount if placed on a premium square.
                let wordScore = scoreWord(intersectingWord) + (value * (letterMultiplier - 1))
                intersectionsScore += wordScore * wordMultiplier
            }
        }
        
        for (i, letter) in word.word.characters.enumerated() {
            scoreLetter(letter,
                        x: word.x + (word.horizontal ? i : 0),
                        y: word.y + (word.horizontal ? 0 : i))
        }
        
        return (score * scoreMultiplier) + intersectionsScore + (tilesUsed == 7 ? allTilesUsedBonus : 0)
    }
    
    /// - returns: `words` will contain the first invalid intersection if `valid` is `false` or the array of intersections if `valid` is `true`. `valid` should be handled appropriately.
    func intersections<T: WordRepresentation>(forWord word: T) -> (valid: Bool, words: [Word]) {
        var words = [Word]()
        for (index, letter) in word.word.characters.enumerated() {
            let pos = word.position(forIndex: index)
            if let intersectedWord = getWord(atX: pos.x, y: pos.y, points: [(x: pos.x, y: pos.y, letter: letter)], horizontal: !word.horizontal) {
                guard intersectedWord.valid else {
                    return (false, [intersectedWord.word])
                }
                words.append(intersectedWord.word)
            }
        }
        return (true, words)
    }
    
    /// - parameter letters: Refers to the tiles in a user's rack we can use, i.e. unplayed/unfixed letters.
    /// - parameter fixedLetters: Letters already on the board.
    /// - parameter length: Length of words to find anagrams with, if length < letters + fixedLetters
    func unvalidatedWords(forLetters letters: [Character], fixedLetters: [Int: Character], length: Int) -> Anagrams? {
        // Get all letters that are possible to be used
        let anagramLetters = (letters + fixedLetters.values)
        
        // Calculate permutations, then filter any that are lexicographically equivalent to reduce work of anagram dictionary
        var combinations: [String]
        if length == anagramLetters.count {
            combinations = [anagramLetters].map(lexicographicalString)
        } else {
            combinations = Array(Set(anagramLetters.combinations(length).map(lexicographicalString)))
        }
        let anagrams = combinations.flatMap({ dictionary[$0, fixedLetters] }).flatMap({ $0 })
        return anagrams.count > 0 ? anagrams : nil
    }
    
    func getWord(atX x: Int, y: Int, points: [(x: Int, y: Int, letter: Character)], horizontal: Bool) -> (word: Word, valid: Bool)? {
        if horizontal && x > 0 && board.isFilled(atX: x - 1, y: y) {
            return getWord(atX: x - 1, y: y, points: points, horizontal: horizontal)
        } else if !horizontal && y > 0 && board.isFilled(atX: x, y: y - 1) {
            return getWord(atX: x, y: y - 1, points: points, horizontal: horizontal)
        }
        
        let size = board.size
        let start: Int = boardState.state(atX: x, y: y, horizontal: horizontal)
        var offset: Int = start
        var characters = [Character]()
        var remainingPoints = points
        
        while offset < size {
            let _x = horizontal ? offset : x
            let _y = horizontal ? y : offset
            var fixedLetter: Character?
            if let index = remainingPoints.index(where: { $0.x == _x && $0.y == _y}) {
                fixedLetter = remainingPoints[index].letter
                remainingPoints.remove(at: index)
            }
            guard let letter = fixedLetter ?? board[_x, _y] else {
                break
            }
            characters.append(letter)
            offset += 1
        }
        
        if characters.count < 2 || remainingPoints.count > 0 {
            return nil
        }
        
        let word = Word(word: String(characters),
                        x: horizontal ? start : x,
                        y: horizontal ? y : start,
                        horizontal: horizontal)
        return (word, dictionary.lookup(word: word.word))
    }
    
}

// Solution
extension Solver {
    mutating func play(solution: Solution) -> [Character] {
        let dropped = board.play(solution: solution)
        boardState = BoardState(board: board)
        return dropped
    }
    
    func solution(forWord word: Word, rackLetters: [RackTile]) -> Solution? {
        let (valid, intersectedWords) = intersections(forWord: word)
        guard valid else { return nil }
        let blankSpots = blanks(forWord: word, rackLetters: rackLetters)
        let score = calculateScore(word, intersectedWords: intersectedWords, blanks: blankSpots)
        return Solution(word: word, score: score, intersections: intersectedWords, blanks: blankSpots)
    }
    
    private func solutions(atX x: Int, y: Int, letters: [Character], rackLetters: [RackTile], length: Int, horizontal: Bool) -> [Solution]? {
        assert((horizontal ? x : y) + length - 1 < board.size)
        
        guard board.isValid(atX: x, y: y, length: length, horizontal: horizontal) else { return nil }
        
        // Is valid spot should filter these...
        let offset = boardState.state(atX: x, y: y, horizontal: horizontal)
        assert(offset == x && horizontal || offset == y && !horizontal)
        
        // Collect characters that are filled, must have at least one character to branch off of
        // Get possible words for given set of letters for this length
        guard let
            fixedLetters = characters(atX: x, y: y, length: length, horizontal: horizontal),
            words = unvalidatedWords(forLetters: letters, fixedLetters: fixedLetters, length: length) else {
                return nil
        }
        
        return words.flatMap({ solution(forWord: Word(word: $0, x: x, y: y, horizontal: horizontal), rackLetters: rackLetters) })
    }
    
    func solutions(forLetters letters: [RackTile], serial: Bool = false, completion: ([Solution]?) -> ()) {
        if letters.count == 0 {
            completion(nil)
            return
        }
        
        let solutionLetters = letters.map({ $0.letter })
        var possibilities = [Solution]()
        var count = 0
        let range = board.boardRange
        let size = board.size
        
        func collect(into array: inout [Solution], effectiveRange: CountableClosedRange<Int>, length: Int) {
            for x in range {
                for y in range {
                    if effectiveRange.contains(x) {
                        if let solves = solutions(atX: x, y: y, letters: solutionLetters, rackLetters: letters, length: length, horizontal: true) {
                            array += solves
                        }
                    }
                    if effectiveRange.contains(y) {
                        if let solves = solutions(atX: x, y: y, letters: solutionLetters, rackLetters: letters, length: length, horizontal: false) {
                            array += solves
                        }
                    }
                }
            }
        }
        
        for length in 2...maximumWordLength {
            count += 1
            let effectiveRange = (0...(size - length))
            if serial {
                collect(into: &possibilities, effectiveRange: effectiveRange, length: length)
            } else {
                let currentQueue = OperationQueue.current()
                operationQueue.addOperation({
                    var innerSolutions = [Solution]()
                    collect(into: &innerSolutions, effectiveRange: effectiveRange, length: length)
                    currentQueue?.addOperation({
                        possibilities += innerSolutions
                        count -= 1
                        if count == 0 {
                            completion(possibilities)
                        }
                    })
                })
            }
        }
        
        if serial {
            completion(possibilities.count > 0 ? possibilities.sorted(isOrderedBefore: { $0.word > $1.word }) : nil)
        }
    }
    
    func solve(with solutions: [Solution], difficulty: Difficulty = .hard) -> Solution? {
        if solutions.count == 0 {
            return nil
        }
        let best = solutions.sorted(isOrderedBefore: { $0.score < $1.score }).last!
        if difficulty == .hard {
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
