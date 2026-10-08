# リスクと制約

## iOSの入力制約
- パスワード等のsecure text欄、phonePad / namePhonePadではシステムキーボードに置き換わる。ホストはCustom Keyboard全体を拒否できる。
- 拡張はホストの編集メニュー・全文・任意選択範囲を自由に操作できない。キーの表示は拡張の領域内に収める。
- 現行UITextDocumentProxyはselectedTextとmarked textを提供する。古いガイドだけから「選択文字は一切取得不可」「marked text不可」と解釈しない。
- 本体から標準日本語辞書・標準変換エンジンを公開APIで呼べるという前提を置かない。

出典: [Apple旧ガイド（アーカイブ）](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)、[現行Proxy](https://developer.apple.com/documentation/uikit/uitextdocumentproxy)。旧資料と現行APIに差がある部分は現行資料と対象OSの実機結果を優先する。

## フルアクセスとオフライン
| 状態 | 設計上の動作 |
| --- | --- |
| フルアクセスなし | 同梱辞書・基本入力、拡張専用コンテナの学習。共有設定は読取試験後に使用 |
| フルアクセスあり | 任意の共有保存・履歴機能。ネットワーク機能は追加しない |
| 権限取消・共有保存失敗 | 拡張機能を停止し、基本入力を維持。共有データを別場所へ自動複製しない |

フルアクセスはネットワーク等の能力も開くが、通信実装を必要とするものではない。ユーザーにはローカル共有・履歴の用途と、OS表示が示す権限範囲を説明する。
共有領域の読み取りと書き込みを区別する。[現行Apple資料](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard)

## クリップボード
- 他アプリで連続コピーされた内容を常時監視して自動収集する通常の仕組みはない。拡張は常駐せず、changeCountや変更通知は過去履歴の回収手段ではない。
- 起動時・キー入力ごとの本文取得は行わない。本人の「取り込む」操作で現在のテキストだけ取得し、保存前に確認する。
- Appleアーカイブ資料は拡張のUIPasteboard利用をopen accessの能力として説明する。拡張内取込はフルアクセス有効時のみを設計前提とし、対象OSで確認する。
- iOS 16以降の他アプリ由来のプログラム的貼付にはOSの確認が関係する。フルアクセスと貼付の許可は別であり、前者で後者が不要になるとは説明しない。
- 本体ではUIPasteControlを優先する。Extension内の同制御と許可UIが同様に動くかは未検証であり、動作保証しない。
- 許可拒否・非テキスト・空内容では保存せず、説明と再操作手段を用意する。
- 履歴項目の挿入はtextDocumentProxy.insertTextを使い、一般pasteboardに書き戻す必要をなくす。
- OSのUniversal Clipboardやバックアップはアプリ独自通信と別。自アプリがpasteboardへ書く機能を追加する場合はlocalOnlyを指定し、他アプリのコピー元の同期を制御できるとは約束しない。

出典: [open access旧ガイド](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)、[UIPasteControl](https://developer.apple.com/documentation/uikit/uipastecontrol)、[UIPasteboard](https://developer.apple.com/documentation/uikit/uipasteboard)、[localOnly](https://developer.apple.com/documentation/uikit/uipasteboard/optionskey)。

## 漢字変換・編集・性能
- 日本語の語境界・固有名詞・連文節・混在入力には評価コーパスが必要。標準IMEと同じ候補順や同じ品質は保証しない。
- 再変換は読みに戻す情報と安全な置換範囲が必要。全文取得や無条件な後方削除で代用しない。
- 文脈がnil／部分的、選択が変わった、別ホストへ移った場合は高度な編集を無効化する。
- Unicodeの書記素・UTF-16 range・Proxyの移動単位は同一とみなさず、結合文字・絵文字・改行を実機試験する。
- キーボードの固定メモリ上限を普遍的な数値として記載しない。端末・OS・ホスト・辞書条件で終了を観測し、余裕を持った実測基準を設ける。
- 高負荷なら候補数・計算量・キャッシュ・入力長を制限し、通常入力を止めない。ニューラル変換は後から評価する。
- 拡張終了時の保存完了を当てにせず、短いトランザクションと復旧可能な形式を使う。

## 未確定事項と検証計画
| 未確定事項 | フェーズ・検証方法 | 判断条件 |
| --- | --- | --- |
| Mac・Xcode・署名環境 | 1: 実機導入 | 本体・拡張をインストール可能。現在の作業環境はWindows |
| 最低OS・OSS固定版 | 1〜2: タグのmanifest・依存・APIを確認 | iOS 17案と矛盾せず実機動作。必要ならOS方針を更新 |
| marked text方式 | 2: UITextField / UITextView / Web入力・代表アプリを比較 | 未確定表示・取消・確定で二重入力や文字消失がない |
| shared UserDefaults・辞書の読取 | 1〜2: フルアクセスON/OFFで本体更新→拡張復帰 | 読取不可時にも既定値で入力できる |
| エンジンの学習保存・副作用 | 2〜3: 固定版ソースとファイル生成を確認 | 拡張コンテナ内で完結し共有領域の書込を必須にしない |
| 遅延・メモリ予算 | 2: 下限候補端末で冷起動・長文・連続入力を測定 | p95・ピークを記録し、受け入れ目標を決定 |
| 再変換・単語削除 | 3: 文脈変更・選択・絵文字・ホスト切替 | 不明な範囲を削除しない。不可時は安全に拒否 |
| 高さ・縦横レイアウト | 4: 複数端末サイズ・回転・文字拡大 | はみ出しや操作不能がない |
| Extension内の取込と貼付許可 | 5: フルアクセス×貼付許可の組合せ | 拒否でも基本入力可能。本体取込の代替経路が成立 |
| SQLite共有と保護 | 5: 同時読書込・中断・migration・ロックを再現 | 破損・無限待機を起こさず保護データ不可を処理 |
| 履歴上限・追加暗号化 | 5: 脅威モデルと容量・検索を評価 | 件数・期間・容量・ピンの上限、削除方針を確定 |
| OSS表示・Privacy manifest・配布 | 6: 固定版の資源とRequired Reason APIを棚卸し | 実装と申告が一致し、第三者許諾を確認 |

## リリース時の再確認
基本入力がフルアクセスなしで使用できること、地球キー、プライバシー説明を確認する。
配布時点の [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)（キーボード拡張・プライバシー）を再確認する。今回の調査は審査通過を保証しない。
