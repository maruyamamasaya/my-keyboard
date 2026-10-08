# Macでの検証手順

## 1. 必要環境と取得
- Swift 6.1以上を含むXcode（例: Xcode 16.3以降。実際のSDK・端末対応を確認）。iOS 17以上のSimulatorとiPhone。
- Python 3、Git、実機署名に使うApple ID/チーム。公開配布の準備は別途行う。
- 現在はremote・Push未設定。フォルダーをMacへコピーするか、ユーザーがremoteへ保存した後にcloneする。取得先URLを仮定しない。

```bash
cd /path/to/my-keyboard
xcodebuild -version
xcrun swift --version
python3 -m unittest discover -s Tests/Static -v
swift test
open MyKeyboard.xcodeproj
```
既存のプロジェクトはPythonで生成済み。ソース追加や生成設定変更時は `python3 scripts/generate_project.py`、一致確認のみなら `--check`。
`Config/Project.xcconfig` は手動編集する正本。生成スクリプトはこのファイルを上書きしない。

## 2. 依存解決とリソース
```bash
xcodebuild -resolvePackageDependencies -project MyKeyboard.xcodeproj -scheme MyKeyboard
xcodebuild -list -project MyKeyboard.xcodeproj
```
ExtensionにAzooKeyKanaKanjiConverterのcommit `8278b6b76e534f1a08e4db2a11602f499d754327`（v0.8.5）と標準辞書付きproductを設定済み。
初回依存解決にはネット接続が必要だが、アプリ実行時の通信は不要という設計。
Package.resolvedが生成されたら採用版・推移依存・ライセンスを確認して管理する。解決済みと捏造したlockfileは作成していない。
辞書・絵文字辞書のサブモジュール資源がSPM checkoutと製品bundleに存在するか確認する。欠落時はpackage取得方式を調査し、通信で実行中に補完しない。
Zenzaiは有効にしない。tokenizers等やbinary targetの解決・リンク状況も確認する。

## 3. Signing & Capabilities
`Config/Project.xcconfig` の例示IDを、自分の固有bundle IDと `group.` で始まるApp Groupへ変更し、DEVELOPMENT_TEAMを設定する。
AppとExtensionのSigning & Capabilitiesで同じチーム・App Groups登録が反映されることを確認する。
Extensionのbundle IDは本体ID＋`.keyboard`。Info.plistのSharedAppGroupと両entitlementsは同じ変数を参照する。
macOSのDeveloper Portal/Xcodeでグループを登録し、プロビジョニングに含まれることを確認する。
RequestsOpenAccessはtrueだが、本人がフルアクセスを拒否しても基本入力を維持する。

## 4. ビルドと単体・保存テスト
Simulator名やUDIDは `xcrun simctl list devices available` で実在するものを選ぶ。
```bash
xcrun simctl list devices available
xcodebuild -project MyKeyboard.xcodeproj -scheme MyKeyboard -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project MyKeyboard.xcodeproj -scheme MyKeyboard -configuration Release -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
# Replace SIMULATOR_UDID with an actual value from simctl.
xcodebuild -project MyKeyboard.xcodeproj -scheme MyKeyboard -destination 'platform=iOS Simulator,id=SIMULATOR_UDID' CODE_SIGNING_ALLOWED=NO test
```
Apple SiliconのSimulatorでx86_64リンク失敗が出る場合は、上のtestに `ONLY_ACTIVE_ARCH=YES ARCHS=arm64` を追加して検証する。

`swift test` は共通ロジック・テーマ・ライブ変換・単語再変換・英語配列・技術用記号の24テスト。schemeのStorageTestsはSQLite Swiftラッパー・テーマ保存・UIKit marked textの13テスト。Pythonテストはこれらを代替しない。
テストbundleのschema.sql存在を確認。Resources/PrivacyInfo.xcprivacy、ThirdPartyNotices.txtが本体と拡張に含まれることも確認する。
ビルドエラーはT-001等へ記録し、修正後に同じ構成で再実行する。

## 5. iPhoneへの導入・有効化
Xcodeで本体schemeと接続したiPhoneを選びRun。必要なら端末のDeveloper Mode・署名信頼を設定する。
設定 → 一般 → キーボード → キーボード → 新しいキーボードを追加 → MyKeyboard。
まずフルアクセスOFFで地球キー・入力・変換を検証。次に履歴試験のためONにし、OFFへ戻した際も基本入力を確認する。
パスワード・電話欄で標準キーボードへ戻ること、ホストが拒否するケースを確認する。

