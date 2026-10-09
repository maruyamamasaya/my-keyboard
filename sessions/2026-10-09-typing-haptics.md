# 入力時の軽い振動
## Request
文字入力時に小さな振動のフィードバックを追加。
## Investigation
FlickButtonのonCommitはタップ/フリック確定/VoiceOverの共通入力入口。移動や取消では呼ばれない。本体が設定保存、拡張が再表示時に読み込む既存経路を利用。
## Changes
- controllerでUIImpactFeedbackGenerator(light/intensity 0.35)を再利用し、入力受理時に1回鳴らす。
- かな/英字/数字/記号、濁点/小文字変更、一覧文字、空白・実行キーを対象。
- フリック移動/取消、空白ドラッグ、変換更新の再描画では鳴らさない。
- 設定→入力の感触→入力時に軽く振動を追加。既定ON、旧設定は他項目を保持してONへ移行。OFFを保存可能。
## Files Changed
Core/Layout/LayoutPreferences.swift、App/Settings/SettingsView.swift、KeyboardExtension/KeyboardViewController.swift、Tests/Unit/KeyboardCoreTests.swift、CURRENT、TESTING、UI/UX、Mac検証手順、この記録。
## Validation
- Core34テスト成功。旧設定移行・OFF保存・他の設定保持を確認。
- Simulator Debugビルド・統合21テスト、署名付き実機Releaseビルド成功。codesign --verify --deep --strict成功。
- 振動の強さ/発生有無はSimulatorでは確認不可。実機で本人確認が必要。
## Result
2026-10-09 22:33 JST、Vesperaへ更新インストール・本体起動成功。Python13テスト、生成設定一致、Fast/Full相当の文書リンク・行数検査、git diff --check成功。PowerShell未導入のため標準Verifyは未実行。
## Remaining Issues
振動の体感とフルアクセスOFF/ON、端末の振動設定との組み合わせは未検証。
