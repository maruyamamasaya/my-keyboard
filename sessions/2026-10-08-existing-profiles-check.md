# 既存署名プロファイル再確認
## Request
既存のものを使ってキーボードの署名を進める。
## Investigation
Xcode UserDataの既存6プロファイルを読み取り確認。
App Groups対応はCalendarTaskApp本体とwidgetの2件のみ。対象groupはgroup.com.example.CalendarTaskAppで、bundle IDもCalendarTaskApp専用。
Vesperaを含むワイルドカードプロファイルはApp Groupsなし。my-keyboard用の対応プロファイルは見つからない。
## Changes
設定変更・署名・インストールなし。他アプリのIDと共有領域の転用はしない。
## Validation
security cmsのsandbox内デコードは失敗。openssl cmsで内容を解析（信頼チェーンの検証は省略）。署名の信頼性を確認した結果ではない。
ビルド・Fullは未実行。プロファイル内容とxcconfigのIDを照合。
## Result
既存資産のみでは署名を完了できない。キーボード用App Groupと本体・Extension用プロファイルの整備が必要。
