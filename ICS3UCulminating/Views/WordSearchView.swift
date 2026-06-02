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
            VStack(spacing: 20) {
                
                // 1. The Word Search Grid
                // We use GeometryReader to help us figure out which cell the user is dragging over.
                GeometryReader { geometry in
                    VStack(spacing: 4) {
                        ForEach(0..<viewModel.game.grid.count, id: \.self) { rowIndex in
                            HStack(spacing: 4) {
                                ForEach(0..<viewModel.game.grid[rowIndex].count, id: \.self) { columnIndex in
                                    
                                    // Display the cell using our sub-view.
                                    // We also tell it if it's currently part of the user's drag selection.
                                    WordSearchCellView(
                                        cell: viewModel.game.grid[rowIndex][columnIndex],
                                        isSelected: viewModel.isCellSelected(row: rowIndex, column: columnIndex)
                                    )
                                }
                            }
                        }
                    }
                    // This gesture allows the user to press down and drag across the grid.
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                // As the user drags, we update the selection in the ViewModel.
                                updateSelection(at: value.location, in: geometry.size)
                            }
                            .onEnded { _ in
                                // When the user lets go, we check if they found a word.
                                viewModel.finalizeSelection()
                            }
                    )
                }
                // We force the grid to be a square based on the screen width.
                .aspectRatio(1, contentMode: .fit)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
                
                Divider()
                
                // 2. The Word List
                VStack(alignment: .leading) {
                    Text("Words to Find")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    List(viewModel.game.words) { word in
                        HStack {
                            Text(word.text)
                                .strikethrough(word.isFound)
                                .foregroundColor(word.isFound ? .gray : .primary)
                                .font(.system(.body, design: .monospaced))
                            
                            Spacer()
                            
                            if word.isFound {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Word Search")
            .padding()
        }
    }
    
    // MARK: - Functions
    
    /// Helper function to convert a touch location (x, y) into a grid position (row, column).
    private func updateSelection(at location: CGPoint, in size: CGSize) {
        let rowCount = viewModel.game.grid.count
        let colCount = viewModel.game.grid[0].count
        
        // Calculate the width and height of a single cell
        let cellWidth = size.width / CGFloat(colCount)
        let cellHeight = size.height / CGFloat(rowCount)
        
        // Use math to find the row and column based on the touch position
        let column = Int(location.x / cellWidth)
        let row = Int(location.y / cellHeight)
        
        // Tell the ViewModel to add this cell to the selection
        viewModel.selectCell(row: row, column: column)
    }
}

#Preview {
    WordSearchView()
}
