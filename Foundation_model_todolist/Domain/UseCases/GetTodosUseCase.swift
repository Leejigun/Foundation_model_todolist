import Foundation

class GetTodosUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    func execute() async throws -> [TodoItem] {
        return try await repository.getTodos()
    }
}
