import Foundation
import Combine

@MainActor
class TodoListViewModel: ObservableObject {
    @Published var todoItems: [TodoItem] = []

    private let getTodosUseCase: GetTodosUseCase
    private let addTodoUseCase: AddTodoUseCase
    private let updateTodoUseCase: UpdateTodoUseCase
    private let toggleTodoUseCase: ToggleTodoUseCase
    private let acceptCorrectionUseCase: AcceptCorrectionUseCase
    private let rejectCorrectionUseCase: RejectCorrectionUseCase
    private let deleteTodoUseCase: DeleteTodoUseCase // New
    private let aiCorrectionService: AICorrectionService

    init(
        getTodosUseCase: GetTodosUseCase,
        addTodoUseCase: AddTodoUseCase,
        updateTodoUseCase: UpdateTodoUseCase,
        toggleTodoUseCase: ToggleTodoUseCase,
        acceptCorrectionUseCase: AcceptCorrectionUseCase,
        rejectCorrectionUseCase: RejectCorrectionUseCase,
        deleteTodoUseCase: DeleteTodoUseCase, // New
        aiCorrectionService: AICorrectionService
    ) {
        self.getTodosUseCase = getTodosUseCase
        self.addTodoUseCase = addTodoUseCase
        self.updateTodoUseCase = updateTodoUseCase
        self.toggleTodoUseCase = toggleTodoUseCase
        self.acceptCorrectionUseCase = acceptCorrectionUseCase
        self.rejectCorrectionUseCase = rejectCorrectionUseCase
        self.deleteTodoUseCase = deleteTodoUseCase // New
        self.aiCorrectionService = aiCorrectionService
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
                // Add the item with the original title, marked as pending correction
                let newItem = try await addTodoUseCase.execute(title: title)
                loadTodos() // Refresh the list to show the new item

                // Correct in the background
                let correctedTitle = await aiCorrectionService.correct(text: newItem.title)
                
                // If a correction is suggested and it's different from the original
                if correctedTitle != newItem.title {
                    var itemToUpdate = newItem
                    itemToUpdate.suggestedCorrection = correctedTitle
                    itemToUpdate.isCorrectionPending = true // Ensure it's marked as pending
                    try await updateTodoUseCase.execute(item: itemToUpdate)
                    
                    // Directly update the published array for immediate UI refresh
                    if let index = todoItems.firstIndex(where: { $0.id == itemToUpdate.id }) {
                        todoItems[index] = itemToUpdate
                    }
                } else {
                    // If no correction or same as original, mark as not pending
                    var itemToUpdate = newItem
                    itemToUpdate.suggestedCorrection = nil
                    itemToUpdate.isCorrectionPending = false
                    try await updateTodoUseCase.execute(item: itemToUpdate)
                    
                    // Directly update the published array
                    if let index = todoItems.firstIndex(where: { $0.id == itemToUpdate.id }) {
                        todoItems[index] = itemToUpdate
                    }
                }
            } catch {
                print("Error adding todo: \(error)")
            }
        }
    }

    func toggleCompletion(for item: TodoItem) {
        Task {
            do {
                try await toggleTodoUseCase.execute(item: item)
                loadTodos() // Just reload the list to show the change
            } catch {
                // Handle error
                print("Error toggling todo: \(error)")
            }
        }
    }

    func acceptCorrection(for item: TodoItem) {
        Task {
            do {
                try await acceptCorrectionUseCase.execute(item: item)
                loadTodos()
            } catch {
                print("Error accepting correction: \(error)")
            }
        }
    }

    func rejectCorrection(for item: TodoItem) {
        Task {
            do {
                try await rejectCorrectionUseCase.execute(item: item)
                loadTodos()
            } catch {
                print("Error rejecting correction: \(error)")
            }
        }
    }

    // New method for deleting todos
    func deleteTodo(for item: TodoItem) {
        Task {
            do {
                try await deleteTodoUseCase.execute(item: item)
                loadTodos() // Reload the list after deletion
            } catch {
                print("Error deleting todo: \(error)")
            }
        }
    }
}