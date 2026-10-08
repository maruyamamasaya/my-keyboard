# 絵文字・記号のカテゴリ一覧
## Request
Simejiを参考に絵文字の選択肢を増やし、記号も一覧画面で選べるようにする。
## Investigation
- Simeji公式ガイド https://simeji.me/guide とカテゴリ別一覧 https://simeji.me/kaomoji を参照。
- 既存は絵文字12個のキー、コード用記号フリック。入力はUIKit、ライブ変換はmarked text。
- カテゴリで豊富な表現を選ぶ操作を参考にした。Simejiの実アプリ画面の完全再現ではない。
## Changes
- Core/InputEngine/CharacterCatalog.swift: オフラインUnicodeカタログ、最近項目の重複除去/上限40件。
- 絵文字8カテゴリ758項目、記号7カテゴリ479項目（カテゴリ間の重複を含む収録項目数）。
- KeyboardExtension/Views/CharacterPickerView.swift: 絵文字/記号タブ、横カテゴリ・縦一覧、再利用UICollectionViewセル。
- 肌色違い・国旗・ZWJ絵文字、括弧ペア・URL等を分断せず選択/挿入。
- ☺/ツールバー絵文字、記号一覧/コード配列の一覧から開く。かな/ABC/記号キーへ戻れる。
- 開く際に既存の未確定入力を確定し、活動を停止。選択は直接挿入、一覧に留まって連続入力可能。
- 最近項目は絵文字/記号別にcontroller生存中のみ保持。共有保存や通信は追加していない。
- タップ空白/削除、既存の地球キー・閉じる操作・高さ300ptを維持。
- テーマ・透明度低減・高コントラストの描画に対応。
## Files Changed
- 上記Core/Extension、KeyboardViewController、Xcode生成設定、Core/UIテスト。
- CURRENT、ARCHITECTURE、CODEMAP、TESTING、docs/08-MAC-VALIDATION、docs/10-UI-UX-AND-THEMES、この記録。
## Validation
- Fast相当のPython文書検査成功。PowerShell未導入でverify.ps1は未実行。
- Swift Core 27テスト成功（最初のsandbox cache制限による失敗後、権限付きで再実行）。
- iPhone 15 Pro / iOS 17.4 Simulator Debugビルド・統合16テスト成功。
- 最近項目の配列復帰/分離・Unicode挿入・320/393/700pt幅を確認。
- 配色調整と画像出力後、CharacterPickerTests 2テストを再実行し成功。
- XCTest添付画像2枚を出力し、一覧/カテゴリ/下部操作の収まりを目視確認。
- 実機向け署名付きReleaseビルド成功、codesign検証成功。
- Python構造/配色/SQL 13テスト、生成一致、Full相当の文書リンク/行数検査、git diff --check成功。
## Result
実装とローカル検証を完了。今回のコード変更は上部ボタン整理とともにコミット・Push対象とした。続く依頼でRelease版をVesperaへ導入・本体起動済み。[導入記録](2026-10-09-character-picker-deploy.md)。
## Remaining Issues
- 実機のホスト入力・切替・回転・VoiceOver・最小幅での操作を確認する。
- 最近項目の永続保存、検索、肌色長押し選択、Unicode全件の網羅は未実装。
- 本体の静的プレビューは従来のかな/ABC/コード記号配列のみ。
