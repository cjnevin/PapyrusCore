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
    
    override func setUp() {
        super.setUp()
        boardType = ScrabbleBoard.self
        let scrabbleBoard = ScrabbleBoard()
        board = scrabbleBoard
        secondBoard = ScrabbleBoard()
        center = scrabbleBoard.center
    }
    
    override func tearDown() {
        super.tearDown()
        board = nil
    }
    
    // MARK: - IsValidAt
    
    func testIsValidAtCenterReturnsTrue() {
        XCTAssertTrue(board.isValidAt(center, center, length: 1, horizontal: true))
        XCTAssertTrue(board.isValidAt(center, center, length: 1, horizontal: false))
    }
    
    func testIsValidAtFilledReturnsFalse() {
        board.layout[center][center] = "A"
        XCTAssertFalse(board.isValidAt(center, center, length: 1, horizontal: true))
        XCTAssertFalse(board.isValidAt(center, center, length: 1, horizontal: false))
    }
    
    func testIsValidAtExceedsBoundaryReturnsFalse() {
        XCTAssertFalse(board.isValidAt(1, 1, length: board.size, horizontal: true))
        XCTAssertFalse(board.isValidAt(1, 1, length: board.size, horizontal: false))
    }
    
    func testIsValidAtHorizontalTouchesOnLeftReturnsFalse() {
        board.layout[0][0] = "A"
        XCTAssertFalse(board.isValidAt(1, 0, length: 1, horizontal: true))
    }
    
    func testIsValidAtVerticalTouchesOnLeftReturnsTrue() {
        board.layout[0][0] = "A"
        XCTAssertTrue(board.isValidAt(1, 0, length: 1, horizontal: false))
    }
    
    func testIsValidAtHorizontalTouchesOnRightReturnsFalse() {
        board.layout[0][1] = "A"
        XCTAssertFalse(board.isValidAt(0, 0, length: 1, horizontal: true))
    }
    
    func testIsValidAtVerticalTouchesOnRightReturnsTrue() {
        board.layout[0][1] = "A"
        XCTAssertTrue(board.isValidAt(0, 0, length: 1, horizontal: false))
    }
    
    func testIsValidAtHorizontalTouchesOnTopReturnsTrue() {
        board.layout[0][0] = "A"
        XCTAssertTrue(board.isValidAt(0, 1, length: 1, horizontal: true))
    }
    
    func testIsValidAtVerticalTouchesOnTopReturnsFalse() {
        board.layout[0][0] = "A"
        XCTAssertFalse(board.isValidAt(0, 1, length: 1, horizontal: false))
    }
    
    func testIsValidAtHorizontalTouchesOnTopReturnsFalse() {
        board.layout[0][0] = "A"
        XCTAssertFalse(board.isValidAt(0, 2, length: 1, horizontal: true))
    }
    
    func testIsValidAtHorizontalTouchesOnBottomReturnsTrue() {
        board.layout[1][0] = "A"
        XCTAssertTrue(board.isValidAt(0, 0, length: 1, horizontal: true))
    }
    
    func testIsValidAtVerticalTouchesOnBottomReturnsFalse() {
        board.layout[1][0] = "A"
        XCTAssertFalse(board.isValidAt(0, 0, length: 1, horizontal: false))
    }
    
    func testIsValidAtVerticalIntersectionReturnsTrue() {
        board.layout[1][0] = "A"
        XCTAssertTrue(board.isValidAt(0, 0, length: 2, horizontal: false))
    }
    
    func testIsValidAtHorizontalIntersectionReturnsTrue() {
        board.layout[0][1] = "A"
        XCTAssertTrue(board.isValidAt(0, 0, length: 2, horizontal: true))
    }
    
    // MARK: - HorizontallyTouchesAt
    
    func testHorizontallyTouchesAtTopReturnsTrue() {
        board.layout[center][center] = "A"
        XCTAssertTrue(board.horizontallyTouchesAt(center, center + 1, length: 2, edges: .Top))
    }
    
    func testHorizontallyTouchesAtTopReturnsFalse() {
        board.layout[center][center] = "A"
        XCTAssertFalse(board.horizontallyTouchesAt(center, center, length: 1, edges: .Top))
    }
    
    // This test covers all edges
    func testHorizontallyTouchesAtTopReturnsFalseIfXIsNegative() {
        XCTAssertFalse(board.horizontallyTouchesAt(-1, center, length: 0, edges: .Top))
    }
    
    // This test covers all edges
    func testHorizontallyTouchesAtBottomReturnsFalseIfLengthExceedsBoardSize() {
        XCTAssertFalse(board.horizontallyTouchesAt(1, center, length: board.size, edges: .Bottom))
    }
    
    func testHorizontallyTouchesAtBottomReturnsTrue() {
        board.layout[center][center] = "A"
        XCTAssertTrue(board.horizontallyTouchesAt(center, center - 1, length: 1, edges: .Bottom))
    }
    
    func testHorizontallyTouchesAtBottomReturnsFalse() {
        board.layout[center][center] = "A"
        XCTAssertFalse(board.horizontallyTouchesAt(center, center, length: 1, edges: .Bottom))
    }
    
    func testHorizontallyTouchesAtLeftReturnsTrue() {
        board.layout[center][center] = "A"
        XCTAssertTrue(board.horizontallyTouchesAt(center + 1, center, length: 1, edges: .Left))
    }
    
    func testHorizontallyTouchesAtLeftReturnsFalse() {
        board.layout[center][center] = "A"
        XCTAssertFalse(board.horizontallyTouchesAt(center, center, length: 1, edges: .Left))
    }
    
    func testHorizontallyTouchesAtRightReturnsTrue() {
        board.layout[center][center] = "A"
        XCTAssertTrue(board.horizontallyTouchesAt(center - 1, center, length: 1, edges: .Right))
    }
    
    func testHorizontallyTouchesAtRightReturnsFalse() {
        board.layout[center][center] = "A"
        XCTAssertFalse(board.horizontallyTouchesAt(center, center, length: 1, edges: .Right))
    }
    
    
    // MARK: - VerticallyTouchesAt
    
    func testVerticallyTouchesAtTopReturnsTrue() {
        board.layout[center][center] = "A"
        XCTAssertTrue(board.verticallyTouchesAt(center, center + 1, length: 0, edges: .Top))
    }
    
    func testVerticallyTouchesAtTopReturnsFalse() {
        board.layout[center][center] = "A"
        XCTAssertFalse(board.verticallyTouchesAt(center, center, length: 0, edges: .Top))
    }
    
    // This test covers all edges
    func testVerticallyTouchesAtTopReturnsFalseIfYIsNegative() {
        XCTAssertFalse(board.verticallyTouchesAt(center, -1, length: 0, edges: .Top))
    }
    
    // This test covers all edges
    func testVerticallyTouchesAtBottomReturnsFalseIfLengthExceedsBoardSize() {
        XCTAssertFalse(board.verticallyTouchesAt(center, 1, length: board.size, edges: .Bottom))
    }
    
    func testVerticallyTouchesAtBottomReturnsTrue() {
        board.layout[center][center] = "A"
        XCTAssertTrue(board.verticallyTouchesAt(center, center - 1, length: 1, edges: .Bottom))
    }
    
    func testVerticallyTouchesAtBottomReturnsFalse() {
        board.layout[center][center] = "A"
        XCTAssertFalse(board.verticallyTouchesAt(center, center, length: 2, edges: .Bottom))
    }
    
    func testVerticallyTouchesAtBottomReturnsFalseIfLengthIsTooLong() {
        board.layout[center][center] = "A"
        XCTAssertFalse(board.verticallyTouchesAt(center, center - 1, length: 2, edges: .Bottom))
    }
    
    func testVerticallyTouchesAtLeftReturnsTrue() {
        board.layout[center][center] = "A"
        XCTAssertTrue(board.verticallyTouchesAt(center + 1, center, length: 1, edges: .Left))
    }
    
    func testVerticallyTouchesAtLeftReturnsFalse() {
        board.layout[center][center] = "A"
        XCTAssertFalse(board.verticallyTouchesAt(center, center, length: 1, edges: .Left))
    }
    
    func testVerticallyTouchesAtRightReturnsTrue() {
        board.layout[center][center] = "A"
        XCTAssertTrue(board.verticallyTouchesAt(center - 1, center, length: 1, edges: .Right))
    }
    
    func testVerticallyTouchesAtRightReturnsFalse() {
        board.layout[center][center] = "A"
        XCTAssertFalse(board.verticallyTouchesAt(center, center, length: 1, edges: .Right))
    }
    
    // MARK: - ExceedsBoundaryAt
    
    func testExceedsBoundaryAtVerticalReturnsTrue() {
        var x = board.size - 2, y = board.size - 2
        XCTAssertTrue(board.exceedsBoundaryAt(&x, &y, length: 3, horizontal: false))
    }
    
    func testExceedsBoundaryAtVerticalReturnsFalse() {
        var x = board.size - 2, y = board.size - 2
        XCTAssertFalse(board.exceedsBoundaryAt(&x, &y, length: 2, horizontal: false))
    }
    
    func testExceedsBoundaryAtHorizontalReturnsTrue() {
        var x = board.size - 2, y = board.size - 2
        XCTAssertTrue(board.exceedsBoundaryAt(&x, &y, length: 3, horizontal: true))
    }
    
    func testExceedsBoundaryAtHorizontalReturnsFalse() {
        var x = board.size - 2, y = board.size - 2
        XCTAssertFalse(board.exceedsBoundaryAt(&x, &y, length: 2, horizontal: true))
    }
    
    func testExceedsBoundaryAtXEqualsSize() {
        var x = board.size - 2, y = board.size - 2
        board.exceedsBoundaryAt(&x, &y, length: 3, horizontal: true)
        XCTAssertEqual(x, board.size)
    }
    
    func testExceedsBoundaryAtXEqualsSizeIfSquareIsFilled() {
        board.layout[board.size - 2][board.size - 2] = "A"
        var x = board.size - 2, y = board.size - 2
        board.exceedsBoundaryAt(&x, &y, length: 2, horizontal: true)
        XCTAssertEqual(x, board.size)
    }
    
    func testExceedsBoundaryAtYEqualsSize() {
        var x = board.size - 2, y = board.size - 2
        board.exceedsBoundaryAt(&x, &y, length: 3, horizontal: false)
        XCTAssertEqual(y, board.size)
    }
    
    func testExceedsBoundaryAtYEqualsSizeIfSquareIsFilled() {
        board.layout[board.size - 2][board.size - 2] = "A"
        var x = board.size - 2, y = board.size - 2
        board.exceedsBoundaryAt(&x, &y, length: 2, horizontal: false)
        XCTAssertEqual(y, board.size)
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
        board.layout[0][0] = "A"
        checkEquality(false)
    }
    
    func testEqualityReturnsTrueIfFilled() {
        board.layout[0][0] = "A"
        board.layout[1][1] = "A"
        board.layout[2][2] = "A"
        secondBoard.layout[0][0] = "A"
        secondBoard.layout[1][1] = "A"
        secondBoard.layout[2][2] = "A"
        checkEquality()
    }
    
    // MARK: - IsCenterAt
    
    func testIsCenterAtReturnsTrue() {
        XCTAssertTrue(board.isCenterAt(center, center))
    }
    
    func testIsCenterAtReturnsFalseIfYIsZero() {
        XCTAssertFalse(board.isCenterAt(center, 0))
    }
    
    func testIsCenterAtReturnsFalseIfXIsZero() {
        XCTAssertFalse(board.isCenterAt(0, center))
    }
    
    // MARK: - Subscript
    
    func testSubscriptReturnsNil() {
        XCTAssertNil(board[0, 0])
    }
    
    func testSubscriptReturnsLetter() {
        board.layout[0][0] = "A"
        XCTAssertEqual(board[0, 0], "A")
    }
    
    // MARK: - IsFirstPlay
    
    func testIsFirstPlayReturnsTrue() {
        XCTAssert(board.isFirstPlay)
    }
    
    func testIsFirstPlayReturnsFalse() {
        board.layout[center][center] = "A"
        XCTAssertFalse(board.isFirstPlay)
    }
    
    // MARK: - IsEmptyAt
    
    func testIsEmptyAtReturnsTrue() {
        XCTAssert(board.isEmptyAt(0, 0))
    }
    
    func testIsEmptyAtReturnsFalse() {
        board.layout[0][0] = "A"
        XCTAssertFalse(board.isEmptyAt(0, 0))
    }
    
    // MARK: - IsFilledAt
    
    func testIsFilledAtReturnsTrue() {
        board.layout[0][0] = "A"
        XCTAssert(board.isFilledAt(0, 0))
    }
    
    func testIsFilledAtReturnsFalse() {
        XCTAssertFalse(board.isFilledAt(0, 0))
    }
    
    // MARK: - LetterAt
    
    func testLetterAtReturnsNil() {
        XCTAssertNil(board.letterAt(0, 0))
    }
    
    func testLetterAtReturnsLetter() {
        board.layout[0][0] = "A"
        XCTAssertEqual(board.letterAt(0, 0), "A")
    }
    
    // MARK: - Play
    
    func testPlayHorizontal() {
        let solution = Solution(word: "TEST", x: center, y: center, horizontal: true, score: 4, intersections: [], blanks: [])
        board.play(solution)
        XCTAssertEqual(board.letterAt(center, center), "T")
        XCTAssertEqual(board.letterAt(center + 1, center), "E")
        XCTAssertEqual(board.letterAt(center + 2, center), "S")
        XCTAssertEqual(board.letterAt(center + 3, center), "T")
    }
    
    func testPlayVertical() {
        let solution = Solution(word: "TEST", x: center, y: center, horizontal: false, score: 4, intersections: [], blanks: [])
        board.play(solution)
        XCTAssertEqual(board.letterAt(center, center), "T")
        XCTAssertEqual(board.letterAt(center, center + 1), "E")
        XCTAssertEqual(board.letterAt(center, center + 2), "S")
        XCTAssertEqual(board.letterAt(center, center + 3), "T")
    }
    
    // MARK: - Board Range
    
    func testConfigBoardRange() {
        XCTAssertEqual(board.boardRange.count, board.size)
    }
    
    // MARK: - Debug String
    
    func testBoardDebugString() {
        board.layout[0][0] = "A"
        XCTAssertEqual(board.debugDescription.characters.first, "A")
        XCTAssert(board.debugDescription.contains("_"))
        XCTAssert(board.debugDescription.contains("\n"))
    }
}
