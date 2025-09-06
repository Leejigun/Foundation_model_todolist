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
    
    func addTodo(item: TodoItem) async throws -> TodoItem {
        let dataModel = TodoItemMapper.toDataModel(entity: item)
        modelContext.insert(dataModel)
        return TodoItemMapper.toEntity(dataModel: dataModel)
    }
    
    func update(item: TodoItem) async throws {
        let itemId = item.id
        let predicate = #Predicate<TodoItemDataModel> { $0.id == itemId }
        let descriptor = FetchDescriptor(predicate: predicate)
        if let dataModel = try modelContext.fetch(descriptor).first {
            dataModel.title = item.title
            dataModel.isCompleted = item.isCompleted
        }
    }
    
    func deleteTodo(item: TodoItem) async throws {
        let itemId = item.id
        let predicate = #Predicate<TodoItemDataModel> { $0.id == itemId }
        let descriptor = FetchDescriptor(predicate: predicate)
        if let dataModel = try modelContext.fetch(descriptor).first {
            modelContext.delete(dataModel)
        }
    }
}
