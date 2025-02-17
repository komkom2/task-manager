import SwiftUI

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var showingAddTask = false

    var body: some View {
        NavigationView {
            List {
                ForEach(tasks) { task in
                    NavigationLink(destination: UpdateTaskView(task: task, onUpdate: fetchTasks)) {
                        TaskRow(task: task)
                    }
                }
                .onDelete(perform: deleteTask)
            }
            .navigationTitle("タスク一覧")
            .onAppear(perform: fetchTasks)
            .navigationBarItems(trailing: Button(action: {
                showingAddTask = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            })
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
        }
    }

    // タスク削除処理
    func deleteTask(at offsets: IndexSet) {
        for index in offsets {
            let task = tasks[index]
            APIService.shared.deleteTask(id: task.id) { success in
                if success {
                    DispatchQueue.main.async {
                        tasks.remove(atOffsets: offsets)
                    }
                } else {
                    print("タスク削除に失敗しました")
                }
            }
        }
    }

    // タスク一覧を取得
    func fetchTasks() {
        APIService.shared.fetchTasks { fetchedTasks in
            DispatchQueue.main.async {
                // 取得したタスクがnilまたは不正な場合でもデフォルト値を設定
                self.tasks = fetchedTasks?.map { task in
                    var updatedTask = task
                    updatedTask.description = task.description ?? ""  // descriptionがnilなら空文字に
                    updatedTask.status = task.status ?? 0              // statusがnilなら0に
                    return updatedTask
                } ?? []
            }
        }
    }
}


#Preview {
    ContentView()
}
