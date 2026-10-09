# キーが縦に伸びて欠ける問題への対策
## Request
実機でキーボードの配置が崩れ、キーが縦に伸びる。スクリーンショットで下段の画面外へのはみ出しを確認。
## Investigation
ルートは300ptを希望するが、キー配置の上下端はホストのsafe areaへ等号で接続されていた。
通常のUIKit高さテストは修正前でも成功。実機でホスト枠が広がる具体的な契機は未確定。
## Changes
キー配置に高さ292pt（300から上下余白を除いた値）の優先制約を追加。
下端はsafe area以内の不等号にし、大きいホスト枠へキーが追随して伸びる経路を抑止。
safe areaによる縮小は許容し、通常のキー寸法を保持。
優先度引数付きsystemLayoutSizeFittingも300ptを返すよう統一。
900ptのホスト枠でも12キーが44〜54ptで300pt内に収まる回帰テストを追加。
## Files Changed
KeyboardExtension/KeyboardViewController.swift、Tests/Integration/KeyboardLifecycleTests.swift、CURRENT.md、この記録。
## Validation
Fast/Full相当文書検査・Python13・生成設定一致は成功。PowerShell不在につき標準Verifyは未実行。
Simulatorの高さ・拡大枠・3モード各20回再表示の3テスト成功。
## Remaining Issues
実機でホストの枠が拡大した契機、修正版の見た目は本人確認待ち。

## Deployment
署名付きReleaseビルド・codesign検証成功。2026-10-09 23:56 JST、Vesperaへ修正版を更新インストール成功。

## Full verification follow-up
全統合実行でCharacterPickerTestsのセル取得によるUICollectionView例外を検出、単独再実行でも再現。
テストがdataSourceを直接呼んで表示要求外のdequeueをしていたため、表示中セルのcellForItem(at:)取得へ修正。
Tests/Integration/CharacterPickerTests.swiftも変更。製品の一覧処理には変更なし。
最終Simulator統合24テストすべて成功。文書Full相当・git diff --checkも成功。
