# 署名待ちの確認
## Request
Vesperaへの他2アプリのインストールは本人が進める。キーボードの署名待ちを解消できるか確認。
## Investigation
CURRENTと前回記録、xcconfig、本体・Extensionのentitlementsを照合。
署名なしDebugビルドは前回成功。現在の設定は例示bundle/App Group ID、チーム未設定。前回確認時は対応する既存App Groupsプロファイルが不足。
## Changes
署名設定・Apple側資産への変更なし。
## Validation
設定と記録の読み取り確認のみ。ビルド・実機検証・Fullは未実行。
## Result
進行には既存対応プロファイルの提供、またはApp Groupと対応プロファイル整備への明示承認が必要。今回の発言だけでは前回の新規作成禁止を解除したとは扱わない。
