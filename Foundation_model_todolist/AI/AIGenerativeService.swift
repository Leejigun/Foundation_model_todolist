import Foundation
import FoundationModels
import Observation

struct AIGenerativeService {
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
        // Check if the session is already responding
        if session.isResponding {
            print("AIGenerativeService: Session is busy, skipping correction for: \"\(text)\"")
            return text // Return original text if busy
        }

        // Simulate network/processing delay for demonstration (can be removed in real app)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초

        // Debug print: Original text
        print("AIGenerativeService: Original text received for correction: \(text))")

        do {
            let correctionPrompt = """
Please correct the following text for any grammatical errors, spelling mistakes, and awkward phrasing.
Maintain the original language of the input text.
Only return the corrected text, without any quotes or delimiters around it.

Text to correct: \(text)
"""
            
            // Debug print: Prompt sent to model
            print("AIGenerativeService: Prompt sent to model for correction: \(correctionPrompt)")

            let stream = session.streamResponse(to: correctionPrompt)
            
            var correctedText = ""
            for try await part in stream {
                correctedText += part.content
            }
            
            let finalCorrectedText = correctedText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Debug print: Corrected text received from model
            print("AIGenerativeService: Corrected text received: \(finalCorrectedText)")

            return finalCorrectedText
            
        } catch {
            // Debug print: Error
            print("AIGenerativeService: Error using Apple Foundation Model for correction: \(error.localizedDescription)")
            return text
        }
    }

    // Modified method for summarization to use @Generable
    func summarize<T: Generable>(text: String) async throws -> T { // Changed signature
        // Check if the session is already responding
        if session.isResponding {
            print("AIGenerativeService: Session is busy, skipping summarization.")
            throw SummarizationError.modelBusy // Throw error if busy
        }

        // Simulate network/processing delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second for summarization

        // Debug print: Original text for summarization
        print("AIGenerativeService: Original text received for summarization: \(text)")

        do {
            let summarizationPrompt = """
            Summarize the following list of tasks into a single, concise, actionable sentence for today's briefing.
            Highlight key tasks, deadlines, and important notes.
            Maintain the original language of the input text.
            Return only the summary sentence, without any quotes or delimiters around it.

            Tasks:
            \(text)

            Example Summary: \"오늘 할 일은 AI 앱 개발과 리뷰 작성이며, 특히 AI 앱 개발은 마감이 임박했습니다.\"
            """
            
            // Debug print: Prompt sent to model for summarization
            print("AIGenerativeService: Prompt sent to model for summarization: \(summarizationPrompt)")

            return try await session.respond(to: summarizationPrompt, generating: T.self).content
            
        } catch {
            // Debug print: Error
            print("AIGenerativeService: Error using Apple Foundation Model for summarization: \(error.localizedDescription)")
            throw error // Re-throw the error
        }
    }
}

// Define a custom error for summarization
enum SummarizationError: Error, LocalizedError {
    case modelBusy
    
    var errorDescription: String? {
        switch self {
        case .modelBusy:
            return "AI 모델이 현재 사용 중입니다. 잠시 후 다시 시도해주세요."
        }
    }
}
