import Foundation
import SwiftData

class TodoRepositoryImpl: TodoRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getTodos() async throws -> [TodoItem] {
        let descriptor = FetchDescriptor<TodoItemDataModel>()
        let dataModels = try modelContext.fetch(descriptor)
        return dataModels.map(TodoItemMapper.toEntity)
    }

    func addTodo(item: TodoItem) async throws {
        let dataModel = TodoItemMapper.toDataModel(entity: item)
        modelContext.insert(dataModel)
    }

    func toggleTodo(item: TodoItem) async throws {
        let predicate = #Predicate<TodoItemDataModel> { $0.id == item.id }
        let descriptor = FetchDescriptor(predicate: predicate)
        if let dataModel = try modelContext.fetch(descriptor).first {
            dataModel.isCompleted.toggle()
        }
    }
}
