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
    /// @State is used because this view "owns" the view model instance.
    @State var viewModel = WordSearchViewModel()
    
    // MARK: - Computed properties
    
    /// The user interface for the entire Word Search screen.
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // 1. The Word Search Grid
                // We use nested VStacks and HStacks to build the 2D grid.
                VStack(spacing: 5) {
                    // Loop through each row in the grid
                    ForEach(0..<viewModel.game.grid.count, id: \.self) { rowIndex in
                        HStack(spacing: 5) {
                            // Loop through each column (cell) in the current row
                            ForEach(0..<viewModel.game.grid[rowIndex].count, id: \.self) { columnIndex in
                                
                                // Display the cell using our sub-view
                                WordSearchCellView(cell: viewModel.game.grid[rowIndex][columnIndex])
                                    // When a cell is tapped, tell the ViewModel to handle it
                                    .onTapGesture {
                                        viewModel.toggleCellSelection(row: rowIndex, column: columnIndex)
                                    }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
                
                Divider()
                
                // 2. The Word List
                // Shows the player which words they still need to find.
                VStack(alignment: .leading) {
                    Text("Words to Find")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    List(viewModel.game.words) { word in
                        HStack {
                            Text(word.text)
                                // If the word is found, draw a line through it.
                                .strikethrough(word.isFound)
                                .foregroundColor(word.isFound ? .gray : .primary)
                            
                            Spacer()
                            
                            // Show a checkmark next to found words.
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
}

#Preview {
    WordSearchView()
}
