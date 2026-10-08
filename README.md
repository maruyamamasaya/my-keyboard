# my-keyboard

iPhone向けの完全オフライン日本語フリックキーボードを開発するプロジェクトです。
漢字変換・文字修正・レイアウト調整、手動取り込み式の履歴、Blue Cosmosを標準とするテーマ機能の初期コードを備えています。

## 技術構成と開発状況
Swift / SwiftUI / UIKit + Custom Keyboard Extensionの初期ソースを作成しました。
AzooKeyKanaKanjiConverter v0.8.5のコミットを固定し、App Groupsの設定・辞書共有、SQLiteの手動履歴を実装する構成です。
Phase 1〜5の初期実装とPhase 6の検証準備まで進めています。**Xcode・Swiftコンパイラがないため、iOSビルド・動作・Swiftテストは未検証**です。
Macで開く手順は [Mac検証](docs/08-MAC-VALIDATION.md)、詳細は [開発状況](docs/09-DEVELOPMENT-STATUS.md) を参照してください。

## 設計とロードマップ
| 文書 | 内容 |
| --- | --- |
| [01 プロジェクト概要](docs/01-PROJECT-OVERVIEW.md) | 背景・目的・方針 |
| [02 要件](docs/02-REQUIREMENTS.md) | 初期範囲・機能・非機能要件 |
| [03 アーキテクチャ](docs/03-ARCHITECTURE.md) | 本体と拡張・入力状態・保存設計 |
| [04 技術構成](docs/04-TECH-STACK.md) | 公式技術・OSS比較・選定理由 |
| [05 ロードマップ](docs/05-ROADMAP.md) | Phase 0〜6・依存・完了条件 |
| [06 リスクと制約](docs/06-RISKS-AND-CONSTRAINTS.md) | 権限・編集・性能・検証計画 |
| [07 テストと課題](docs/07-TESTING-AND-ISSUES.md) | 検証状況と持ち越し課題 |
| [08 Mac検証](docs/08-MAC-VALIDATION.md) | ビルド・署名・実機手順 |
| [09 開発状況](docs/09-DEVELOPMENT-STATUS.md) | 初期実装・未実装・次回タスク |
| [10 UI/UXとテーマ](docs/10-UI-UX-AND-THEMES.md) | 独自デザイン・共有保存・画像・検証方針 |

## 開発用の案内

| 文書 | 役割 |
| --- | --- |
| [CURRENT.md](CURRENT.md) | 現在地 |
| [AGENTS.md](AGENTS.md) | AI作業ルール |
| [ARCHITECTURE.md](ARCHITECTURE.md) | 現在の構造 |
| [CODEMAP.md](CODEMAP.md) | 検索入口 |
| [TESTING.md](TESTING.md) | 検証コマンド |
| [OPERATIONS.md](OPERATIONS.md) | 起動・運用 |
| [decisions/](decisions/README.md) | 設計判断 |
| [sessions/](sessions/README.md) | 作業記録 |

開発の開始時は AGENTS → CURRENT → 関連文書 → 検索 → 対象コードの順に参照してください。
