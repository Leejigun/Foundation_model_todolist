import Foundation

class RejectCorrectionUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    func execute(item: TodoItem) async throws {
        var updatedItem = item
        updatedItem.suggestedCorrection = nil
        updatedItem.isCorrectionPending = false
        try await repository.update(item: updatedItem)
    }
}
