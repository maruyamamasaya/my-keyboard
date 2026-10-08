# 起動・運用

プロジェクトルートは `C:\Users\m-maruyama\Development\my-keyboard`。
Gitブランチは main。初期ソースはあるがiOSビルド・起動未確認。CI/CD・デプロイは未設定。
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
