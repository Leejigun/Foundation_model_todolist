
import Foundation
import SwiftData

@Model
final class TodoItemDataModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var suggestedCorrection: String?
    var isCorrectionPending: Bool
    var dueDate: Date?
    var creationDate: Date
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool, suggestedCorrection: String? = nil, isCorrectionPending: Bool = false, dueDate: Date? = nil, creationDate: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.suggestedCorrection = suggestedCorrection
        self.isCorrectionPending = isCorrectionPending
        self.dueDate = dueDate
        self.creationDate = creationDate
    }
}
