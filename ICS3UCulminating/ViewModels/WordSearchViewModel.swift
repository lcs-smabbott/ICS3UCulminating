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
    
    /// Tracks the cells currently highlighted by the user (in yellow with an orange border).
    var selectedCells: [WordSearchCell] = []
    
    /// Tracks where the user first started their selection to allow for "line snapping".
    private var startCell: WordSearchCell?
    
    /// UI State flags
    var isGenerating: Bool = false    // Shows the "AI is thinking..." spinner
    var errorMessage: String?         // Stores any errors to show the user
    var themeTitle: String = "Word Search" // The name of the puzzle
    
    /// Tracks if a word was JUST found. This triggers the ConfettiView to appear briefly.
    var showConfetti: Bool = false
    
    /// Tracks if every single word in the list has been found.
    var isGameComplete: Bool = false
    
    /// Configuration settings controlled by the sliders in the View.
    var gridSize: Int = 10
    var wordCount: Int = 6
    
    // MARK: - Initializer
    
    init(game: WordSearch = exampleWordSearch) {
        self.game = game
    }
    
    // MARK: - AI Functions
    
    /// Connects to Apple's on-device AI to generate a list of words.
    func generateNewGame(from promptText: String) async {
        isGenerating = true
        errorMessage = nil
        
        do {
            let model = SystemLanguageModel.default
            if !model.isAvailable {
                throw NSError(domain: "WordSearch", code: 2, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence not available."])
            }
            
            let session = LanguageModelSession(model: model)
            // We tell the AI exactly how many words to give us and how long they should be.
            let aiPrompt = Prompt("Generate a Word Search theme for: \(promptText). Provide exactly \(wordCount) words that are 3 to \(gridSize - 2) letters long.")
            
            let response = try await session.respond(to: aiPrompt, generating: WordSearchTheme.self)
            let theme = response.content
            
            if let newGame = createGame(with: theme.words, size: gridSize) {
                await MainActor.run {
                    self.themeTitle = theme.title
                    self.game = newGame
                    self.isGenerating = false
                    self.isGameComplete = false // Reset completion state for the new game
                    self.selectedCells = []
                }
            } else {
                throw NSError(domain: "WordSearch", code: 1, userInfo: [NSLocalizedDescriptionKey: "The grid was too crowded! Try a larger grid or fewer words."])
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "AI Error: \(error.localizedDescription)"
                self.isGenerating = false
            }
        }
    }
    
    /// Creates a game using a list of words provided directly by the user.
    /// This bypasses the AI and goes straight to the grid placement logic.
    func generateManualGame(with words: [String]) {
        // Clear any old error messages
        errorMessage = nil
        
        // Use our same 'createGame' logic to hide the user's words in the grid.
        if let newGame = createGame(with: words, size: gridSize) {
            // If successful, update the game state
            self.game = newGame
            self.themeTitle = "Custom Game"
            self.isGameComplete = false
            self.selectedCells = []
        } else {
            // If the words don't fit (e.g., too many long words), show an error.
            self.errorMessage = "Could not fit all words. Try a larger grid or fewer/shorter words."
        }
    }
    
    // MARK: - Grid Generation
    
    /// Creates a fresh grid and hides the provided words inside it.
    private func createGame(with words: [String], size: Int) -> WordSearch? {
        var grid: [[WordSearchCell]] = []
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        // 1. Fill a blank grid with spaces
        for row in 0..<size {
            var rowCells: [WordSearchCell] = []
            for col in 0..<size {
                rowCells.append(WordSearchCell(row: row, column: col, letter: " "))
            }
            grid.append(rowCells)
        }
        
        // 2. Hide each word
        var placedWords: [String] = []
        for word in words {
            let upperWord = word.uppercased().trimmingCharacters(in: .whitespaces)
            if upperWord.count > size || upperWord.count < 2 { continue }
            
            if placeWord(upperWord, in: &grid) {
                placedWords.append(upperWord)
            }
        }
        
        if placedWords.isEmpty { return nil }
        
        // 3. Fill the rest with random noise letters
        for row in 0..<size {
            for col in 0..<size {
                if grid[row][col].letter == " " {
                    grid[row][col] = WordSearchCell(row: row, column: col, letter: letters.randomElement()!)
                }
            }
        }
        
        return WordSearch(grid: grid, words: placedWords.map { WordToFind(text: $0) })
    }
    
    /// Tries 100 times to find a random spot for a word.
    private func placeWord(_ word: String, in grid: inout [[WordSearchCell]]) -> Bool {
        let size = grid.count
        let directions: [(Int, Int)] = [(0,1), (0,-1), (1,0), (-1,0), (1,1), (1,-1), (-1,1), (-1,-1)]
        let chars = Array(word)
        
        for _ in 0..<100 {
            let startRow = Int.random(in: 0..<size)
            let startCol = Int.random(in: 0..<size)
            let dir = directions.randomElement()!
            
            if canPlace(chars, in: grid, at: startRow, col: startCol, dr: dir.0, dc: dir.1) {
                for i in 0..<chars.count {
                    let nr = startRow + i * dir.0
                    let nc = startCol + i * dir.1
                    grid[nr][nc] = WordSearchCell(row: nr, column: nc, letter: chars[i])
                }
                return true
            }
        }
        return false
    }
    
    private func canPlace(_ chars: [Character], in grid: [[WordSearchCell]], at r: Int, col c: Int, dr: Int, dc: Int) -> Bool {
        let size = grid.count
        for i in 0..<chars.count {
            let nr = r + i * dr
            let nc = c + i * dc
            if nr < 0 || nr >= size || nc < 0 || nc >= size { return false }
            let existing = grid[nr][nc].letter
            if existing != " " && existing != chars[i] { return false }
        }
        return true
    }
    
    // MARK: - Interaction Functions (Dragging & Tapping)
    
    /// Starts a new selection (used when the user first clicks/taps).
    func startSelection(row: Int, column: Int) {
        let cell = game.grid[row][column]
        startCell = cell
        selectedCells = [cell]
    }
    
    /// Called repeatedly as the user drags. It calculates a straight line path.
    func updateDragSelection(row: Int, column: Int) {
        guard let start = startCell else { return }
        
        let dr = row - start.row
        let dc = column - start.column
        
        var targetRow = row
        var targetCol = column
        let absDr = abs(dr); let absDc = abs(dc)
        
        // Snapping logic: determines if the user is moving mostly Vertical, Horizontal, or Diagonal.
        if absDr > absDc * 2 {
            targetCol = start.column
        } else if absDc > absDr * 2 {
            targetRow = start.row
        } else {
            let step = max(absDr, absDc)
            targetRow = start.row + (dr > 0 ? step : (dr < 0 ? -step : 0))
            targetCol = start.column + (dc > 0 ? step : (dc < 0 ? -step : 0))
        }
        
        // Clamping to stay within the grid
        targetRow = max(0, min(targetRow, game.grid.count - 1))
        targetCol = max(0, min(targetCol, game.grid[0].count - 1))
        
        // Build the actual path of cells
        let finalDr = targetRow - start.row
        let finalDc = targetCol - start.column
        let steps = max(abs(finalDr), abs(finalDc))
        
        var newPath: [WordSearchCell] = []
        if steps == 0 {
            newPath.append(start)
        } else {
            let stepR = finalDr / steps
            let stepC = finalDc / steps
            for i in 0...steps {
                newPath.append(game.grid[start.row + i * stepR][start.column + i * stepC])
            }
        }
        self.selectedCells = newPath
    }
    
    /// Adds one cell at a time. If the tap is "out of line", it starts a new selection.
    func handleTap(row: Int, column: Int) {
        let cell = game.grid[row][column]
        
        if let last = selectedCells.last, selectedCells.count >= 1 {
            if selectedCells.count == 1 {
                // Second tap: this defines the direction of the word
                selectedCells.append(cell)
            } else {
                // Third tap+: must follow the existing direction
                let first = selectedCells[0]
                let second = selectedCells[1]
                let dr = second.row - first.row
                let dc = second.column - first.column
                
                if row == last.row + dr && column == last.column + dc {
                    selectedCells.append(cell)
                } else {
                    // Start over if the user taps somewhere else
                    startSelection(row: row, column: column)
                }
            }
        } else {
            startSelection(row: row, column: column)
        }
        checkIfWordFound()
    }
    
    /// Checks the current selection. If it matches a word, we celebrate!
    func checkIfWordFound() {
        let selectedText = selectedCells.map { String($0.letter) }.joined()
        let reversedText = String(selectedText.reversed())
        
        for i in 0..<game.words.count {
            if !game.words[i].isFound && (game.words[i].text == selectedText || game.words[i].text == reversedText) {
                // 1. Mark word as found
                game.words[i].isFound = true
                for cell in selectedCells {
                    game.grid[cell.row][cell.column].isFound = true
                }
                
                // 2. Trigger the Confetti burst
                self.showConfetti = true
                // Stop the confetti after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.showConfetti = false
                }
                
                // 3. Check if they just won the whole game
                checkGameCompletion()
                
                // 4. Clear selection
                selectedCells = []
                return
            }
        }
    }
    
    /// Checks if every word in the list has its 'isFound' flag set to true.
    private func checkGameCompletion() {
        if game.words.allSatisfy({ $0.isFound }) {
            self.isGameComplete = true
        }
    }
    
    /// Called when the user releases the mouse button.
    func endInteraction() {
        checkIfWordFound()
        selectedCells = []
        startCell = nil
    }
    
    func isCellSelected(row: Int, column: Int) -> Bool {
        return selectedCells.contains(where: { $0.row == row && $0.column == column })
    }
}
