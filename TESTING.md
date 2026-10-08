# 検証方法

## 標準Verify
リポジトリルートから実行する。追加ライブラリは不要。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify.ps1
```

既定値は Full。文書・Gitルート・Xcode設定構造・SQLスキーマを検証し、失敗時は終了コード1を返す。FullはPython 3も必要。
この環境では通常のスクリプト実行が無効のため、起動プロセスに限定した実行オプションを指定する。システムの実行ポリシーは変更しない。

## Fast / Full
| 種類 | コマンド末尾 | 対象 |
| --- | --- | --- |
| Fast（実装中） | `-Mode Fast` | 必須文書の存在、ルート文書の行数、Gitルート |
| Full（完了前） | `-Mode Full` または省略 | Fast + 文書リンク/行数 + 生成設定一致 + Pythonの13構造/配色/SQLテスト |

相対ファイル・ディレクトリリンクを検証する。外部URLや見出しアンカーの正しさ、文書と実装の意味的な一致は人間・AIが確認する。

## 変更と必要な検証
| 変更 | 検証 |
| --- | --- |
| 文書 | Fast → Full + 内容と実ファイルの照合 |
| verifyスクリプト | Fast + Full + 一時Markdownでリンク切れ・行数超過の失敗確認 |
| Core変更 | `swift test`（Swift 6.1以上）。現在のWindowsにはSwiftなし |
| App/Extension/Storage変更 | Full + MacのDebug/Release build・StorageTests・該当実機課題 |
| Xcode設定変更 | 生成→Full→MacでXcode解釈・ビルド確認 |

## Mac側のFull
`swift test`、Xcodeビルド・StorageTests・対象操作を検証する。コマンドの正本は [Mac手順](docs/08-MAC-VALIDATION.md)。
Core27単体テストとStorage/marked text/一覧画面の16統合テストをMac/Simulatorで実行済み。候補表示の旧設定移行、単語境界・修正、UITextViewのmarked text更新・単語修正・確定・取消、文書IDがnilのObjective-C getter、オフライン予測と通常変換・ユーザー辞書、日本語/英語/記号の各20回のコントローラー再表示と20回のmarked text確定を含む。UIKit入力欄のinputViewへ接続した300ptの実表示・キー寸法試験、本体プレビューの3配列・ネイティブキー表示試験も含む。絵文字/記号のカテゴリ切替、複合文字列の挿入、最近使った項目の分離/復帰、一覧からかな/記号キーへ戻る操作も含む。これらは実機のExtension表示・実際のキーボード切り替え試験ではない。実機ホストの通知・入力互換性は別途検証する。
lint/format専用ツール、E2E自動化、実測性能基準は未整備。WindowsのVerify成功はSwift型検査やアプリ品質の保証ではない。
