# 振動しない実機報告の調査
## Request
入力時の振動をONにしても振動しない。
## Investigation
- 設定値と文字入力からの呼び出し経路は存在する。
- Apple SDKでiOS17.5以降のviewに接続するGenerator APIを確認。旧生成方法は置換推奨。
- フルアクセス設定のON/OFFをユーザーへ確認中。端末接続は確認できたが振動発生の実測はできない。
- 旧Generatorが原因とはまだ確定していない。
## Changes
- iOS17.5以降は表示されたviewへGeneratorを接続。iOS17.0〜17.4は旧APIを維持。
- 表示後に準備し、非表示・再表示時に古いinteractionを外して生成し直す。
- lightの強度を0.35→0.5へ調整。入力ごと1回は維持。
- 個人の入力内容を含まないフルアクセス状態のログをGenerator生成時に追加。
- 本体設定にSwiftUIの「振動を試す」ボタンとフルアクセス設定への案内を追加。
## Files Changed
KeyboardExtension/KeyboardViewController.swift、App/Settings/SettingsView.swift、CURRENT、UI/UX、Mac検証手順、この記録。
## Validation
- iOS17.4 Debugビルド・統合21テスト成功。最終の後片付け変更はiOS26.5で検証する。
- iOS26.5の対象7テストと最終Debugビルド、署名付き実機Releaseビルド、codesign検証成功。Vesperaへ更新インストール成功。Python13テスト、生成一致、Full相当文書検査、git diff --check成功。PowerShell未導入で標準Verifyは未実行。
- Coreロジックに変更なし。前回Core34テスト成功を引き継ぐ。
## Result
2026-10-09 22:42 JST、修正版をVesperaへ更新・本体起動成功。実機での振動改善は未確認。
## Remaining Issues
フルアクセス設定と本体テスト/キーボードでの振動結果を本人確認する必要がある。Simulatorは物理振動を検証できない。
