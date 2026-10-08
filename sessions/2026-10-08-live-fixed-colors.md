# ライブ変換・固定サイズ・カラー編集
## Request
ライブ変換、下部の空白縮小、縦横とも高さ360/幅100%/間隔3固定、キー表現を現標準値固定としてカラーだけを編集。
## Changes
CoreのLiveTextSessionとUIKitアダプターでmarked textを更新。先頭の全文候補を反映し、確定時はunmark。外部文脈変更・document変更時は更新を停止。
確定・取消・削除・読み内カーソル移動・キーボード終了時の処理を更新。
独立した地球キー行を撤去し上へ移動。ヘッダー116pt、読み16pt、全体高さ360を指定。下端safe areaは維持。
旧保存値にかかわらず固定レイアウト・標準のキー表現を適用。サイズ/形状/画像の編集UIを撤去し4色のカラー編集だけにする。
過去の画像ファイルは削除しない。保存処理の互換コードも残す。
## Validation
Core16テスト成功（ライブ変換3テスト、固定サイズと表現の検証を含む）。
Simulatorの保存5件とUITextView marked text2件、計7統合テスト成功。
Python13構造・配色・SQLテスト成功。
最終版の署名付きDebug/Releaseビルド、codesignのdeep/strict検証、Vesperaへの更新インストール成功。
Simulatorで設定・カラー編集画面を目視確認。署名なしSimulator本体のApp Group警告は、実機共有試験とは区別。
生成一致、文書存在/リンク/行数の代替Verify、git diff --check成功。PowerShellの標準Verifyは未実行。
## Files Changed
Core/InputEngine/LiveTextSession.swift、Core/Layout/LayoutPreferences.swift、Core/Theme/ThemeTokens.swift
KeyboardExtension/KeyboardViewController.swift、KeyboardExtension/Input/DocumentProxyAdapter.swift
App/MyKeyboardApp.swift、App/Settings/SettingsView.swift、App/Theme/ThemeViews.swift
DesignSystem/Preview/KeyboardPreview.swift、DesignSystem/Theme/ThemeRendering.swift
Tests/Unit/LiveTextSessionTests.swift、Tests/Unit/KeyboardCoreTests.swift、Tests/Unit/ThemeTests.swift
Tests/Integration/LiveMarkedTextTests.swift、MyKeyboard.xcodeproj/project.pbxproj
CURRENT.md、ARCHITECTURE.md、CODEMAP.md、TESTING.md、関連docsと設計判断、この記録。
## Remaining Issues
実機の入力先ごとの通知・候補更新・確定/取消・カーソル/ホスト変更を網羅検証する必要がある。
