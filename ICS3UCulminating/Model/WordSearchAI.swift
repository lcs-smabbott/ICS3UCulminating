//
//  WordSearchAI.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation
import FoundationModels

// MARK: - AI MODEL LAYER
// This file handles the data transfer between Apple Intelligence and our app.

/// A structure that defines the "Contract" between our code and the AI.
/// The '@Generable' macro is a modern Swift feature for Apple Intelligence.
/// It tells the on-device Large Language Model (LLM): 
/// "I am going to ask you a question, and I want you to fill out this specific structure with the answer."
@Generable
struct WordSearchTheme {
    
    /// The AI's creative name for the puzzle based on your prompt.
    /// For example: If you prompt "Ocean", the AI might return "Depths of the Pacific".
    var title: String
    
    /// The list of words that fit the theme.
    /// By using [String], we tell the AI to give us an array of text, which we will then hide in our grid.
    var words: [String]
}

// NOTE: All generation happens locally on your Mac's M-series chip. 
// No data is sent to a server for this specific prompt!
