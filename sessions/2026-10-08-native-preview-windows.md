# 本体プレビュー差し替え・Windows風テーマ

## Request
本体の外観プレビューを実キーボードに合わせ、Windows 98/XP/Vista/7風テーマを追加する。

## Investigation
従来のSwiftUIプレビューはキー間隔・役割・字体・配列がExtensionのUIKit実装と異なっていた。ThemeSelectionは全プリセットの形状をBlue Cosmosへ固定していた。

## Changes
- FlickButtonをDesignSystem/Keyboardへ移し、AppとExtensionで同じキー部品を利用。
- 上下余白・候補32・ツールバー36・区切り4をKeyboardGeometryで共有。高さ300、キー間隔3は維持。
- 本体プレビューをUIKitへ差し替え。候補1行、横スクロールのツールバー、右上の閉じる操作、5列と縦長Enter、実際の書体・フリックガイドを表示。
- 専用プレビューにかな/ABC/記号の配列切替を追加。入力操作は行わない。
- Windows 98の青緑/灰色、XPの青/クリーム/緑、Vistaの暗いガラス風、7の明るいAero風を追加。計9プリセット。
- Windows風はプリセットの形状を固定。カラー編集は従来通り。既存5テーマの描画設定・入力変換処理は維持。

## Validation
- Swift Core: 25テスト成功。
- Simulator統合: 14テスト成功。ネイティブプレビュー3配列のキー内容・表示寸法・形状を含む。
- Python構造/配色/SQL: 13テスト成功。生成設定一致・文書代替Verify・diff検査成功。
- 署名付きDebug/ReleaseのiOSビルド成功、codesign検証成功。
- Simulatorで本体ホーム・カラーパレットのネイティブプレビューを目視確認。Windows各カードの目視確認は未完了。
- Release版をVesperaへ更新。インストール成功は入力動作・テーマ切替の実機検証を意味しない。

## Remaining Issues
- Vesperaで4テーマの選択、3配列のプレビューとキーボード比較、読みやすさを確認する。
- iOSが表示する地球/音声フッターはアプリの静的プレビューに含めない。
- 既存のキーボード切替後非表示問題の実機検証は別途継続。
