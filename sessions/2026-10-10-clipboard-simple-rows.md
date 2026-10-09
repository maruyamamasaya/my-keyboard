# クリップボード一覧の整理
## Request
文字列の幅を安定させ、長文は省略。追加指示で削除・星ボタンを撤去。
## Investigation
キーボード内の一覧行は文字列・星・削除の横並びで文字幅が内容依存。
## Changes
- キーボード内一覧の削除・星ボタンを撤去。
- 文字列は幅いっぱいの左寄せ1行、末尾を…で省略。行高44pt。
- 改行は表示のみ空白へ置換。挿入・アクセシビリティは元の全文を維持。
- 本体の削除・ピン管理、保存データは維持。
## Files Changed
KeyboardExtension/KeyboardViewController.swift、CURRENT.md、この記録。
## Validation
- Fast代替検査、生成設定一致、Python13テスト成功。
- 最終版Simulator Debug/Release build成功。iOS26.5統合24テスト成功。
- 文書Full代替検査は別作業のCURRENTリンク（night-sky-retro-terminalの記録未作成）で失敗。今回追加したリンクは正常。
- git diff --check成功。
## Remaining Issues
実機更新・一覧の操作確認は未実施。
