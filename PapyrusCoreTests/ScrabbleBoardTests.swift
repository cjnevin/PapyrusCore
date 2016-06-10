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
    var board: Board!
    var config: BoardConfig!
    
    override func setUp() {
        super.setUp()
        config = ScrabbleBoardConfig()
        board = Board(config: config)
    }
    
    override func tearDown() {
        super.tearDown()
        board = nil
        config = nil
    }
    
    // MARK: - IsValidAt
    
    func testIsValidAtCenterReturnsTrue() {
        XCTAssertTrue(board.isValidAt(config.center, config.center, length: 1, horizontal: true))
        XCTAssertTrue(board.isValidAt(config.center, config.center, length: 1, horizontal: false))
    }
    
    func testIsValidAtFilledReturnsFalse() {
        board.board[config.center][config.center] = "A"
        XCTAssertFalse(board.isValidAt(config.center, config.center, length: 1, horizontal: true))
        XCTAssertFalse(board.isValidAt(config.center, config.center, length: 1, horizontal: false))
    }
    
    func testIsValidAtExceedsBoundaryReturnsFalse() {
        XCTAssertFalse(board.isValidAt(1, 1, length: config.size, horizontal: true))
        XCTAssertFalse(board.isValidAt(1, 1, length: config.size, horizontal: false))
    }
    
    func testIsValidAtHorizontalTouchesOnLeftReturnsFalse() {
        board.board[0][0] = "A"
        XCTAssertFalse(board.isValidAt(1, 0, length: 1, horizontal: true))
    }
    
    func testIsValidAtVerticalTouchesOnLeftReturnsTrue() {
        board.board[0][0] = "A"
        XCTAssertTrue(board.isValidAt(1, 0, length: 1, horizontal: false))
    }
    
    func testIsValidAtHorizontalTouchesOnRightReturnsFalse() {
        board.board[0][1] = "A"
        XCTAssertFalse(board.isValidAt(0, 0, length: 1, horizontal: true))
    }
    
    func testIsValidAtVerticalTouchesOnRightReturnsTrue() {
        board.board[0][1] = "A"
        XCTAssertTrue(board.isValidAt(0, 0, length: 1, horizontal: false))
    }
    
    func testIsValidAtHorizontalTouchesOnTopReturnsTrue() {
        board.board[0][0] = "A"
        XCTAssertTrue(board.isValidAt(0, 1, length: 1, horizontal: true))
    }
    
    func testIsValidAtVerticalTouchesOnTopReturnsFalse() {
        board.board[0][0] = "A"
        XCTAssertFalse(board.isValidAt(0, 1, length: 1, horizontal: false))
    }
    
    func testIsValidAtHorizontalTouchesOnTopReturnsFalse() {
        board.board[0][0] = "A"
        XCTAssertFalse(board.isValidAt(0, 2, length: 1, horizontal: true))
    }
    
    func testIsValidAtHorizontalTouchesOnBottomReturnsTrue() {
        board.board[1][0] = "A"
        XCTAssertTrue(board.isValidAt(0, 0, length: 1, horizontal: true))
    }
    
    func testIsValidAtVerticalTouchesOnBottomReturnsFalse() {
        board.board[1][0] = "A"
        XCTAssertFalse(board.isValidAt(0, 0, length: 1, horizontal: false))
    }
    
    func testIsValidAtVerticalIntersectionReturnsTrue() {
        board.board[1][0] = "A"
        XCTAssertTrue(board.isValidAt(0, 0, length: 2, horizontal: false))
    }
    
    func testIsValidAtHorizontalIntersectionReturnsTrue() {
        board.board[0][1] = "A"
        XCTAssertTrue(board.isValidAt(0, 0, length: 2, horizontal: true))
    }
    
    // MARK: - HorizontallyTouchesAt
    
    func testHorizontallyTouchesAtTopReturnsTrue() {
        board.board[config.center][config.center] = "A"
        XCTAssertTrue(board.horizontallyTouchesAt(config.center, config.center + 1, length: 2, edges: .Top))
    }
    
    func testHorizontallyTouchesAtTopReturnsFalse() {
        board.board[config.center][config.center] = "A"
        XCTAssertFalse(board.horizontallyTouchesAt(config.center, config.center, length: 1, edges: .Top))
    }
    
    // This test covers all edges
    func testHorizontallyTouchesAtTopReturnsFalseIfXIsNegative() {
        XCTAssertFalse(board.horizontallyTouchesAt(-1, config.center, length: 0, edges: .Top))
    }
    
    // This test covers all edges
    func testHorizontallyTouchesAtBottomReturnsFalseIfLengthExceedsBoardSize() {
        XCTAssertFalse(board.horizontallyTouchesAt(1, config.center, length: config.size, edges: .Bottom))
    }
    
    func testHorizontallyTouchesAtBottomReturnsTrue() {
        board.board[config.center][config.center] = "A"
        XCTAssertTrue(board.horizontallyTouchesAt(config.center, config.center - 1, length: 1, edges: .Bottom))
    }
    
    func testHorizontallyTouchesAtBottomReturnsFalse() {
        board.board[config.center][config.center] = "A"
        XCTAssertFalse(board.horizontallyTouchesAt(config.center, config.center, length: 1, edges: .Bottom))
    }
    
    func testHorizontallyTouchesAtLeftReturnsTrue() {
        board.board[config.center][config.center] = "A"
        XCTAssertTrue(board.horizontallyTouchesAt(config.center + 1, config.center, length: 1, edges: .Left))
    }
    
    func testHorizontallyTouchesAtLeftReturnsFalse() {
        board.board[config.center][config.center] = "A"
        XCTAssertFalse(board.horizontallyTouchesAt(config.center, config.center, length: 1, edges: .Left))
    }
    
    func testHorizontallyTouchesAtRightReturnsTrue() {
        board.board[config.center][config.center] = "A"
        XCTAssertTrue(board.horizontallyTouchesAt(config.center - 1, config.center, length: 1, edges: .Right))
    }
    
    func testHorizontallyTouchesAtRightReturnsFalse() {
        board.board[config.center][config.center] = "A"
        XCTAssertFalse(board.horizontallyTouchesAt(config.center, config.center, length: 1, edges: .Right))
    }
    
    
    // MARK: - VerticallyTouchesAt
    
    func testVerticallyTouchesAtTopReturnsTrue() {
        board.board[config.center][config.center] = "A"
        XCTAssertTrue(board.verticallyTouchesAt(config.center, config.center + 1, length: 0, edges: .Top))
    }
    
    func testVerticallyTouchesAtTopReturnsFalse() {
        board.board[config.center][config.center] = "A"
        XCTAssertFalse(board.verticallyTouchesAt(config.center, config.center, length: 0, edges: .Top))
    }
    
    // This test covers all edges
    func testVerticallyTouchesAtTopReturnsFalseIfYIsNegative() {
        XCTAssertFalse(board.verticallyTouchesAt(config.center, -1, length: 0, edges: .Top))
    }
    
    // This test covers all edges
    func testVerticallyTouchesAtBottomReturnsFalseIfLengthExceedsBoardSize() {
        XCTAssertFalse(board.verticallyTouchesAt(config.center, 1, length: config.size, edges: .Bottom))
    }
    
    func testVerticallyTouchesAtBottomReturnsTrue() {
        board.board[config.center][config.center] = "A"
        XCTAssertTrue(board.verticallyTouchesAt(config.center, config.center - 1, length: 1, edges: .Bottom))
    }
    
    func testVerticallyTouchesAtBottomReturnsFalse() {
        board.board[config.center][config.center] = "A"
        XCTAssertFalse(board.verticallyTouchesAt(config.center, config.center, length: 2, edges: .Bottom))
    }
    
    func testVerticallyTouchesAtBottomReturnsFalseIfLengthIsTooLong() {
        board.board[config.center][config.center] = "A"
        XCTAssertFalse(board.verticallyTouchesAt(config.center, config.center - 1, length: 2, edges: .Bottom))
    }
    
    func testVerticallyTouchesAtLeftReturnsTrue() {
        board.board[config.center][config.center] = "A"
        XCTAssertTrue(board.verticallyTouchesAt(config.center + 1, config.center, length: 1, edges: .Left))
    }
    
    func testVerticallyTouchesAtLeftReturnsFalse() {
        board.board[config.center][config.center] = "A"
        XCTAssertFalse(board.verticallyTouchesAt(config.center, config.center, length: 1, edges: .Left))
    }
    
    func testVerticallyTouchesAtRightReturnsTrue() {
        board.board[config.center][config.center] = "A"
        XCTAssertTrue(board.verticallyTouchesAt(config.center - 1, config.center, length: 1, edges: .Right))
    }
    
    func testVerticallyTouchesAtRightReturnsFalse() {
        board.board[config.center][config.center] = "A"
        XCTAssertFalse(board.verticallyTouchesAt(config.center, config.center, length: 1, edges: .Right))
    }
    
    // MARK: - ExceedsBoundaryAt
    
    func testExceedsBoundaryAtVerticalReturnsTrue() {
        var x = config.size - 2, y = config.size - 2
        XCTAssertTrue(board.exceedsBoundaryAt(&x, &y, length: 3, horizontal: false))
    }
    
    func testExceedsBoundaryAtVerticalReturnsFalse() {
        var x = config.size - 2, y = config.size - 2
        XCTAssertFalse(board.exceedsBoundaryAt(&x, &y, length: 2, horizontal: false))
    }
    
    func testExceedsBoundaryAtHorizontalReturnsTrue() {
        var x = config.size - 2, y = config.size - 2
        XCTAssertTrue(board.exceedsBoundaryAt(&x, &y, length: 3, horizontal: true))
    }
    
    func testExceedsBoundaryAtHorizontalReturnsFalse() {
        var x = config.size - 2, y = config.size - 2
        XCTAssertFalse(board.exceedsBoundaryAt(&x, &y, length: 2, horizontal: true))
    }
    
    func testExceedsBoundaryAtXEqualsSize() {
        var x = config.size - 2, y = config.size - 2
        board.exceedsBoundaryAt(&x, &y, length: 3, horizontal: true)
        XCTAssertEqual(x, config.size)
    }
    
    func testExceedsBoundaryAtXEqualsSizeIfSquareIsFilled() {
        board.board[config.size - 2][config.size - 2] = "A"
        var x = config.size - 2, y = config.size - 2
        board.exceedsBoundaryAt(&x, &y, length: 2, horizontal: true)
        XCTAssertEqual(x, config.size)
    }
    
    func testExceedsBoundaryAtYEqualsSize() {
        var x = config.size - 2, y = config.size - 2
        board.exceedsBoundaryAt(&x, &y, length: 3, horizontal: false)
        XCTAssertEqual(y, config.size)
    }
    
    func testExceedsBoundaryAtYEqualsSizeIfSquareIsFilled() {
        board.board[config.size - 2][config.size - 2] = "A"
        var x = config.size - 2, y = config.size - 2
        board.exceedsBoundaryAt(&x, &y, length: 2, horizontal: false)
        XCTAssertEqual(y, config.size)
    }
    
    // MARK: - Equality
    
    func testEqualityReturnsTrueIfEmpty() {
        let secondBoard = Board(config: config)
        XCTAssertEqual(board, secondBoard)
    }
    
    func testEqualityReturnsFalse() {
        board.board[0][0] = "A"
        let secondBoard = Board(config: config)
        XCTAssertNotEqual(board, secondBoard)
    }
    
    func testEqualityReturnsTrueIfFilled() {
        board.board[0][0] = "A"
        board.board[1][1] = "A"
        board.board[2][2] = "A"
        var secondBoard = Board(config: config)
        secondBoard.board[0][0] = "A"
        secondBoard.board[1][1] = "A"
        secondBoard.board[2][2] = "A"
        XCTAssertEqual(board, secondBoard)
    }
    
    // MARK: - IsCenterAt
    
    func testIsCenterAtReturnsTrue() {
        XCTAssertTrue(board.isCenterAt(config.center, config.center))
    }
    
    func testIsCenterAtReturnsFalseIfYIsZero() {
        XCTAssertFalse(board.isCenterAt(config.center, 0))
    }
    
    func testIsCenterAtReturnsFalseIfXIsZero() {
        XCTAssertFalse(board.isCenterAt(0, config.center))
    }
    
    // MARK: - Subscript
    
    func testSubscriptReturnsNil() {
        XCTAssertNil(board[0, 0])
    }
    
    func testSubscriptReturnsLetter() {
        board.board[0][0] = "A"
        XCTAssertEqual(board[0, 0], "A")
    }
    
    // MARK: - IsFirstPlay
    
    func testIsFirstPlayReturnsTrue() {
        XCTAssert(board.isFirstPlay)
    }
    
    func testIsFirstPlayReturnsFalse() {
        board.board[config.center][config.center] = "A"
        XCTAssertFalse(board.isFirstPlay)
    }
    
    // MARK: - IsEmptyAt
    
    func testIsEmptyAtReturnsTrue() {
        XCTAssert(board.isEmptyAt(0, 0))
    }
    
    func testIsEmptyAtReturnsFalse() {
        board.board[0][0] = "A"
        XCTAssertFalse(board.isEmptyAt(0, 0))
    }
    
    // MARK: - IsFilledAt
    
    func testIsFilledAtReturnsTrue() {
        board.board[0][0] = "A"
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
        board.board[0][0] = "A"
        XCTAssertEqual(board.letterAt(0, 0), "A")
    }
    
    // MARK: - Play
    
    func testPlayHorizontal() {
        let solution = Solution(word: "TEST", x: config.center, y: config.center, horizontal: true, score: 4, intersections: [], blanks: [])
        board.play(solution)
        XCTAssertEqual(board.letterAt(config.center, config.center), "T")
        XCTAssertEqual(board.letterAt(config.center + 1, config.center), "E")
        XCTAssertEqual(board.letterAt(config.center + 2, config.center), "S")
        XCTAssertEqual(board.letterAt(config.center + 3, config.center), "T")
    }
    
    func testPlayVertical() {
        let solution = Solution(word: "TEST", x: config.center, y: config.center, horizontal: false, score: 4, intersections: [], blanks: [])
        board.play(solution)
        XCTAssertEqual(board.letterAt(config.center, config.center), "T")
        XCTAssertEqual(board.letterAt(config.center, config.center + 1), "E")
        XCTAssertEqual(board.letterAt(config.center, config.center + 2), "S")
        XCTAssertEqual(board.letterAt(config.center, config.center + 3), "T")
    }
    
    // MARK: - Board Range
    
    func testConfigBoardRange() {
        XCTAssertEqual(config.boardRange.count, config.size)
    }
    
    // MARK: - Debug String
    
    func testBoardDebugString() {
        board.board[0][0] = "A"
        XCTAssertEqual(board.debugDescription.characters.first, "A")
        XCTAssert(board.debugDescription.containsString("_"))
        XCTAssert(board.debugDescription.containsString("\n"))
    }
}