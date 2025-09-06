import Foundation

struct TodoItem: Identifiable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}
