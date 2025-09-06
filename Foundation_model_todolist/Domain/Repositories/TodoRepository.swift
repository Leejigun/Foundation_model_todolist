import Foundation

protocol TodoRepository {
    func getTodos() async throws -> [TodoItem]
    func addTodo(item: TodoItem) async throws -> TodoItem
    func update(item: TodoItem) async throws
    func deleteTodo(item: TodoItem) async throws
}