## 6. 日本語入力・編集
- 「あいうえお」「がっこう」「きょうはいいてんき」を各方向のflickと濁点/小書きで入力。候補→確定・取消・かな/カタカナを確認。
- ABCのフリック、⇧、数字、記号、空白、改行、地球キーを確認。toolbarは横スクロール可能。
- 本体の入力テスト画面、メモ、Safari等でUITextField/TextView/Web欄の互換性を比較。
- ライブ変換の更新・確定・取消、候補既定非表示・目アイコン切替を確認する。再変換→左右で単語選択→候補タップ→Enterで全体確定し、周囲の本文と他の単語が保たれることを確認する。
- ⌫長押し→離指→別ホストで削除が止まる。スペースdrag後に余計な空白が入らない。
- 本体で単語を追加/編集/削除し、拡張を開き直して完全一致読みの候補を確認。学習ON/OFFとリセットを試す。
- 再変換・語削除は既定無効。非個人情報の試験環境でのみ `Config/MyKeyboardExtension-Info.plist` のEnableExperimentalHostReplacementを一時trueへ変更し、T-009を実施する。生成スクリプトの再実行はfalseへ戻す。
- 部分削除が生じる場合は不具合として記録し、無効のまま正式操作の方式を再設計する。

## 7. レイアウト・アクセシビリティ
縦横とも高さ360・幅100%・間隔3の固定配置を確認し、カラーを変更する。
回転・再起動・共有設定読取失敗を確認。ホスト制約で実高さが指定値と異なる可能性を評価する。
最小キー高さ・制約warning・safe area・画面外表示を測定。VoiceOverのカスタムアクションで各かなを選べるか、候補全文が読めるか確認する。

## 8. クリップボード
本体の設定で手動履歴を有効化。他アプリで架空の文をコピー→本体のシステムPasteControl→プレビュー→保存/取消。
履歴で完全一致重複、pin、文字列検索、1件削除、確認付き全削除を試す。
拡張はフルアクセスONで「履歴」→「取り込む」→OS許可→内容確認→保存。拒否・空・非テキスト・16KB超過も確認する。
拡張の「読みに一致」は、開く前の未確定読みを検索語に使用する。本体では任意文字列検索が可能。
選択した1件だけホストへ挿入されることを確認。上限をピンで埋めると新規保存を拒否する。学習と履歴のローカル保護、ロック中の失敗、プロセス間のDB更新を試験する。
拡張の貼付許可が成立しなければ、本体取込のみを正式経路に変更してT-013へ記録する。

## 9. オフラインと品質
依存解決・インストール後、機内モードで初回起動・かな漢字変換・辞書・設定・履歴を確認。
Releaseで通信・ログを監査。Debug版OSSは本文debug出力があり、実データを使わない。
Instrumentsで冷起動・候補遅延・ピークメモリ・連続入力・拡張終了復帰を測定。lastLatencyMillisecondsは変換部分のみで、描画を含む入力遅延とは別。
Privacy Reportと推移依存の全ライセンス、絵文字由来のUnicode/Mozc表示、アイコン・配布要件を整えてからArchive/配布へ進む。

## 10. テーマの検証（T-020〜023）
1. 最初に `swift test` とDebug/Releaseビルド、StorageTestsのThemeStoreTestsを実行する。
2. 新規インストールでBlue Cosmosを確認。以前のsystem/light/dark設定をそれぞれ読み、レイアウト・辞書・履歴の保持を確認する。
3. ホーム→テーマギャラリーで5種類を比較・適用。テーマ編集で背景/キー/文字/アクセント、角丸・不透明度・枠線・影を変更し、保存・未保存の戻る・初期化を確認する。
4. 本体を再起動し、拡張を開き直して反映を確認。フルアクセスON/OFFと保護データ不可の条件で、画像なしの基本入力も試す。選択JSONの破損・未知スキーマはテスト用データで確認する。
5. 機内モードで「このiPhone内」の画像を選択。JPEG/PNG/HEIC・回転・透過、壊れた/巨大画像・複数フレーム・未取得iCloudを試す。保存画像の長辺≤1024px、サイズ≤1MB、Exif/GPSなし、保護属性・バックアップ除外を確認する。
6. 20画像上限、未使用画像の明示削除、画像を外す、JSON保存失敗時の旧設定保持を確認。OSの外部プロバイダーはアプリと独立するため、通信禁止試験は端末内ファイルに限定する。
7. プレビューの縦横設定・高さ・幅・間隔・左右配置を比較し、実キーボードでも測定。候補/読み/履歴/地球キー/押下/ガイドの表示と既存のフリック・削除・cursor・変換を全テーマで確認する。
8. Reduce Motion、透明度低減、高コントラスト、VoiceOver、最大文字サイズ、白黒同色の編集、画像ありを試す。キーの読みやすさと44ptの操作領域を確認する。
9. Instrumentsで画像なし/あり・各テーマの起動時間、連続入力、メモリを比較。memory warningで画像を解放し、次回表示時に再読込することを確認する。実測後に性能目標を決める。

## 11. 不具合の記録
[課題表](07-TESTING-AND-ISSUES.md) のIDへ、Xcode/OS/端末、権限設定、ホスト、入力手順、期待/実際、再現率を記録する。
ログに個人情報を含めない。ビルド/型エラー、辞書資源欠落、共有ID・署名、Auto Layout warning、DB error codeを確認する。
検証したIDだけを「検証済み」に更新し、アプリ全体の確認完了とは混同しない。
