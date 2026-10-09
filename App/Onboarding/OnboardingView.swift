import SwiftUI
import UIKit
import WebKit

struct OnboardingView: View {
    var body: some View {
        List {
            Section("追加手順") {
                Text("1. iPhoneの設定 → 一般 → キーボード → キーボードを開く")
                Text("2. 新しいキーボードを追加 → MyKeyboardを選ぶ")
                Text("3. 入力欄の地球キーからMyKeyboardに切り替える")
            }
            NavigationLink("入力テスト画面") { HostTestView() }
            NavigationLink("OSSライセンス") { LicenseView() }
        }.navigationTitle("キーボードを追加")
    }
}
struct LicenseView: View {
    private var notices: String {
        guard let url = Bundle.main.url(forResource: "ThirdPartyNotices", withExtension: "txt") else { return "ライセンスファイルがありません。" }
        return (try? String(contentsOf: url, encoding: .utf8)) ?? "ライセンスファイルを読み込めません。"
    }
    var body: some View {
        ScrollView {
            Text(notices)
                .font(.caption).textSelection(.enabled).padding()
        }.navigationTitle("OSSライセンス")
    }
}
struct HostTestView: View {
    @State private var text = ""
    @State private var password = ""
    var body: some View {
        Form {
            TextField("通常入力", text: $text)
            TextEditor(text: $text).frame(height: 120)
            SecureField("標準キーボード確認", text: $password)
            TextField("数字欄", text: $text).keyboardType(.numberPad)
            LocalWebInput().frame(height: 140)
        }.navigationTitle("入力テスト")
    }
}
struct LocalWebInput: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.loadHTMLString("<meta name='viewport' content='width=device-width,initial-scale=1'><label>Web入力<textarea style='width:90%;height:80px'></textarea></label>", baseURL: nil)
        return view
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
