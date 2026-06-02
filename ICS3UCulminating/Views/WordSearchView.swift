//
//  WordSearchView.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

// VIEW

/// The main view for the Word Search game.
/// It displays the grid of letters and the list of words to find.
struct WordSearchView: View {
    
    // MARK: - Stored properties
    
    /// The ViewModel that holds the game data and logic.
    @State var viewModel = WordSearchViewModel()
    
    // MARK: - Computed properties
    
    /// The user interface for the entire Word Search screen.
    var body: some View {
        NavigationStack {
            // On macOS, we use an HStack to put the grid and the word list side-by-side.
            // This takes advantage of the wider screen space.
            HStack(alignment: .top, spacing: 30) {
                
                // 1. The Word Search Grid
                VStack {
                    GeometryReader { geometry in
                        VStack(spacing: 4) {
                            // Loop through each row
                            ForEach(0..<viewModel.game.grid.count, id: \.self) { rowIndex in
                                HStack(spacing: 4) {
                                    // Loop through each cell in the row
                                    ForEach(0..<viewModel.game.grid[rowIndex].count, id: \.self) { columnIndex in
                                        
                                        // Display the cell using our flexible sub-view.
                                        WordSearchCellView(
                                            cell: viewModel.game.grid[rowIndex][columnIndex],
                                            isSelected: viewModel.isCellSelected(row: rowIndex, column: columnIndex)
                                        )
                                    }
                                }
                            }
                        }
                        // This gesture handles dragging across the letters.
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    updateSelection(at: value.location, in: geometry.size)
                                }
                                .onEnded { _ in
                                    viewModel.finalizeSelection()
                                }
                        )
                    }
                    // This keeps the grid perfectly square even as the window is resized.
                    .aspectRatio(1, contentMode: .fit)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
                // Set a generous frame size for the grid on macOS.
                .frame(minWidth: 400, maxWidth: 600, minHeight: 400, maxHeight: 600)
                
                // 2. The Word List (Side Panel)
                VStack(alignment: .leading, spacing: 15) {
                    Text("Words to Find")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(viewModel.game.words) { word in
                                HStack {
                                    Text(word.text)
                                        .strikethrough(word.isFound)
                                        .foregroundColor(word.isFound ? .gray : .primary)
                                        .font(.system(.title3, design: .monospaced))
                                    
                                    Spacer()
                                    
                                    if word.isFound {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .frame(width: 250) // Fixed width for the word list sidebar
                .padding()
            }
            .navigationTitle("Word Search")
            .padding()
        }
    }
    
    // MARK: - Functions
    
    /// Helper function to convert a touch/mouse location into a grid position (row, column).
    private func updateSelection(at location: CGPoint, in size: CGSize) {
        let rowCount = viewModel.game.grid.count
        let colCount = viewModel.game.grid[0].count
        
        // Calculate the relative position within the grid
        let cellWidth = size.width / CGFloat(colCount)
        let cellHeight = size.height / CGFloat(rowCount)
        
        let column = Int(location.x / cellWidth)
        let row = Int(location.y / cellHeight)
        
        // Update selection if the mouse is within the grid bounds
        if row >= 0 && row < rowCount && column >= 0 && column < colCount {
            viewModel.selectCell(row: row, column: column)
        }
    }
}

#Preview {
    WordSearchView()
}
