# 現在地

- Project: my-keyboard。iPhone用の完全オフライン日本語キーボード。
- 現在のフェーズ: Phase 1〜5の初期ソース作成、Phase 6の検証準備。各フェーズの実機完了条件は未達。
- 実装済み（コードあり・iOS未検証）: 本体、Keyboard Extension、flick・OSS変換アダプター、編集操作、設定・辞書、SQLite手動履歴。[開発状況](docs/09-DEVELOPMENT-STATUS.md) を参照。
- テーマ追加（実機の全設定操作は未検証）: Blue Cosmos標準、15プリセット、カラーパレット・カラー編集・共通プレビュー。[UI/UX](docs/10-UI-UX-AND-THEMES.md)。
- 設計済み: [要件](docs/02-REQUIREMENTS.md)、[構成案](docs/03-ARCHITECTURE.md)、[ロードマップ](docs/05-ROADMAP.md)。設計はアプリ実装ではない。
- 検証済み: Python構造・配色・SQLiteスキーマ13テスト、Swift Core25テスト、Simulator保存/marked text/予測/文書ID/再表示/高さ/プレビュー14テスト、生成設定・文書代替Verify。Mac/Xcodeでビルド可能。
- アイコン: Blue Cosmos配色の軌道・星・キーボード図案を本体のAppIconへ追加。原稿と60px、実機向けAsset Catalogコンパイルを確認。検証の詳細は [記録](sessions/2026-10-08-app-icon.md)。
- Mac実機導入: 専用App Groupと本体・拡張用プロファイルを整備。署名付きDebug build、Vesperaへのインストール・本体起動成功。本人が起動・操作成功を確認。入力・共有動作の網羅検証は未実施。[導入記録](sessions/2026-10-08-app-groups-install.md)。
- キーボード外観: 5列配置、縦長の実行キー、役割別の面・アイコン・影、華やかなBlue Cosmosへ変更。[変更記録](sessions/2026-10-08-five-column-keyboard.md)。上部を固定し、予測候補を枠なし文字表示へ調整。[調整記録](sessions/2026-10-08-stable-prediction-header.md)。
- ライブ変換: 最上位候補を入力先の未確定領域へ更新。本人が実機で動作確認。サイズ300/100%/間隔3・キー表現固定、編集はカラーのみ。[記録](sessions/2026-10-08-live-fixed-colors.md)。
- 最新調整: 細い文字・フリック方向ガイド・キー凸面、候補表示切替、確定前の単語再変換、コピー画面の収まりを調整。[記録](sessions/2026-10-08-word-reconversion-flick.md)。
- 閉じる操作: ツールバー右上に下向きボタンを固定。未確定の変換を確定して閉じる。Vesperaへ更新済み。[記録](sessions/2026-10-08-dismiss-keyboard.md)。
- 入力改善: 予測候補を既定表示・1行横スクロールへ変更、読み行を撤去。実機クラッシュ2件のUUID橋渡し経路へnil対策を実装。実機で再発が止まるかは確認待ち。[記録](sessions/2026-10-08-prediction-stability.md)。
- 未実装: 実機ホストのライブ変換比較、実測最適化、配布準備・CI/CD。
- 既知の問題: 旧方式の確定後の語削除は実験コードを既定無効。実機UI・共有動作の網羅検証は未実施。[課題](docs/07-TESTING-AND-ISSUES.md) を参照。
- 次に行うこと: Vesperaで変更後の配置・フリック・実行キー・共有動作を検証。[Mac手順](docs/08-MAC-VALIDATION.md) を参照。

構造は [ARCHITECTURE.md](ARCHITECTURE.md)、前回の結果は [sessions/](sessions/README.md) を参照。

上部余白を4pt、ヘッダーを88ptへ圧縮。上部を詰める前のキー寸法を基準に全体340ptへ縮小。[記録](sessions/2026-10-08-compact-keyboard.md)。

