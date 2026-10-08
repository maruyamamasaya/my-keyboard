import SwiftUI
import UIKit
import WebKit

struct OnboardingView: View {
    var body: some View {
        List {
            Section("キーボードを追加") {
                Text("設定 → 一般 → キーボード → キーボード → 新しいキーボードを追加 → MyKeyboard を選択してください。")
                Text("入力欄で地球キーから切り替えます。基本入力と変換はフルアクセスなしで使う設計です。")
            }
            Section("ローカルで処理") {
                Text("通信・クラウド同期・入力全文ログはありません。設定と辞書は端末内で共有します。履歴は手動保存だけです。")
                Text("拡張で履歴を使う場合はフルアクセスが必要です。OSは通信などを含む権限の説明を表示しますが、このアプリは通信機能を持ちません。")
                Text("パスワード欄などでは標準キーボードへ切り替わります。他アプリがこのキーボードを拒否する場合もあります。")
            }
            NavigationLink("入力テスト画面") { HostTestView() }
            NavigationLink("OSSライセンス") { LicenseView() }
        }.navigationTitle("MyKeyboard")
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
            Text("個人情報を入力せず、かな・漢字・絵文字・改行で試してください。")
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
