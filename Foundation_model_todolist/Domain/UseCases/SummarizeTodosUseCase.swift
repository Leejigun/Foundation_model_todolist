import Foundation

class SummarizeTodosUseCase {
    private let repository: TodoRepository
    private let generativeService: AIGenerativeService

    init(repository: TodoRepository, generativeService: AIGenerativeService) {
        self.repository = repository
        self.generativeService = generativeService
    }

    func execute() async throws -> DailyBriefing { // Changed return type
        let allTodos = try await repository.getTodos()
        
        // Filter for today's or overdue tasks for summarization
        let relevantTodos = allTodos.filter {
            // For simplicity, let's summarize all non-completed tasks for now.
            // Later, we can add logic for due dates.
            !$0.isCompleted
        }
        
        guard !relevantTodos.isEmpty else {
            // Return a default DailyBriefing if no tasks
            return DailyBriefing(summary: "오늘 할 일이 없습니다. 새로운 할 일을 추가해 보세요!")
        }
        
        // Format tasks for the AI prompt
        let tasksText = relevantTodos.map {
            var description = "- \($0.title)"
            if let dueDate = $0.dueDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                description += " (마감: \(dateFormatter.string(from: dueDate)))"
            }
            return description
        }.joined(separator: "\n")
        
        // Call summarize with generating: DailyBriefing.self
        return try await generativeService.summarize(text: tasksText)
    }
}
