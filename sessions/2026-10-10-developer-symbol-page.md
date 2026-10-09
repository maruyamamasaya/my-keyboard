# 開発者向け記号2ページ目
## Request
完成済み記号1を維持し、一覧ではなく記号2へ1→2→1で切り替える。
## Investigation
記号1はFlickMap.engineeringSymbols、左上ボタンは記号一覧mode 5を開いていた。
絵文字画面には既に記号一覧タブがあり、一覧はそこから引き続き利用できる。
## Changes
- mode 6に12キー×5方向のMarkdown/コード演算子/シェル断片を追加。
- 左上は記号2/記号1へ循環。本体プレビューに記号2を追加。
- 見出し/リストの末尾空白、言語付きコードフェンスの改行をそのまま挿入。
- ペア構文は文字列をそのまま挿入し、カーソルは末尾に置く。
## Files Changed
- Core/InputEngine/FlickMap.swift
- KeyboardExtension/KeyboardViewController.swift
- DesignSystem/Preview/KeyboardPreview.swift
- Tests/Unit/KeyboardCoreTests.swift
- Tests/Integration/CharacterPickerTests.swift
- Tests/Integration/KeyboardPreviewTests.swift
- CURRENT.md、docs/08-MAC-VALIDATION.md
## Validation
- Fast/Full文書検証はpwsh不在のため既存Python代替を使用。
- 生成設定一致、Python13テスト、Swift35テスト成功。
- Release Simulatorビルド成功。iOS26.5の一覧/循環/4配列プレビュー3テスト成功。
- UIテスト初回は同時ビルドによるDBロックで失敗、ビルド完了後の再実行で成功。
## Remaining Issues
一覧描画テストでCoreGraphicsのNaN警告あり（テスト失敗なし）。署名付きReleaseビルド・codesign検証・Vesperaへの更新インストール・本体起動成功。実機入力操作は本人確認待ち。絵文字と記号一覧の追加再設計は今回の範囲外。
