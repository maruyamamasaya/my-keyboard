# ゲーム機の外装配色版

## 要求
- 採用済みの基板版に加え、本体外装をイメージした配色も追加。

## 変更
- Game Boy Shell: グレー樹脂、オリーブの文字キー、チャコール操作、えんじの実行キー。
- Color Violet Shell: 淡い紫の樹脂、チャコールのキー、透明外装を思わせる縁。
- Super Famicom Shell: ライトグレー樹脂、白灰キー、4色の操作キー。
- 既存3基板版は維持。15プリセット。キー不透明度80%。
- 背景はネイティブ解像度で樹脂の陰影・画面枠・スピーカー溝を描画。
- 本体の形をそのまま背景へ貼らず、外装の色と素材感をキーボードに翻案。
- 公式の[初代紹介](https://www.nintendo.com/en-za/Hardware/Nintendo-History/Game-Boy/Game-Boy-627031.html)と[Color紹介](https://www.nintendo.com/en-gb/Hardware/Nintendo-History/Game-Boy-Color/Game-Boy-Color-627137.html)を参照。配色値は設計上の解釈。

## 検証
- Core34件、Static13件、生成プロジェクト一致。
- Fast/Full相当の文書検査とgit diff --check。
- Debug全15パレット描画・alpha 0.8の試験、Release arm64 Simulatorビルド。
- 実機への更新・操作確認は未実施。
