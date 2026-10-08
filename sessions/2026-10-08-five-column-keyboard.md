# 5列キーボードと役割別デザイン
## Request
添付画像の配置を実装し、派手なデザインへ調整。追加指示で上の画面との境界と、Enterなど各ボタンの役割を見た目で区別。
## Investigation
KeyboardViewController、FlickButton、共通プレビューとテーマ描画、関連Core/Storageテストを確認。
Simeji公式のボタンデザイン紹介（2019年）を表現の参考として参照。現在の仕様の確認とは区別。
https://simeji.me/blog/news/originalkeybord_newbutton_1/id=20269
## Changes
中央3列×4段、左の入力モード4個、右の削除/空白/2段分の実行キー、上の編集ツール、下の地球キーに配置。
かな/英字/数字/記号に加え固定12個の絵文字を提供。濁点・小文字、削除長押し、空白ドラッグは維持。
実行キーは未確定中に確定、その他は改行を挿入。表示はホストのreturnKeyTypeを参照。
文字キー、暗い補助面、枠なしアイコン、青い光沢と影の実行キーで役割を区別。
Blue Cosmos配色・角丸・静的な光を更新。本体の共通プレビューも新配置へ変更。
背景は全幅で描画し上端の線で境界を整える。外側角丸カードは追加しない。iOSが付けるホスト側の角丸は制御しない。
44ptの行高さを確保する最小高さを適用。読み・地球キー非表示時の固定制約は優先度を下げる。
## Files Changed
KeyboardExtension/KeyboardViewController.swift、KeyboardExtension/UI/FlickButton.swift
DesignSystem/Preview/KeyboardPreview.swift、DesignSystem/Theme/ThemeRendering.swift
Core/Theme/ThemeTokens.swift、Tests/Unit/ThemeTests.swift
docs/10-UI-UX-AND-THEMES.md、CURRENT.md、この記録。
## Validation
最終版の署名付き実機Debug/Releaseビルド成功。Vesperaへ更新インストール、本体起動成功。
Python13テスト、Core12テスト、Storage5テスト成功。StorageはONLY_ACTIVE_ARCH=YES ARCHS=arm64で実行。
既定のSimulatorテストはx86_64のCoreリンク失敗。並行ビルドのDBロックも発生したため、ビルドを直列化して再試験。
UIKitのrole名衝突をkeyRoleに修正、標準テーマ変更に追随する既存期待値を更新。
Simulator本体の5列プレビューを目視確認。署名なしSimulatorでは共有領域の警告が出るため、共有の実機確認とは区別。
生成設定一致、文書存在/リンク/行数の代替検査、git diff --check成功。PowerShellがないため標準Verifyは未実行。
## Remaining Issues
実機ホストとの境界、フリック、長押し、入力先ごとの実行結果、幅/高さ最小設定、VoiceOverの網羅検証は未実施。
既存カスタムテーマは保持するため、標準の新配色確認にはBlue Cosmosプリセットの適用が必要な場合がある。
