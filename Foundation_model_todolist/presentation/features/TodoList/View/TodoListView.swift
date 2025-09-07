import SwiftUI
import SwiftData

struct TodoListView: View {
    @StateObject private var viewModel: TodoListViewModel
    @State private var newTodoTitle = ""
    @State private var selectedDueDate: Date? = nil // New state variable

    init(modelContext: ModelContext) {
        let repository = TodoRepositoryImpl(modelContext: modelContext)
        let getTodosUseCase = GetTodosUseCase(repository: repository)
        let addTodoUseCase = AddTodoUseCase(repository: repository)
        let updateTodoUseCase = UpdateTodoUseCase(repository: repository)
        let toggleTodoUseCase = ToggleTodoUseCase(repository: repository)
        let acceptCorrectionUseCase = AcceptCorrectionUseCase(repository: repository)
        let rejectCorrectionUseCase = RejectCorrectionUseCase(repository: repository)
        let deleteTodoUseCase = DeleteTodoUseCase(repository: repository)
        let generativeService = AIGenerativeService() // Renamed
        let summarizeTodosUseCase = SummarizeTodosUseCase(repository: repository, generativeService: generativeService) // New

        _viewModel = StateObject(wrappedValue: TodoListViewModel(
            getTodosUseCase: getTodosUseCase,
            addTodoUseCase: addTodoUseCase,
            updateTodoUseCase: updateTodoUseCase,
            toggleTodoUseCase: toggleTodoUseCase,
            acceptCorrectionUseCase: acceptCorrectionUseCase,
            rejectCorrectionUseCase: rejectCorrectionUseCase,
            deleteTodoUseCase: deleteTodoUseCase,
            summarizeTodosUseCase: summarizeTodosUseCase, // New
            aiCorrectionService: generativeService // Renamed
        ))
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Display Daily Briefing
                if let briefing = viewModel.dailyBriefing {
                    Text(briefing.summary) // Access .summary property
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                }

                HStack {
                    TextField("Enter new todo", text: $newTodoTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        viewModel.addTodo(title: newTodoTitle, dueDate: selectedDueDate) // Pass selectedDueDate
                        newTodoTitle = ""
                        selectedDueDate = nil // Reset date after adding
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                    }
                    .disabled(newTodoTitle.isEmpty)
                }
                .padding(.horizontal) // Apply horizontal padding here

                // New DatePicker
                DatePicker(
                    "Due Date",
                    selection: Binding(get: { selectedDueDate ?? Date() }, set: { selectedDueDate = $0 }),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .padding(.horizontal)
                .onChange(of: selectedDueDate) { newValue in
                    // Handle date change if needed, or just let it update the state
                }
                
                // Add a button to clear the due date
                if selectedDueDate != nil {
                    Button("Clear Due Date") {
                        selectedDueDate = nil
                    }
                    .font(.caption)
                    .padding(.horizontal)
                }


                List {
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
                            // Display Due Date if available
                            if let dueDate = item.dueDate {
                                Text("Due: \(dueDate, formatter: dateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
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
    
    // Date Formatter
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoItemDataModel.self, configurations: config)
    
    return TodoListView(modelContext: container.mainContext)
}