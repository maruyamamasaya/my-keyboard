# 夜空・90年代・Terminalのテーマ整理
## Request
- Blue Cosmosを星の多い青い夜空へ。
- Living Aurora/Pulse Neon/Windows 7を廃止。
- Windows 3.1/95/98の90年代イメージとドット感の文字、Terminalを追加。
- 全パレットのキー不透明度80%を維持。
## Investigation
- ThemeCatalog/ThemeSelection、共通背景/キー、ThemeStore、関連テストを確認。
## Changes
- Blue Cosmos: 深い青の背景とキー、180個の大小の固定配置の星。
- Windows 3.1/95を追加。98もCourier系文字/日本語フォールバックと1ptラスタライズでドット感。
- Terminal: 黒/緑の等幅文字、走査線、細い枠、光沢なし。
- 廃止3テーマの保存済みIDをBlue Cosmosへ移行。カスタム色/画像参照を保持。
- 最終カタログは9種類。全キー役割の不透明度80%をSimulatorで検証。
## Files Changed
- Core/Theme/ThemeTokens.swift、Storage/Preferences/ThemeStore.swift
- DesignSystem/Theme/ThemeRendering.swift、DesignSystem/Keyboard/FlickButton.swift
- App/Theme/ThemeViews.swift
- Tests/Unit/ThemeTests.swift、Tests/Integration/ThemeStoreTests.swift
- Tests/Integration/KeyboardPreviewTests.swift、Tests/Static/test_themes.py
- CURRENT.md、CODEMAP.md、docs/10-UI-UX-AND-THEMES.md
## Validation
- Core34、Python13、生成設定一致確認成功。
- iOS26.5 arm64 Simulator: 全9テーマの実不透明度/描画、3配列、保存/廃止テーマ移行の4テスト成功。
- arm64 Debugテストビルド/Release本体・拡張ビルド成功。
- Blue Cosmos/3.1/95/98/Terminalの実描画画像を目視確認。
- Fast/Full相当の文書検証成功。PowerShell未導入。
## Result
- 全9パレットの整理と夜空/90年代/Terminalの表現を実装。
## Remaining Issues
- 実機更新・実機上の文字のドット感/操作確認は未実施。
