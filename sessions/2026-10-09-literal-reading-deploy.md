# 文字種変換・英字キー変更の実機デプロイ
## Request
かな・カナ・ローマ字変換と英字左列の入れ替えをデプロイする。
## Investigation
既存導入先Vesperaが接続可能であることをdevicectlで確認。
## Changes
現在のソースを署名付きReleaseでビルドし、本体とKeyboard ExtensionをVesperaへ更新インストール。
CURRENTの導入状態を更新。
## Validation
- xcodebuildの実機向けRelease build成功。
- codesign --verify --deep --strict成功。
- 最初のインストールは接続リセットで失敗。再試行で成功。
- devicectlによるmaruyama.MyKeyboardの本体起動成功。
- 前回のCore28、iOS17.4統合16、Python13テスト成功を引き継ぐ。
- 生成設定一致、Fast/Full相当文書検査、git diff --check成功。
- PowerShell未導入のためverify.ps1は未実行。
## Result
2026-10-09 22:08 JST、Vesperaへの更新インストールと本体起動完了。
## Remaining Issues
実機上の文字種変換・英字左列の操作は本人確認待ち。iOS26.5の既存統合テスト異常終了は前回記録参照。
