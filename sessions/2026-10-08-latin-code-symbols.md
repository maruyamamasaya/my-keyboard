# 英語フォントと技術用記号
## Request
英語を少し小さくモダンな字体へ。URL・@・バッククオート等を優先。
## Changes
英語は16pt/mediumのsystem rounded、技術記号は17pt/regularのmonospaced。日本語の20pt/lightは維持。
記号面を12キーのフリック配列へ。最上段 ://・@・バッククオート、括弧/波括弧/角括弧・=・; を中央に配置。
フリックでhttps://、全角＠、引用符、バックスラッシュ、パイプ、$などを入力可能。
複数文字トークンも既存の英数字/記号の直接挿入処理へ渡す。高さ300・テーマ・ライブ変換は維持。
別作業で未コミットだった英語配列改修も今回の関連変更として保存する。
## Validation
Core24、Simulator統合13、Python静的13、生成設定一致、文書代替Verify、diff検査を確認。
Debug/Release実機向けビルド・署名検証成功。VesperaへRelease版更新済み。
関連変更をcodex/input-prediction-stabilityへコミット/Push。
## Remaining Issues
実機での字体・技術記号のフリックの押しやすさは本人の確認待ち。
