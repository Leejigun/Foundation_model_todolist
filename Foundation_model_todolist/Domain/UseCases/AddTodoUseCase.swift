import Foundation

class AddTodoUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    func execute(title: String, dueDate: Date?) async throws -> TodoItem {
        let newItem = TodoItem(
            id: UUID(),
            title: title,
            isCompleted: false,
            suggestedCorrection: nil,
            isCorrectionPending: true,
            dueDate: nil,
            creationDate: Date()
        )
        return try await repository.addTodo(item: newItem)
    }
}
