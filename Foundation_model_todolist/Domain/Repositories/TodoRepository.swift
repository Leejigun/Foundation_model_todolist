import Foundation

protocol TodoRepository {
    func getTodos() async throws -> [TodoItem]
    func addTodo(item: TodoItem) async throws
    func toggleTodo(item: TodoItem) async throws
}
