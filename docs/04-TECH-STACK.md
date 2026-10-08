# 技術構成と調査

## 調査条件
確認日: 2026-10-08。設計時はmain、実装時はv0.8.5を取得してmanifest・公開API・学習保存・ライセンスを確認した。ビルド・実機・メモリ測定は未実施。
リンク先mainは可変。採用時にはタグ／commitとPackage.resolved、同梱辞書版を固定し、差分・ライセンス・依存を再確認する。

## Apple技術
| 技術 | 確認内容・採用方針 | 一次資料 |
| --- | --- | --- |
| Custom Keyboard Extension | 別プロセスで他アプリへ入力。本体と分離して採用 | [作成ガイド](https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard) |
| UIInputViewController | inputView、textDocumentProxy、地球キー、hasFullAccessを制御。拡張のUIKit入口 | [API](https://developer.apple.com/documentation/uikit/uiinputviewcontroller) |
| UITextDocumentProxy | insert/delete、前後文脈、selectedText、位置移動、marked text。本体全文への自由なアクセスは前提にしない | [API](https://developer.apple.com/documentation/uikit/uitextdocumentproxy)、[編集ガイド](https://developer.apple.com/documentation/uikit/handling-text-interactions-in-custom-keyboards) |
| App Groups | 本体と拡張に共通entitlement。共有コンテナと設定を利用 | [設定](https://developer.apple.com/documentation/xcode/configuring-app-groups) |
| UserDefaults | suiteNameで共有一般設定。本文・機微情報の保管には使わない | [suiteName](https://developer.apple.com/documentation/foundation/userdefaults/init(suitename:)) |
| SQLite | 履歴の局所検索と明示的なトランザクション。Phase 5の推奨候補 | [WAL](https://www.sqlite.org/wal.html) |
| SwiftData | App Group設定が可能。採用時はCloudKitを明示的に無効化。今回の拡張共有DBには第一候補にしない | [GroupContainer](https://developer.apple.com/documentation/swiftdata/modelconfiguration/groupcontainer-swift.struct)、[同期設定](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices) |
| UIPasteboard / UIPasteControl | 手動取込。本文取得にはユーザー意図・OS許可を考慮。本体でシステムPasteControlを優先 | [Pasteboard](https://developer.apple.com/documentation/uikit/uipasteboard)、[PasteControl](https://developer.apple.com/documentation/uikit/uipastecontrol) |

Swift / SwiftUI / UIKitを採用する。ジェスチャーと入力先制御はUIKit、設定画面はSwiftUIが推奨。候補UIのSwiftUI併用は実機負荷を見て決める。
SQLiteの標準C APIから始める案とSwiftラッパー導入を比較し、Phase 5で保守コストを判断する。今回は導入しない。

## OSS比較
| 候補 | 利用可能な要素・オフライン | ライセンス・依存 | 拡張適合性・導入保守 |
| --- | --- | --- | --- |
| azooKey全体のfork | 日本語入力UI、ライブ変換、カスタマイズの既存実装を再利用可能。fork後の通信・同梱資源監査は別途必要 | アプリコードMIT。サブモジュールあり。付属資源・推移依存は別ライセンス確認が必要 | iOSキーボードの既存実装が利点。独自UI・設定との差分が増え、上流追従範囲が広い |
| AzooKeyKanaKanjiConverter単体 | かな漢字変換、候補、入力状態API、学習。辞書を同梱しローカル変換する構成が可能 | コードMIT。標準辞書リポジトリはApache-2.0。Packageの外部依存あり | azooKey向けエンジン。UIは自作が必要。境界をアダプターに限定できる。1.0未満の破壊的変更へ対策が必要 |
| macSKK | SwiftのSKK入力・辞書処理を参考にできる。サードパーティライブラリ不使用と説明 | GPL v3以降。辞書は別確認 | macOS用でiOS拡張の部品として即導入できる根拠はない。SKK操作は通常の連文節フリック変換と異なる。移植・配布条件の検討が必要 |

出典: [azooKey README](https://github.com/azooKey/azooKey)、[アプリLICENSE](https://github.com/azooKey/azooKey/blob/main/LICENSE)、[変換器README](https://github.com/azooKey/AzooKeyKanaKanjiConverter)、[変換器LICENSE](https://github.com/azooKey/AzooKeyKanaKanjiConverter/blob/main/LICENSE)、[辞書](https://github.com/azooKey/azooKey_dictionary_storage)、[macSKK](https://github.com/mtgto/macSKK)。
macSKKは代替方式の比較対象であり、iOS用の汎用Swift変換ライブラリとして確認したものではない。

## 変換器の版・依存に関する重要事項
- READMEはiOS 16以降・Swift 6.1以上と記載するが、閲覧したmainのPackage.swiftはiOS 17を宣言している。最低OSはREADMEだけで確定しない。
- 暫定対応OSはiOS 17以降。採用タグのmanifestと実機を確認して確定する。READMEの導入例の0.8.0を最新安定版とは断定しない。
- manifestにswift-algorithms、swift-collections、swift-argument-parser、swift-tokenizers、条件付きSwiftyMarisaがある。通常変換のtargetにもEfficientNGram依存があり、ニューラル無効でも依存ゼロではない。
- Zenzai / ZenzaiCPU traitでllama.cpp依存が有効になる。既定traitは空。binary targetの定義もあるため、無効時にどの資源を解決・取得・リンクするかは実ビルドで確認する。
- Package解決時のダウンロードと製品の実行時通信を区別する。製品は初回起動から通信不要とする。
- 標準辞書・絵文字辞書のリソースが含まれる。コードのMITを全資源の許諾と解釈しない。各辞書の著作権表示・NOTICEと推移依存を配布前に棚卸しする。

出典: [Package.swift](https://github.com/azooKey/AzooKeyKanaKanjiConverter/blob/main/Package.swift)、[学習データ仕様](https://github.com/azooKey/AzooKeyKanaKanjiConverter/blob/main/Docs/learning_data.md)。

## 推奨構成と理由
**推奨（実機確認前）:** 新規の薄い本体・Extension + AzooKeyKanaKanjiConverterの標準辞書付き通常変換。
自作する範囲をフリック・修正・レイアウトに集中し、変換アルゴリズムと辞書を再発明しない。全体forkより独自設定の設計自由度が高く、上流差分を変換境界に限定できる。
ニューラル変換・ライブ変換は初期必須にしない。必要なら品質評価とメモリ余裕を確認して追加する。

全体forkは基本UIまでそのまま再利用する場合の有力代替。単体プロトタイプが実装負荷・品質の基準を満たさない場合に再比較する。
採用前に固定版の辞書同梱、Extension安全性、権限なし保存、性能、学習の動作を確認し、通らなければ選定を更新する。

## 性能と更新方針
比較可能なiPhone Extension条件での測定値は今回取得していない。アプリ公開実績から本プロジェクトの性能保証はできない。
通常変換とニューラル変換の冷起動・ピークメモリ・候補遅延を分けて測定する。具体的な性能目標はPhase 2で設定する。
更新は固定版から小さく行い、変換コーパス、候補品質、学習データ互換、メモリ、オフライン試験を通してから反映する。

## 初期ソースで固定した版
`v0.8.5` / `8278b6b76e534f1a08e4db2a11602f499d754327` をXcodeのリモートSPM参照へ設定した。[固定版manifest](https://github.com/azooKey/AzooKeyKanaKanjiConverter/blob/8278b6b76e534f1a08e4db2a11602f499d754327/Package.swift)
この版はSwift 6.1・iOS 16以上を宣言する。本プロジェクトはiOS 17以上を維持し、ニューラルtraitは無効。
最新mainの `withDefaultDictionary()` 初期化とは異なり、`KanaKanjiConverter()` + `ConvertRequestOptions.withDefaultDictionary(...)` を使用する。
`Candidate.correspondingCount`で全読みを覆う候補だけを採用。v0.9へ上げるとAPI変更があるため、無条件に更新しない。
固定版の辞書はcommit `7ed1c6b3e361e9f453d23beefa344422f4027eb1`、絵文字資源は `ec11764a92fa044cd7d497b8b7d67e966c054a6f`。辞書Apache-2.0本文と変換器MIT本文をOSS表示へ収録した。
絵文字のREADMEはMozc BSD・Unicodeデータ・独自MIT由来を記載。推移依存の版と全表示条件はSPM解決後に監査する。現OSS表示は開発用で、配布準備完了ではない。
Package.resolvedは未生成。参照設定とAPI調査の完了を、依存解決・ビルドの成功とは扱わない。
Privacy manifest案はUserDefaultsの1C8F.1/CA92.1、変換時間計測systemUptimeの35F9.1を記載。[AppleのAPI理由](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype)
