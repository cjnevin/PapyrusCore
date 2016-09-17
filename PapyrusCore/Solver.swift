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

internal protocol SolverType {
    var letterPoints: [Character: Int] { get set }
    var board: Board { get set }
    var boardState: BoardState { get set }
    var dictionary: Lookup { get set }
    var debug: Bool { get set }
    var maximumWordLength: Int { get }
    var allTilesUsedBonus: Int { get }
    var operationQueue: OperationQueue { get }
    
    init(allTilesUsedBonus: Int, maximumWordLength: Int, letterPoints: [Character: Int], board: Board, dictionary: Lookup, debug: Bool)
    
    func characters(startingAt: Position, length: Int, horizontal: Bool) -> [Int: Character]?
    func word<T: PositionType>(startingAt: T, horizontal: Bool, with positions: LetterPositions) -> (word: Word, valid: Bool)?
    func validate(positions: LetterPositions, blanks: Positions) -> ValidationResponse
    func lexicographicalString(withLetters letters: [Character]) -> String
    func unvalidatedWords(forLetters letters: [Character], fixedLetters: [Int: Character], length: Int) -> Anagrams?
    func intersections<T: WordType>(forWord word: T) -> (valid: Bool, words: [Word])
    func solution(for word: Word, rackTiles: [RackTile]) -> Solution?
    func solutions(for letters: [RackTile], serial: Bool, completion: @escaping ([Solution]?) -> ())
    mutating func play(solution: Solution) -> [Character]
}


// Characters

extension SolverType {
    func lexicographicalString(withLetters letters: [Character]) -> String {
        return String(letters.sorted())
    }
    
    func characters(startingAt origin: Position, length: Int, horizontal: Bool) -> [Int: Character]? {
        let start = boardState.state(at: origin, horizontal: horizontal)
        var position = Position(x: horizontal ? start : origin.x, y: horizontal ? origin.y : start)
        var positions = [Position]()
        let startPosition = position
        let finalPosition = startPosition.move(amount: length - 1, horizontal: horizontal)
        
        @discardableResult func addPosition(ifTrue: ((Position) -> (Bool))? = nil) -> Bool {
            guard position.axesFallBelow(maximum: board.size) && (ifTrue == nil || ifTrue?(position) == true) else {
                return false
            }
            positions.append(position)
            position.nextInPlace(horizontal: horizontal)
            return true
        }
        
        func addPositionWhileFilled() {
            board.size.times(whileTrue: { addPosition(ifTrue: self.board.isFilled) })
        }
        
        addPositionWhileFilled()
        length.times({ addPosition() })
        addPositionWhileFilled()
        
        return positions.last != finalPosition ? nil : Dictionary(positions.flatMap({ p in
            let letter = board.letter(at: p)
            return letter == nil ? nil : (horizontal ? p.x - start : p.y - start, letter!) }))
    }
    
