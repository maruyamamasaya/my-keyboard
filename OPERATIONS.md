# 起動・運用

Macのプロジェクトルートは `/Users/maruyamasusumuya/Development/my-keyboard`。
開発の基準ブランチは main。Mac/Xcodeで署名付きビルド・Vesperaへの導入済み。CI/CD・デプロイは未設定。
リモートoriginは https://github.com/maruyamamasaya/my-keyboard.git 。
Macの起動・署名・依存解決・DB検証の正本は [Mac手順](docs/08-MAC-VALIDATION.md)。

## 開発基盤
PowerShell・Python 3・Gitでリポジトリ検証を実行できる。実行方法は [TESTING.md](TESTING.md)。
Xcodeプロジェクトは `python scripts/generate_project.py` でソースから再生成する。
署名・グループIDは `Config/Project.xcconfig` に設定する。秘密鍵・実行時環境変数は不要。
検索に `rg` を使える場合は [CODEMAP.md](CODEMAP.md) を参照。

## トラブルシューティング
- 文書検証失敗: 表示されたパスを確認し、欠落文書・相対リンク・行数超過を修正する。
- スクリプト実行が組織のポリシーで拒否される場合: 環境管理者の方針に従う。文書の存在・リンクを手動確認し、未実行として記録する。
- 新しい実行環境やサービスを導入したら、必要な環境変数名と準備手順をここに追記する。秘密値は保存しない。

## キーボード消失の調査
- macOS ConsoleでVesperaを選び、subsystem `maruyama.MyKeyboard` / category `KeyboardLifecycle` を絞り込む。表示・終了・明示的な閉じる操作・memory warning・文書ID欠落を記録する。入力本文・候補・文書IDはログへ出さない。
- 実機の通常確認はRelease版を使用する。固定版OSSのDEBUG出力には入力内容が含まれるため、Debug版の入力はテスト文字列に限定する。
- クラッシュ一覧: `xcrun devicectl device info files --device Vespera --domain-type systemCrashLogs`。
- 該当するMyKeyboardExtensionのipsだけを `xcrun devicectl device copy from --device Vespera --domain-type systemCrashLogs --source <該当ファイル名> --destination /private/tmp/keyboard-crash.ips` で取得する。生ログはGitへ保存しない。
- 発生時刻、入力先アプリ/欄、全体か候補だけか、直前の操作、復帰方法を併記し、SIGNALクラッシュとJetsam/フォーカス変更/明示終了を区別する。
