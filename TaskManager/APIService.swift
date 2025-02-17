import Foundation

struct Task: Identifiable, Codable {
    var id: Int
    var title: String
    var description: String?
    var status: Int?  // Bool から Int に変更
    var createdAt: String  // APIから返される日時形式に合わせる
    var updatedAt: String  // APIから返される日時形式に合わせる

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // デフォルト値を設定
    init(id: Int, title: String, description: String? = nil, status: Int? = 0, createdAt: String, updatedAt: String) {
        self.id = id
        self.title = title
        self.description = description ?? ""  // descriptionがnilの場合は空文字に
        self.status = status ?? 0              // statusがnilの場合は0に
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}



class APIService {
    static let shared = APIService()
    private let baseURL = "http://127.0.0.1:8000/api/tasks"

    // タスク一覧を取得（GET）
    func fetchTasks(completion: @escaping ([Task]?) -> Void) {
        guard let url = URL(string: baseURL) else { return }
        print("APIリクエスト開始: \(url)") // ← 追加

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("通信エラー: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("データなし")
                completion(nil)
                return
            }
            
            // JSONデータを文字列に変換してログ出力（デバッグ用）
            if let jsonString = String(data: data, encoding: .utf8) {
                print("取得したJSONデータ: \(jsonString)")
            }

            do {
                let tasks = try JSONDecoder().decode([Task].self, from: data)
                print("取得したタスク一覧: \(tasks)") // ← 追加
                completion(tasks)
            } catch {
                print("デコードエラー: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }


    // タスクを登録（POST）
    func createTask(title: String, description: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "title": title,
            "description": description,
            "status": false
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("JSONエンコードエラー: \(error.localizedDescription)")
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("通信エラー: \(error.localizedDescription)")
                completion(false)
                return
            }

            completion(true)
        }
        task.resume()
    }

    // タスクを更新（PUT）
    func updateTask(id: Int, title: String, description: String,status: Bool, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "title": title,
            "description": description,
            "status": status
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("JSONエンコードエラー: \(error.localizedDescription)")
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("通信エラー: \(error.localizedDescription)")
                completion(false)
                return
            }

            completion(true)
        }
        task.resume()
    }

    // タスクを削除（DELETE）
    func deleteTask(id: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let task = URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("通信エラー: \(error.localizedDescription)")
                completion(false)
                return
            }

            completion(true)
        }
        task.resume()
    }
}
