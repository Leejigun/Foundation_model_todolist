import SwiftUI
import SwiftData

struct TodoListView: View {
    @StateObject private var viewModel: TodoListViewModel
    @State private var newTodoTitle = ""

    init(modelContext: ModelContext) {
        let repository = TodoRepositoryImpl(modelContext: modelContext)
        let getTodosUseCase = GetTodosUseCase(repository: repository)
        let addTodoUseCase = AddTodoUseCase(repository: repository)
        let toggleTodoUseCase = ToggleTodoUseCase(repository: repository)
        
        _viewModel = StateObject(wrappedValue: TodoListViewModel(
            getTodosUseCase: getTodosUseCase,
            addTodoUseCase: addTodoUseCase,
            toggleTodoUseCase: toggleTodoUseCase
        ))
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter new todo", text: $newTodoTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        viewModel.addTodo(title: newTodoTitle)
                        newTodoTitle = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                    }
                    .disabled(newTodoTitle.isEmpty)
                }
                .padding()

                List(viewModel.todoItems) { item in
                    HStack {
                        Text(item.title)
                        Spacer()
                        Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                            .onTapGesture {
                                viewModel.toggleCompletion(for: item)
                            }
                    }
                }
            }
            .navigationTitle("Todo List")
            .onAppear {
                viewModel.loadTodos()
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoItemDataModel.self, configurations: config)
    
    return TodoListView(modelContext: container.mainContext)
}
