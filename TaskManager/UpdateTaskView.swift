import SwiftUI

struct UpdateTaskView: View {
    @State var task: Task
    var onUpdate: () -> Void // 更新後にタスク一覧をリロードするためのクロージャ
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            TextField("タイトル", text: $task.title)
            TextField("詳細", text: $task.description)

            Toggle(isOn: Binding(
                get: { task.status == 1 },  // Int (0 or 1) を Bool に変換
                set: { task.status = $0 ? 1 : 0 }  // Bool を Int (1 or 0) に変換
            )) {
                Text("完了")
            }

            Button("更新") {
                updateTask()
            }
        }
        .navigationTitle("タスク更新")
    }
    
    func updateTask() {
        APIService.shared.updateTask(id: task.id, title: task.title, status: task.status == 1) { success in
            if success {
                DispatchQueue.main.async {
                    onUpdate() // 更新後にリストをリロード
                    presentationMode.wrappedValue.dismiss() // 画面を閉じる
                }
            } else {
                print("タスク更新に失敗しました")
            }
        }
    }
}
