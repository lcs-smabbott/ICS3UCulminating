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
    @State private var creationMode: Int = 0
    @State private var manualWord: String = ""
    @State private var manualWordList: [String] = []
    
    // MARK: - Computed properties
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                HStack(alignment: .top, spacing: 0) {
                    
                    // 1. LEFT SIDE: Game Board
                    VStack(spacing: 20) {
                        
                        VStack(spacing: 8) {
                            Text(viewModel.themeTitle.uppercased())
                                .font(.system(size: 32, weight: .black, design: .serif))
                                .tracking(4)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            VStack(spacing: 4) {
                                HStack(spacing: 15) {
                                    Rectangle().fill(rankColor).frame(width: 40, height: 2)
                                    Text(viewModel.difficultyRank)
                                        .font(.system(size: 10, weight: .bold))
                                        .tracking(2)
                                        .foregroundColor(rankColor)
                                    Rectangle().fill(rankColor).frame(width: 40, height: 2)
                                }
                                Text(viewModel.rankDescription)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        
                        ZStack {
                            GeometryReader { geometry in
                                // SAFETY: Capture grid count to local constant for the loop pass
                                let currentGrid = viewModel.game.grid
                                
                                VStack(spacing: gridSpacing) {
                                    ForEach(0..<currentGrid.count, id: \.self) { rowIndex in
                                        HStack(spacing: gridSpacing) {
                                            ForEach(0..<currentGrid[rowIndex].count, id: \.self) { columnIndex in
                                                // SAFETY: Only render if indices are still valid
                                                if rowIndex < viewModel.game.grid.count && columnIndex < viewModel.game.grid[rowIndex].count {
                                                    WordSearchCellView(
                                                        cell: viewModel.game.grid[rowIndex][columnIndex],
                                                        isSelected: viewModel.isCellSelected(row: rowIndex, column: columnIndex),
                                                        gridSize: currentGrid.count
                                                    )
                                                    .onTapGesture {
                                                        viewModel.handleTap(row: rowIndex, column: columnIndex)
                                                    }
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
                            
                            if viewModel.showConfetti {
                                ConfettiView()
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(gridPadding)
                        .background(.ultraThinMaterial)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        .frame(minWidth: 500, maxWidth: 800, minHeight: 500, maxHeight: 800)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                    
                    // 2. RIGHT SIDE: Control Center
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 30) {
                                
                                ControlSection(title: "Creator Engine", icon: "wand.and.stars") {
                                    VStack(spacing: 20) {
                                        HStack(spacing: 0) {
                                            CreatorTab(title: "AI DREAM", icon: "sparkles", isSelected: creationMode == 0) { creationMode = 0 }
                                            CreatorTab(title: "MANUAL", icon: "hammer.fill", isSelected: creationMode == 1) { creationMode = 1 }
                                        }
                                        .background(Color.primary.opacity(0.05))
                                        .cornerRadius(12)
                                        
                                        if creationMode == 0 {
                                            aiCreatorView
                                        } else {
                                            manualCreatorView
                                        }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(16)
                                    .shadow(color: rankColor.opacity(0.1), radius: 10, x: 0, y: 5)
                                }
                                
                                ControlSection(title: "Dimensions", icon: "square.resize.down") {
                                    VStack(spacing: 18) {
                                        SettingSlider(label: "Complexity (Grid Size)", value: Binding(get: { Double(viewModel.gridSize) }, set: { viewModel.gridSize = Int($0) }), range: 8...25, current: "\(viewModel.gridSize)x\(viewModel.gridSize)")
                                        
                                        if creationMode == 0 {
                                            SettingSlider(label: "AI Word Density", value: Binding(get: { Double(viewModel.wordCount) }, set: { viewModel.wordCount = Int($0) }), range: 3...40, current: "\(viewModel.wordCount) Words")
                                        }
                                    }
                                }
                                
                                ControlSection(title: "Mastery Tracker", icon: "target") {
                                    wordBankView
                                }
                                
                                if let error = viewModel.errorMessage {
                                    Text(error).font(.system(size: 11, weight: .bold)).foregroundColor(.red).multilineTextAlignment(.center).frame(maxWidth: .infinity)
                                }
                            }
                            .padding(25)
                        }
                    }
                    .frame(width: 320)
                    .background(.ultraThinMaterial)
                    .overlay(Rectangle().fill(Color.primary.opacity(0.1)).frame(width: 1), alignment: .leading)
                }
                .blur(radius: viewModel.isGenerating || viewModel.isGameComplete ? 8 : 0)
                
                if viewModel.isGenerating {
                    LoadingOverlay()
                }
                
                if viewModel.isGameComplete {
                    VictoryOverlay(theme: viewModel.themeTitle) {
                        withAnimation { viewModel.isGameComplete = false }
                    }
                }
            }
        }
    }
    
    // MARK: - Sub-Views
    
    private var aiCreatorView: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("What's the theme?", text: $userPrompt)
                .textFieldStyle(.plain)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue.opacity(0.3)))
            
            Button(action: startAIGeneration) {
                HStack {
                    Image(systemName: "cpu")
                    Text("INITIALIZE AI BUILD")
                }
                .font(.system(size: 13, weight: .black))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .background(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(color: .blue.opacity(0.2), radius: 5, x: 0, y: 3)
            .disabled(userPrompt.isEmpty || viewModel.isGenerating)
            
            Text("REQUIRES APPLE INTELLIGENCE")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
    }
    
    private var manualCreatorView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Add word...", text: $manualWord)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.indigo.opacity(0.3)))
                    .onSubmit(addManualWord)
                
                Button(action: addManualWord) {
                    Image(systemName: "plus.square.fill")
                        .font(.title2)
                        .foregroundColor(.indigo)
                }
                .buttonStyle(.plain)
            }
            
            if !manualWordList.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(manualWordList, id: \.self) { word in
                            HStack(spacing: 4) {
                                Text(word).font(.system(size: 10, weight: .black))
                                Button(action: { manualWordList.removeAll(where: { $0 == word }) }) {
                                    Image(systemName: "xmark.circle.fill").font(.system(size: 12))
                                }.buttonStyle(.plain)
                            }
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.indigo.opacity(0.1)).cornerRadius(8)
                        }
                    }
                }
                .frame(height: 30)
            }
            
            Button(action: startManualGeneration) {
                Text("LAUNCH CUSTOM GRID")
                    .font(.system(size: 13, weight: .black))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .background(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(color: .indigo.opacity(0.2), radius: 5, x: 0, y: 3)
            .disabled(manualWordList.isEmpty || viewModel.isGenerating)
        }
    }
    
    private var wordBankView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(viewModel.game.words) { word in
                HStack {
                    Image(systemName: word.isFound ? "checkmark.seal.fill" : "circle.dotted")
                        .foregroundColor(word.isFound ? .green : .blue)
                    Text(word.text)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .strikethrough(word.isFound)
                        .foregroundColor(word.isFound ? .secondary : .primary)
                    Spacer()
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(word.isFound ? Color.green.opacity(0.1) : Color.white.opacity(0.3))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Dynamic Sizing
    
    private var gridSpacing: CGFloat {
        let size = viewModel.game.grid.count
        if size > 20 { return 1 }
        if size > 15 { return 2 }
        return 4
    }
    
    private var gridPadding: CGFloat {
        let size = viewModel.game.grid.count
        if size > 20 { return 8 }
        if size > 15 { return 12 }
        return 20
    }
    
    private var rankColor: Color {
        switch viewModel.difficultyRank {
        case "GRANDMASTER": return .red
        case "EXPERT": return .orange
        case "CHALLENGER": return .blue
        default: return .green
        }
    }
    
    // MARK: - Functions
    
    private func addManualWord() {
        let trimmed = manualWord.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if !trimmed.isEmpty && !manualWordList.contains(trimmed) {
            manualWordList.append(trimmed)
            manualWord = ""
        }
    }
    
    private func startManualGeneration() {
        Task {
            await viewModel.generateManualGame(with: manualWordList)
        }
    }
    
    private func startAIGeneration() {
        Task {
            await viewModel.generateNewGame(from: userPrompt)
            userPrompt = ""
        }
    }
    
    private func updateSelection(at location: CGPoint, in size: CGSize, isStart: Bool) {
        // SAFETY: Only perform math if grid exists
        let rowCount = viewModel.game.grid.count
        guard rowCount > 0 else { return }
        let colCount = viewModel.game.grid[0].count
        guard colCount > 0 else { return }
        
        let cellWidth = size.width / CGFloat(colCount)
        let cellHeight = size.height / CGFloat(rowCount)
        
        let column = Int(location.x / cellWidth)
        let row = Int(location.y / cellHeight)
        
        if row >= 0 && row < rowCount && column >= 0 && column < colCount {
            if isStart { viewModel.startSelection(row: row, column: column) }
            else { viewModel.updateDragSelection(row: row, column: column) }
        }
    }
}

// MARK: - Component Definitions (Sub-Views)

struct CreatorTab: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                Text(title).font(.system(size: 10, weight: .black))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .foregroundColor(isSelected ? .blue : .secondary)
        }
        .buttonStyle(.plain)
    }
}