    func validate(positions: LetterPositions, blanks: Positions) -> ValidationResponse {
        let allBlanks = board.blanks + blanks
        
        let direction = positions.direction
        switch direction {
        case .none, .scattered:
            return .invalidArrangement
            
        case .both:
            guard !board.isFirstPlay else {
                return .invalidArrangement
            }
            
            func solution(for word: Word?, inverse: Word?) -> Solution? {
                guard let word = word else {
                    return nil
                }
                let intersections = inverse != nil ? [inverse!] : []
                let score = totalScore(for: word, intersections: intersections, blanks: allBlanks)
                return Solution(word: word, score: score, intersections: intersections, blanks: blanks)
            }
            
            let horizontalWord = word(startingAt: positions.first!, horizontal: true, with: positions)
            if let word = horizontalWord, word.valid == false {
                return .invalidWord(word.word)
            }
            let verticalWord = word(startingAt: positions.first!, horizontal: false, with: positions)
            if let word = verticalWord, word.valid == false {
                return .invalidWord(word.word)
            }
            
            let result = (solution(for: horizontalWord?.word, inverse: verticalWord?.word) ??
                solution(for: verticalWord?.word, inverse: horizontalWord?.word))
            return result != nil ? .valid(solution: result!) : .invalidArrangement
            
        case .horizontal, .vertical:
            let xSorted = positions.sortedByX()
            let ySorted = positions.sortedByY()
            let start = Position(x: xSorted.first!.x, y: ySorted.first!.y)
            let sortedPositions = direction == .horizontal ? xSorted : ySorted
            
            guard let (word, valid) = word(startingAt: start, horizontal: direction == .horizontal, with: sortedPositions) else {
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
            else if board.isFirstPlay && !word.toPositions().contains(where: { board.isCenter(at: $0) }) {
                return .invalidArrangement
            }
            
            // Calculate score and return solution
            let score = totalScore(for: word, intersections: intersectedWords, blanks: allBlanks)
            let solution = Solution(word: word, score: score, intersections: intersectedWords, blanks: blanks)
            return .valid(solution: solution)
        }
    }
}

// Word
extension SolverType {
    func points(for letterPosition: LetterPosition, with blanks: [Position]) -> Int {
        guard !blanks.contains(where: { $0.x == letterPosition.x && $0.y == letterPosition.y }) else {
            return 0
        }
        return letterPoints[letterPosition.letter]!
    }
    
    // TODO: Possible Improvement
    // Scores could be weighted under the following circumstances:
    // - Triple/Quadruple squares should get higher weighting (opportunistic instead of highest score)
    // - All Tile Bonus could get higher weighting
    // - If bag is empty using highest number of letters possible might be better (to end game sooner)
    //
    // This would make it more difficult for human players to compete against AI
    // while also emptying the bag/rack faster (to achieve victory sooner)
    func totalScore<T: WordType>(for word: T, intersections: [Word], blanks: [Position]) -> Int {
        func score(forIntersection word: WordType) -> Int {
            return word.toLetterPositions()
                .flatMap({ points(for: $0, with: blanks) })
                .reduce(0, +)
        }
        
        var tilesUsed: Int = 0
        var intersectionTotal: Int = 0
        var total: Int = 0
        var multiplier: Int = 1
        word.toLetterPositions().forEach { position in
            let letterScore = points(for: position, with: blanks)
            guard board.isEmpty(at: position) else {
                total += letterScore
                return
            }
            
            let letterMultiplier = board.letterMultiplier(at: position)
            let wordMultiplier = board.wordMultiplier(at: position)
            
            if let intersection = intersections.filter({ word.horizontal ? $0.x == position.x : $0.y == position.y }).first {
                intersectionTotal += wordMultiplier * score(forIntersection: intersection) + (letterScore * (letterMultiplier - 1))
            }
            
            tilesUsed += 1
            total += letterScore * letterMultiplier
            multiplier *= wordMultiplier
        }
        return total * multiplier + intersectionTotal + (tilesUsed == Game.rackAmount ? allTilesUsedBonus : 0)
    }
    
