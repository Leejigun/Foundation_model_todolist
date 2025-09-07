import Foundation
import FoundationModels

@Generable
struct DailyBriefing {
    @Guide(description: "A single, concise, actionable sentence summarizing today's tasks. Highlight key tasks, deadlines, and important notes.")
    let summary: String
}
