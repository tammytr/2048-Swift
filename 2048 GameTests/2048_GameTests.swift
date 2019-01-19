//
//  _048_GameTests.swift
//  2048 GameTests
//
//  Created by Tammy Truong on 1/17/19.
//  Copyright © 2019 Tammy Truong. All rights reserved.
//

import XCTest
@testable import _048_Game

class _048_GameTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRotateBoard() {
        let board = Board(size: 4)
        board.board = [[0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11], [12, 13, 14, 15]]
        let expected = [[12, 8, 4, 0], [13, 9, 5, 1], [14, 10, 6, 2], [15, 11, 7, 3]]
        let actual = board.rotateClockwise()
        assert(actual == expected, "incorrect rotation")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
