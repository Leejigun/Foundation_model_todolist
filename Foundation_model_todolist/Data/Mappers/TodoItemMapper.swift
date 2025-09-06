import Foundation

struct TodoItemMapper {
    static func toEntity(dataModel: TodoItemDataModel) -> TodoItem {
        return TodoItem(id: dataModel.id, title: dataModel.title, isCompleted: dataModel.isCompleted)
    }

    static func toDataModel(entity: TodoItem) -> TodoItemDataModel {
        return TodoItemDataModel(id: entity.id, title: entity.title, isCompleted: entity.isCompleted)
    }
}
