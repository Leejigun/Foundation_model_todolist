import Foundation

struct TodoItemMapper {
    static func toEntity(dataModel: TodoItemDataModel) -> TodoItem {
        return TodoItem(
            id: dataModel.id,
            title: dataModel.title,
            isCompleted: dataModel.isCompleted,
            suggestedCorrection: dataModel.suggestedCorrection,
            isCorrectionPending: dataModel.isCorrectionPending,
            dueDate: dataModel.dueDate,
            creationDate: dataModel.creationDate
        )
    }

    static func toDataModel(entity: TodoItem) -> TodoItemDataModel {
        return TodoItemDataModel(
            id: entity.id,
            title: entity.title,
            isCompleted: entity.isCompleted,
            suggestedCorrection: entity.suggestedCorrection,
            isCorrectionPending: entity.isCorrectionPending,
            dueDate: entity.dueDate,
            creationDate: entity.creationDate
        )
    }
}
