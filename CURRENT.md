# 現在地

- Project: my-keyboard。iPhone用の完全オフライン日本語キーボード。
- 現在のフェーズ: Phase 1〜5の初期ソース作成、Phase 6の検証準備。各フェーズの実機完了条件は未達。
- 実装済み（コードあり・iOS未検証）: 本体、Keyboard Extension、flick・OSS変換アダプター、編集操作、設定・辞書、SQLite手動履歴。[開発状況](docs/09-DEVELOPMENT-STATUS.md) を参照。
- テーマ追加（iOS未検証）: Blue Cosmos標準、5プリセット、ギャラリー・色/画像編集・共通プレビュー。[UI/UX](docs/10-UI-UX-AND-THEMES.md)。
- 設計済み: [要件](docs/02-REQUIREMENTS.md)、[構成案](docs/03-ARCHITECTURE.md)、[ロードマップ](docs/05-ROADMAP.md)。設計はアプリ実装ではない。
- 検証済み: Python構造・テーマ配色・SQLiteスキーマ13テスト、生成設定・文書Verify。SwiftコンパイラとXcodeはない。
- 未実装: marked text比較、実測最適化、配布準備・CI/CD。
- 既知の問題: 再変換/語削除は実験コードを既定無効。依存解決・Swift型検査・UIは未検証。[課題](docs/07-TESTING-AND-ISSUES.md) を参照。
- 次に行うこと: Macで `swift test` とXcode依存解決・Debug/Releaseビルド。[Mac手順](docs/08-MAC-VALIDATION.md) を参照。

構造は [ARCHITECTURE.md](ARCHITECTURE.md)、前回の結果は [sessions/](sessions/README.md) を参照。
