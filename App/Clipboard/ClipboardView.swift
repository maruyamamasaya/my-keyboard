import SwiftUI
import UIKit
import KeyboardCore

struct ClipboardView: View {
    @ObservedObject var model: AppModel
    @State private var search = ""
    @State private var draft = ""
    @State private var registrationText = ""
    @State private var confirmClear = false
    var body: some View {
        List {
            Section("文字列を登録") {
                TextField("登録する文字列", text: $registrationText, axis: .vertical)
                    .lineLimit(3...6)
                    .disabled(!model.preferences.clipboardEnabled)
                Button("保存") {
                    model.message = nil
                    model.historyAction(search: search) { try $0.add(registrationText, limit: model.preferences.safeClipboardLimit) }
                    if model.message == nil { registrationText = "" }
                }
                .disabled(!model.preferences.clipboardEnabled || !ClipboardPolicy.accepts(registrationText))
            }
            Section("手動取り込み") {
                if !model.preferences.clipboardEnabled {
                    Text("設定 → キーボード設定で履歴保存をONにしてください。").font(.footnote).foregroundStyle(.secondary)
                }
                PasteCapture { draft = $0 }.frame(height: 44).disabled(!model.preferences.clipboardEnabled)
                if !draft.isEmpty {
                    Text(draft).lineLimit(5)
                    Button("この内容を保存") {
                        model.historyAction(search: search) { try $0.add(draft, limit: model.preferences.safeClipboardLimit) }
                        if model.message == nil { draft = "" }
                    }.disabled(!model.preferences.clipboardEnabled)
                    Button("取り込みを取消") { draft = "" }
                }
            }
            ForEach(model.history) { item in
                VStack(alignment: .leading) {
                    Text(item.text).lineLimit(4)
                    HStack {
                        Button(item.pinned ? "ピン解除" : "ピン留め") { model.historyAction(search: search) { try $0.togglePin(item.id) } }
                        Button("削除", role: .destructive) { model.historyAction(search: search) { try $0.remove(item.id) } }
                    }.buttonStyle(.borderless)
                }
            }
        }.navigationTitle("履歴")
            .searchable(text: $search, prompt: "端末内を検索")
            .onChange(of: search) { _, value in if model.preferences.clipboardEnabled { model.historyAction(search: value) } }
            .onAppear { if model.preferences.clipboardEnabled { model.historyAction() } }
            .onDisappear { draft = ""; registrationText = "" }
            .onChange(of: model.preferences.clipboardEnabled) { _, enabled in if !enabled { draft = ""; registrationText = "" } }
            .toolbar { Button("全削除", role: .destructive) { confirmClear = true } }
            .confirmationDialog("ピンを含む履歴をすべて削除しますか？", isPresented: $confirmClear) {
                Button("すべて削除", role: .destructive) { model.historyAction { try $0.removeAll() } }
            }
    }
}
// PasteControl establishes user intent. No pasteboard polling or direct read during appearance.
struct PasteCapture: UIViewRepresentable {
    let receive: (String) -> Void
    func makeUIView(context: Context) -> PasteReceiver {
        let view = PasteReceiver(); view.receive = receive; return view
    }
    func updateUIView(_ uiView: PasteReceiver, context: Context) {
        uiView.receive = receive
        uiView.isUserInteractionEnabled = context.environment.isEnabled
    }
}
final class PasteReceiver: UIView {
    var receive: ((String) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        pasteConfiguration = UIPasteConfiguration(forAccepting: NSString.self)
        let control = UIPasteControl(configuration: .init())
        control.target = self
        control.translatesAutoresizingMaskIntoConstraints = false
        addSubview(control)
        NSLayoutConstraint.activate([control.leadingAnchor.constraint(equalTo: leadingAnchor), control.centerYAnchor.constraint(equalTo: centerYAnchor)])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func paste(itemProviders: [NSItemProvider]) {
        guard let provider = itemProviders.first(where: { $0.canLoadObject(ofClass: NSString.self) }) else { return }
        provider.loadObject(ofClass: NSString.self) { [weak self] value, _ in
            guard let text = value as? String else { return }
            DispatchQueue.main.async { self?.receive?(text) }
        }
    }
}
