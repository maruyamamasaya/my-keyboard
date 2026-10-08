# 絵文字・記号一覧の実機デプロイ
## Request
今回追加した絵文字・記号一覧をデプロイする。
## Investigation
- 接続中のiPhoneは既存導入先Vespera。devicectlで確認。
- 前回作業の実機向けRelease成果物、本体/Keyboard Extensionとも0.1.0（build 2）。
- bundle IDはmaruyama.MyKeyboard / maruyama.MyKeyboard.keyboard。
## Changes
- 既存の署名付きReleaseアプリをVesperaへ更新インストール。
- devicectlで本体アプリを起動。
- CURRENTと実装記録を導入済みへ更新。ソースとビルド設定の変更はなし。
## Validation
- 前回のCore27・Simulator統合16テストとReleaseビルド成功を引き継ぐ。
- 生成設定一致、Fast/Full相当のPython文書検査、git diff --check成功。
- codesign --verify --deep --strict成功。
- devicectl device install app: 成功。
- devicectl device process launch: 成功。
- PowerShellのverify.ps1は環境未導入で未実行。
## Result
2026-10-09 00:53 JST、VesperaへRelease版更新・本体起動完了。
## Remaining Issues
実機の絵文字/記号選択・回転・ホスト入力・VoiceOver操作は本人確認待ち。
