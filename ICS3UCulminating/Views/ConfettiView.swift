//
//  ConfettiView.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI
import Combine

// MODEL - Confetti

/// A simple structure to represent one single "bit" of confetti.
/// We use 'Identifiable' so SwiftUI can track each piece individually in the loop.
struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat      // Horizontal position
    var y: CGFloat      // Vertical position
    var color: Color    // The color of this specific piece
    var size: CGFloat   // How big it is
    var velocity: CGPoint // The direction and speed it is currently moving
    var rotation: Double  // The angle it's spinning at
}

// VIEW - Confetti

/// A view that displays a burst of colorful confetti.
/// It uses a timer to update the position of the pieces 50 times per second.
struct ConfettiView: View {
    
    // MARK: - Stored properties
    
    /// The array of all 50 pieces of confetti currently flying.
    @State private var pieces: [ConfettiPiece] = []
    
    /// A timer that "ticks" every 0.02 seconds (50 FPS).
    /// .autoconnect() means it starts running as soon as the view appears.
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    // MARK: - Computed properties
    
    var body: some View {
        ZStack {
            // Loop through our array and draw each piece at its current (x, y).
            ForEach(pieces) { piece in
                Rectangle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(x: piece.x, y: piece.y)
                    .rotationEffect(.degrees(piece.rotation))
            }
        }
        .onAppear {
            // When the view first shows up, create the initial burst!
            createBurst()
        }
        .onReceive(timer) { _ in
            // Every time the timer ticks, move the pieces a little bit.
            updatePieces()
        }
    }
    
    // MARK: - Functions
    
    /// Creates 50 random pieces of confetti at the starting center point.
    private func createBurst() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
        var newPieces: [ConfettiPiece] = []
        
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                x: 250, // Start in the middle of the 500px grid area
                y: 250,
                color: colors.randomElement()!,
                size: CGFloat.random(in: 6...14),
                // Velocity is random: some go left, some go right, most go UP (negative Y)
                velocity: CGPoint(
                    x: CGFloat.random(in: -12...12),
                    y: CGFloat.random(in: -18...0)
                ),
                rotation: Double.random(in: 0...360)
            )
            newPieces.append(piece)
        }
        pieces = newPieces
    }
    
    /// The "Physics Engine": calculates the new position for every piece.
    private func updatePieces() {
        for i in 0..<pieces.count {
            // 1. Move the piece based on its current speed (velocity)
            pieces[i].x += pieces[i].velocity.x
            pieces[i].y += pieces[i].velocity.y
            
            // 2. Add Gravity: make the Y velocity more positive (pulling it DOWN)
            pieces[i].velocity.y += 0.6
            
            // 3. Spin the piece
            pieces[i].rotation += 15
        }
        
        // 4. Optimization: If a piece falls off the bottom of the grid, delete it.
        pieces.removeAll { $0.y > 600 }
    }
}
