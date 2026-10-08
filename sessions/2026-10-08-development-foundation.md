# AI開発基盤の整備

## Request
前回の基本文書整備と今回の検索優先・軽量文書・自動検証を実装する。

## Investigation
初期状態は .git のみ。アプリ、設定、テスト、既存文書は存在しなかった。
前回と今回の添付指示を確認。関数・API・DB等の検索性は対象コードがなく未評価。

## Changes
役割別の短い文書、検索手順、更新条件、階層AGENTSの追加条件、文書Verifyを作成。
既存文書の重複はなく、詳細は正本へリンク。子AGENTSは責務領域がないため未作成。

## Files Changed
ルート7文書、decisions/README.md と 0001-development-foundation.md、
sessions/README.md と本記録、scripts/verify.ps1。すべて新規。

## Validation
Fast / Full 成功。一時Markdownのリンク切れ・81行のsessionを検出し、終了コード1を確認。
一時ファイルは削除。通常実行は端末の実行ポリシーで拒否されたため、
PowerShell起動プロセスに限定した ExecutionPolicy Bypass で検証した。
システム設定の変更は行っていない。

## Result
少量の文書から探索・検証・記録へ進める基盤を整備。

## Remaining Issues
アプリ要件・技術スタック・アプリの検証・CI/CDは未決定。
semantic search / repository index は未導入。利用可能な環境で活用する。
