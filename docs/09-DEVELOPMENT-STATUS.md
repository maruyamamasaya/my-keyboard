# 開発状況

## 現在地
2026-10-08。Phase 1〜5の初期実装とPhase 6の検証準備を作成した。フェーズの実機完了条件は未達。
Xcode・SwiftコンパイラはWindows環境にない。iOSアプリ全体はビルド・動作未確認。

## コードを作成した機能（すべてiOS未検証）
| Phase | 機能 | 主な場所 |
| --- | --- | --- |
| 1 | 2製品ターゲット・拡張埋込・共有ID・署名設定・導入案内・ホスト試験画面 | MyKeyboard.xcodeproj、Config、App |
| 2 | 12キーflick、読み/cursor/revision、濁点・小書き、英字大小・数字・記号、候補/かな/カタカナ/確定/取消 | Core、KeyboardExtension |
| 2 | v0.8.5固定の変換アダプターとSPM product参照 | KeyboardExtension/Input/AzooKeyConversion.swift |
| 3 | cursor、space drag、repeat delete、完全一致ユーザー辞書、OSS学習・リセット | App/Dictionary、Storage、KeyboardExtension |
| 3 | 限定再変換・語削除の実験コード（既定無効） | Core/TextEditing、DocumentProxyAdapter |
| 4 | 縦横の高さ/幅/間隔/左右配置・テーマ・一般設定保存 | App/Settings、Core/Layout、PreferencesStore |
| 4 | Blue Cosmos標準・5プリセット、ホーム・ギャラリー・編集・共通プレビュー、色/画像/キー表現・共有保存・押下/フリックガイド | Core/Theme、DesignSystem、App/Theme、ThemeStore |
| 5 | 本体PasteControl/拡張手動取込、確認/取消、SQLite、上限/重複/ピン/検索/削除/全削除/期限 | App/Clipboard、Storage/Clipboard、KeyboardExtension |
| 6 | 読み長・候補数制限、debounce、変換遅延計測、memory warning、VoiceOver代替アクション、Privacy manifest案 | KeyboardExtension、Resources |

## 検証済み項目
- Pythonの13テスト成功: Xcodeファイルの構造・参照・埋込・source所属・生成整合・plist/権限値、アプリソースのネットワーククライアント不使用、SQLスキーマの制約/rollback/読取専用。
- テーマの5配色のコントラスト、DesignSystemのターゲット所属、入力依存の分離を静的検査した。
- 文書・生成設定のFast/Full Verify成功。
- 固定タグのソース/API・MIT、辞書Apache-2.0、絵文字由来のREADMEを調査。SPM推移依存は未解決。

## 実装中・未実装
- 実装中: 実機の完了ゲートを通すための初期実装。ビルド可能と断定しない。
- 未実装: marked text比較版、文節単位の高度な変換、辞書の文中組込（現在は読み全文の完全一致候補）、ニューラル/ライブ変換。
- 未実装: 性能目標の確定と実測最適化、配布アイコン・推移依存の完全なライセンス表示・リリース準備。CI/CDは未設定。
- 未検証: Swift Core 12テスト、iOS StorageTests 5テスト、全UIKit/SwiftUI、SPM解決、署名、App Groups、paste権限、実機操作。

## 既知の問題・懸念
再変換と語削除の原子的置換は保証できず、実験フラグをOFFにしている。Debug版依存は本文ログがあるため実データを使わない。
メインスレッドの変換負荷、回転と最小キー領域、ホスト変更通知、辞書資源のSPM同梱をMacで確認する。
保存の最大件数はピンを含み、全ピンなら新規項目を拒否。設定で上限を減らしてもピンを自動削除しない。

テーマのSwiftUI/UIKit表示・画像処理・共有反映・アクセシビリティ・性能も未検証（T-020〜023）。カスタム設定は1組。複数名付きカスタムテーマは未実装。

## 次の開始地点
1. [Mac手順](08-MAC-VALIDATION.md) に従いT-001（Swift型検査・Debug/Releaseビルド）とT-004（Coreテスト）を最初に実施する。
2. T-002の署名・共有設定、T-005の辞書・変換を確認する。
3. [課題表](07-TESTING-AND-ISSUES.md) の実機ゲートを順に検証し、不具合を修正する。
4. リリース範囲・性能目標を決め、実験編集機能を正式採用するか判断する。
