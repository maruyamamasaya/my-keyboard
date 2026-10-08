# 現在地

- Project: my-keyboard。iPhone用の完全オフライン日本語キーボード。
- 現在のフェーズ: Phase 1〜5の初期ソース作成、Phase 6の検証準備。各フェーズの実機完了条件は未達。
- 実装済み（コードあり・iOS未検証）: 本体、Keyboard Extension、flick・OSS変換アダプター、編集操作、設定・辞書、SQLite手動履歴。[開発状況](docs/09-DEVELOPMENT-STATUS.md) を参照。
- テーマ追加（実機の全設定操作は未検証）: Blue Cosmos標準、5プリセット、カラーパレット・カラー編集・共通プレビュー。[UI/UX](docs/10-UI-UX-AND-THEMES.md)。
- 設計済み: [要件](docs/02-REQUIREMENTS.md)、[構成案](docs/03-ARCHITECTURE.md)、[ロードマップ](docs/05-ROADMAP.md)。設計はアプリ実装ではない。
- 検証済み: Python構造・配色・SQLiteスキーマ13テスト、Swift Core22テスト、Simulator保存/marked text/予測/文書ID10テスト、生成設定・文書代替Verify。Mac/Xcodeでビルド可能。
- アイコン: Blue Cosmos配色の軌道・星・キーボード図案を本体のAppIconへ追加。原稿と60px、実機向けAsset Catalogコンパイルを確認。検証の詳細は [記録](sessions/2026-10-08-app-icon.md)。
- Mac実機導入: 専用App Groupと本体・拡張用プロファイルを整備。署名付きDebug build、Vesperaへのインストール・本体起動成功。本人が起動・操作成功を確認。入力・共有動作の網羅検証は未実施。[導入記録](sessions/2026-10-08-app-groups-install.md)。
- キーボード外観: 5列配置、縦長の実行キー、役割別の面・アイコン・影、華やかなBlue Cosmosへ変更。[変更記録](sessions/2026-10-08-five-column-keyboard.md)。上部を固定し、予測候補を枠なし文字表示へ調整。[調整記録](sessions/2026-10-08-stable-prediction-header.md)。
- ライブ変換: 最上位候補を入力先の未確定領域へ更新。本人が実機で動作確認。サイズ360/100%/間隔3・キー表現固定、編集はカラーのみ。[記録](sessions/2026-10-08-live-fixed-colors.md)。
- 最新調整: 細い文字・フリック方向ガイド・キー凸面、候補表示切替、確定前の単語再変換、コピー画面の収まりを調整。[記録](sessions/2026-10-08-word-reconversion-flick.md)。
- 閉じる操作: ツールバー右上に下向きボタンを固定。未確定の変換を確定して閉じる。Vesperaへ更新済み。[記録](sessions/2026-10-08-dismiss-keyboard.md)。
- 入力改善: 予測候補を既定表示・1行横スクロールへ変更、読み行を撤去。実機クラッシュ2件のUUID橋渡し経路へnil対策を実装。実機で再発が止まるかは確認待ち。[記録](sessions/2026-10-08-prediction-stability.md)。
- 未実装: 実機ホストのライブ変換比較、実測最適化、配布準備・CI/CD。
- 既知の問題: 確定後の再変換/語削除は実験コードを既定無効。実機UI・共有動作の網羅検証は未実施。[課題](docs/07-TESTING-AND-ISSUES.md) を参照。
- 次に行うこと: Vesperaで変更後の配置・フリック・実行キー・共有動作を検証。[Mac手順](docs/08-MAC-VALIDATION.md) を参照。

構造は [ARCHITECTURE.md](ARCHITECTURE.md)、前回の結果は [sessions/](sessions/README.md) を参照。

上部余白を4pt、ヘッダーを88ptへ圧縮。全体の高さ360ptは維持。[記録](sessions/2026-10-08-compact-keyboard.md)。
