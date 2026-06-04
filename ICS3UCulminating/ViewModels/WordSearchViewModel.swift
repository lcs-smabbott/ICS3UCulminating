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
@Observable
class WordSearchViewModel {
    
    // MARK: - Stored properties
    
    /// The current state of the game.
    var game: WordSearch
    
    /// Tracks the cells currently highlighted by the user.
    var selectedCells: [WordSearchCell] = []
    
    /// Tracks where the user first started their selection.
    private var startCell: WordSearchCell?
    
    /// UI State
    var isGenerating: Bool = false
    var errorMessage: String?
    var themeTitle: String = "Word Search"
    
    /// Tracks if a word was JUST found (to trigger a celebration).
    var showConfetti: Bool = false
    
    /// Tracks if the entire game is complete.
    var isGameComplete: Bool = false
    
    /// Configuration
    var gridSize: Int = 10
    var wordCount: Int = 6
    
    // MARK: - Initializer
    
    init(game: WordSearch = exampleWordSearch) {
        self.game = game
    }
    
    // MARK: - AI Functions
    
    func generateNewGame(from promptText: String) async {
        isGenerating = true
        errorMessage = nil
        
        do {
            let model = SystemLanguageModel.default
            if !model.isAvailable {
                throw NSError(domain: "WordSearch", code: 2, userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence not available."])
            }
            
            let session = LanguageModelSession(model: model)
            let aiPrompt = Prompt("Generate a Word Search theme for: \(promptText). Provide exactly \(wordCount) words that are 3 to \(gridSize - 2) letters long.")
            
            let response = try await session.respond(to: aiPrompt, generating: WordSearchTheme.self)
            let theme = response.content
            
            if let newGame = createGame(with: theme.words, size: gridSize) {
                await MainActor.run {
                    self.themeTitle = theme.title
                    self.game = newGame
                    self.isGenerating = false
                    self.isGameComplete = false // Reset completion state for new game
                    self.selectedCells = []
                }
            } else {
                throw NSError(domain: "WordSearch", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not fit words."])
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "AI Error: \(error.localizedDescription)"
                self.isGenerating = false
            }
        }
    }
    
    // MARK: - Grid Generation
    
    private func createGame(with words: [String], size: Int) -> WordSearch? {
        var grid: [[WordSearchCell]] = []
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        for row in 0..<size {
            var rowCells: [WordSearchCell] = []
            for col in 0..<size {
                rowCells.append(WordSearchCell(row: row, column: col, letter: " "))
            }
            grid.append(rowCells)
        }
        
        var placedWords: [String] = []
        for word in words {
            let upperWord = word.uppercased().trimmingCharacters(in: .whitespaces)
            if upperWord.count > size || upperWord.count < 2 { continue }
            
            if placeWord(upperWord, in: &grid) {
                placedWords.append(upperWord)
            }
        }
        
        if placedWords.isEmpty { return nil }
        
        for row in 0..<size {
            for col in 0..<size {
                if grid[row][col].letter == " " {
                    grid[row][col] = WordSearchCell(row: row, column: col, letter: letters.randomElement()!)
                }
            }
        }
        
        return WordSearch(grid: grid, words: placedWords.map { WordToFind(text: $0) })
    }
    
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
    
    // MARK: - Interaction Functions (Simplified)
    
    /// Starts a new selection (used by both tap and drag).
    func startSelection(row: Int, column: Int) {
        let cell = game.grid[row][column]
        startCell = cell
        selectedCells = [cell]
    }
    
    /// Continues a selection (used during dragging).
    func updateDragSelection(row: Int, column: Int) {
        guard let start = startCell else { return }
        
        // Straight-line snap logic
        let dr = row - start.row
        let dc = column - start.column
        
        var targetRow = row
        var targetCol = column
        
        let absDr = abs(dr)
        let absDc = abs(dc)
        
        if absDr > absDc * 2 {
            targetCol = start.column
        } else if absDc > absDr * 2 {
            targetRow = start.row
        } else {
            let step = max(absDr, absDc)
            targetRow = start.row + (dr > 0 ? step : (dr < 0 ? -step : 0))
            targetCol = start.column + (dc > 0 ? step : (dc < 0 ? -step : 0))
        }
        
        targetRow = max(0, min(targetRow, game.grid.count - 1))
        targetCol = max(0, min(targetCol, game.grid[0].count - 1))
        
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
    
    /// Handles tapping a cell one-by-one.
    func handleTap(row: Int, column: Int) {
        let cell = game.grid[row][column]
        
        // If we have a selection, check if the new tap is "in-line"
        if let last = selectedCells.last, selectedCells.count >= 1 {
            // Check if we are continuing the existing line
            if selectedCells.count == 1 {
                // Second cell: sets the direction
                selectedCells.append(cell)
            } else {
                // Third+ cell: must follow the existing direction
                let first = selectedCells[0]
                let second = selectedCells[1]
                let dr = second.row - first.row
                let dc = second.column - first.column
                
                let expectedRow = last.row + dr
                let expectedCol = last.column + dc
                
                if row == expectedRow && column == expectedCol {
                    selectedCells.append(cell)
                } else {
                    // Start a new selection if tap is out of line
                    startSelection(row: row, column: column)
                }
            }
        } else {
            startSelection(row: row, column: column)
        }
        
        checkIfWordFound()
    }
    
    /// Checks if selection is a word; if so, marks it permanently.
    func checkIfWordFound() {
        let selectedText = selectedCells.map { String($0.letter) }.joined()
        let reversedText = String(selectedText.reversed())
        
        for i in 0..<game.words.count {
            if !game.words[i].isFound && (game.words[i].text == selectedText || game.words[i].text == reversedText) {
                // MARK: SUCCESS - Word Found!
                game.words[i].isFound = true
                for cell in selectedCells {
                    game.grid[cell.row][cell.column].isFound = true
                }
                
                // Trigger the "Word Found" celebration
                self.showConfetti = true
                
                // Clear the message after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.showConfetti = false
                }
                
                // Check if the WHOLE game is finished
                checkGameCompletion()
                
                selectedCells = [] // Clear selection after finding
                return
            }
        }
    }
    
    /// Checks if every single word in the list has been found.
    private func checkGameCompletion() {
        var allFound = true
        for word in game.words {
            if !word.isFound {
                allFound = false
                break
            }
        }
        
        if allFound {
            self.isGameComplete = true
        }
    }
    
    /// Finalizes a drag. If no word was found, clear the highlight.
    func endInteraction() {
        checkIfWordFound()
        selectedCells = []
        startCell = nil
    }
    
    func isCellSelected(row: Int, column: Int) -> Bool {
        for cell in selectedCells {
            if cell.row == row && cell.column == column { return true }
        }
        return false
    }
}
