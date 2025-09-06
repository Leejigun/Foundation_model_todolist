
import Foundation
import SwiftData

@Model
final class TodoItemDataModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}
