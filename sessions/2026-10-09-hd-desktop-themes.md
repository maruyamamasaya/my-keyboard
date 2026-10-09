# XP / Vista 高解像度テーマ
## Request
- XP/Vistaを高解像度化し、画像生成でプロダクト向けの品質に仕上げる。
## Investigation
- 共通背景とキー、本体プレビュー、生成Xcode設定、テーマ保存テストを確認。
- 既存の160×120手続き背景はXP/Vistaの細部とグラデーションを制限していた。
## Changes
- built-in image_genでオリジナル背景を2枚生成、1448×1086 PNGを原寸で保存。
- XPは青空/草の丘、Vistaは青緑の光/透明な層。プロンプトはdocs/theme-wallpapers.md。
- 共通Asset Catalogを本体・拡張・StorageTestsに同梱。高品質aspect fill表示。
- 上部を柔らかい暗色グラデーション、キーを細い枠/共通光沢/システム中太文字へ調整。
- カスタム背景色は色相ブレンドとして反映。アクセシビリティ時の装飾省略と欠落時の代替描画を維持。
## Files Changed
- DesignSystem/Assets.xcassets、DesignSystem/Theme/ThemeRendering.swift
- DesignSystem/Keyboard/FlickButton.swift、scripts/generate_project.py
- MyKeyboard.xcodeproj/project.pbxproj
- Tests/Integration/KeyboardPreviewTests.swift、Tests/Static/test_themes.py
- CURRENT.md、ARCHITECTURE.md、CODEMAP.md、docs/10-UI-UX-AND-THEMES.md、docs/theme-wallpapers.md
## Validation
- Fast/Full相当の文書検証、Python13テスト、生成設定一致確認成功（PowerShell未導入）。
- iOS26.5 arm64 Simulatorで素材の実解像度/描画/3配列/テーマ保存4テスト成功。
- arm64 Release本体・拡張ビルド成功。実際のキーと背景を重ねた画像を目視確認。
## Result
- 高解像度背景とネイティブキーを同じ描画で本体/拡張へ反映。
## Remaining Issues
- 実機更新と操作確認は未実施。4K素材ではない。
