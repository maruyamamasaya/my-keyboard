# 上部ボタンの整理
## Request
上部の不要ボタンを外し、コピー・左右カーソルの順にする。デプロイとリモートPushまで実施する。
## Investigation
- コピーは既存の手動クリップボード履歴入口として維持。
- 上部あA撤去後、英語配列の下部に直接かなへ戻るキーが必要。
## Changes
- 上部はコピー・左・右、必要時の地球キー、右端の閉じるボタン。
- 上部の表示切替・あA・再変換・絵文字・記号一覧・確定・取消・単語削除を撤去。
- 英語配列の取消キーをあAへ置き換え、かなへ戻れるようにする。
- 絵文字は下部☺、記号一覧は記号配列の一覧から開く。
- 本体のプレビュー・候補設定の説明も現在の操作へ合わせる。
## Files Changed
- KeyboardExtension/KeyboardViewController.swift
- DesignSystem/Preview/KeyboardPreview.swift
- App/Settings/SettingsView.swift
- Tests/Integration/CharacterPickerTests.swift（一覧を開く操作の更新）
- CURRENT、UI/UX・Mac検証手順、この記録。
## Validation
- 最初の統合テストは上部あAの撤去でかなへの直接復帰が欠落し1件失敗。下部キー追加後、16件全て成功。
- Simulator Debugビルド・UIKit統合16テスト、署名付き実機向けReleaseビルド成功。
- UIテスト画像でコピー→左→右、閉じるボタンの配置を目視確認。
- Python構造/配色/SQL 13テスト、生成一致、Fast/Full相当文書検査、git diff --check成功。
- codesign --verify --deep --strict成功。
- Coreは変更なし。直前作業の27テスト成功を引き継ぐ。
- PowerShell未導入のためverify.ps1は未実行。
## Result
2026-10-09、Release版をVesperaへ更新インストール・本体起動成功。絵文字/記号一覧の未コミット変更と今回の整理をまとめてcommit/push対象とする。
## Remaining Issues
実機上のボタン操作・ホスト入力・VoiceOverの本人確認は未実施。
