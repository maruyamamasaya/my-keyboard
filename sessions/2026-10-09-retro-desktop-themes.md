# Windowsデスクトップ風テーマ再設計
## Request
- 98・XP・Vistaをデスクトップの配色と雰囲気から作り直す。粗い画素表現も使用可能。
## Investigation
- ThemeCatalog、ThemeSelection、共通キー描画、本体のネイティブプレビューを確認。
- 従来のWindows系は単色背景と共通のキー表現が中心だった。
## Changes
- 98: 青緑のディザ背景、角丸0、灰色キー、白/濃灰の立体枠と押下反転。
- XP: 青空・雲・丘を160×120で描画。クリームキーと緑の実行キー。
- Vista: 暗い青緑のグラデーション、光の曲線、ガラス風のキー。
- Windows系の等幅文字、候補/操作領域の暗い帯、ギャラリー説明を追加。
- desktopStyleはプリセットから固定。既存JSONとカスタム色の互換を維持。
## Files Changed
- Core/Theme/ThemeTokens.swift
- DesignSystem/Theme/ThemeRendering.swift
- DesignSystem/Keyboard/FlickButton.swift
- App/Theme/ThemeViews.swift
- Tests/Unit/ThemeTests.swift、Tests/Integration/KeyboardPreviewTests.swift
- CURRENT.md、docs/10-UI-UX-AND-THEMES.md
## Validation
- Fast相当のPython検証成功。PowerShell未導入のため標準Verify直接実行不可。
- Core34テスト、Python13テスト、生成設定一致確認、Full相当の文書リンク/行数検証成功。
- iOS26.5 arm64 Simulatorでテーマ描画/3配列の2テスト、ThemeStoreの2テスト成功。画像を取り出して目視確認。
- 最終調整後のarm64 DebugテストビルドとRelease本体/拡張ビルド成功。
- 全アーキテクチャのDebugビルドはx86_64の既存依存リンク問題で失敗。arm64構成で検証。
- 初回の画像取得は黒画像、次回はシーン必須条件で失敗。UIView layer描画とシーンなし対応で修正。
## Result
- 本体プレビューと拡張で同じテーマ表現を使用。
## Remaining Issues
- 実機の更新・操作確認は未実施。
- ドットフォントそのものは導入せず、OSの等幅文字と日本語フォールバックを使用。
