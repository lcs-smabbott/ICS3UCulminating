//
//  WordSearchCellView.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

// VIEW

/// A small sub-view that represents a single square (cell) in the Word Search grid.
struct WordSearchCellView: View {
    
    // MARK: - Stored properties
    
    /// The specific cell data this view should display.
    let cell: WordSearchCell
    
    /// Whether this cell is currently being dragged over.
    let isSelected: Bool
    
    // MARK: - Computed properties
    
    /// The user interface for a single cell.
    var body: some View {
        Text(String(cell.letter))
            // Use a monospaced font so all letters line up perfectly in the grid.
            .font(.system(.title2, design: .monospaced))
            .fontWeight(.bold)
            // Make each cell a fixed size square.
            // We use a slightly smaller size for the 10x10 grid.
            .frame(width: 32, height: 32)
            // Change the background color:
            // - Orange if currently being selected (dragged over)
            // - Yellow if already part of a found word
            // - Light blue if it's just a normal cell
            .background(isSelected ? Color.orange : (cell.isFound ? Color.yellow : Color.blue.opacity(0.1)))
            // Round the corners slightly for a modern look.
            .cornerRadius(4)
            // Add a subtle border around each cell.
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
    }
}

#Preview {
    // Previewing a few cells to see the different states.
    HStack {
        WordSearchCellView(cell: WordSearchCell(row: 0, column: 0, letter: "A", isFound: false), isSelected: false)
        WordSearchCellView(cell: WordSearchCell(row: 0, column: 1, letter: "B", isFound: true), isSelected: false)
        WordSearchCellView(cell: WordSearchCell(row: 0, column: 2, letter: "C", isFound: false), isSelected: true)
    }
    .padding()
}
