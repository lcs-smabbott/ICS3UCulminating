//
//  WordSearchView.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

// VIEW

/// The main view for the Word Search game.
struct WordSearchView: View {
    
    // MARK: - Stored properties
    
    /// The ViewModel that holds the game data and logic.
    @State var viewModel = WordSearchViewModel()
    
    /// The text the user enters to generate a new game theme.
    @State private var userPrompt: String = ""
    
    // MARK: - Computed properties
    
    /// The user interface for the entire Word Search screen.
    var body: some View {
        NavigationStack {
            ZStack {
                HStack(alignment: .top, spacing: 30) {
                    
                    // 1. The Word Search Grid
                    VStack {
                        GeometryReader { geometry in
                            VStack(spacing: 4) {
                                ForEach(0..<viewModel.game.grid.count, id: \.self) { rowIndex in
                                    HStack(spacing: 4) {
                                        ForEach(0..<viewModel.game.grid[rowIndex].count, id: \.self) { columnIndex in
                                            WordSearchCellView(
                                                cell: viewModel.game.grid[rowIndex][columnIndex],
                                                isSelected: viewModel.isCellSelected(row: rowIndex, column: columnIndex)
                                            )
                                        }
                                    }
                                }
                            }
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
                        .aspectRatio(1, contentMode: .fit)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .frame(minWidth: 400, maxWidth: 600, minHeight: 400, maxHeight: 600)
                    
                    // 2. The Side Panel (AI Prompt & Word List)
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // AI Prompt Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Create Custom Theme")
                                .font(.headline)
                            
                            TextField("e.g., Solar System, Countries...", text: $userPrompt)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    startAIGeneration()
                                }
                            
                            Button(action: startAIGeneration) {
                                Label("Generate with AI", systemImage: "sparkles")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(userPrompt.isEmpty || viewModel.isGenerating)
                            
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(8)
                        
                        Divider()
                        
                        // Word List Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Words to Find")
                                .font(.title3)
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
                    }
                    .frame(width: 280)
                    .padding()
                }
                .padding()
                .blur(radius: viewModel.isGenerating ? 3 : 0)
                
                // Loading Overlay
                if viewModel.isGenerating {
                    VStack(spacing: 15) {
                        ProgressView()
                            .controlSize(.large)
                        Text("AI is thinking...")
                            .font(.headline)
                    }
                    .padding(40)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
            }
            .navigationTitle("AI Word Search")
        }
    }
    
    // MARK: - Functions
    
    /// Triggers the AI to generate a new game.
    private func startAIGeneration() {
        Task {
            await viewModel.generateNewGame(from: userPrompt)
            userPrompt = "" // Clear the prompt after starting
        }
    }
    
    private func updateSelection(at location: CGPoint, in size: CGSize) {
        let rowCount = viewModel.game.grid.count
        let colCount = viewModel.game.grid[0].count
        
        let cellWidth = size.width / CGFloat(colCount)
        let cellHeight = size.height / CGFloat(rowCount)
        
        let column = Int(location.x / cellWidth)
        let row = Int(location.y / cellHeight)
        
        if row >= 0 && row < rowCount && column >= 0 && column < colCount {
            viewModel.selectCell(row: row, column: column)
        }
    }
}

#Preview {
    WordSearchView()
}
