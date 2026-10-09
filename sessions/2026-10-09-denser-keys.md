# XP / Vista のキー面を濃くする
## Request
- 半透明に見えるキーを少し濃くする。
## Investigation
- 両テーマのキー不透明度は既に1。明るい光沢とベース色が薄く見える原因。
## Changes
- XPは深いクリーム色、Vistaは濃い青緑へ変更。
- 共通キー光沢の白いハイライトを弱めた。
- CURRENTとUI/UX文書に記録。
## Validation
- Core34、Python13、Simulator描画/3配列2テスト成功。
- arm64 Debugテストビルド/Releaseビルド成功、画像を目視確認。
- Fast/Full相当の文書検証と生成設定一致確認成功。PowerShell未導入。
## Result
- 背景と調和させながら、キーの面をより濃くした。
## Remaining Issues
- 実機への更新は未実施。
