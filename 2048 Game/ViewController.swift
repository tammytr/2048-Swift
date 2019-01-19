//
//  ViewController.swift
//  2048 Game
//
//  Created by Tammy Truong on 1/17/19.
//  Copyright © 2019 Tammy Truong. All rights reserved.
//

import UIKit
import os.log

class ViewController: UIViewController {

    
    @IBOutlet weak var instructionsLabel: UILabel!
    
    // Connecting the tiles
    @IBOutlet weak var tile0: UIImageView!
    @IBOutlet weak var tile1: UIImageView!
    @IBOutlet weak var tile2: UIImageView!
    @IBOutlet weak var tile3: UIImageView!
    @IBOutlet weak var tile4: UIImageView!
    @IBOutlet weak var tile5: UIImageView!
    @IBOutlet weak var tile6: UIImageView!
    @IBOutlet weak var tile7: UIImageView!
    @IBOutlet weak var tile8: UIImageView!
    @IBOutlet weak var tile9: UIImageView!
    @IBOutlet weak var tile10: UIImageView!
    @IBOutlet weak var tile11: UIImageView!
    @IBOutlet weak var tile12: UIImageView!
    @IBOutlet weak var tile13: UIImageView!
    @IBOutlet weak var tile14: UIImageView!
    @IBOutlet weak var tile15: UIImageView!
    
    // The current board of the game with each of its tile values
    var gameBoard: Board = Board(size: 4, board: [[0]], gameOver: false, winTile: 2048)

    // The previous board tiles before the most recent swipe, for undoing a move.
    // var prevBoard: [[Int]]

    // Set up board, swipe gestures, and tile images
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSwipes()
        if let savedBoard = loadBoard() {
            gameBoard = savedBoard
            let stringRepresentation = gameBoard.board.joined()
        } else {
            gameBoard.addTile()
            gameBoard.addTile()
        }
        updateTileImages()
    }
    
    // Set up up, down, left, and right swipe gestures
    func setUpSwipes() {
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpAction(swipe:)))
        upSwipe.direction = UISwipeGestureRecognizer.Direction.up
        self.view.addGestureRecognizer(upSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightAction(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(rightSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownAction(swipe:)))
        downSwipe.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftAction(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(leftSwipe)
    }

    // Functions to merge the tiles according to which direction the swipe is in
    
    @objc func swipeUpAction(swipe: UISwipeGestureRecognizer) {
        if !gameBoard.gameOver && !gameBoard.checkWin() && !gameBoard.checkGameOver() {
            gameBoard.prevBoard = gameBoard.board
            gameBoard.mergeUp()
            checkUpdates(previousBoard: gameBoard.prevBoard, currentBoard: gameBoard.board)
        }
        displayGameOver()
    }

    @objc func swipeRightAction(swipe: UISwipeGestureRecognizer) {
        if !gameBoard.gameOver && !gameBoard.checkWin() && !gameBoard.checkGameOver() {
            gameBoard.prevBoard = gameBoard.board
            for _ in 0...2 {
                gameBoard.board = gameBoard.rotateClockwise()
            }
            gameBoard.mergeUp()
            gameBoard.board = gameBoard.rotateClockwise()
            checkUpdates(previousBoard: gameBoard.prevBoard, currentBoard: gameBoard.board)
        }
        displayGameOver()
    }
    
    @objc func swipeDownAction(swipe: UISwipeGestureRecognizer) {
        if !gameBoard.gameOver && !gameBoard.checkWin() && !gameBoard.checkGameOver() {
            gameBoard.prevBoard = gameBoard.board
            for _ in 0...1 {
                gameBoard.board = gameBoard.rotateClockwise()
            }
            gameBoard.mergeUp()
            for _ in 0...1 {
                gameBoard.board = gameBoard.rotateClockwise()
            }
            checkUpdates(previousBoard: gameBoard.prevBoard, currentBoard: gameBoard.board)
        }
        displayGameOver()
    }
    
    @objc func swipeLeftAction(swipe: UISwipeGestureRecognizer) {
        if !gameBoard.gameOver && !gameBoard.checkWin() && !gameBoard.checkGameOver() {
            gameBoard.prevBoard = gameBoard.board
            gameBoard.board = gameBoard.rotateClockwise()
            gameBoard.mergeUp()
            for _ in 0...2 {
                gameBoard.board = gameBoard.rotateClockwise()
            }
            checkUpdates(previousBoard: gameBoard.prevBoard, currentBoard: gameBoard.board)
        }
        displayGameOver()
    }
    
    // Update the tile images after every move
    func updateTileImages() {
        let boardImagesBoard = [[tile0, tile1, tile2, tile3], [tile4, tile5, tile6, tile7], [tile8, tile9, tile10, tile11], [tile12, tile13, tile14, tile15]]
        for row in 0...(gameBoard.size - 1) {
            for col in 0...(gameBoard.size - 1) {
                boardImagesBoard[row][col]!.image = UIImage(named: "tile\(gameBoard.tileAt(row: row, col: col))")
            }
        }
        saveBoard()
    }
    
    // Check if the game board has changed upon a move and updates it with a tile
    func checkUpdates(previousBoard: [[Int]], currentBoard: [[Int]]) {
        if previousBoard != currentBoard {
            gameBoard.addTile()
            updateTileImages()
        }
    }
    
    // Undo the last move
    @IBAction func undoButton(_ sender: UIButton) {
        gameBoard.board = gameBoard.prevBoard
        updateTileImages()
    }
    
    // Reset the game to a new board
    @IBAction func resetButton(_ sender: UIButton) {
        gameBoard.clear()
        gameBoard.addTile()
        gameBoard.addTile()
        updateTileImages()
        instructionsLabel.text = "Merge the tiles to reach the 2048 tile!"
    }
    
    // Displays text if the game is over or if the game is won
    func displayGameOver() {
        if gameBoard.win {
            instructionsLabel.text = "You won!"
        } else if gameBoard.gameOver {
            instructionsLabel.text = "Game over!"
        }
    }
    
    private func saveBoard() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(gameBoard, toFile: Board.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Board successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save board...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadBoard() -> Board? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Board.ArchiveURL.path) as? Board
    }
}

