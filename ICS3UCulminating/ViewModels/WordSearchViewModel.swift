//
//  WordSearchViewModel.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation

// VIEW MODEL

/// This class manages the state and logic for the Word Search game.
/// It acts as the "brain" of the game, handling grid data and user interactions.
@Observable
class WordSearchViewModel {
    
    // MARK: - Stored properties
    
    /// The current state of the game, including the grid and the word list.
    /// By using @Observable, any changes to this property will automatically update the View.
    var game: WordSearch
    
    /// Tracks the cells the user is currently dragging over.
    /// This allows us to highlight the selection in real-time.
    var selectedCells: [WordSearchCell] = []
    
    // MARK: - Initializer
    
    /// Creates a new view model. 
    /// By default, it uses the example word search data we defined in the Model.
    init(game: WordSearch = exampleWordSearch) {
        self.game = game
    }
    
    // MARK: - Functions
    
    /// Adds a cell to the current selection if it's not already there.
    /// This is called as the user drags their finger across the grid.
    func selectCell(row: Int, column: Int) {
        // Make sure the row and column are valid
        guard row >= 0 && row < game.grid.count,
              column >= 0 && column < game.grid[0].count else {
            return
        }
        
        let cell = game.grid[row][column]
        
        // Only add the cell if it's not already the last one selected
        // (to avoid adding the same cell many times during a drag)
        if selectedCells.last?.id != cell.id {
            selectedCells.append(cell)
        }
    }
    
    /// Checks if the current selection matches a word when the drag ends.
    func finalizeSelection() {
        // 1. Build the word from the selected letters
        var selectedText = ""
        for cell in selectedCells {
            selectedText.append(cell.letter)
        }
        
        // 2. Check if this text matches any of our target words
        for i in 0..<game.words.count {
            // Check both forward and backward (some word searches allow reverse)
            let wordText = game.words[i].text
            let reversedText = String(selectedText.reversed())
            
            if wordText == selectedText || wordText == reversedText {
                // We found a match!
                game.words[i].isFound = true
                
                // Mark all cells in the selection as "found" so they stay highlighted
                for cell in selectedCells {
                    game.grid[cell.row][cell.column].isFound = true
                }
            }
        }
        
        // 3. Clear the temporary selection
        selectedCells = []
    }
    
    /// Helper to check if a specific cell is currently being dragged over.
    func isCellSelected(row: Int, column: Int) -> Bool {
        for cell in selectedCells {
            if cell.row == row && cell.column == column {
                return true
            }
        }
        return false
    }
}
