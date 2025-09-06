import Foundation

class UpdateTodoUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    func execute(item: TodoItem) async throws {
        try await repository.update(item: item)
    }
}
