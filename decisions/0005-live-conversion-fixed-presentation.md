# ライブ変換と固定表示
Date: 2026-10-08 / Status: Accepted
## Context
本人が予測候補からライブ変換への変更、縦横とも高さ360・幅100%・間隔3の固定、表現調整をカラーだけにすることを依頼。
## Decision
予測補完を除く最上位の全文候補をUITextDocumentProxyのmarked textとして反映。確定はmarked textを更新してunmarkし、二重挿入しない。
LiveTextSessionでdocument IDと更新後の文脈を照合。文書IDが取得できない場合は所有権を拒否。外部編集・入力先変更を検出したら所有権を放棄し、本文を置換・削除しない。
未確定内のカーソル編集では読みを表示。候補タップで別候補を確定できる。キーボードを離れる際は現在候補を確定。
旧レイアウト・テーマ表現の保存値は互換のため残し、表示では固定値を使う。画像は削除せず描画しない。
単語単位の再変換は確定前のmarked text内だけで行う。変換エンジンの読み/表記連結が全文と一致する境界のみ採用し、未知の境界は全体1単位にする。合成結果は元の候補tokenを使わず確定し、誤った学習を避ける。
## Reason
入力中の変換結果を見せ、候補選択の手間を減らす。サイズと装飾設定を減らして配置を安定させる。
## Consequences
Coreの所有権・UTF16試験とUITextViewの更新・確定・取消試験を追加。実機ホストの通知タイミング・Web入力欄の互換性はまだ比較が必要。
Apple API: https://developer.apple.com/documentation/uikit/uitextdocumentproxy/setmarkedtext(_:selectedrange:)
