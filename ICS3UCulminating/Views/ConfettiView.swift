//
//  ConfettiView.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI
import Combine

/// A single piece of confetti.
struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var size: CGFloat
    var velocity: CGPoint
    var rotation: Double
}

/// A view that displays a burst of colorful confetti.
struct ConfettiView: View {
    @State private var pieces: [ConfettiPiece] = []
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ForEach(pieces) { piece in
                Rectangle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(x: piece.x, y: piece.y)
                    .rotationEffect(.degrees(piece.rotation))
            }
        }
        .onAppear {
            createBurst()
        }
        .onReceive(timer) { _ in
            updatePieces()
        }
    }
    
    private func createBurst() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
        var newPieces: [ConfettiPiece] = []
        
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                x: 200, // Center of the burst
                y: 200,
                color: colors.randomElement()!,
                size: CGFloat.random(in: 5...12),
                velocity: CGPoint(
                    x: CGFloat.random(in: -10...10),
                    y: CGFloat.random(in: -15...5)
                ),
                rotation: Double.random(in: 0...360)
            )
            newPieces.append(piece)
        }
        pieces = newPieces
    }
    
    private func updatePieces() {
        for i in 0..<pieces.count {
            pieces[i].x += pieces[i].velocity.x
            pieces[i].y += pieces[i].velocity.y
            pieces[i].velocity.y += 0.5 // Gravity
            pieces[i].rotation += 10
        }
        
        // Remove pieces that go off screen
        pieces.removeAll { $0.y > 600 }
    }
}
