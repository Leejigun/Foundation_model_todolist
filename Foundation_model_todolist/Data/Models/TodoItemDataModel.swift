
import Foundation
import SwiftData

@Model
final class TodoItemDataModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var suggestedCorrection: String?
    var isCorrectionPending: Bool
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool, suggestedCorrection: String? = nil, isCorrectionPending: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.suggestedCorrection = suggestedCorrection
        self.isCorrectionPending = isCorrectionPending
    }
}
