# 高さ300と実表示の検証
## Request
実機で360に見えるとの指摘。より小さく、キーは標準程度、最終指定は300。
## Investigation
高さ制約は340へ更新済みだったが、本体設定の説明は360・候補既定非表示のまま残っていた。
入力ルートのallowsSelfSizing未設定で、固有サイズも実装していなかった。
## Changes
高さ300をCoreの共通値にし、本体の説明・拡張制約・入力ルートの固有サイズ/自己サイズ計算へ統一。
UIInputViewのallowsSelfSizing=true、制約priority999。上部余白・テーマ・入力方式は維持。候補32pt/ツールバー36ptへ圧縮し、キー44pt以上とiOSのsafe areaを両立。
ビルド番号2で導入版を区別。UIApplicationアクセスはテストターゲットだけ許可、ExtensionはAPI制限を維持。
## Validation
最初のホスト試験は入力コントローラーが表示されず失敗。UIInputViewを接続するとwindowには付いたが高さ0。
固有サイズ・自己サイズ計算・初期フレームを共通値へ揃え、UIKit入力欄への接続試験で実際の高さ300を確認。
300pt化直後はキー実測39.33ptで試験が失敗。ヘッダーを20pt圧縮して44pt以上を確保。
Core23（別作業の英語配列試験1件含む）・Simulator統合13・Python静的13成功。
UIKit入力欄の実測: ルート300pt、キー44.33pt。Device Debugビルド成功。
別チャットの英語配列変更は保持し、現在の構成で検証。今回のコミットでは高さに関する変更だけ保存。
Releaseビルド・署名検証成功。Vesperaへインストールし、devicectl一覧でMyKeyboardのビルド2を確認。
高さ変更をcodex/input-prediction-stabilityへコミット/Push。
## Remaining Issues
UIKit入力欄の表示試験は実機Keyboard Extensionホストの測定ではない。Vesperaの修正後の実寸は本人の確認待ち。
Apple仕様: https://developer.apple.com/documentation/uikit/uiinputview/allowsselfsizing
