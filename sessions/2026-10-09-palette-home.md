# カラーパレットをホームへ
## Request
カラーパレットをそのままホームにする。カラー適用で本体のライト/ダーク表示を変えない。
## Changes
ホームタブの先頭をThemeGalleryへ変更し、使われなくなったDashboardViewを撤去。履歴/辞書/設定の順と設定内の各入口を維持。本体ルートのテーマ連動の明暗・背景・アクセントを解除し、端末の明暗と標準背景、固定の青アクセントを使用。
## Files Changed
App/RootView.swift、App/Theme/ThemeViews.swift、CURRENT、CODEMAP、UI/UX、この記録。
## Validation
Fast/Full相当の文書・リンク・行数確認、生成設定一致、Python13テスト、Simulator Debug/統合21テスト、署名付きReleaseビルド、codesign検証、diffチェック成功。PowerShell不在のため文書VerifyはPython代替。Core変更なし。低影響の入口変更のため新しいテストは追加しない。
## Result
2026-10-09 23:13 JST、VesperaへRelease版をインストール成功。本体起動も成功。
## Remaining Issues
実機画面の本人確認待ち。
