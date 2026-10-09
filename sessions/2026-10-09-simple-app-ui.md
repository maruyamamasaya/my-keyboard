# 本体UIの整理
## Request
アプリ全体をスッキリさせ、まずフレーバーテキストを撤去。履歴を左から2番目、設定を右端へ。使い方・キーボード設定・プライバシー/アプリ情報・プレビュー・カラー編集を設定内へまとめる。
## Investigation
ホームのキャッチコピー、カラー画面の導入文、設定の各説明とプレビューが重複していた。
## Changes
- キャッチコピー、カラー/設定/プレビュー画面の常設説明文を撤去。
- タブをホーム/履歴/辞書/設定に変更。
- ホームをキーボード表示とパレット入口の一覧へ整理。
- 設定を入口の一覧にし、キーボード設定を専用画面へ分離。
- 使い方・プレビュー・カラー編集・アプリ情報を設定へ集約。パレット画面内の編集ショートカットも撤去。
- 有効化手順は3項目、アプリ情報は項目/値中心へ。振動トラブル案内は折りたたみ。
- 保存データ・キーボード入力・設定の保存経路は維持。
## Files Changed
App/RootView.swift、App/Settings/SettingsView.swift、App/Theme/ThemeViews.swift、App/Onboarding/OnboardingView.swift、App/Clipboard/ClipboardView.swift、CURRENT、CODEMAP、UI/UX、この記録。
## Validation
- 最終のSimulator Debugビルド・統合21テスト、署名付き実機Releaseビルド成功。codesign検証はsandbox内では証明書ストアの制限で失敗、制限外で成功。
- CUAのSimulator取得を2回試したが接続タイムアウト。画面の目視確認は未実施。
- Coreに変更なし。直前Core34テスト成功を引き継ぐ。
## Result
2026-10-09 22:59 JST、VesperaへRelease版更新インストール・本体起動成功。Python13テスト、生成設定一致、Full相当文書検査、git diff --check成功。途中の文書検査は同時作業中のstrong-haptics記録のリンク先未作成で失敗、記録作成後に成功。PowerShell未導入で標準Verifyは未実行。
## Remaining Issues
本体全画面の実機レイアウト確認は本人確認待ち。振動の実機改善確認も継続中。
