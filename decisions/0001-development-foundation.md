# 空のリポジトリでの開発基盤

Date: 2026-10-08 / Status: Accepted

## Context
Gitのみ存在し、アプリ・ビルドシステム・検証コマンドはない。

## Decision
短い役割別文書と、依存追加の不要なPowerShell文書Verifyを設置する。
子AGENTSは実際の責務境界ができてから追加する。

## Reason
未確定の技術構成を固定せず、次回のAIが現在地と探索・検証方法へ到達できる。

## Alternatives
NodeやPythonの検証基盤、架空のfrontend/backendフォルダーを先に作る案は、現在の要件では必要がない。

## Consequences
文書整合性を自動確認できる。アプリ導入時に実際のテストとビルドをVerifyへ組み込む必要がある。
