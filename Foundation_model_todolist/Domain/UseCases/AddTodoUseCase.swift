import Foundation

class AddTodoUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    func execute(title: String) async throws {
        let newItem = TodoItem(id: UUID(), title: title, isCompleted: false)
        try await repository.addTodo(item: newItem)
    }
}
