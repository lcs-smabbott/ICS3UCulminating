//
//  WordSearchView.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

// VIEW

/// The main view for the Word Search game.
/// Redesigned with a "Game Dashboard" aesthetic for a more unique macOS feel.
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
                // Background Gradient to give the app more "depth"
                LinearGradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                HStack(alignment: .top, spacing: 0) {
                    
                    // 1. LEFT SIDE: The Game Board Area
                    VStack(spacing: 25) {
                        
                        // Theme Title with a more "Epic" look
                        VStack(spacing: 5) {
                            Text(viewModel.themeTitle.uppercased())
                                .font(.system(size: 32, weight: .black, design: .serif))
                                .tracking(4) // Extra spacing between letters
                                .foregroundColor(.primary)
                            
                            Rectangle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                                .frame(width: 150, height: 4)
                                .cornerRadius(2)
                        }
                        .padding(.top, 20)
                        
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
                            
                            if viewModel.showConfetti {
                                ConfettiView()
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(25)
                        .background(.ultraThinMaterial) // Glass background for the grid
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        .frame(minWidth: 450, maxWidth: 650, minHeight: 450, maxHeight: 650)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                    
                    // 2. RIGHT SIDE: The Control Center (Sidebar)
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 30) {
                                
                                // Section: Game Creator
                                ControlSection(title: "Puzzle Creator", icon: "plus.viewfinder") {
                                    VStack(spacing: 15) {
                                        Picker("", selection: $creationMode) {
                                            Text("AI Engine").tag(0)
                                            Text("Manual").tag(1)
                                        }
                                        .pickerStyle(.segmented)
                                        
                                        if creationMode == 0 {
                                            VStack(alignment: .leading, spacing: 8) {
                                                TextField("Enter a theme...", text: $userPrompt)
                                                    .textFieldStyle(.plain)
                                                    .padding(10)
                                                    .background(Color.primary.opacity(0.05))
                                                    .cornerRadius(8)
                                                
                                                Button(action: startAIGeneration) {
                                                    HStack {
                                                        Image(systemName: "sparkles")
                                                        Text("Generate Theme")
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 8)
                                                }
                                                .buttonStyle(.borderedProminent)
                                                .tint(.blue)
                                                .disabled(userPrompt.isEmpty || viewModel.isGenerating)
                                                
                                                Text("Powered by Apple Intelligence")
                                                    .font(.system(size: 9, weight: .semibold))
                                                    .foregroundColor(.secondary)
                                                    .frame(maxWidth: .infinity)
                                            }
                                        } else {
                                            VStack(alignment: .leading, spacing: 10) {
                                                HStack {
                                                    TextField("Add a word...", text: $manualWord)
                                                        .textFieldStyle(.plain)
                                                        .padding(8)
                                                        .background(Color.primary.opacity(0.05))
                                                        .cornerRadius(8)
                                                        .onSubmit(addManualWord)
                                                    
                                                    Button(action: addManualWord) {
                                                        Image(systemName: "plus.circle.fill")
                                                            .font(.title3)
                                                    }
                                                    .buttonStyle(.plain)
                                                    .foregroundColor(.blue)
                                                    .disabled(manualWord.isEmpty)
                                                }
                                                
                                                // Chip-style word list
                                                FlowLayout(items: manualWordList) { word in
                                                    HStack(spacing: 4) {
                                                        Text(word)
                                                            .font(.system(size: 10, weight: .bold))
                                                        Button(action: { manualWordList.removeAll(where: { $0 == word }) }) {
                                                            Image(systemName: "xmark")
                                                                .font(.system(size: 8))
                                                        }
                                                        .buttonStyle(.plain)
                                                    }
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.blue.opacity(0.1))
                                                    .cornerRadius(20)
                                                }
                                                .frame(minHeight: 40)
                                                
                                                Button(action: startManualGeneration) {
                                                    Text("Build Manual Puzzle")
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 8)
                                                }
                                                .buttonStyle(.borderedProminent)
                                                .tint(.indigo)
                                                .disabled(manualWordList.isEmpty)
                                            }
                                        }
                                    }
                                }
                                
                                // Section: Puzzle Settings
                                ControlSection(title: "Settings", icon: "slider.horizontal.3") {
                                    VStack(spacing: 15) {
                                        SettingSlider(label: "Grid Complexity", value: Binding(get: { Double(viewModel.gridSize) }, set: { viewModel.gridSize = Int($0) }), range: 8...15, current: "\(viewModel.gridSize)x\(viewModel.gridSize)")
                                        
                                        if creationMode == 0 {
                                            SettingSlider(label: "Target Words", value: Binding(get: { Double(viewModel.wordCount) }, set: { viewModel.wordCount = Int($0) }), range: 3...12, current: "\(viewModel.wordCount)")
                                        }
                                    }
                                }
                                
                                // Section: Word Bank
                                ControlSection(title: "Word Bank", icon: "list.bullet.rectangle") {
                                    VStack(alignment: .leading, spacing: 12) {
                                        ForEach(viewModel.game.words) { word in
                                            HStack {
                                                Circle()
                                                    .fill(word.isFound ? Color.green : Color.blue.opacity(0.3))
                                                    .frame(width: 8, height: 8)
                                                
                                                Text(word.text)
                                                    .font(.system(.body, design: .monospaced))
                                                    .fontWeight(word.isFound ? .bold : .medium)
                                                    .strikethrough(word.isFound)
                                                    .foregroundColor(word.isFound ? .secondary : .primary)
                                                
                                                Spacer()
                                                
                                                if word.isFound {
                                                    Image(systemName: "checkmark.seal.fill")
                                                        .foregroundColor(.green)
                                                        .font(.caption)
                                                }
                                            }
                                            .padding(10)
                                            .background(word.isFound ? Color.green.opacity(0.05) : Color.white.opacity(0.5))
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                                
                                if let error = viewModel.errorMessage {
                                    Text(error).font(.caption).foregroundColor(.red).multilineTextAlignment(.center)
                                }
                            }
                            .padding(25)
                        }
                    }
                    .frame(width: 320)
                    .background(.ultraThinMaterial) // Sidebar Glass Effect
                    .overlay(Rectangle().fill(Color.primary.opacity(0.1)).frame(width: 1), alignment: .leading) // Vertical Divider
                }
                .blur(radius: viewModel.isGenerating || viewModel.isGameComplete ? 8 : 0)
                
                // Overlays
                if viewModel.isGenerating {
                    LoadingOverlay()
                }
                
                if viewModel.isGameComplete {
                    VictoryOverlay(theme: viewModel.themeTitle) {
                        withAnimation { viewModel.isGameComplete = false }
                    }
                }
            }
            .navigationTitle("") // Hide standard title to use our custom one
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
        withAnimation { viewModel.generateManualGame(with: manualWordList) }
    }
    
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
            if isStart { viewModel.startSelection(row: row, column: column) }
            else { viewModel.updateDragSelection(row: row, column: column) }
        }
    }
}

