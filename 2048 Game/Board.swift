//
//  Board.swift
//  2048 Game
//
//  Created by Tammy Truong on 1/17/19.
//  Copyright © 2019 Tammy Truong. All rights reserved.
//

import Foundation
import os.log

class Board: NSObject, NSCoding {
    
    // MARK: Properties
    
    // State of the game
    var gameOver: Bool
    // If the winning tile has been attained
    var win: Bool
    // Board state of the game
    var board = [[Int]]()
    // Previous state of the board for undo purposes
    var prevBoard = [[Int]]()
    // Size of board
    let size: Int
    // The value of the winning tile
    let winTile = 2048
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("board")
    
    //MARK: Types
    
    struct PropertyKey {
        static let gameOver = "gameOver"
        static let board = "board"
        static let size = "size"
        static let winTile = "winTile"
    }
    
    // Initialize a game board with starting tiles
    init(size: Int, board: [[Int]], gameOver: Bool, winTile: Int) {
        self.gameOver = gameOver
        self.win = false
        self.size = size
        var row = [Int]()
        if board == [[0]] {
            for _ in 0...(size - 1) {
                row.append(0)
            }
            for _ in 0...(size - 1) {
                self.board.append(row)
            }
        } else {
            self.board = board
        }
    }
    
    // Clear the board
    func clear() {
        self.gameOver = false
        for row in 0...(size - 1) {
            for col in 0...(size - 1) {
                self.board[row][col] = 0
            }
        }
    }
    
    
    // Add a tile of either 2 or 4 to the board
    func addTile() {
        let tileToAdd = [2, 2, 2, 4]
        let dice = [0, 1, 2, 3]
        var rowToAdd = 4
        var colToAdd = 4
        while (rowToAdd == 4 && colToAdd == 4) || (tileAt(row: rowToAdd, col: colToAdd) != 0) {
            rowToAdd = dice.randomElement()!
            colToAdd = dice.randomElement()!
        }
        setTile(row: rowToAdd, col: colToAdd, val: tileToAdd.randomElement()!)
    }
    
    // Copy of the current board
    func copyBoard() -> Board {
        let copy = Board(size: size, board: board, gameOver: gameOver, winTile: winTile)
        for row in 0...(size - 1) {
            for col in 0...(size - 1) {
                copy.board[row][col] = tileAt(row: row, col: col)
            }
        }
        return copy
    }
    
    // Returns a copy of the board that is rotated clockwise
    func rotateClockwise() -> [[Int]] {
        var copy = [[Int]]()        
        var newRow = [Int]()
        for _ in 0...(size - 1) {
            newRow.append(0)
        }
        for oldCol in 0...(size - 1) {
            for oldRow in 0...(size - 1) {
                newRow[oldRow] = board[oldRow][oldCol]
            }
            newRow = newRow.reversed()
            copy.append(newRow)
        }
        return copy
    }
    
    // 2D array of the empty positions on the board in row, col pairs [row, col]
    func emptyPositions() -> [[Int]] {
        var result = [[Int]]()
        for row in 0...(size - 1) {
            for col in 0...(size - 1) {
                if tileAt(row: row, col: col) == 0 {
                    result.append([row, col])
                }
            }
        }
        return result
    }
    
    // The value of the tile at row ROW and column COL
    func tileAt(row: Int, col: Int) -> Int {
        return board[row][col]
    }
    
    // Set the tile of row ROW and column COL to VAL
    func setTile(row: Int, col: Int, val: Int) {
        board[row][col] = val
    }
    
    // Returns true if the column is all shifted up
    func allShiftedUp(col: Int) -> Bool {
        var foundZero = false
        for row in 0...(size - 2) {
            if tileAt(row: row, col: col) == 0 {
                foundZero = true
            }
            if foundZero && tileAt(row: row + 1, col: col) != 0 {
                return false
            }
        }
        return true
    }
    
    // Shift all the tiles of column COL upward
    func shiftColUp(col: Int) {
        var shiftedTiles = [Int]()
        for row in 0...(size - 1) {
            if tileAt(row: row, col: col) != 0 {
                shiftedTiles.append(tileAt(row: row, col: col))
            }
        }
        if shiftedTiles.count == 4 {
            return
        }
        for _ in 0...(4 - shiftedTiles.count - 1) {
            shiftedTiles.append(0)
        }
        for row in 0...(size - 1) {
            setTile(row: row, col: col, val: shiftedTiles[row])
        }
    }
    
    // Merge column COL of the board up
    func mergeColUp(col: Int) {
        shiftColUp(col: col)
        for row in 0...(size - 2) {
            if tileAt(row: row, col: col) == tileAt(row: row + 1, col: col) {
                let newVal = tileAt(row: row, col: col) * 2
                setTile(row: row, col: col, val: newVal)
                setTile(row: row + 1, col: col, val: 0)
            }
        }
        shiftColUp(col: col)
    }
    
    // Merge the whole board up
    func mergeUp() {
        for col in 0...(size - 1) {
            mergeColUp(col: col)
        }
    }
    
    // Checks if the winning tile is on the board
    func checkWin() -> Bool {
        for row in 0...(size - 1) {
            for col in 0...(size - 1) {
                if tileAt(row: row, col: col) == winTile {
                    win = true
                    return true
                }
            }
        }
        win = false
        return false
    }
    
    // Checks if there are no moves left for the player on the board
    // Although the entire board may be filled, this does not mean that the game is over if there are still merges left
    func checkGameOver() -> Bool {
        if win {
            gameOver = true
            return true
        }
        for row in 0...(size - 1) {
            for col in 0...(size - 1) {
                if tileAt(row: row, col: col) == 0 {
                    gameOver = false
                    return false
                }
            }
        }
        let copyOriginalBoard = copyBoard()
        let copy = copyBoard()
        for _ in 0...3 {
            copy.mergeUp()
            if copy.board != copyOriginalBoard.board {
                gameOver = false
                return false
            }
            copy.board = copy.rotateClockwise()
            copyOriginalBoard.board = copyOriginalBoard.rotateClockwise()
        }
        gameOver = true
        return true
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(gameOver, forKey: PropertyKey.gameOver)
        aCoder.encode(board, forKey: PropertyKey.board)
        aCoder.encode(size, forKey: PropertyKey.size)
        aCoder.encode(winTile, forKey: PropertyKey.winTile)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The board is required. If we cannot decode the board, the initializer should fail.
        guard let board = aDecoder.decodeObject(forKey: PropertyKey.board) as? [[Int]] else {
            os_log("Unable to decode the board for a Board object.", log: OSLog.default, type: .debug)
            return nil
        }
        let gameOver = aDecoder.decodeBool(forKey: PropertyKey.gameOver)
        let size = aDecoder.decodeInteger(forKey: PropertyKey.size)
        let winTile = aDecoder.decodeInteger(forKey: PropertyKey.winTile)
        self.init(size: size, board: board, gameOver: gameOver, winTile: winTile)
    }
    
}
