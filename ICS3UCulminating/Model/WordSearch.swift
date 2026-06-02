//
//  WordSearch.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation

// MODEL

/// Represents a single cell in the Word Search grid.
/// This structure stores the information for one "tile" in the game.
struct WordSearchCell: Identifiable {
    
    // MARK: - Stored properties
    
    /// Unique identifier for the cell. 
    /// This is needed so SwiftUI can keep track of which cell is which when displaying them in a list or grid.
    let id = UUID()
    
    /// The row position of the cell in the grid (e.g., Row 0 is the top row).
    let row: Int
    
    /// The column position of the cell in the grid (e.g., Column 0 is the leftmost column).
    let column: Int
    
    /// The letter contained within the cell (e.g., 'A', 'B', 'C').
    let letter: Character
    
    /// Whether this cell is part of a word that has been successfully found.
    /// We use this to change the appearance of the cell (like highlighting it) when the player finds a word.
    var isFound: Bool
    
    // MARK: - Initializer
    
    /// Creates a new cell with a specific position and letter.
    init(row: Int, column: Int, letter: Character, isFound: Bool = false) {
        self.row = row
        self.column = column
        self.letter = letter
        self.isFound = isFound
    }
}

/// Represents a word that the player needs to find in the Word Search grid.
struct WordToFind: Identifiable {
    
    // MARK: - Stored properties
    
    /// Unique identifier for the word.
    /// Just like the cell, this helps SwiftUI identify each word uniquely in the list.
    let id = UUID()
    
    /// The text of the word (e.g., "SWIFT").
    let text: String
    
    /// Whether the word has been found in the grid.
    /// We use this to "cross off" the word from the list once the player finds it.
    var isFound: Bool
    
    // MARK: - Initializer
    
    /// Creates a new word to find.
    init(text: String, isFound: Bool = false) {
        self.text = text
        self.isFound = isFound
    }
}

/// Represents the overall state of a Word Search game.
/// This is the "master" structure that holds both the grid and the list of words.
struct WordSearch {
    
    // MARK: - Stored properties
    
    /// The 2D grid of cells. 
    /// It's an array of arrays: the outer array represents rows, and each inner array contains the cells for that row.
    var grid: [[WordSearchCell]]
    
    /// The list of words that are hidden in the grid for the player to find.
    var words: [WordToFind]
    
    // MARK: - Initializer
    
    /// Creates a new game instance with a provided grid and word list.
    init(grid: [[WordSearchCell]], words: [WordToFind]) {
        self.grid = grid
        self.words = words
    }
}

// MARK: - Example Data

/// A small example Word Search for testing and previews.
/// This shows how we can manually create a simple 5x5 grid with some hidden words.
let exampleWordSearch = WordSearch(
    grid: [
        // Row 0: Contains the word "SWIFT"
        [WordSearchCell(row: 0, column: 0, letter: "S"), WordSearchCell(row: 0, column: 1, letter: "W"), WordSearchCell(row: 0, column: 2, letter: "I"), WordSearchCell(row: 0, column: 3, letter: "F"), WordSearchCell(row: 0, column: 4, letter: "T")],
        
        // Row 1: Random filler letters
        [WordSearchCell(row: 1, column: 0, letter: "L"), WordSearchCell(row: 1, column: 1, letter: "X"), WordSearchCell(row: 1, column: 2, letter: "C"), WordSearchCell(row: 1, column: 3, letter: "O"), WordSearchCell(row: 1, column: 4, letter: "D")],
        
        // Row 2: Contains the word "APPLE"
        [WordSearchCell(row: 2, column: 0, letter: "A"), WordSearchCell(row: 2, column: 1, letter: "P"), WordSearchCell(row: 2, column: 2, letter: "P"), WordSearchCell(row: 2, column: 3, letter: "L"), WordSearchCell(row: 2, column: 4, letter: "E")],
        
        // Row 3: Random filler letters
        [WordSearchCell(row: 3, column: 0, letter: "X"), WordSearchCell(row: 3, column: 1, letter: "Y"), WordSearchCell(row: 3, column: 2, letter: "Z"), WordSearchCell(row: 3, column: 3, letter: "A"), WordSearchCell(row: 3, column: 4, letter: "B")],
        
        // Row 4: Contains the word "ROSS"
        [WordSearchCell(row: 4, column: 0, letter: "R"), WordSearchCell(row: 4, column: 1, letter: "O"), WordSearchCell(row: 4, column: 2, letter: "S"), WordSearchCell(row: 4, column: 3, letter: "S"), WordSearchCell(row: 4, column: 4, letter: "Y")]
    ],
    words: [
        WordToFind(text: "SWIFT"),
        WordToFind(text: "APPLE"),
        WordToFind(text: "ROSS")
    ]
)
