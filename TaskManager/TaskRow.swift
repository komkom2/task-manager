import SwiftUI

struct TaskRow: View {
    var task: Task

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                Text(task.description ?? "説明なし")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(task.status == 1 ? "☑️" : "◽️")
                .foregroundColor(task.status == 1 ? .green : .red)
        }
        .padding()
    }
}
