# Xcodeなしでの初期実装

Date: 2026-10-08 / Status: 採用。iOS実行は未検証

## Context
WindowsでSwiftコンパイラ・Xcodeがない。ユーザーはこの制約で全体停止せず実装を進めることを指定した。

## Decision
Coreを依存なしSwift Packageにし、PythonでXcodeプロジェクトを再生成・構造検査する。
変換器v0.8.5のcommitを固定し、調査済みAPIでアダプターを作成する。SPM解決済みlockfileは作らない。
未確定文字は拡張内表示・確定時挿入から始める。再変換と単語削除の実験コードは既定無効。
履歴はDELETE journalのSQLiteとし、manual import・プレビュー・件数上限・期限・ピンを実装する。

## Reason
ビルド不能でも後続開発に必要なコード・設定・テストを整備できる。既知の固定版APIを使い、未検証のホスト置換を既定で実行しない。

## Alternatives
XcodeGen導入は不要なツール依存を増やすため見送った。marked textとWALは実機比較後に再評価する。

## Consequences
Python成功はSwift/iOSの動作保証ではない。Macで型検査・依存解決・署名・全操作を確認する。
現時点の正本は [開発状況](../docs/09-DEVELOPMENT-STATUS.md) と [課題表](../docs/07-TESTING-AND-ISSUES.md)。
