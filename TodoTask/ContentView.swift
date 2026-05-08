import SwiftUI

enum Filter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}

struct ContentView: View {

    @State private var newTaskText: String = ""
    @State private var selectedFilter: Filter = .all
    @State private var tasks: [Task] = ContentView.loadTasks()

    var filteredTasks: [Task] {
        switch selectedFilter {
        case .all:       return tasks
        case .active:    return tasks.filter { !$0.isCompleted }
        case .completed: return tasks.filter { $0.isCompleted }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                HStack {
                    TextField("Tasks to add...", text: $newTaskText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                }
                .padding()

                Picker("Filter", selection: $selectedFilter) {
                    ForEach(Filter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 8)

                List {
                    ForEach(filteredTasks) { task in
                        TaskRow(task: task, onToggle: { toggleTask(task) })
                    }
                    .onDelete(perform: deleteTasks)
                }
                .listStyle(.plain)
            }
            .navigationTitle("My Tasks")
        }
    }

    func addTask() {
        let trimmed = newTaskText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let newTask = Task(title: trimmed)
        tasks.append(newTask)
        newTaskText = ""
        saveTasks()
    }

    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }

    func deleteTasks(at offsets: IndexSet) {
        let tasksToDelete = offsets.map { filteredTasks[$0] }
        tasks.removeAll { task in
            tasksToDelete.contains(where: { $0.id == task.id })
        }
        saveTasks()
    }

    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "saved_tasks")
        }
    }

    static func loadTasks() -> [Task] {
        if let data = UserDefaults.standard.data(forKey: "saved_tasks"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            return decoded
        }
        return []
    }
}

struct TaskRow: View {
    let task: Task
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {

            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)

            Text(task.title)
                .foregroundColor(task.isCompleted ? .gray : .primary)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
