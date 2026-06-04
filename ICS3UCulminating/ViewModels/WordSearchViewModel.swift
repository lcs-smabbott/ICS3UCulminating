//
//  WordSearchViewModel.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation
import FoundationModels

// VIEW MODEL

/// This class manages the state and logic for the Word Search game.
/// It uses Apple's Foundation Models to create custom word searches.
@Observable
class WordSearchViewModel {
    
    // MARK: - Stored properties
    
    /// The current state of the game (the grid and words).
    var game: WordSearch
    
    /// Tracks the cells the user is currently dragging over to highlight them orange.
    var selectedCells: [WordSearchCell] = []
    
    /// A flag to tell the View when to show the "AI is thinking..." loading screen.
    var isGenerating: Bool = false
    
    /// Stores any error messages (e.g., if the device doesn't support AI).
    var errorMessage: String?
    
    // MARK: - Initializer
    
    init(game: WordSearch = exampleWordSearch) {
        self.game = game
    }
    
    // MARK: - AI Functions
    
    /// Connects to Apple's on-device AI to generate a list of words.
    func generateNewGame(from promptText: String) async {
        // 1. Reset state: Show loader and hide old errors.
        isGenerating = true
        errorMessage = nil
        
        do {
            // 2. Access the system model (Apple Intelligence).
            let model = SystemLanguageModel.default
            
            // 3. Safety check: Is AI actually ready/enabled on this Mac?
            if !model.isAvailable {
                throw NSError(domain: "WordSearch", code: 2, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence is not available. Ensure you have an M-series Mac and it's enabled in Settings."])
            }
            
            // 4. Start a communication session.
            let session = LanguageModelSession(model: model)
            
            // 5. Build the prompt. We give the AI specific constraints to help it succeed.
            let aiPrompt = Prompt("Generate a Word Search theme for: \(promptText). Provide 5 to 8 words that are 3 to 8 letters long.")
            
            // 6. Guided Generation: The AI returns a 'WordSearchTheme' object automatically!
            let response = try await session.respond(to: aiPrompt, generating: WordSearchTheme.self)
            let theme = response.content
            
            // 7. Take the AI's words and try to "hide" them in a new grid.
            if let newGame = createGame(with: theme.words) {
                // 'await MainActor.run' ensures we update the UI properties on the main thread.
                await MainActor.run {
                    self.game = newGame
                    self.isGenerating = false
                }
            } else {
                // This happens if the words were too long or too many to fit in a 10x10.
                throw NSError(domain: "WordSearch", code: 1, userInfo: [NSLocalizedDescriptionKey: "The grid was too crowded! Try a different prompt."])
            }
            
        } catch {
            // Catch any AI errors (like no internet, or model busy).
            await MainActor.run {
                self.errorMessage = "AI Error: \(error.localizedDescription)"
                self.isGenerating = false
            }
        }
    }
    
    // MARK: - Grid Placement Logic
    
    /// This complex function builds a fresh grid from scratch.
    private func createGame(with words: [String]) -> WordSearch? {
        let size = 10
        var grid: [[WordSearchCell]] = []
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        // Step 1: Create a 10x10 grid filled with spaces (" ").
        for row in 0..<size {
            var rowCells: [WordSearchCell] = []
            for col in 0..<size {
                rowCells.append(WordSearchCell(row: row, column: col, letter: " "))
            }
            grid.append(rowCells)
        }
        
        // Step 2: Try to place every word the AI gave us.
        var placedWords: [String] = []
        for word in words {
            let upperWord = word.uppercased().trimmingCharacters(in: .whitespaces)
            // If the word is too long for a 10x10, we just skip it.
            if upperWord.count > size { continue }
            
            if placeWord(upperWord, in: &grid) {
                placedWords.append(upperWord)
            }
        }
        
        // Fail if we couldn't place at least a few words.
        if placedWords.isEmpty { return nil }
        
        // Step 3: Replace all remaining " " spaces with random random letters.
        for row in 0..<size {
            for col in 0..<size {
                if grid[row][col].letter == " " {
                    grid[row][col] = WordSearchCell(row: row, column: col, letter: letters.randomElement()!)
                }
            }
        }
        
        // Step 4: Wrap it up in a WordSearch model.
        let wordsToFind = placedWords.map { WordToFind(text: $0) }
        return WordSearch(grid: grid, words: wordsToFind)
    }
    
    /// This function tries 100 times to find a random spot and direction for a word.
    private func placeWord(_ word: String, in grid: inout [[WordSearchCell]]) -> Bool {
        let size = grid.count
        // These represent (row change, column change) for all 8 directions.
        let directions: [(Int, Int)] = [
            (0, 1), (0, -1), (1, 0), (-1, 0), // L->R, R->L, Top->Down, Down->Top
            (1, 1), (1, -1), (-1, 1), (-1, -1) // All 4 Diagonals
        ]
        
        let chars = Array(word)
        
        // Try random spots until we find one that works or we run out of tries.
        for _ in 0..<100 {
            let startRow = Int.random(in: 0..<size)
            let startCol = Int.random(in: 0..<size)
            let dir = directions.randomElement()!
            
            // Check: "Can the word fit here without hitting edges or other words?"
            if canPlace(chars, in: grid, at: startRow, col: startCol, dr: dir.0, dc: dir.1) {
                // If yes, actually write the letters into the grid.
                insert(chars, in: &grid, at: startRow, col: startCol, dr: dir.0, dc: dir.1)
                return true
            }
        }
        return false
    }
    
    /// Helper: Checks every letter of a word to see if the path is clear.
    private func canPlace(_ chars: [Character], in grid: [[WordSearchCell]], at r: Int, col c: Int, dr: Int, dc: Int) -> Bool {
        let size = grid.count
        for i in 0..<chars.count {
            let nr = r + i * dr
            let nc = c + i * dc
            // 1. Is it outside the 10x10 boundary?
            if nr < 0 || nr >= size || nc < 0 || nc >= size { return false }
            // 2. Is there already a DIFFERENT letter there? (Intersections are okay!)
            let existing = grid[nr][nc].letter
            if existing != " " && existing != chars[i] { return false }
        }
        return true
    }
    
    /// Helper: Actually puts the characters into the 2D grid.
    private func insert(_ chars: [Character], in grid: inout [[WordSearchCell]], at r: Int, col c: Int, dr: Int, dc: Int) {
        for i in 0..<chars.count {
            let nr = r + i * dr
            let nc = c + i * dc
            grid[nr][nc] = WordSearchCell(row: nr, column: nc, letter: chars[i])
        }
    }
    
    // MARK: - Interaction Functions
    
    /// Adds a cell to the current 'selection path' while the user is dragging.
    func selectCell(row: Int, column: Int) {
        guard row >= 0 && row < game.grid.count, column >= 0 && column < game.grid[0].count else { return }
        
        let cell = game.grid[row][column]
        // Avoid adding the exact same cell twice in a row.
        if selectedCells.last?.id != cell.id {
            selectedCells.append(cell)
        }
    }
    
    /// Checks if the user's drag matches a word.
    func finalizeSelection() {
        // Build the string from the selected tiles.
        var selectedText = ""
        for cell in selectedCells {
            selectedText.append(cell.letter)
        }
        
        // Compare against every word in our list.
        for i in 0..<game.words.count {
            let wordText = game.words[i].text
            let reversedText = String(selectedText.reversed())
            
            // Match found (either forward or backward)!
            if wordText == selectedText || wordText == reversedText {
                game.words[i].isFound = true
                // Permanently highlight these cells yellow.
                for cell in selectedCells {
                    game.grid[cell.row][cell.column].isFound = true
                }
            }
        }
        // Clear the temporary orange drag selection.
        selectedCells = []
    }
    
    /// Used by the View to know if a specific square should be orange.
    func isCellSelected(row: Int, column: Int) -> Bool {
        for cell in selectedCells {
            if cell.row == row && cell.column == column { return true }
        }
        return false
    }
}
