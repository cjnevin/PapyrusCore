//
//  BoardTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 10/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class ScrabbleBoardTests: XCTestCase {
    var boardType: Board.Type!
    var board: Board!
    var secondBoard: Board!
    var center: Int!
    var centerPosition: Position!
    var bottomEdgePosition: Position!
    
    override func setUp() {
        super.setUp()
        boardType = ScrabbleBoard.self
        let scrabbleBoard = ScrabbleBoard()
        board = scrabbleBoard
        secondBoard = ScrabbleBoard()
        center = scrabbleBoard.center
        centerPosition = Position(x: center, y: center)
        bottomEdgePosition = Position(x: board.size - 2, y: board.size - 2)
    }
    
    override func tearDown() {
        super.tearDown()
        board = nil
    }
    
    // MARK: - IsValidAt
    
    func testIsValidAtCenterReturnsTrue() {
        XCTAssertTrue(board.isValid(at: centerPosition, length: 1, horizontal: true))
        XCTAssertTrue(board.isValid(at: centerPosition, length: 1, horizontal: false))
    }
    
    func testIsValidAtFilledReturnsFalse() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertFalse(board.isValid(at: centerPosition, length: 1, horizontal: true))
        XCTAssertFalse(board.isValid(at: centerPosition, length: 1, horizontal: false))
    }
    
    func testIsValidAtExceedsBoundaryReturnsFalse() {
        XCTAssertFalse(board.isValid(at: Position(x: 1, y: 1), length: board.size, horizontal: true))
        XCTAssertFalse(board.isValid(at: Position(x: 1, y: 1), length: board.size, horizontal: false))
    }
    
    func testIsValidAtHorizontalTouchesOnLeftReturnsFalse() {
        board.set(letter: "A", at: Position.zero)
        XCTAssertFalse(board.isValid(at: Position(x: 1, y: 0), length: 1, horizontal: true))
    }
    
    func testIsValidAtVerticalTouchesOnLeftReturnsTrue() {
        board.set(letter: "A", at: Position.zero)
        XCTAssertTrue(board.isValid(at: Position(x: 1, y: 0), length: 1, horizontal: false))
    }
    
    func testIsValidAtHorizontalTouchesOnRightReturnsFalse() {
        board.set(letter: "A", at: Position(x: 1, y: 0))
        XCTAssertFalse(board.isValid(at: Position.zero, length: 1, horizontal: true))
    }
    
    func testIsValidAtVerticalTouchesOnRightReturnsTrue() {
        board.set(letter: "A", at: Position(x: 1, y: 0))
        XCTAssertTrue(board.isValid(at: Position.zero, length: 1, horizontal: false))
    }
    
    func testIsValidAtHorizontalTouchesOnTopReturnsTrue() {
        board.set(letter: "A", at: Position.zero)
        XCTAssertTrue(board.isValid(at: Position(x: 0, y: 1), length: 1, horizontal: true))
    }
    
    func testIsValidAtVerticalTouchesOnTopReturnsFalse() {
        board.set(letter: "A", at: Position.zero)
        XCTAssertFalse(board.isValid(at: Position(x: 0, y: 1), length: 1, horizontal: false))
    }
    
    func testIsValidAtHorizontalTouchesOnTopReturnsFalse() {
        board.set(letter: "A", at: Position.zero)
        XCTAssertFalse(board.isValid(at: Position(x: 0, y: 2), length: 1, horizontal: true))
    }
    
    func testIsValidAtHorizontalTouchesOnBottomReturnsTrue() {
        board.set(letter: "A", at: Position(x: 0, y: 1))
        XCTAssertTrue(board.isValid(at: Position.zero, length: 1, horizontal: true))
    }
    
    func testIsValidAtVerticalTouchesOnBottomReturnsFalse() {
        board.set(letter: "A", at: Position(x: 0, y: 1))
        XCTAssertFalse(board.isValid(at: Position.zero, length: 1, horizontal: false))
    }
    
    func testIsValidAtVerticalIntersectionReturnsTrue() {
        board.set(letter: "A", at: Position(x: 0, y: 1))
        XCTAssertTrue(board.isValid(at: Position.zero, length: 2, horizontal: false))
    }
    
    func testIsValidAtHorizontalIntersectionReturnsTrue() {
        board.set(letter: "A", at: Position(x: 1, y: 0))
        XCTAssertTrue(board.isValid(at: Position.zero, length: 2, horizontal: true))
    }
    
    // MARK: - HorizontallyTouchesAt
    
    func testHorizontallyTouchesAtTopReturnsTrue() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertTrue(board.touchesHorizontally(at: centerPosition.bottom, length: 2, edges: .Top))
    }
    
    func testHorizontallyTouchesAtTopReturnsFalse() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertFalse(board.touchesHorizontally(at: centerPosition, length: 1, edges: .Top))
    }
    
    // This test covers all edges
    func testHorizontallyTouchesAtTopReturnsFalseIfXIsNegative() {
        XCTAssertFalse(board.touchesHorizontally(at: Position(x: -1, y: center), length: 0, edges: .Top))
    }
    
    // This test covers all edges
    func testHorizontallyTouchesAtBottomReturnsFalseIfLengthExceedsBoardSize() {
        XCTAssertFalse(board.touchesHorizontally(at: Position(x: 1, y: center), length: board.size, edges: .Bottom))
    }
    
    func testHorizontallyTouchesAtBottomReturnsTrue() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertTrue(board.touchesHorizontally(at: Position(x: center, y: center - 1), length: 1, edges: .Bottom))
    }
    
    func testHorizontallyTouchesAtBottomReturnsFalse() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertFalse(board.touchesHorizontally(at: centerPosition, length: 1, edges: .Bottom))
    }
    
    func testHorizontallyTouchesAtLeftReturnsTrue() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertTrue(board.touchesHorizontally(at: Position(x: center + 1, y: center), length: 1, edges: .Left))
    }
    
    func testHorizontallyTouchesAtLeftReturnsFalse() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertFalse(board.touchesHorizontally(at: centerPosition, length: 1, edges: .Left))
    }
    
    func testHorizontallyTouchesAtRightReturnsTrue() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertTrue(board.touchesHorizontally(at: Position(x: center - 1, y: center), length: 1, edges: .Right))
    }
    
    func testHorizontallyTouchesAtRightReturnsFalse() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertFalse(board.touchesHorizontally(at: centerPosition, length: 1, edges: .Right))
    }
    
    
    // MARK: - VerticallyTouchesAt
    
    func testVerticallyTouchesAtTopReturnsTrue() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertTrue(board.touchesVertically(at: Position(x: center, y: center + 1), length: 0, edges: .Top))
    }
    
    func testVerticallyTouchesAtTopReturnsFalse() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertFalse(board.touchesVertically(at: centerPosition, length: 0, edges: .Top))
    }
    
    // This test covers all edges
    func testVerticallyTouchesAtTopReturnsFalseIfYIsNegative() {
        XCTAssertFalse(board.touchesVertically(at: Position(x: center, y: -1), length: 0, edges: .Top))
    }
    
    // This test covers all edges
    func testVerticallyTouchesAtBottomReturnsFalseIfLengthExceedsBoardSize() {
        XCTAssertFalse(board.touchesVertically(at: Position(x: center, y: 1), length: board.size, edges: .Bottom))
    }
    
    func testVerticallyTouchesAtBottomReturnsTrue() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertTrue(board.touchesVertically(at: Position(x: center, y: center - 1), length: 1, edges: .Bottom))
    }
    
    func testVerticallyTouchesAtBottomReturnsFalse() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertFalse(board.touchesVertically(at: centerPosition, length: 2, edges: .Bottom))
    }
    
    func testVerticallyTouchesAtBottomReturnsFalseIfLengthIsTooLong() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertFalse(board.touchesVertically(at: Position(x: center, y: center - 1), length: 2, edges: .Bottom))
    }
    
    func testVerticallyTouchesAtLeftReturnsTrue() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertTrue(board.touchesVertically(at: Position(x: center + 1, y: center), length: 1, edges: .Left))
    }
    
    func testVerticallyTouchesAtLeftReturnsFalse() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertFalse(board.touchesVertically(at: centerPosition, length: 1, edges: .Left))
    }
    
    func testVerticallyTouchesAtRightReturnsTrue() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertTrue(board.touchesVertically(at: Position(x: center - 1, y: center), length: 1, edges: .Right))
    }
    
    func testVerticallyTouchesAtRightReturnsFalse() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertFalse(board.touchesVertically(at: centerPosition, length: 1, edges: .Right))
    }
    
    // MARK: - ExceedsBoundaryAt
    
    func testRestrictVerticallyExceedingBoundaryReturnsNil() {
        XCTAssertNil(board.restrict(position: bottomEdgePosition, to: 3, horizontal: false))
    }
    
    func testRestrictVerticallyReturnsPosition() {
        let newPosition = board.restrict(position: bottomEdgePosition, to: 2, horizontal: false)
        XCTAssertEqual(newPosition?.x, board.size - 2)
        XCTAssertEqual(newPosition?.y, board.size)
    }
    
    func testRestrictHorizontallyExceedingBoundaryReturnsNil() {
        XCTAssertNil(board.restrict(position: bottomEdgePosition, to: 3, horizontal: true))
    }
    
    func testRestrictHorizontallyReturnsPosition() {
        let newPosition = board.restrict(position: bottomEdgePosition, to: 2, horizontal: true)
        XCTAssertEqual(newPosition?.x, board.size)
        XCTAssertEqual(newPosition?.y, board.size - 2)
    }
    
    func testRestrictHorizontallyExceedingBoundaryWithFilledSpotReturnsNil() {
        board.set(letter: "A", at: Position(x: board.size - 2, y: board.size - 2))
        XCTAssertNil(board.restrict(position: bottomEdgePosition, to: 2, horizontal: true))
    }
    
    func testRestrictVerticallyExceedingBoundaryWithFilledSpotReturnsNil() {
        board.set(letter: "A", at: Position(x: board.size - 2, y: board.size - 2))
        XCTAssertNil(board.restrict(position: bottomEdgePosition, to: 2, horizontal: false))
    }
    
    // MARK: - Equality
    
    func checkEquality(_ expected: Bool = true) {
        if expected {
            XCTAssertEqual(board as? ScrabbleBoard, secondBoard as? ScrabbleBoard)
        } else {
            XCTAssertNotEqual(board as? ScrabbleBoard, secondBoard as? ScrabbleBoard)
        }
    }
    
    func testEqualityReturnsTrueIfEmpty() {
        checkEquality()
    }
    
    func testEqualityReturnsFalse() {
        board.set(letter: "A", at: Position.zero)
        checkEquality(false)
    }
    
    func testEqualityReturnsTrueIfFilled() {
        board.set(letter: "A", at: Position.zero)
        board.set(letter: "A", at: Position(x: 1, y: 1))
        board.set(letter: "A", at: Position(x: 2, y: 2))
        secondBoard.set(letter: "A", at: Position.zero)
        secondBoard.set(letter: "A", at: Position(x: 1, y: 1))
        secondBoard.set(letter: "A", at: Position(x: 2, y: 2))
        checkEquality()
    }
    
    // MARK: - IsCenterAt
    
    func testIsCenterAtReturnsTrue() {
        XCTAssertTrue(board.isCenter(at: centerPosition))
    }
    
    func testIsCenterAtReturnsFalseIfYIsZero() {
        XCTAssertFalse(board.isCenter(at: Position(x: center, y: 0)))
    }
    
    func testIsCenterAtReturnsFalseIfXIsZero() {
        XCTAssertFalse(board.isCenter(at: Position(x: 0, y: center)))
    }
    
    // MARK: - Subscript
    
    func testSubscriptReturnsNil() {
        XCTAssertNil(board.letter(at: Position.zero))
    }
    
    func testSubscriptReturnsLetter() {
        board.set(letter: "A", at: Position.zero)
        XCTAssertEqual(board.letter(at: Position.zero), "A")
    }
    
    // MARK: - IsFirstPlay
    
    func testIsFirstPlayReturnsTrue() {
        XCTAssert(board.isFirstPlay)
    }
    
    func testIsFirstPlayReturnsFalse() {
        board.set(letter: "A", at: centerPosition)
        XCTAssertFalse(board.isFirstPlay)
    }
    
    // MARK: - IsEmptyAt
    
    func testIsEmptyAtReturnsTrue() {
        XCTAssert(board.isEmpty(at: Position.zero))
    }
    
    func testIsEmptyAtReturnsFalse() {
        board.set(letter: "A", at: Position.zero)
        XCTAssertFalse(board.isEmpty(at: Position.zero))
    }
    
    // MARK: - IsFilledAt
    
    func testIsFilledAtReturnsTrue() {
        board.set(letter: "A", at: Position.zero)
        XCTAssert(board.isFilled(at: Position.zero))
    }
    
    func testIsFilledAtReturnsFalse() {
        XCTAssertFalse(board.isFilled(at: Position.zero))
    }
    
    // MARK: - LetterAt
    
    func testLetterAtReturnsNil() {
        XCTAssertNil(board.letter(at: Position.zero))
    }
    
    func testLetterAtReturnsLetter() {
        board.set(letter: "A", at: Position.zero)
        XCTAssertEqual(board.letter(at: Position.zero), "A")
    }
    
    // MARK: - Play
    
    func testPlayHorizontal() {
        let solution = Solution(word: "TEST", x: center, y: center, horizontal: true, score: 4, intersections: [], blanks: [])
        XCTAssert(board.play(solution: solution).count > 0)
        XCTAssertEqual(board.letter(at: centerPosition), "T")
        XCTAssertEqual(board.letter(at: centerPosition.right), "E")
        XCTAssertEqual(board.letter(at: centerPosition.moveX(amount: 2)), "S")
        XCTAssertEqual(board.letter(at: centerPosition.moveX(amount: 3)), "T")
    }
    
    func testPlayVertical() {
        let solution = Solution(word: "TEST", x: center, y: center, horizontal: false, score: 4, intersections: [], blanks: [])
        XCTAssert(board.play(solution: solution).count > 0)
        XCTAssertEqual(board.letter(at: centerPosition), "T")
        XCTAssertEqual(board.letter(at: centerPosition.bottom), "E")
        XCTAssertEqual(board.letter(at: centerPosition.moveY(amount: 2)), "S")
        XCTAssertEqual(board.letter(at: centerPosition.moveY(amount: 3)), "T")
    }
    
    // MARK: - Board Range
    
    func testConfigBoardRange() {
        XCTAssertEqual(board.boardRange.count, board.size)
    }
    
    // MARK: - Debug String
    
    func testBoardDebugString() {
        board.set(letter: "A", at: Position.zero)
        XCTAssertEqual(board.debugDescription.characters.first, "A")
        XCTAssert(board.debugDescription.contains("_"))
        XCTAssert(board.debugDescription.contains("\n"))
    }
}
