//
//  WordSearch.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation

// MARK: - MODEL LAYER
// The Model Layer contains the "Nouns" of our application. 
// It defines the data structures that represent what a Word Search game IS.

/// Represents a single cell (square) in the Word Search grid.
/// Every letter you see on the board is one of these cells.
struct WordSearchCell: Identifiable {
    
    // MARK: - Stored properties
    
    /// Unique identifier for the cell. 
    /// Required by the 'Identifiable' protocol so SwiftUI can track this specific cell in a grid.
    let id = UUID()
    
    /// The horizontal row index (0 is top). 
    /// We store this so the cell "knows" where it lives in the 2D array.
    let row: Int
    
    /// The vertical column index (0 is leftmost).
    let column: Int
    
    /// The actual character shown to the user (e.g., 'A', 'Z').
    let letter: Character
    
    /// A state variable that tracks if this specific letter has been found as part of a word.
    /// When this is true, the View will highlight this cell permanently.
    var isFound: Bool
    
    // MARK: - Initializer
    
    /// Creates a new cell. By default, 'isFound' is false because the game just started.
    init(row: Int, column: Int, letter: Character, isFound: Bool = false) {
        self.row = row
        self.column = column
        self.letter = letter
        self.isFound = isFound
    }
}

/// Represents a word that the player is looking for.
struct WordToFind: Identifiable {
    
    // MARK: - Stored properties
    
    /// Unique identifier for the word in the list.
    let id = UUID()
    
    /// The string representation of the word (e.g., "SWIFT").
    let text: String
    
    /// Tracks if the player has successfully highlighted this word in the grid.
    /// When this is true, the word will be crossed off in the sidebar list.
    var isFound: Bool
    
    // MARK: - Initializer
    
    /// Creates a new word to find.
    init(text: String, isFound: Bool = false) {
        self.text = text
        self.isFound = isFound
    }
}

/// The master structure that holds the entire state of a single Word Search game.
struct WordSearch {
    
    // MARK: - Stored properties
    
    /// The 2D Grid.
    /// It's an "Array of Arrays". grid[0] is the first row, grid[0][0] is the top-left cell.
    var grid: [[WordSearchCell]]
    
    /// The list of target words hidden within the grid.
    var words: [WordToFind]
    
    // MARK: - Initializer
    
    /// Creates a new game instance.
    init(grid: [[WordSearchCell]], words: [WordToFind]) {
        self.grid = grid
        self.words = words
    }
}

// MARK: - FALLBACK DATA

/// A simple 5x5 example used as a safety fallback if the generator fails.
let exampleWordSearch = WordSearch(
    grid: [
        [WordSearchCell(row: 0, column: 0, letter: "S"), WordSearchCell(row: 0, column: 1, letter: "W"), WordSearchCell(row: 0, column: 2, letter: "I"), WordSearchCell(row: 0, column: 3, letter: "F"), WordSearchCell(row: 0, column: 4, letter: "T")],
        [WordSearchCell(row: 1, column: 0, letter: "L"), WordSearchCell(row: 1, column: 1, letter: "X"), WordSearchCell(row: 1, column: 2, letter: "C"), WordSearchCell(row: 1, column: 3, letter: "O"), WordSearchCell(row: 1, column: 4, letter: "D")],
        [WordSearchCell(row: 2, column: 0, letter: "A"), WordSearchCell(row: 2, column: 1, letter: "P"), WordSearchCell(row: 2, column: 2, letter: "P"), WordSearchCell(row: 2, column: 3, letter: "L"), WordSearchCell(row: 2, column: 4, letter: "E")],
        [WordSearchCell(row: 3, column: 0, letter: "X"), WordSearchCell(row: 3, column: 1, letter: "Y"), WordSearchCell(row: 3, column: 2, letter: "Z"), WordSearchCell(row: 3, column: 3, letter: "A"), WordSearchCell(row: 3, column: 4, letter: "B")],
        [WordSearchCell(row: 4, column: 0, letter: "R"), WordSearchCell(row: 4, column: 1, letter: "O"), WordSearchCell(row: 4, column: 2, letter: "S"), WordSearchCell(row: 4, column: 3, letter: "S"), WordSearchCell(row: 4, column: 4, letter: "Y")]
    ],
    words: [
        WordToFind(text: "SWIFT"),
        WordToFind(text: "APPLE"),
        WordToFind(text: "ROSS")
    ]
)