切り替え後の非表示は新しいクラッシュ証拠なし。再表示時のキー面再生成を撤去、ライフサイクルログと3モード×20回試験を追加。上部を詰める前のキー寸法を基準に全体340ptへ変更。[記録](sessions/2026-10-08-switch-reappearance.md)。

高さ再修正: 本体の説明に360が残っていたため共通値から表示。UIInputViewの固有サイズ・自己サイズ計算・制約を300へ統一。ビルド2。[記録](sessions/2026-10-08-keyboard-height-300.md)。

英語配列を参考画像のグループ順・左列操作へ変更。大文字小文字切替と日本語へ戻る操作を維持。[記録](sessions/2026-10-08-english-layout.md)。

英語キー16ptのrounded書体、コード記号17ptの等幅書体へ変更。記号は ://・@・バッククオート等を優先。[記録](sessions/2026-10-08-latin-code-symbols.md)。

本体プレビューを実キー部品・共通寸法へ差し替え、かな/英語/記号の表示切替を追加。Windows 98/XP/Vista/7風テーマを追加。[記録](sessions/2026-10-08-native-preview-windows.md)。

絵文字・記号一覧を追加。絵文字8カテゴリ、記号7カテゴリ、タブ/スクロール/最近使った項目（controller生存中40件）を利用可能。Release版をVesperaへインストール・本体起動成功。実機の一覧操作は未検証。[実装記録](sessions/2026-10-09-character-picker.md)、[導入記録](sessions/2026-10-09-character-picker-deploy.md)。

上部ボタンをコピー・カーソル左・カーソル右へ整理。下部の絵文字/配列切替と右端の閉じるボタンを保持。本体プレビューも更新。Release版をVesperaへ更新・本体起動成功。[記録](sessions/2026-10-09-simple-toolbar.md)。

カーソル横にかな・カナ・ローマ字変換を追加。未確定の読みを指定した文字種で確定し、通常のライブ変換を維持。英字左列の☆123とあAを入れ替え、あAを縦2段へ変更。[記録](sessions/2026-10-09-literal-reading.md)。署名付きRelease版をVesperaへ更新・本体起動成功。[導入記録](sessions/2026-10-09-literal-reading-deploy.md)。実機上の操作確認は未実施。

確定済み文字の変換を追加。選択範囲優先、未選択なら直前単語を対象にかな/カナ/ローマ字・再変換候補を使用。漢字の読みは端末内推定。Core33・iOS17.4統合21・iOS26.5新機能5テスト成功。署名付きReleaseをVesperaへ更新・本体起動成功。実機操作は本人確認待ち。[記録](sessions/2026-10-09-committed-conversion.md)。

入力時の軽い振動を追加。文字・濁点/小文字・絵文字/記号一覧・空白・実行キーで1回、設定でOFF可能。初期値ON。署名付きReleaseをVesperaへ更新・本体起動成功。振動の体感は本人確認待ち。[記録](sessions/2026-10-09-typing-haptics.md)。

振動しないとの実機報告を受け、iOS17.5以降は表示中のキー画面に振動Generatorを接続、強度を0.5へ調整。本体設定に振動テストを追加。修正版ReleaseをVesperaへ更新。原因・実機振動の再確認は継続中。[記録](sessions/2026-10-09-haptics-troubleshooting.md)。

振動の体感不足を切り分けるため、入力と本体テストをheavy/強度1.0へ増強。署名付きReleaseをVesperaへ更新済み。本人が実機で振動の体感改善を確認。[記録](sessions/2026-10-09-strong-haptics.md)。

本体UIを整理。キャッチコピーと常設の説明文を削除。タブはホーム/履歴/辞書/設定、使い方・キーボード設定・プレビュー・カラー編集・アプリ情報は設定内へ集約。署名付きReleaseをVesperaへ更新。[記録](sessions/2026-10-09-simple-app-ui.md)。

