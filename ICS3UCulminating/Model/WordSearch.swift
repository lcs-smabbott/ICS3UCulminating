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

/// A helper function to create a 10x10 grid with some placeholder words.
func createExample10x10Game() -> WordSearch {
    let size = 10
    var grid: [[WordSearchCell]] = []
    
    // Create a 10x10 grid filled with random letters
    let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    for row in 0..<size {
        var rowCells: [WordSearchCell] = []
        for column in 0..<size {
            let randomLetter = letters.randomElement() ?? "A"
            rowCells.append(WordSearchCell(row: row, column: column, letter: randomLetter))
        }
        grid.append(rowCells)
    }
    
    // Manually place some words for the example
    // We make sure these words are actually placed in the grid letters!
    let wordsToPlace = ["SWIFT", "XCODE", "APPLE", "IPHONE", "IPAD"]
    
    // SWIFT (Row 0, Columns 0-4)
    let swift = "SWIFT"
    for (index, char) in swift.enumerated() {
        grid[0][index] = WordSearchCell(row: 0, column: index, letter: char)
    }
    
    // XCODE (Row 2, Columns 0-4)
    let xcode = "XCODE"
    for (index, char) in xcode.enumerated() {
        grid[2][index] = WordSearchCell(row: 2, column: index, letter: char)
    }
    
    // APPLE (Row 4, Columns 0-4)
    let apple = "APPLE"
    for (index, char) in apple.enumerated() {
        grid[4][index] = WordSearchCell(row: 4, column: index, letter: char)
    }
    
    // IPHONE (Column 9, Rows 0-5)
    let iphone = "IPHONE"
    for (index, char) in iphone.enumerated() {
        grid[index][9] = WordSearchCell(row: index, column: 9, letter: char)
    }
    
    // IPAD (Column 7, Rows 5-8)
    let ipad = "IPAD"
    for (index, char) in ipad.enumerated() {
        grid[5 + index][7] = WordSearchCell(row: 5 + index, column: 7, letter: char)
    }
    
    // Create the WordToFind objects from the strings
    var wordsToFind: [WordToFind] = []
    for word in wordsToPlace {
        wordsToFind.append(WordToFind(text: word))
    }
    
    return WordSearch(
        grid: grid,
        words: wordsToFind
    )
}

/// A 10x10 example Word Search for testing and previews.
let exampleWordSearch = createExample10x10Game()
