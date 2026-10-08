# キーボードを閉じるボタン
## Request
右上に下向きの閉じるボタンを追加する。
## Investigation
ツールバーの横スクロール、変換確定、入力操作の停止、コピー画面の終了処理を確認。
## Changes
ツールバーの右側へ44ptのchevron.downボタンを固定。
押下時は未確定変換を確定し、操作とコピー画面を終了してdismissKeyboardを呼ぶ。
アクセシビリティラベル・説明と、本体のキーボードプレビューも追加。
## Files Changed
KeyboardExtension/KeyboardViewController.swift、DesignSystem/Preview/KeyboardPreview.swift、CURRENT.md、docs/10-UI-UX-AND-THEMES.md。
## Validation
Python文書代替Verify、生成設定一致、静的13テスト、git diff --checkを確認。
署名付きDebug/Releaseビルド成功。Simulatorの保存・marked text統合8テスト成功。
署名検証成功、Vesperaへの更新インストール成功。
## Result
閉じるボタンはツールバーの横スクロールから独立し、常に右上に表示する。
## Remaining Issues
Vesperaの入力先アプリで、実際の閉じる操作と未確定変換の確定は未確認。
