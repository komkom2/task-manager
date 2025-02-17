import SwiftUI

struct AddTaskView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var status: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var onTaskAdded: (() -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("タスク情報")) {
                    TextField("タイトル", text: $title)
                    TextField("説明", text: $description)
                    Toggle(isOn: $status) {
                        Text("完了済み")
                    }
                }
                
                Button(action: {
                    createTask()
                }) {
                    Text("タスクを作成")
                }
            }
            .navigationTitle("タスク作成")
        }
    }

    func createTask() {
        let task = Task(id: 0, title: title, description: description, status: status ? 1 : 0, createdAt: "", updatedAt: "")
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/tasks") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(task)
            request.httpBody = jsonData
        } catch {
            print("エラー: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print("タスク作成成功: \(data)")
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss() // 作成後、前の画面に戻る
                    self.onTaskAdded?()
                }
            }
        }.resume()
    }
}
