# AI作業ルール

## 探索と変更
- 最初にこの文書と [CURRENT.md](CURRENT.md) を読む。目的に応じて [CODEMAP.md](CODEMAP.md)、[ARCHITECTURE.md](ARCHITECTURE.md)、[TESTING.md](TESTING.md)、[OPERATIONS.md](OPERATIONS.md)、[設計判断](decisions/README.md) を参照する。
- 概念しか分からない場合は利用可能な semantic / repository search を使う。未提供なら CODEMAP のキーワードを起点に `rg` や IDE 検索を使う。検索サービスの導入は必須ではない。
- 名前が判明したら exact / symbol search、呼び出し元は references search に切り替える。検索結果から対象部分だけ読む。
- 変更前に定義、呼び出し元・先、関連テスト、設定、データ依存を確認する。ファイル全体やリポジトリ全体を無差別に読み込まない。
- 対象ファイルの祖先にある AGENTS.md を確認し、最も近い文書の領域ルールも適用する。
- 実装の事実、意図された仕様、過去の判断、不具合を区別する。不明点は推測で確定しない。
- 要求に関係する小さな変更を行う。検索性だけの大規模 rename、依存追加、リファクタリングを避ける。秘密情報をコード・文書・ログへ保存しない。

## コンテキストの取得順
1. AGENTS + CURRENT
2. 関連する設計文書 + CODEMAP
3. 検索結果
4. 対象コード + 該当領域の AGENTS
5. 依存コード + テスト

## 検証と記録
- 実装中は Fast、完了前は変更範囲に応じた Full を実行する。コマンドと対応表の正本は [TESTING.md](TESTING.md)。未実行や失敗は明記する。
- AI作業終了時は [sessions/](sessions/README.md) に簡潔な記録を残す。生ログや巨大な diff は保存しない。
- 状態変更 → CURRENT、構造変更 → ARCHITECTURE、主要入口・配置変更 → CODEMAP、検証方法変更 → TESTING、起動・運用変更 → OPERATIONS を更新する。
- 将来の理解に必要な重要判断のみ decisions に記録する。全作業で全ドキュメントを更新しない。

## 文書の規模と階層
- 詳細は正本へリンクし、説明を複製しない。CURRENT は現在地のみ、CODEMAP は検索入口のみを保持する。
- ルート文書は各120行以内、session記録は80行以内を目安に保つ。超過時は詳細を責務に沿って分離する。
- 独立した技術スタック、検証方法、変更ルール、強い責務境界ができた領域にだけ子 AGENTS.md を追加する。共通ルールは複製しない。
