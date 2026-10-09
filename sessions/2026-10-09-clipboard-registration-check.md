# クリップボードの文字列登録確認
## Request
文字列を自分で登録する機能が追加済みか確認。
## Investigation
本体のClipboardViewと拡張のrefreshClipboardを確認。
コピー済みテキストの明示的な取り込み・確認保存・ピン留めは実装済み。
任意文字列を直接入力する登録欄は現行UIにない。
## Changes
実装変更なし。
## Validation
コード参照のみ。テスト・実機操作は未実施（実装変更なし）。
## Result
コピー経由の登録は可能。直接入力による登録は未実装。
## Remaining Issues
なし。

## Follow-up
キーボードのコピー画面から本体設定へ移動する案を調査。
既存コードにURL schemeや本体への遷移処理はない。
AppleのExtensionOverviewでは本体を開くAPIをToday拡張向けとしており、キーボードからの保証された起動導線は確認できない。
実装追加は行わず、制約と本体の履歴タブでの管理案を案内。
