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
    
    /// The current game data.
    var game: WordSearch
    
    /// Tracks the cells currently highlighted by the user.
    var selectedCells: [WordSearchCell] = []
    
    /// Tracks where the user first started their selection.
    private var startCell: WordSearchCell?
    
    /// UI State flags
    var isGenerating: Bool = false    // Now used for BOTH AI and Manual loading
    var errorMessage: String?
    var themeTitle: String = "Word Search"
    
    /// Celebration flags
    var showConfetti: Bool = false
    var isGameComplete: Bool = false
    
    /// Configuration
    var gridSize: Int = 10
    var wordCount: Int = 6
    
    // MARK: - Computed properties
    
    var difficultyRank: String {
        if gridSize > 20 || wordCount > 25 { return "GRANDMASTER" }
        if gridSize > 16 || wordCount > 18 { return "EXPERT" }
        if gridSize > 12 || wordCount > 10 { return "CHALLENGER" }
        return "APPRENTICE"
    }
    
    var rankDescription: String {
        switch difficultyRank {
        case "GRANDMASTER": return "A massive challenge for the most eagle-eyed players."
        case "EXPERT": return "Tough patterns and a crowded board. Good luck!"
        case "CHALLENGER": return "Stepping up the pace with more words and a wider grid."
        default: return "A perfect size for a quick and relaxing puzzle."
        }
    }
    
    // MARK: - Initializer
    
    init() {
        // Start with a valid but empty 10x10 grid to avoid indexing crashes on frame 1.
        var emptyGrid: [[WordSearchCell]] = []
        for r in 0..<10 {
            var row: [WordSearchCell] = []
            for c in 0..<10 {
                row.append(WordSearchCell(row: r, column: c, letter: " "))
            }
            emptyGrid.append(row)
        }
        self.game = WordSearch(grid: emptyGrid, words: [])
        
        // Now attempt to load a random theme.
        let themes: [(String, [String])] = [
            ("COFFEE BREAK", ["LATTE", "MOCHA", "BEANS", "BREW", "ROAST", "CUP"]),
            ("SPACE MISSION", ["MARS", "ORBIT", "ROCKET", "STAR", "COMET", "MOON"]),
            ("OCEAN LIFE", ["SHARK", "WHALE", "CORAL", "FISH", "SHELL", "WAVE"])
        ]
        let randomTheme = themes.randomElement()!
        self.themeTitle = randomTheme.0
        
        if let startingGame = createGame(with: randomTheme.1, size: 10) {
            self.game = startingGame
        }
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
            
            // We run the heavy grid calculation on a background thread.
            let size = gridSize // Capture local copy
            let words = theme.words
            
            if let newGame = createGame(with: words, size: size) {
                await MainActor.run {
                    self.themeTitle = theme.title.uppercased()
                    self.game = newGame
                    self.isGenerating = false
                    self.isGameComplete = false
                    self.selectedCells = []
                }
            } else {
                throw NSError(domain: "WordSearch", code: 1, userInfo: [NSLocalizedDescriptionKey: "Grid too crowded!"])
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "AI Error: \(error.localizedDescription)"
                self.isGenerating = false
            }
        }
    }
    
    /// Creates a manual game. Now ASYNCHRONOUS to prevent freezing.
    func generateManualGame(with words: [String]) async {
        isGenerating = true
        errorMessage = nil
        
        let size = gridSize
        
        // Perform calculation.
        if let newGame = createGame(with: words, size: size) {
            await MainActor.run {
                self.game = newGame
                self.themeTitle = "CUSTOM PUZZLE"
                self.isGameComplete = false
                self.selectedCells = []
                self.isGenerating = false
            }
        } else {
            await MainActor.run {
                self.errorMessage = "Could not fit all words. Try a larger grid."
                self.isGenerating = false
            }
        }
    }
    
    // MARK: - Grid Generation Logic
    
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
    
    // MARK: - Interaction Functions
    
    func startSelection(row: Int, column: Int) {
        // SAFETY: Check if grid actually has this cell before accessing.
        guard row < game.grid.count, column < game.grid[0].count else { return }
        let cell = game.grid[row][column]
        startCell = cell
        selectedCells = [cell]
    }
    
    func updateDragSelection(row: Int, column: Int) {
        guard let start = startCell else { return }
        
        // SAFETY: Bounds checking for current grid.
        let safeRow = max(0, min(row, game.grid.count - 1))
        let safeCol = max(0, min(column, game.grid[0].count - 1))
        
        let dr = safeRow - start.row
        let dc = safeCol - start.column
        
        var targetRow = safeRow
        var targetCol = safeCol
        let absDr = abs(dr); let absDc = abs(dc)
        
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
                let r = start.row + i * stepR
                let c = start.column + i * stepC
                // Final safety check for nested arrays.
                if r < game.grid.count && c < game.grid[0].count {
                    newPath.append(game.grid[r][c])
                }
            }
        }
        self.selectedCells = newPath
    }
    
    func handleTap(row: Int, column: Int) {
        // SAFETY: Check bounds.
        guard row < game.grid.count, column < game.grid[0].count else { return }
        let cell = game.grid[row][column]
        
        if let last = selectedCells.last, selectedCells.count >= 1 {
            if selectedCells.count == 1 {
                selectedCells.append(cell)
            } else {
                let first = selectedCells[0]
                let second = selectedCells[1]
                let dr = second.row - first.row
                let dc = second.column - first.column
                
                if row == last.row + dr && column == last.column + dc {
                    selectedCells.append(cell)
                } else {
                    startSelection(row: row, column: column)
                }
            }
        } else {
            startSelection(row: row, column: column)
        }
        checkIfWordFound()
    }
    
    func checkIfWordFound() {
        let selectedText = selectedCells.map { String($0.letter) }.joined()
        let reversedText = String(selectedText.reversed())
        
        for i in 0..<game.words.count {
            if !game.words[i].isFound && (game.words[i].text == selectedText || game.words[i].text == reversedText) {
                game.words[i].isFound = true
                for cell in selectedCells {
                    // Double check bounds before permanent highlight.
                    if cell.row < game.grid.count && cell.column < game.grid[0].count {
                        game.grid[cell.row][cell.column].isFound = true
                    }
                }
                self.showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.showConfetti = false }
                checkGameCompletion()
                selectedCells = []
                return
            }
        }
    }
    
    private func checkGameCompletion() {
        if game.words.count > 0 && game.words.allSatisfy({ $0.isFound }) {
            self.isGameComplete = true
        }
    }
    
    func endInteraction() {
        checkIfWordFound()
        selectedCells = []
        startCell = nil
    }
    
    func isCellSelected(row: Int, column: Int) -> Bool {
        return selectedCells.contains(where: { $0.row == row && $0.column == column })
    }
}
