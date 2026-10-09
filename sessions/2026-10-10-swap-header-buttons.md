# 閉じる・パレットの位置交換
## Request
キーボードの閉じるボタンとパレットボタンを入れ替える。
## Investigation
候補行右端がパレット、ツールバー右端が閉じる。本体プレビューも同じ構成。
## Changes
- 候補行右端を閉じる、ツールバー右端をパレットへ変更。
- 行に合わせた描画roleと入力状態ラベルの制約を更新。
- 各操作の処理・44pt幅・アクセシビリティ説明を維持。
## Files Changed
KeyboardExtension/KeyboardViewController.swift、DesignSystem/Preview/KeyboardPreview.swift、CURRENT.md。
## Validation
- PowerShell未導入のためFast/Fullの文書検査をPythonで代替。
- 生成設定一致、Python構造/配色/SQLite 13テスト成功。
- Simulator Debug/Release build成功。
- iOS26.5 Simulator統合テスト成功（既存suite全体）。
- 初回テストはReleaseビルドとの同時実行でDBロック。順次再実行して成功。
- 文書リンク/行数のFull代替検査、git diff --check成功。
## Result
実キーボードとプレビューのボタン配置を交換。
## Remaining Issues
実機への更新・操作確認は未実施。
