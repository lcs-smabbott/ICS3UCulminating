//
//  WordSearchAI.swift
//  ICS3UCulminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation
import FoundationModels

// MODEL - AI Integration

/// A structure that the AI model will use to provide a list of words.
/// The @Generable macro is a special instruction to Apple's AI framework.
/// It tells the AI: "Whatever you generate, it MUST fit into this exact structure."
/// This prevents the AI from just talking to us; it forces it to give us clean data.
@Generable
struct WordSearchTheme {
    /// A short title for the theme (e.g., "The Solar System").
    /// The AI decides this based on the user's prompt.
    var title: String
    
    /// A list of 5 to 10 words related to the theme.
    /// The AI will provide these as an array of Strings.
    var words: [String]
}
