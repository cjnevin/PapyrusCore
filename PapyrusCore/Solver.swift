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
    
    func characters(startingAt: Position, length: Int, horizontal: Bool) -> [Int: Character]?
    func word<T: PositionType>(startingAt: T, horizontal: Bool, with positions: LetterPositions) -> (word: Word, valid: Bool)?
    func validate(positions: LetterPositions, blanks: Positions) -> ValidationResponse
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
    
    func characters(startingAt position: Position, length: Int, horizontal: Bool) -> [Int: Character]? {
        let size = board.size
        var fixedLetters = [Int: Character]()
        var index = 0
        var offset = boardState.state(atX: position.x, y: position.y, horizontal: horizontal)
        
        func addCharacter(_ mustExist: Bool, alwaysIncrement: Bool) -> Bool {
            if offset >= size { return false }
            var didExist = false
            if let value = board[horizontal ? offset : position.x, horizontal ? position.y : offset] {
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
        for _ in 0..<length { _ = addCharacter(false, alwaysIncrement: true) }
        while addCharacter(true, alwaysIncrement: false) { }
        
        return length != index ? nil : fixedLetters
    }
    
    func validate(positions: LetterPositions, blanks: Positions) -> ValidationResponse {
        if positions.count == 0 || (positions.count == 1 && board.isFirstPlay) {
            return .invalidArrangement
        }
        
        let allBlanks = board.blanks + blanks
        
        if positions.count == 1 {
            let horizontalWord = word(startingAt: positions.first!, horizontal: true, with: positions)
            if let word = horizontalWord where word.valid == false {
                return .invalidWord(word.word)
            }
            let verticalWord = word(startingAt: positions.first!, horizontal: false, with: positions)
            if let word = verticalWord where word.valid == false {
                return .invalidWord(word.word)
            }
            if let word = horizontalWord?.word {
                let intersections = verticalWord != nil ? [verticalWord!.word] : []
                let score = totalScore(for: word, with: intersections, blanks: allBlanks)
                let solution = Solution(word: word, score: score, intersections: intersections, blanks: blanks)
                return .valid(solution:solution)
            }
            else if let word = verticalWord?.word {
                let score = totalScore(for: word, with: [], blanks: allBlanks)
                let solution = Solution(word: word, score: score, intersections: [], blanks: blanks)
                return .valid(solution: solution)
            }
            return .invalidArrangement
        }
        
        // Determine direction of word
        let horizontalSort = positions.sorted(isOrderedBefore: { $0.x < $1.x })
        let verticalSort = positions.sorted(isOrderedBefore: { $0.y < $1.y })
        
        let horizontalFirst = horizontalSort.first!
        let verticalFirst = verticalSort.first!
        let isHorizontal = horizontalFirst.y == horizontalSort.last!.y
        let isVertical = verticalFirst.x == verticalSort.last!.x
        if !isHorizontal && !isVertical {
            return .invalidArrangement
        }
        
        guard let (word, valid) = word(startingAt: Position(x: horizontalFirst.x, y: verticalFirst.y), horizontal: isHorizontal, with: isHorizontal ? horizontalSort : verticalSort) else {
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
        let score = totalScore(for: word, with: intersectedWords, blanks: allBlanks)
        let solution = Solution(word: word, score: score, intersections: intersectedWords, blanks: blanks)
        return .valid(solution: solution)
    }
}

// Word
extension Solver {
    /// - returns: Offsets in word that are blank using a players rack tiles.
    func blanks(forWord word: Word, rackLetters: [RackTile]) -> Positions {
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
    
    
    func points(for letterPosition: LetterPosition, with blanks: [Position]) -> Int {
        guard !blanks.contains({ $0.x == letterPosition.x && $0.y == letterPosition.y }) else {
            return 0
        }
        return bagType.letterPoints[letterPosition.letter]!
    }
    
    func intersectingScore(for word: Word, blanks: [Position]) -> Int {
        return word.toLetterPositions()
            .flatMap({ points(for: $0, with: blanks) })
            .reduce(0, combine: +)
    }
    
    func totalScore<T: WordRepresentation>(for word: T, with intersections: [Word], blanks: [Position]) -> Int {
        var tilesUsed: Int = 0
        var intersectionTotal: Int = 0
        var total: Int = 0
        var multiplier: Int = 1
        word.toLetterPositions().forEach { position in
            let letterScore = points(for: position, with: blanks)
            guard board.isEmpty(atX: position.x, y: position.y) else {
                total += letterScore
                return
            }
            
            let letterMultiplier = board.letterMultipliers[position.y][position.x]
            let wordMultiplier = board.wordMultipliers[position.y][position.x]
            
            if let intersection = intersections.filter({ word.horizontal ? $0.x == position.x : $0.y == position.y }).first {
                intersectionTotal += wordMultiplier * intersectingScore(for: intersection, blanks: blanks) + (letterScore * (letterMultiplier - 1))
            }
            
            tilesUsed += 1
            total += letterScore * letterMultiplier
            multiplier *= wordMultiplier
        }
        return total * multiplier + intersectionTotal + (tilesUsed == Game.rackAmount ? allTilesUsedBonus : 0)
    }
        
    /// - returns: `words` will contain the first invalid intersection if `valid` is `false` or the array of intersections if `valid` is `true`. `valid` should be handled appropriately.
    func intersections<T: WordRepresentation>(forWord word: T) -> (valid: Bool, words: [Word]) {
        var words = [Word]()
        for (index, letter) in word.word.characters.enumerated() {
            let pos = word.position(forIndex: index)
            if let intersectedWord = self.word(startingAt: pos, horizontal: !word.horizontal, with: [LetterPosition(x: pos.x, y: pos.y, letter: letter)]) {
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
    
    func word<T: PositionType>(startingAt position: T, horizontal: Bool, with positions: LetterPositions) -> (word: Word, valid: Bool)? {
        let origin = Position(x: position.x, y: position.y)
        let left = origin.left
        let top = origin.top
        
        if horizontal && position.x > 0 && board.isFilled(at: left) {
            return word(startingAt: left, horizontal: horizontal, with: positions)
        } else if !horizontal && position.y > 0 && board.isFilled(at: top) {
            return word(startingAt: top, horizontal: horizontal, with: positions)
        }
        
        let size = board.size
        let start: Int = boardState.state(at: origin, horizontal: horizontal)
        var offset: Int = start
        var characters = [Character]()
        var remaining = positions
        
        while offset < size {
            let _x = horizontal ? offset : position.x
            let _y = horizontal ? position.y : offset
            var fixedLetter: Character?
            if let index = remaining.index(where: { $0.x == _x && $0.y == _y}) {
                fixedLetter = remaining[index].letter
                remaining.remove(at: index)
            }
            guard let letter = fixedLetter ?? board[_x, _y] else {
                break
            }
            characters.append(letter)
            offset += 1
        }
        
        if characters.count < 2 || remaining.count > 0 {
            return nil
        }
        
        let result = Word(word: String(characters),
                        x: horizontal ? start : position.x,
                        y: horizontal ? position.y : start,
                        horizontal: horizontal)
        return (result, dictionary.lookup(word: result.word))
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
        let score = totalScore(for: word, with: intersectedWords, blanks: blankSpots)
        return Solution(word: word, score: score, intersections: intersectedWords, blanks: blankSpots)
    }
    
    private func solutions(at position: Position, letters: [Character], rackLetters: [RackTile], length: Int, horizontal: Bool) -> [Solution]? {
        assert((horizontal ? position.x : position.y) + length - 1 < board.size)
        
        guard board.isValid(at: position, length: length, horizontal: horizontal) else {
            return nil
        }
        
        // Is valid spot should filter these...
        let offset = boardState.state(at: position, horizontal: horizontal)
        assert(offset == position.x && horizontal || offset == position.y && !horizontal)
        
        // Collect characters that are filled, must have at least one character to branch off of
        // Get possible words for given set of letters for this length
        guard let
            fixedLetters = characters(startingAt: position, length: length, horizontal: horizontal),
            words = unvalidatedWords(forLetters: letters, fixedLetters: fixedLetters, length: length) else {
                return nil
        }
        
        return words.flatMap({ solution(forWord: Word(word: $0, x: position.x, y: position.y, horizontal: horizontal), rackLetters: rackLetters) })
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
                    let position = Position(x: x, y: y)
                    if effectiveRange.contains(x) {
                        if let solves = solutions(at: position, letters: solutionLetters, rackLetters: letters, length: length, horizontal: true) {
                            array += solves
                        }
                    }
                    if effectiveRange.contains(y) {
                        if let solves = solutions(at: position, letters: solutionLetters, rackLetters: letters, length: length, horizontal: false) {
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
                let currentQueue = OperationQueue.current
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
