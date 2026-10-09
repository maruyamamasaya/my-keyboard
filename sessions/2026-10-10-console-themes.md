# 携帯ゲーム機・16bitゲーム機テーマ
## Request
- Game Boy、透明バイオレットのGame Boy Color、Super Famicomの配色を作る。
- 画像生成で、それぞれをイメージした内部基板と部品の背景を制作・実装する。
## Investigation
- ThemeCatalog/ThemeSelection、共通背景/キー、本体プレビュー、画像素材の同梱と関連テストを確認。
## Changes
- built-in image_genで基板背景を3枚生成し、各1448×1086の原寸PNGを共通Asset Catalogへ保存。
- Game Boyはオリーブの基板、グレー/緑/バーガンディ、ドット感の文字。
- Game Boy Color Violetは透明な紫の樹脂と内部部品、紫の半透明キーと光沢。
- Super Famicomは灰色キー、青/黄/緑/赤の操作キー、深緑の基板。
- 全12パレット、キー面80%、文字/アイコン不透明。画像に文字やキーは焼き込まない。
- 上部の明るい金属部品と白文字が重なる箇所を、暗いグラデーションで調整。
- 素材/最終プロンプトはdocs/console-board-assets.mdに記録。
## Files Changed
- Core/Theme/ThemeTokens.swift、DesignSystem/Assets.xcassets
- DesignSystem/Theme/ThemeRendering.swift、DesignSystem/Keyboard/FlickButton.swift
- App/Theme/ThemeViews.swift
- CURRENT.md、CODEMAP.md、docs/10-UI-UX-AND-THEMES.md、docs/console-board-assets.md
## Validation
- Core34、Python13、生成設定一致確認成功。
- iOS26.5 arm64 Simulatorの全12テーマ/実不透明度/3配列/保存の4テスト成功。
- arm64 Debugテストビルド/Release本体・拡張ビルド成功。
- Game Boy/Game Boy Color Violet/Super Famicomの実描画を目視確認。
- Fast/Full相当の文書検証成功。PowerShell未導入。
- 上部の陰影調整後も全12テーマ描画テスト成功、最終画像を目視確認。
## Result
- オリジナルの内部基板背景とネイティブキーを組み合わせた3テーマを追加。
## Remaining Issues
- 実機更新・実機上の操作/メモリ確認は未実施。
