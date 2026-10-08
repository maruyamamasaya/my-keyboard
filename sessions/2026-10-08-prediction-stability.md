# 予測候補1行と入力安定性
## Request
日本語予測を改善し、候補を既定表示の1行に統一。読み行を撤去。
実機のキーボード消失を調査し、根拠のある対策・検証・コミット/Pushを行う。
## Investigation
固定版OSSの日本語予測オプションがfalse、共通ボタンは2行指定だった。
Vesperaから取得した22:39の2件のクラッシュはEXC_BREAKPOINT/SIGTRAP。
停止スタックはUUID._unconditionallyBridgeFromObjectiveC → DocumentProxyAdapter.snapshot → textDidChangeで一致。
メモリ終了・SwiftUI再描画を原因とする根拠はこの2件にない。生ログは/private/tmpのみ。
## Changes
日本語の同梱辞書予測を有効化。全文対応数・actions安全フィルターを維持。
予測はタップで確定、ライブ変換は通常候補だけ採用。単語再変換では予測補完を無効化。
候補1行・横スクロール・44ptタップ領域。固定ヘッダー96pt、通常の読み行なし。
旧候補非表示設定は一度表示へ移行し、その後はユーザーの明示設定を保持。
エラーは候補行の一時メッセージとアクセシビリティ通知で表示する。
Objective-C側の文書IDをnullableで取得してからUUIDへ変換。欠落時はmarked text/本文置換の所有権を拒否。
表示・終了・ユーザーによる閉じる・memory warning・文書ID欠落だけをOSLogへ記録。入力内容を記録しない。
## Files Changed
Extension入力/UI、CoreのComposition/文書ID/ライブ入力/候補設定、Shared/DocumentIdentity、共通プレビュー、単体/統合テスト、生成スクリプトと関連文書。
以前の依頼で実装済みの未コミットのライブ変換・デザイン・署名変更も今回の保存対象に含む。
## Validation
Core22、Simulator統合10（実際のOSS予測/通常変換/ユーザー辞書・Objective-C nil getterを含む）、Python静的13。
署名付きDebug/Releaseビルド、署名検証、文書代替Verify・生成一致・diff検査成功。
Vesperaへ更新。最終導入はRelease版で、依存エンジンの入力内容を含むDEBUG出力を無効化。
Gitはcodex/input-prediction-stabilityに保存し、originへPush。
## Remaining Issues
修正後の実機入力・非再発・長時間の遅延/メモリは未確認。
実機再確認項目はdocs/07-TESTING-AND-ISSUES.md、ログ手順はOPERATIONS.md。
