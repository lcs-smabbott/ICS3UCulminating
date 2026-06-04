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
    
    @State var viewModel = WordSearchViewModel()
    @State private var userPrompt: String = ""
    
    // MARK: - Computed properties
    
    var body: some View {
        NavigationStack {
            ZStack {
                HStack(alignment: .top, spacing: 30) {
                    
                    // 1. The Word Search Grid
                    VStack(spacing: 15) {
                        Text(viewModel.themeTitle)
                            .font(.system(.title, design: .serif))
                            .fontWeight(.bold)
                            .italic()
                            .foregroundColor(.blue)
                        
                        ZStack {
                            GeometryReader { geometry in
                                VStack(spacing: 4) {
                                    ForEach(0..<viewModel.game.grid.count, id: \.self) { rowIndex in
                                        HStack(spacing: 4) {
                                            ForEach(0..<viewModel.game.grid[rowIndex].count, id: \.self) { columnIndex in
                                                WordSearchCellView(
                                                    cell: viewModel.game.grid[rowIndex][columnIndex],
                                                    isSelected: viewModel.isCellSelected(row: rowIndex, column: columnIndex)
                                                )
                                                .onTapGesture {
                                                    viewModel.handleTap(row: rowIndex, column: columnIndex)
                                                }
                                            }
                                        }
                                    }
                                }
                                .gesture(
                                    DragGesture(minimumDistance: 5)
                                        .onChanged { value in
                                            updateSelection(at: value.location, in: geometry.size, isStart: false)
                                        }
                                        .onEnded { _ in
                                            viewModel.endInteraction()
                                        }
                                )
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            if viewModel.selectedCells.isEmpty {
                                                updateSelection(at: value.location, in: geometry.size, isStart: true)
                                            }
                                        }
                                )
                            }
                            .aspectRatio(1, contentMode: .fit)
                            
                            // INDIVIDUAL CELEBRATION: Confetti Burst
                            if viewModel.showConfetti {
                                ConfettiView()
                                    .allowsHitTesting(false) // Don't block clicking while confetti is flying
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .frame(minWidth: 400, maxWidth: 600, minHeight: 400, maxHeight: 600)
                    
                    // 2. Side Panel
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Custom Settings
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Custom Game Settings").font(.headline)
                            
                            TextField("Theme (e.g., Space)", text: $userPrompt)
                                .textFieldStyle(.roundedBorder)
                            
                            HStack {
                                Text("Grid: \(viewModel.gridSize)x\(viewModel.gridSize)")
                                Slider(value: Binding(get: { Double(viewModel.gridSize) }, set: { viewModel.gridSize = Int($0) }), in: 8...15, step: 1)
                            }.font(.caption)
                            
                            HStack {
                                Text("Words: \(viewModel.wordCount)")
                                Slider(value: Binding(get: { Double(viewModel.wordCount) }, set: { viewModel.wordCount = Int($0) }), in: 3...12, step: 1)
                            }.font(.caption)
                            
                            Button(action: startAIGeneration) {
                                Label("Generate with AI", systemImage: "sparkles")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(userPrompt.isEmpty || viewModel.isGenerating)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(8)
                        
                        Divider()
                        
                        // Word List
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
                                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: 250)
                    .padding()
                }
                .padding()
                .blur(radius: viewModel.isGenerating || viewModel.isGameComplete ? 5 : 0)
                
                // AI Loading Overlay
                if viewModel.isGenerating {
                    VStack(spacing: 15) {
                        ProgressView().controlSize(.large)
                        Text("AI is thinking...").font(.headline)
                    }
                    .padding(40)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                }
                
                // FINAL CELEBRATION: Game Complete Overlay
                if viewModel.isGameComplete {
                    VStack(spacing: 20) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.yellow)
                        
                        Text("Congratulations!")
                            .font(.system(size: 40, weight: .bold))
                        
                        Text("You found all the words for '\(viewModel.themeTitle)'!")
                            .multilineTextAlignment(.center)
                        
                        Button("Play Again") {
                            withAnimation {
                                viewModel.isGameComplete = false
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(50)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(radius: 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("AI Word Search")
        }
    }
    
    // MARK: - Functions
    
    private func startAIGeneration() {
        Task {
            await viewModel.generateNewGame(from: userPrompt)
            userPrompt = ""
        }
    }
    
    private func updateSelection(at location: CGPoint, in size: CGSize, isStart: Bool) {
        let rowCount = viewModel.game.grid.count
        let colCount = viewModel.game.grid[0].count
        let cellWidth = size.width / CGFloat(colCount)
        let cellHeight = size.height / CGFloat(rowCount)
        let column = Int(location.x / cellWidth)
        let row = Int(location.y / cellHeight)
        
        if row >= 0 && row < rowCount && column >= 0 && column < colCount {
            if isStart {
                viewModel.startSelection(row: row, column: column)
            } else {
                viewModel.updateDragSelection(row: row, column: column)
            }
        }
    }
}

#Preview {
    WordSearchView()
}
