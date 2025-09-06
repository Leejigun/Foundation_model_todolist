import SwiftUI
import SwiftData

struct TodoListView: View {
    @StateObject private var viewModel: TodoListViewModel
    @State private var newTodoTitle = ""

    init(modelContext: ModelContext) {
        let repository = TodoRepositoryImpl(modelContext: modelContext)
        let getTodosUseCase = GetTodosUseCase(repository: repository)
        let addTodoUseCase = AddTodoUseCase(repository: repository)
        let updateTodoUseCase = UpdateTodoUseCase(repository: repository)
        let toggleTodoUseCase = ToggleTodoUseCase(repository: repository)
        let acceptCorrectionUseCase = AcceptCorrectionUseCase(repository: repository)
        let rejectCorrectionUseCase = RejectCorrectionUseCase(repository: repository)
        let deleteTodoUseCase = DeleteTodoUseCase(repository: repository) // New
        let aiCorrectionService = AICorrectionService()

        _viewModel = StateObject(wrappedValue: TodoListViewModel(
            getTodosUseCase: getTodosUseCase,
            addTodoUseCase: addTodoUseCase,
            updateTodoUseCase: updateTodoUseCase,
            toggleTodoUseCase: toggleTodoUseCase,
            acceptCorrectionUseCase: acceptCorrectionUseCase,
            rejectCorrectionUseCase: rejectCorrectionUseCase,
            deleteTodoUseCase: deleteTodoUseCase, // New
            aiCorrectionService: aiCorrectionService
        ))
    }

    var body: some View {
        NavigationStack {
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

                List { // Use ForEach inside List for onDelete
                    ForEach(viewModel.todoItems) { item in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(item.title)
                                    .strikethrough(item.isCorrectionPending && item.suggestedCorrection != nil) // Strikethrough original if pending correction
                                Spacer()
                                Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                                    .onTapGesture {
                                        viewModel.toggleCompletion(for: item)
                                    }
                            }

                            if item.isCorrectionPending, let suggested = item.suggestedCorrection {
                                Text("Suggested: \(suggested)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                HStack {
                                    Button("Accept") {
                                        viewModel.acceptCorrection(for: item)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    Button("Reject") {
                                        viewModel.rejectCorrection(for: item)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let itemToDelete = viewModel.todoItems[index]
                            viewModel.deleteTodo(for: itemToDelete)
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