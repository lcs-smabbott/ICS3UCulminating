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
    
    // MARK: - Initializer
    
    /// Creates a new view model. 
    /// By default, it uses the example word search data we defined in the Model.
    init(game: WordSearch = exampleWordSearch) {
        self.game = game
    }
    
    // MARK: - Functions
    
    /// This function handles what happens when a player taps a cell.
    /// For this basic version, it simply toggles the 'isFound' status of the cell.
    /// In a full game, this would be part of a larger logic to check if a whole word was selected.
    func toggleCellSelection(row: Int, column: Int) {
        // We access the specific cell in the grid and change its found status.
        game.grid[row][column].isFound.toggle()
        
        // After toggling a cell, we might want to check if any words are now "found".
        checkIfWordsAreFound()
    }
    
    /// A simple check to see if the words in our list match the "found" cells in the grid.
    /// Note: This is a simplified version for demonstration.
    func checkIfWordsAreFound() {
        // In a real game, this would contain logic to see if a sequence of found cells
        // forms one of the words in the 'game.words' list.
    }
}