ホームをカラーパレット一覧へ直接変更。カラー適用と本体の明暗・背景を分離し、本体は端末の明暗設定に従う。署名付きReleaseをVesperaへ更新。[記録](sessions/2026-10-09-palette-home.md)。

Windows 98/XP/Vistaの外観をデスクトップ風へ再設計。低解像度背景、立体枠/ガラス、等幅文字、上部の暗い帯を追加。[記録](sessions/2026-10-09-retro-desktop-themes.md)。

XP/Vistaの背景を1448×1086の生成画像へ変更。滑らかな背景・細いキー枠・共通光沢・システム文字へ調整。arm64 Simulatorの描画/保存4テストとReleaseビルド成功。実機更新は未実施。[記録](sessions/2026-10-09-hd-desktop-themes.md)。

XP/Vistaのキー面を濃くし、白い光沢を抑えて充実感を調整。[記録](sessions/2026-10-09-denser-keys.md)。

履歴タブに文字列の直接入力・保存欄を追加。コピー取り込みと同じ保存先・上限・ピン留めを利用。[記録](sessions/2026-10-09-clipboard-direct-registration.md)。実機操作は未確認。

使用中のキーボードにパレット切替を追加。入力を保持して即時反映、フルアクセス有効時は選択を保存。統合23テスト成功、署名付きReleaseをVesperaへ更新。[記録](sessions/2026-10-09-live-palette.md)。

XP/Vistaは濃いキー色を保ち、不透明度0.86の半透明へ変更。[記録](sessions/2026-10-09-dark-translucent-keys.md)。

実機でキーが縦に伸びて下段が欠ける報告を受け、キー配置の高さを300pt内に制限。優先度指定付きの自己サイズ計算も300ptへ統一。900ptホスト枠・通常表示・再表示3テスト成功。[記録](sessions/2026-10-09-keyboard-stretch-fix.md)。

全9パレットのキー面を不透明度80%へ統一。文字/操作/実行キーに共通適用。[記録](sessions/2026-10-10-all-palette-opacity.md)。

閉じるボタンを候補行右端、パレットボタンをツールバー右端へ入れ替え。本体プレビューも同じ配置へ更新。[記録](sessions/2026-10-10-swap-header-buttons.md)。実機更新・操作確認は未実施。

Blue Cosmosを青い夜空と180個の星へ変更。Living Aurora/Pulse Neon/Windows 7を廃止し、Windows 3.1/95とTerminalを追加。全9パレット・キー不透明度80%。[記録](sessions/2026-10-10-night-sky-retro-terminal.md)。

キーボード内のクリップボード一覧から削除・星ボタンを撤去。文字列を幅いっぱいの固定1行で表示し、長文は末尾を省略。本体の履歴管理は維持。[記録](sessions/2026-10-10-clipboard-simple-rows.md)。

Game Boy/Game Boy Color Violet/Super Famicomを追加。生成した基板背景と80%の半透明キーを組み合わせ、Super Famicomは4色の操作キー。[記録](sessions/2026-10-10-console-themes.md)。

ゲーム機テーマの3基板背景すべてを採用。Violetのみ元の構図を保って少し淡い紫へ画像編集し、キー色も微調整。[記録](sessions/2026-10-10-violet-refinement.md)。

基板版3種を維持し、Game Boy/Color Violet/Super Famicomの外装配色版3種を追加。[記録](sessions/2026-10-10-console-shells.md)。

シェル版3種を生成樹脂素材へ変更し、Game Boy/Colorのボタン色をチャコールへ修正。基板版との計6ゲーム機テーマを維持。署名付きReleaseをVesperaへ更新・本体起動成功。[記録](sessions/2026-10-10-console-material-deploy.md)。

記号キーボード2ページ目を追加。記号1→記号2→記号1で循環し、Markdown/コード/シェルの60文字列をタップ・フリック入力。本体プレビューも追加。[記録](sessions/2026-10-10-developer-symbol-page.md)。署名付きReleaseをVesperaへ更新・本体起動成功。実機入力操作は本人確認待ち。
