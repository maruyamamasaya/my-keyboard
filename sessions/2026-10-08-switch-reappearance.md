# 切り替え後の再表示調査と高さの訂正
## Request
標準キーボードから戻った際の非表示を調査。既存機能を維持し、検証後にcommit/Push。
追加指示で「大きさを維持」はキー寸法と解釈し直し、全体360固定を解除。
## Investigation
Vesperaのクラッシュ一覧に新しいMyKeyboardExtensionログはなく、22:39の修正前2件のみ。
拡張UIはUIKitでHostingControllerなし。地球キーは標準handleInputModeList/allTouchEvents。
viewWillAppearで変換器を再利用していたが、applyLayoutは毎回固定キー面を再生成していた。
非表示の直接原因は未特定。メモリ終了やSwiftUI競合を原因とは断定しない。
## Changes
固定レイアウト適用時のキー面再生成を撤去。モード変更時の再生成は維持。
viewDidLoad/didAppear/didDisappearをログへ追加。controller識別子・表示寸法・modeで復帰/再生成を区別。
入力本文・候補・ホストの文書IDはログへ出さない。ライブ変換のアルゴリズム・終了時確定処理は維持。
上部16→4pt/96→88ptの圧縮前のキー寸法を基準に全体360→340pt。テーマ・列・間隔は維持。
## Validation
Core22、Python13、Simulator統合12（3モード各20回の再表示、20回のmarked text確定を含む）。
最初の再表示試験はFlickButtonをUIButtonと誤認して失敗。UIControl探索へ訂正。
UI試験へ共通描画を組み込んだため、旧「保存テストには描画なし」の構造試験を新構成へ更新。
最終Debug/Releaseビルド成功。署名検証・文書代替Verify・生成一致・diff検査成功。VesperaへRelease版更新。
codex/input-prediction-stabilityへコミットしてoriginへPush。
## Remaining Issues
実機の標準→自作切り替え20回、ライブ変換中・別アプリ・focus・背景復帰の非表示解消は未確認。
今回の変更は再生成回避と診断追加であり、非表示原因を特定して直したという報告ではない。