struct ControlSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title; self.icon = icon; self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon).foregroundColor(.blue)
                Text(title.uppercased()).font(.system(size: 12, weight: .black)).tracking(1.5).foregroundColor(.secondary)
            }
            content
        }
    }
}

struct SettingSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let current: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(.caption).foregroundColor(.secondary)
                Spacer()
                Text(current).font(.caption).fontWeight(.bold)
            }
            Slider(value: $value, in: range, step: 1).accentColor(.blue)
        }
    }
}

struct LoadingOverlay: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView().controlSize(.large)
            Text("ORCHESTRATING AI...").font(.system(size: 14, weight: .black)).tracking(2)
        }
        .padding(40).background(.ultraThinMaterial).cornerRadius(30).shadow(radius: 20)
    }
}

struct VictoryOverlay: View {
    let theme: String
    let onDismiss: () -> Void
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle().fill(Color.yellow.opacity(0.2)).frame(width: 150, height: 150)
                Image(systemName: "crown.fill").font(.system(size: 80)).foregroundColor(.yellow).shadow(color: .orange, radius: 10)
            }
            VStack(spacing: 10) {
                Text("VICTORY!").font(.system(size: 48, weight: .black)).tracking(5)
                Text("Mastered: \(theme)").font(.title3).foregroundColor(.secondary)
            }
            Button(action: onDismiss) {
                Text("RESTART MISSION").fontWeight(.bold).padding(.horizontal, 40).padding(.vertical, 15)
            }
            .buttonStyle(.borderedProminent).tint(.blue).cornerRadius(15)
        }
        .padding(60).background(.ultraThinMaterial).cornerRadius(40).shadow(radius: 30).transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    WordSearchView()
}
