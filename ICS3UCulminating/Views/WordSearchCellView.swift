//
//  WordSearchCellView.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

// MARK: - SUB-VIEW
// This view represents one single letter tile in the Word Search grid.

struct WordSearchCellView: View {
    
    // MARK: - Stored properties
    
    /// The data for this specific cell (row, column, letter, etc.)
    let cell: WordSearchCell
    
    /// Whether this cell is currently being hovered/dragged over by the user.
    let isSelected: Bool
    
    /// The total grid size (e.g., 25). We use this to calculate how small the letters need to be.
    let gridSize: Int
    
    // MARK: - Computed properties
    
    var body: some View {
        Text(String(cell.letter))
            // DYNAMIC FONT SCALING:
            // We use a math formula to shrink the font as the grid gets larger.
            // 8x8 grid -> size 24 (large)
            // 25x25 grid -> size 8 (small but clear)
            .font(.system(size: CGFloat(max(8, 32 - gridSize)), weight: .bold, design: .monospaced))
            
            // Expand to fill the available space provided by the grid layout.
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Force the cell to stay a perfect square.
            .aspectRatio(1, contentMode: .fit)
            
            // VISUAL STATE:
            // If the user is selecting it OR it was already found, highlight it Yellow.
            .background(isSelected || cell.isFound ? Color.yellow : Color.blue.opacity(0.1))
            
            // Make the corners sharper for massive grids.
            .cornerRadius(gridSize > 15 ? 2 : 4)
            
            // Add a subtle border.
            .overlay(
                RoundedRectangle(cornerRadius: gridSize > 15 ? 2 : 4)
                    .stroke(isSelected ? Color.orange : Color.black.opacity(0.05), lineWidth: isSelected ? 2 : 0.5)
            )
    }
}

#Preview {
    // Show a sample of different cell states.
    HStack {
        WordSearchCellView(cell: WordSearchCell(row: 0, column: 0, letter: "A", isFound: false), isSelected: false, gridSize: 10)
        WordSearchCellView(cell: WordSearchCell(row: 0, column: 1, letter: "B", isFound: true), isSelected: false, gridSize: 10)
        WordSearchCellView(cell: WordSearchCell(row: 0, column: 2, letter: "C", isFound: false), isSelected: true, gridSize: 10)
    }
    .padding()
}
