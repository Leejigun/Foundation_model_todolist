import Foundation
import Combine

@MainActor
class TodoListViewModel: ObservableObject {
    @Published var todoItems: [TodoItem] = []

    private let getTodosUseCase: GetTodosUseCase
    private let addTodoUseCase: AddTodoUseCase
    private let toggleTodoUseCase: ToggleTodoUseCase

    init(
        getTodosUseCase: GetTodosUseCase,
        addTodoUseCase: AddTodoUseCase,
        toggleTodoUseCase: ToggleTodoUseCase
    ) {
        self.getTodosUseCase = getTodosUseCase
        self.addTodoUseCase = addTodoUseCase
        self.toggleTodoUseCase = toggleTodoUseCase
    }

    func loadTodos() {
        Task {
            do {
                todoItems = try await getTodosUseCase.execute()
            } catch {
                // Handle error
                print("Error loading todos: \(error)")
            }
        }
    }

    func addTodo(title: String) {
        Task {
            do {
                try await addTodoUseCase.execute(title: title)
                loadTodos() // Reload the list
            } catch {
                // Handle error
                print("Error adding todo: \(error)")
            }
        }
    }

    func toggleCompletion(for item: TodoItem) {
        Task {
            do {
                try await toggleTodoUseCase.execute(item: item)
                loadTodos() // Reload the list
            } catch {
                // Handle error
                print("Error toggling todo: \(error)")
            }
        }
    }
}
