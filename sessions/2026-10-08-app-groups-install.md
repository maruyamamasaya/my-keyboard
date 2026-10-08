# App Groups整備とVespera導入
## Request
既存資産の不足を確認後、本人が新規作成で進めることを承認。
## Changes
既存チームU29GY347DYを設定。専用bundle IDはmaruyama.MyKeyboard、拡張は同ID.keyboard、App Groupはgroup.maruyama.MyKeyboard。
Xcode自動署名で本体・拡張用プロファイルを整備。両プロファイルに専用App GroupとVesperaが含まれることを確認。
## Files Changed
Config/Project.xcconfig、CURRENT.md、この記録。
## Validation
生成設定一致、Python構造/配色/SQLの13テスト、文書存在/リンク/行数の代替検査、git diff --check成功。PowerShellなしのため標準Verifyは未実行。
署名付きDebug/Release実機build、Debug製品のcodesign --verify --deep --strict成功。
Vesperaへのインストールとdevicectlによる本体起動成功。
## Result
署名待ちは解消。実機に本体とキーボード拡張を導入。
## Remaining Issues
キーボードの設定追加、入力・変換、フルアクセスOFF/ONとApp Group共有動作は未検証。端末設定は変更していない。
