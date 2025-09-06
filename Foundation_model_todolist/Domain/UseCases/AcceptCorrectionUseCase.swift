import Foundation

class AcceptCorrectionUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    func execute(item: TodoItem) async throws {
        guard let suggestedCorrection = item.suggestedCorrection else {
            // No suggested correction to accept
            return
        }
        var updatedItem = item
        updatedItem.title = suggestedCorrection
        updatedItem.suggestedCorrection = nil
        updatedItem.isCorrectionPending = false
        try await repository.update(item: updatedItem)
    }
}
