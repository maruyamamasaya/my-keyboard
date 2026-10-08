# キーボード固有のテーマと入力の分離
Date: 2026-10-08 / Status: 採用、iOS実行は未検証

## Context
Blue Cosmosを標準に、ローカル画像・カラー編集とテーマ切替を追加する。既存の入力・レイアウト設定を壊さず、拡張の負荷を抑える必要がある。

## Decision
純粋なThemeSelection/ThemeTokensをCoreに置き、UIKit/SwiftUI描画をDesignSystemに分離する。本体だけがApp Groupへ原子的に保存し、拡張は表示時に読み取る。
旧テーマenumを残して既存JSONとの互換性を保つ。Blue Cosmosと4テーマを独自の配色で同梱し、常時アニメーションは採用しない。

## Reason
入力エンジンに見た目の依存を増やさず、共通ロジックをSwift Packageで試験できる。軽い静的表現が入力の反応を優先する方針に合う。

## Alternatives
Web UIの移植、入力設定とテーマの一体化、背景画像をUserDefaultsへ保存する方式は、負荷・移行・責務の点で採用しない。

## Consequences
キーボードを開き直すまでテーマは更新されない。現在のカスタム設定は1組で、複数名付きテーマは将来機能。Mac検証の課題を残す。
詳細は [UI/UX設計](../docs/10-UI-UX-AND-THEMES.md)。
