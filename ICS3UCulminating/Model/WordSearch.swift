//
//  WordSearch.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation

// MODEL

/// Represents a single cell in the Word Search grid.
struct WordSearchCell: Identifiable {
    
    // MARK: - Stored properties
    
    /// Unique identifier for the cell.
    let id = UUID()
    
    /// The row position of the cell in the grid.
    let row: Int
    
    /// The column position of the cell in the grid.
    let column: Int
    
    /// The letter contained within the cell.
    let letter: Character
    
    /// Whether this cell is part of a word that has been successfully found.
    var isFound: Bool
    
    // MARK: - Initializer
    
    init(row: Int, column: Int, letter: Character, isFound: Bool = false) {
        self.row = row
        self.column = column
        self.letter = letter
        self.isFound = isFound
    }
}

/// Represents a word that needs to be found in the Word Search grid.
struct WordToFind: Identifiable {
    
    // MARK: - Stored properties
    
    /// Unique identifier for the word.
    let id = UUID()
    
    /// The text of the word.
    let text: String
    
    /// Whether the word has been found in the grid.
    var isFound: Bool
    
    // MARK: - Initializer
    
    init(text: String, isFound: Bool = false) {
        self.text = text
        self.isFound = isFound
    }
}

/// Represents the overall state of a Word Search game.
struct WordSearch {
    
    // MARK: - Stored properties
    
    /// The 2D grid of cells.
    var grid: [[WordSearchCell]]
    
    /// The list of words to be found.
    var words: [WordToFind]
    
    // MARK: - Initializer
    
    init(grid: [[WordSearchCell]], words: [WordToFind]) {
        self.grid = grid
        self.words = words
    }
}

// MARK: - Example Data

/// A small example Word Search for testing and previews.
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
