import SwiftUI

struct DictionaryView: View {
    @ObservedObject var model: AppModel
    @State private var editing: DictionaryEntry?
    var body: some View {
        List {
            ForEach(model.dictionary) { entry in
                Button { editing = entry } label: {
                    VStack(alignment: .leading) { Text(entry.text); Text(entry.reading).font(.caption).foregroundStyle(.secondary) }
                }
            }.onDelete(perform: model.removeEntries)
        }.navigationTitle("ユーザー辞書")
            .toolbar { Button("追加") { editing = .init(reading: "", text: "") } }
            .sheet(item: $editing) { entry in
                DictionaryEditor(entry: entry) { model.saveEntry($0) }
            }
    }
}
struct DictionaryEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State var entry: DictionaryEntry
    let save: (DictionaryEntry) -> Void
    var body: some View {
        NavigationStack {
            Form { TextField("読み（ひらがな）", text: $entry.reading); TextField("表記", text: $entry.text) }
                .navigationTitle("単語編集")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") { save(entry); dismiss() }.disabled(entry.reading.isEmpty || entry.text.isEmpty)
                    }
                }
        }
    }
}
