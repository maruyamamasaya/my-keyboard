# iOSキーボード設計

## Request
実装せず、日本語Markdownの基本設計とPhase 0〜6のロードマップを作成する。

## Investigation
既存AGENTS・CURRENT・構造・検証・前回判断を確認。
Apple現行API・アーカイブガイド、azooKey・変換器のREADME / LICENSE / Package.swift、辞書、macSKKを閲覧。
READMEとmanifestの最低iOS記載に差があることを記録。実機・性能は未確認。

## Changes
設計と実装済み事実を分離。本体／拡張の責務、権限別保存、通常変換の再利用、安全な編集範囲、検証ゲートを整理。

## Files Changed
新規: docs/01〜06、decisions/0002-ios-keyboard-design.md、本session。
更新: README.md、CURRENT.md、ARCHITECTURE.md、CODEMAP.md。

## Validation
文書VerifyのFast・Full、UTF-8読取、要求された6文書の存在と内容構成を確認。
アプリのビルド・テストは今回の対象外。

## Result
要件・技術比較・構成・実装順序・リスクをリンク付き文書として作成。
コード・依存導入・Xcodeプロジェクト作成・Pushは行っていない。

## Remaining Issues
Mac / Xcode / 署名環境、固定する変換器版、最低OS、marked textの互換性、性能目標、貼付許可の実機確認。
