# Blue Cosmosと独立テーマシステム
## Request
Living Auroraを参考に、キーボード固有のUI/UX・ギャラリー・編集・プレビューを追加する。
## Investigation
既存App/Extension/Core/保存/生成設定を確認。Living Aurora commit 1efef7fd0f10e906ef179224a762091b90749f6dのデザイン文書・テーマ定義・CSSを調査。ソースや画像は転用せず、依存を増やさない。
## Changes
Blue Cosmosと4プリセット、独立した選択・トークン、App Groupの原子的JSONと画像保存、共通描画・プレビュー、ホーム・ギャラリー・編集、押下と方向ガイドを追加。
既存入力処理・レイアウト・旧設定の互換性を維持。画像の縮小/メタデータ除去/上限・明示削除・メモリ警告時の解放を実装。
## Files Changed
Core/Theme、DesignSystem、App/Theme、ThemeStore、AppModel/Root/Settings、Extension UI、生成スクリプト/Xcode設定、Swift/Pythonテスト。
docs/02・03・05・07・08・09・10、ルート案内、decisions/0004。
## Validation
Fast/Full VerifyとPython 13テスト成功。プリセットコントラストとソース所属を検査。Swift Core 12、Storage 5テストは作成済み・未実行。
## Result
実装コードとMacでの検証手順を作成した。iOSビルド・表示・動作は未確認。
## Remaining Issues
T-020〜023: 型検査、画像・保存共有・移行、表示・アクセシビリティ、性能と既存入力の回帰。カスタムは1組、複数名付きテーマは将来。
