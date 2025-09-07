import Foundation
import Combine

@MainActor
class TodoListViewModel: ObservableObject {
    @Published var todoItems: [TodoItem] = []
    @Published var dailyBriefing: DailyBriefing? // Changed type
    
    private let getTodosUseCase: GetTodosUseCase
    private let addTodoUseCase: AddTodoUseCase
    private let updateTodoUseCase: UpdateTodoUseCase
    private let toggleTodoUseCase: ToggleTodoUseCase
    private let acceptCorrectionUseCase: AcceptCorrectionUseCase
    private let rejectCorrectionUseCase: RejectCorrectionUseCase
    private let deleteTodoUseCase: DeleteTodoUseCase
    private let summarizeTodosUseCase: SummarizeTodosUseCase
    private let aiCorrectionService: AIGenerativeService
    
    init(
        getTodosUseCase: GetTodosUseCase,
        addTodoUseCase: AddTodoUseCase,
        updateTodoUseCase: UpdateTodoUseCase,
        toggleTodoUseCase: ToggleTodoUseCase,
        acceptCorrectionUseCase: AcceptCorrectionUseCase,
        rejectCorrectionUseCase: RejectCorrectionUseCase,
        deleteTodoUseCase: DeleteTodoUseCase,
        summarizeTodosUseCase: SummarizeTodosUseCase,
        aiCorrectionService: AIGenerativeService
    ) {
        self.getTodosUseCase = getTodosUseCase
        self.addTodoUseCase = addTodoUseCase
        self.updateTodoUseCase = updateTodoUseCase
        self.toggleTodoUseCase = toggleTodoUseCase
        self.acceptCorrectionUseCase = acceptCorrectionUseCase
        self.rejectCorrectionUseCase = rejectCorrectionUseCase
        self.deleteTodoUseCase = deleteTodoUseCase
        self.summarizeTodosUseCase = summarizeTodosUseCase
        self.aiCorrectionService = aiCorrectionService
    }
    
    func loadTodos() {
        Task {
            do {
                todoItems = try await getTodosUseCase.execute()
                // Generate daily briefing after loading todos
                dailyBriefing = try await summarizeTodosUseCase.execute()
            } catch {
                // Handle error
                print("Error loading todos or generating briefing: \(error)")
                // Set a default DailyBriefing object for error case
                dailyBriefing = DailyBriefing(summary: "브리핑 생성에 실패했습니다.")
            }
        }
    }
    
    func addTodo(title: String, dueDate: Date?) {
        Task {
            do {
                // Add the item with the original title, marked as pending correction
                let newItem = try await addTodoUseCase.execute(title: title, dueDate: dueDate) // Pass dueDate
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
                loadTodos() // Reload the list after deletioni
            } catch {
                print("Error deleting todo: \(error)")
            }
        }
    }
}
