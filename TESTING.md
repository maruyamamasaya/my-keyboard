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
Coreの12単体テストとStorageの5統合テストは作成済みだが未実行。PythonのSQL試験はSwiftラッパーを実行していない。
lint/format専用ツール、E2E自動化、実測性能基準は未整備。WindowsのVerify成功はSwift型検査やアプリ品質の保証ではない。
