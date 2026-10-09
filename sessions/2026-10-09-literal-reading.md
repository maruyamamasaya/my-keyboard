# 読みの文字種変換と英字左列の入れ替え
## Request
ライブ変換を維持し、カーソル横からかな・カナ・ローマ字を選ぶ。英字左列のあAと☆123を入れ替え、あAを縦2段にする。
## Investigation
- composition.readingに元の読みを保持。既存commit経路でmarked textを確定できる。
- 英字左列は3キーで最下段だけ2段分。枠の寸法を変えず機能を入れ替える。
## Changes
- 上部にかな・カナ・ローマ字を追加。未確定の読み全体を指定形式で確定する。読みなしは何もしない。
- ローマ字はFoundationのかな→Latin変換後に発音記号を除去。か→ka、がっこう→gakkou、きょう→kyou。
- 通常の候補更新とライブ変換は維持。文字種の固定モードではなく、その入力の確定操作。
- 英字左列を→・☆123・縦2段あAへ変更。本体プレビューも同期。
## Files Changed
- KeyboardExtension/KeyboardViewController.swift、Core/InputEngine/Composition.swift
- DesignSystem/Preview/KeyboardPreview.swift
- Tests/Unit/KeyboardCoreTests.swift、Tests/Integration/CharacterPickerTests.swift
- CURRENT、UI/UX、Mac検証手順、この記録。
## Validation
- Core28テスト成功（ローマ字・かな/カナの検証を追加）。
- Simulator Debugビルド成功、iOS17.4の統合16テスト成功。
- 英字あAの2段寸法・位置、数字/かな切替、3変換ボタンの存在と読みなし操作を確認。
- iOS26.5では既存のUICollectionViewテストの直接dequeueと入力欄テストが異常終了。今回の変更によるものかは未確定。iOS17.4へ切り替えて確認。
- Python13テスト、生成設定一致、Fast相当の必須文書/行数確認は成功。
- PowerShell未導入のためverify.ps1は未実行。文書リンクはPython代替で確認する。
## Result
実装完了。Simulator Releaseビルド成功。最終のFull相当文書リンク/行数検査、生成設定一致、git diff --check成功。
## Remaining Issues
実機への更新インストールと実機ホスト上の操作確認は未実施。iOS26.5の既存統合テスト異常終了は別途調査が必要。
