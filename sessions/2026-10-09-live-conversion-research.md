# ライブ変換の技術調査
## Request
現実装を調査し、Mermaid付きMarkdownを保存。ソースと動作を変更せず、作成文書のみcommit/pushする。
## Investigation
- アプリ基準commit: 22fa0be314675d0015657f03fc45a2335853ab39。
- AzooKeyKanaKanjiConverter v0.8.5固定revisionとローカルSPM checkout HEAD、辞書gitlinkを照合。
- 入力・候補順位・差分ラティス・品詞/意味接続・学習・marked text・切替を調査。
- ニューラル推論は無効。学習は既定無効、任意で単語/文節bigram/全文を記憶する。
- Webでの固定版取得は失敗。上流の内容は同revisionのローカルソースを根拠とした。
## Changes
- docs/live-conversion-architecture.mdを14節構成で作成。実装対応の図4点、改善優先度表を収録。
- 未計測の性能値、未確認の例文順位、一般論と実装事実を区別。
## Files Changed
- docs/live-conversion-architecture.md
- sessions/2026-10-09-live-conversion-research.md（この記録）
## Validation
- PowerShellが未導入のためverify.ps1のFast/Fullは未実行。
- 同スクリプト相当のPython文書検査: Fast/Full（必須文書・Gitルート・行数・相対リンク）成功。
- python3 scripts/generate_project.py --check: 成功。
- python3 -m unittest discover -s Tests/Static -v: 13テスト成功。
- git diff --check、追加Markdownの構成/参照コード/4 Mermaid図の手動照合: 成功。
- Swift/iOSテスト、実機性能測定、Mermaidレンダラーでの表示確認は未実施（調査/文書のみ）。
## Result
ソース変更なし。新規Markdown 2点のみcommit/push対象とする。
## Remaining Issues
実機時間/メモリ・例文別スコア・各ホストの通知/切替互換性は未計測または未確認。
