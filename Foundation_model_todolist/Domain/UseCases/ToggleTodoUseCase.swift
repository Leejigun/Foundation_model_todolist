import Foundation

class ToggleTodoUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    func execute(item: TodoItem) async throws {
        try await repository.toggleTodo(item: item)
    }
}
