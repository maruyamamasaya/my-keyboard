# Violetの微調整と3基板の採用

## 要求
- Game Boy、Game Boy Color Violet、Super Famicomの背景をすべて採用。
- Violetだけ、現在の色味からほんの少し淡くする。

## 変更
- 画像生成の編集でViolet基板の構図・部品配置を維持し、紫の明度を少し上げた。
- Violetの背景色を`#29183F`、キー色を`#513578`へ微調整。不透明度80%は維持。
- 画像とプロンプトの正本は[素材記録](../docs/console-board-assets.md)。

## 検証
- Fast/Full相当の文書・リンク検査、Core 34件、Static 13件、生成プロジェクト一致、差分空白検査。
- Debugの全12パレット描画テスト成功。キー背景のalpha 0.8を確認。
- Violetの実際のUIKitプレビューで部品の透過、文字の可読性を目視確認。
- arm64 Simulator Releaseビルド成功。

## 残事項
- 実機へのインストールは未実施。
