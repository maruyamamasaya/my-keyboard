# 探索の入口

## AI開発基盤
- Primary paths: [AGENTS.md](AGENTS.md)、[CURRENT.md](CURRENT.md)
- Search keywords: `探索`、`コンテキスト`、`更新`、`階層`
- Key entry points: AGENTS の探索と変更、CURRENT の次に行うこと
- Related tests: [scripts/verify.ps1](scripts/verify.ps1)

## 文書検証
- Primary paths: [scripts/verify.ps1](scripts/verify.ps1)、[TESTING.md](TESTING.md)
- Search keywords: `RequiredDocs`、`Get-MarkdownFiles`、`Test-Path`、`Full`
- Key entry points: verify.ps1 の Mode パラメーター
- Related tests: 成功実行と一時ファイルによるリンク切れ・行数超過の検出確認

## 判断と作業履歴
- Primary paths: [decisions/README.md](decisions/README.md)、[sessions/README.md](sessions/README.md)
- Search keywords: `Decision`、`Request`、`Validation`、`Remaining Issues`
- Key entry points: 各ディレクトリの記録形式
- Related tests: Full のリンク検証

## iOS入力・変換
- Primary paths: [KeyboardViewController](KeyboardExtension/KeyboardViewController.swift)、[Composition](Core/InputEngine/Composition.swift)、[FlickMap](Core/InputEngine/FlickMap.swift)、[AzooKeyConversion](KeyboardExtension/Input/AzooKeyConversion.swift)
- Search keywords: `DocumentIdentity`、`KeyboardLifecycle`、`requireJapanesePrediction`、`WordReconversion`、`showsCandidates`、`LiveTextSession`、`setMarkedText`、`updateCandidates`、`revision`、`correspondingCount`、`repeatDelete`、`startReconversion`
- Key entry points: UIInputViewController、input、commit
- Related tests: [Coreテスト](Tests/Unit/KeyboardCoreTests.swift)、[Mac課題](docs/07-TESTING-AND-ISSUES.md)

## 設定・辞書・履歴
- Primary paths: [本体](App/MyKeyboardApp.swift)、[PreferencesStore](Storage/Preferences/PreferencesStore.swift)、[UserDictionaryStore](Storage/Dictionary/UserDictionaryStore.swift)、[ClipboardStore](Storage/Clipboard/ClipboardStore.swift)
- Search keywords: `historyAction`、`learningResetID`、`prune`、`transaction`、`ClipboardPolicy`
- Key entry points: AppModel、ClipboardStore、SharedContainer
- Related tests: [保存統合テスト](Tests/Integration/ClipboardStoreTests.swift)、[構造・SQLテスト](Tests/Static/test_repository.py)

## テーマ・UI/UX
- Primary paths: [トークン/選択](Core/Theme/ThemeTokens.swift)、[保存](Storage/Preferences/ThemeStore.swift)、[描画](DesignSystem/Theme/ThemeRendering.swift)、[画面](App/Theme/ThemeViews.swift)
- Search keywords: `ThemeSelection`、`ThemeCatalog`、`applyAppearance`、`ThemeImageImporter`、`KeyboardPreview`
- Related tests: [Core](Tests/Unit/ThemeTests.swift)、[保存](Tests/Integration/ThemeStoreTests.swift)、[構造/配色](Tests/Static/test_themes.py)。設計正本は [UI/UX](docs/10-UI-UX-AND-THEMES.md)。

## Xcode設定
- Primary paths: [生成スクリプト](scripts/generate_project.py)、[設定](Config/Project.xcconfig)、[Package.swift](Package.swift)
- Search keywords: `REVISION`、`Embed App Extensions`、`APP_GROUP_IDENTIFIER`
- Key entry points: project_model、outputs
- Related tests: [構造検査](Tests/Static/test_repository.py)

## iOS設計
- Primary paths: [要件](docs/02-REQUIREMENTS.md)、[構成](docs/03-ARCHITECTURE.md)、[技術](docs/04-TECH-STACK.md)、[リスク](docs/06-RISKS-AND-CONSTRAINTS.md)
- Search keywords: `DocumentProxyAdapter`、`ConversionAdapter`、`フルアクセス`、`再変換`、`SQLite`
- Key entry points: [Phase 1](docs/05-ROADMAP.md) の最小動作環境
- Related tests: リスク文書と課題表の検証計画

## コード追加後の探索
主要入口だけを登録し、追加機能は責務・symbol名から検索する。

```powershell
rg --files --hidden -g '!.git/**'
rg -n -F 'RequiredDocs' scripts
rg -n 'TODO|FIXME' --glob '!sessions/**'
```

名前不明 → 利用可能なら semantic search → 正確な名前で symbol / exact search → references → 関連テスト。
`rg` がなければ IDE 検索、または追跡済みファイルに `git grep -n` を使う。初回コミット前の未追跡ファイルは git grep の通常対象外。
