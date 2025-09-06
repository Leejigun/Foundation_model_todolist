import Foundation

class DeleteTodoUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    func execute(item: TodoItem) async throws {
        try await repository.deleteTodo(item: item)
    }
}
