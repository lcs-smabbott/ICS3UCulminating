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
            // On macOS, we can use a slightly larger font.
            .font(.system(.title, design: .monospaced))
            .fontWeight(.bold)
            // Instead of a fixed frame, we allow the cell to expand to fill the space.
            // This makes the grid responsive to window resizing.
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // We ensure each individual cell stays square.
            .aspectRatio(1, contentMode: .fit)
            // Change the background color:
            .background(isSelected ? Color.orange : (cell.isFound ? Color.yellow : Color.blue.opacity(0.1)))
            // Round the corners slightly.
            .cornerRadius(4)
            // Add a subtle border.
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