    /// - returns: `words` will contain the first invalid intersection if `valid` is `false` or the array of intersections if `valid` is `true`. `valid` should be handled appropriately.
    func intersections<T: WordType>(forWord word: T) -> (valid: Bool, words: [Word]) {
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
            guard let letter = fixedLetter ?? board.letter(at: Position(x: _x, y: _y)) else {
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
extension SolverType {
    mutating func play(solution: Solution) -> [Character] {
        let dropped = board.play(solution: solution)
        boardState = BoardState(board: board)
        return dropped
    }
    
    func solution(for word: Word, rackTiles: [RackTile]) -> Solution? {
        let (valid, intersectedWords) = intersections(forWord: word)
        guard valid else { return nil }
        let blankSpots = word.blankPositions(using: rackTiles)
        let score = totalScore(for: word, intersections: intersectedWords, blanks: blankSpots)
        return Solution(word: word, score: score, intersections: intersectedWords, blanks: blankSpots)
    }
    
    fileprivate func letters(forString string: String) -> [Character]? {
        return letters(forCharacters: Array(string.characters))
    }
    
    fileprivate func letters(forCharacters characters: [Character]) -> [Character]? {
        var buffer = [Character]()
        var letters = [Character]()
        for character in characters {
            buffer.append(character)
            let letter = character
            if letterPoints.keys.contains(letter) {
                letters.append(letter)
                buffer.removeAll()
            }
        }
        return letters.count > 0 && buffer.count == 0 ? letters : nil
    }
    
    fileprivate func solutions(at position: Position, letters: [Character], rackLetters: [RackTile], length: Int, horizontal: Bool) -> [Solution]? {
        assert((horizontal ? position.x : position.y) + length - 1 < board.size)
        
        guard board.isValid(at: position, length: length, horizontal: horizontal) else {
            return nil
        }
        
        // Is valid spot should filter these...
        let offset = boardState.state(at: position, horizontal: horizontal)
        assert(offset == position.x && horizontal || offset == position.y && !horizontal)
        
        // Collect characters that are filled, must have at least one character to branch off of
        // Get possible words for given set of letters for this length
        guard
            let fixedLetters = characters(startingAt: position, length: length, horizontal: horizontal),
            let words = unvalidatedWords(forLetters: letters, fixedLetters: fixedLetters, length: length) else {
                return nil
        }
        
        return words.flatMap({ solution(for: Word(word: $0, x: position.x, y: position.y, horizontal: horizontal), rackTiles: rackLetters) })
    }
    
    func solutions(for letters: [RackTile], serial: Bool = false, completion: @escaping ([Solution]?) -> ()) {
        if letters.count == 0 {
            completion(nil)
            return
        }
        
        let solutionLetters = letters.map({ $0.letter })
        var possibilities = [Solution]()
        var count = 0
        let size = board.size
        
        func collect(into array: inout [Solution], effectiveRange: CountableClosedRange<Int>, length: Int) {
            for position in board.allPositions {
                if effectiveRange.contains(position.x) {
                    if let solves = solutions(at: position, letters: solutionLetters, rackLetters: letters, length: length, horizontal: true) {
                        array += solves
                    }
                }
                if effectiveRange.contains(position.y) {
                    if let solves = solutions(at: position, letters: solutionLetters, rackLetters: letters, length: length, horizontal: false) {
                        array += solves
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
                operationQueue.addOperation({
                    var innerSolutions = [Solution]()
                    collect(into: &innerSolutions, effectiveRange: effectiveRange, length: length)
                    OperationQueue.current?.addOperation {
                        possibilities += innerSolutions
                        count -= 1
                        if count == 0 {
                            completion(possibilities)
                        }
                    }
                })
            }
        }
        
        if serial {
            completion(possibilities.count > 0 ? possibilities.sorted(by: { $0.word > $1.word }) : nil)
        }
    }
}

internal struct Solver: SolverType {
    var letterPoints: [Character: Int]
    var board: Board
    var boardState: BoardState
    var dictionary: Lookup
    var debug: Bool
    let maximumWordLength: Int
    let allTilesUsedBonus: Int
    let operationQueue = OperationQueue()
    
    init?(json: JSON, bag: Bag, dictionary: Lookup) {
        guard
            let board = Board(json: json),
            let allTilesUsedBonus: Int = JSONConfigKey.allTilesUsedBonus.in(json),
            let maximumWordLength: Int = JSONConfigKey.maximumWordLength.in(json) else {
                return nil
        }
        self.init(allTilesUsedBonus: allTilesUsedBonus, maximumWordLength: maximumWordLength,
                  letterPoints: bag.letterPoints, board: board, dictionary: dictionary)
    }
    
    init(allTilesUsedBonus: Int, maximumWordLength: Int, letterPoints: [Character: Int], board: Board, dictionary: Lookup, debug: Bool = false) {
        self.allTilesUsedBonus = allTilesUsedBonus
        self.maximumWordLength = maximumWordLength
        self.letterPoints = letterPoints
        self.board = board
        boardState = BoardState(board: board)
        self.debug = debug
        self.dictionary = dictionary
    }
}
