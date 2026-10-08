# 現在の構造

初期ソースとXcodeプロジェクトを作成済み。iOSビルド・実機導入済み。入力先ごとの動作は網羅検証前。
詳細は [設計アーキテクチャ](docs/03-ARCHITECTURE.md)、固定版選定は [技術構成](docs/04-TECH-STACK.md) が正本。

| 項目 | 現状 |
| --- | --- |
| 技術スタック・依存 | Swift、SwiftUI、UIKit、KeyboardCore（ローカルSPM）、固定版変換器（リモートSPM参照） |
| エントリーポイント | App/MyKeyboardApp.swift、KeyboardExtension/KeyboardViewController.swift |
| 保存 | テーマの原子的JSON/ローカル画像、共有UserDefaults、原子的JSON辞書、拡張専用OSS学習、SQLite手動履歴 |
| 認証・外部サービス | なし。App Groupsと署名値はConfig/Project.xcconfigで設定 |
| デプロイ・CI/CD | 未設定 |

```text
root/          共通ルール・現在地・各分野の案内
  decisions/   重要判断
  sessions/    作業結果
  scripts/     文書検証
  docs/        設計・ロードマップ・課題・検証手順
  App/         SwiftUI本体
  KeyboardExtension/ UIKit拡張・OSSアダプター
  Core/        依存なしの共有ロジック（Swift Package）
  Storage/     設定・辞書・履歴
  DesignSystem/ 共通のUIKitフリックキー・背景・本体プレビュー描画
  Shared/      共有保存先・エラー
  Tests/       Swift単体/統合、Python構造/SQLテスト
  Config/      plist・entitlement・xcconfig
  Resources/   Privacy manifest・OSS表示
  MyKeyboard.xcodeproj/ Python生成Xcode設定
```

ライブ変換の未確定領域管理はCore/InputEngine/LiveTextSession.swift、単語修正はCore/InputEngine/WordReconversion.swift、UIKit操作はDocumentProxyAdapter。[設計判断](decisions/0005-live-conversion-fixed-presentation.md)。

文書IDの取得はShared/DocumentIdentity.swiftでObjective-Cのnullableオブジェクトを確認してからUUIDへ橋渡しする。ID不明時はmarked text・破壊的置換の所有権を認めない。

検索入口は [CODEMAP.md](CODEMAP.md)、運用の正本は [OPERATIONS.md](OPERATIONS.md)。

入力ルートはKeyboardViewController内のKeyboardInputView。allowsSelfSizingを有効にし、intrinsicContentSizeとsystemLayoutSizeFittingでCoreの高さ300を返す。本体の説明も同じ値を使う。