// MARK: - Sub-Views for Cleaner UI

/// A consistent section container for the sidebar.
struct ControlSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title.uppercased())
                    .font(.system(size: 12, weight: .black))
                    .tracking(1.5)
                    .foregroundColor(.secondary)
            }
            content
        }
    }
}

/// A stylized slider with a label.
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
            Slider(value: $value, in: range, step: 1)
                .accentColor(.blue)
        }
    }
}

/// Simple flow layout for manual word chips.
struct FlowLayout: View {
    let items: [String]
    let content: (String) -> AnyView
    
    init(items: [String], @ViewBuilder content: @escaping (String) -> some View) {
        self.items = items
        self.content = { AnyView(content($0)) }
    }
    
    var body: some View {
        // This is a simplified version; in a production app, we'd use a more complex algorithm.
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }
}

/// Stylized AI Loading Overlay
struct LoadingOverlay: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
            Text("ORCHESTRATING AI...")
                .font(.system(size: 14, weight: .black))
                .tracking(2)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .cornerRadius(30)
        .shadow(radius: 20)
    }
}

/// Epic Victory Overlay
struct VictoryOverlay: View {
    let theme: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 150, height: 150)
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .shadow(color: .orange, radius: 10)
            }
            
            VStack(spacing: 10) {
                Text("VICTORY!")
                    .font(.system(size: 48, weight: .black))
                    .tracking(5)
                
                Text("Mastered: \(theme)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onDismiss) {
                Text("RESTART MISSION")
                    .fontWeight(.bold)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .cornerRadius(15)
        }
        .padding(60)
        .background(.ultraThinMaterial)
        .cornerRadius(40)
        .shadow(radius: 30)
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    WordSearchView()
}
