# 使用中のキーボードでカラー切替
## Request
閉じるボタンの上からカラーパレットを切り替える。実装と実機更新。
## Changes
候補行の右端・閉じるボタンの上にパレットアイコン。キー面に9プリセットのスクロール一覧と戻るボタンを表示。選択時はキー部品を再生成せず外観だけを更新し、本文・未確定変換を保持する。
フルアクセス有効時はThemeStoreへ原子的に保存、失敗時は切替せずエラー表示。無効時はcontroller内だけの一時選択。保存済み選択は本体アクティブ復帰時に再読込。本体の明暗は独立。
## Files Changed
KeyboardViewController、KeyboardPreview、ThemeStore、AppModel、RootView、CommittedTextConversionTests、App/AGENTS、CURRENT、CODEMAP、ARCHITECTURE、UI/UX、この記録。
## Validation
未確定文字の保持・確定継続・一覧取消を統合テストに追加。Simulator Debug/統合23テスト、Python13、生成設定一致、文書Full相当・diffチェック成功。初回テストでビュー追加前の制約有効化による例外を検出し、順序を修正して全テスト成功。PowerShell不在につき文書検証はPython代替。署名付きReleaseビルドとcodesign検証も成功。
## Result
2026-10-09 23:44 JST、VesperaへのRelease更新・本体起動成功。
## Remaining Issues
実機での一覧操作は本人確認待ち。
