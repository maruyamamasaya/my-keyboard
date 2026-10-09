# 入力振動を強める
## Request
振動が反映されない。弱すぎる可能性がある。
## Investigation
入力からGeneratorへの呼び出しは存在し、light/強度0.5だった。振動が発生しない原因はまだ未確定。
## Changes
- Extensionをheavy/強度1.0へ変更。1入力1回とON/OFF設定は維持。
- 本体の振動テストもheavy/強度1.0へ変更、設定名を「入力時に振動」へ更新。
- CURRENT、UI/UX、実機検証手順を更新。
## Validation
- Fast相当の必須文書・ルート行数検査成功。
- 生成設定一致、Python13テスト、Full相当文書リンク・行数検査、diff check成功。
- 署名付き実機Releaseビルド、codesign検証成功。
- 新規Simulatorビルドはsandbox内のGitHub名前解決失敗。既存依存を使ったReleaseで検証。
- PowerShell未導入のため標準Verify未実行。StorageTestsは今回未実行（保存処理変更なし）。
## Result
2026-10-09 22:57 JST、Vesperaへ更新インストール成功。本人から「いい感じになった」と報告があり、実機での振動の体感改善を確認。
## Remaining Issues
振動が改善したことは本人確認済み。以前の無振動の原因は確定していない。
