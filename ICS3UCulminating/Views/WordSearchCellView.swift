//
//  WordSearchCellView.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

// VIEW

/// A single square in the Word Search grid.
struct WordSearchCellView: View {
    
    // MARK: - Stored properties
    
    let cell: WordSearchCell
    let isSelected: Bool
    
    // MARK: - Computed properties
    
    var body: some View {
        Text(String(cell.letter))
            .font(.system(.title, design: .monospaced))
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            // Use Yellow for BOTH "actively selecting" and "already found"
            .background(isSelected || cell.isFound ? Color.yellow : Color.blue.opacity(0.1))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
            // Add a subtle border to the ACTIVE selection to distinguish it slightly
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
    }
}

#Preview {
    HStack {
        WordSearchCellView(cell: WordSearchCell(row: 0, column: 0, letter: "A", isFound: false), isSelected: false)
        WordSearchCellView(cell: WordSearchCell(row: 0, column: 1, letter: "B", isFound: true), isSelected: false)
        WordSearchCellView(cell: WordSearchCell(row: 0, column: 2, letter: "C", isFound: false), isSelected: true)
    }
    .padding()
}
