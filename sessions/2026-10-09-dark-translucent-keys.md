# 濃い色味の半透明キー
## Request
- 濃くした色味を保持したうえでキーを透明にする。
## Investigation
- XP/Vistaはプリセット不透明度1、実行キーも別途1へ固定されていた。
## Changes
- 濃いクリーム色/青緑と控えめな光沢を保持、不透明度を0.86に変更。
- 実行キーも半透明を適用。コントラスト不足時の補正とアクセシビリティ時の不透明化を維持。
- CURRENTとUI/UX文書を更新。
## Validation
- Core34/Python13/生成設定一致とFast/Full相当の文書検証成功（PowerShell未導入）。
- arm64 Releaseビルド成功。Simulator初回描画テストは予期せず終了、単独再実行で描画/3配列2テスト成功。実画像を目視確認。
## Result
- 色味を保ちながら背景がうっすら透けるキーに調整。
## Remaining Issues
- 実機への更新は未実施。
