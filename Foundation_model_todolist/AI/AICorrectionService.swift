import Foundation
import FoundationModels
import Observation

struct AICorrectionService {
    private let session: LanguageModelSession

    init() {
        self.session = LanguageModelSession(tools: []) {
            """
You are a highly accurate text correction AI. Your task is to correct any grammatical errors, spelling mistakes, and awkward phrasing in the provided text.
Maintain the original language of the input text.
Return only the corrected text. Do NOT include any quotes, delimiters, or extra explanations.
"""
        }
    }

    func correct(text: String) async -> String {
        // Simulate network/processing delay for demonstration (can be removed in real app)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초

        // Debug print: Original text
        print("AICorrectionService: Original text received: \"\(text)\"")

        do {
            let correctionPrompt = """
Please correct the following text for any grammatical errors, spelling mistakes, and awkward phrasing.
Maintain the original language of the input text.
Only return the corrected text, without any quotes or delimiters around it.

Text to correct: \(text)
"""
            
            // Debug print: Prompt sent to model
            print("AICorrectionService: Prompt sent to model: \"\(correctionPrompt)\"")

            let stream = session.streamResponse(to: correctionPrompt)
            
            var correctedText = ""
            for try await part in stream {
                correctedText += part.content
            }
            
            let finalCorrectedText = correctedText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Debug print: Corrected text received from model
            print("AICorrectionService: Corrected text received: \"\(finalCorrectedText)\"")

            return finalCorrectedText
            
        } catch {
            // Debug print: Error
            print("AICorrectionService: Error using Apple Foundation Model for correction: \(error.localizedDescription)")
            return text
        }
    }
}
