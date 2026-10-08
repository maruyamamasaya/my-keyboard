# 細い文字・フリックガイド・単語再変換
## Request
キーの文字を小さく細く、フリックできる凸面表現、読みと候補を同じサイズ、コピー文字のボタン内収まり、候補既定非表示/切替、ライブ変換中の単語再変換。
## Investigation
固定版変換器のCandidate.dataに単語のruby/wordがあり、ひらがなへ正規化して全文一致を確認できる。
コピー画面は固定高のキー領域に操作・確認・一覧を詰め込み、ボタンが圧縮されていた。
## Changes
キー20pt/light・方向ガイド9pt常時表示、光と陰影で凸面を表現。読み・候補・補助文字14pt/light。
候補既定非表示。本体設定で初期表示を保存し、目アイコンで一時切替。表示領域は固定する。
旧設定の新しいキー欠落をdecodeIfPresentで扱い、学習/履歴等を保持。
確定前の再変換で単語を選び、左右移動・候補選択でその単語だけ修正。Enterで合成結果を確定。
境界の読み/表記が全文と一致しない場合は1単位とし、推測で本文を切らない。確定後再変換の実験ゲートは維持。
コピー画面をキー面に重ねた全体スクロールへ変更。ボタン44pt・内側余白・2行/縮小表示で文字を収める。
本体のプレビュー・関連文書を更新。
## Validation
Core20テスト成功（単語修正/境界拒否/選択/候補設定移行を追加）。
Simulator統合8テスト成功（UITextViewの単語修正で周囲を保持する試験を追加）。Python13テスト成功。
最終版の署名付きDebug/Releaseビルド成功。codesignのdeep/strict検証成功。
Simulator本体で細い文字・方向ガイド・凸面プレビューを目視確認。候補表示スイッチが既定OFFであることを確認。
署名なしSimulator本体のApp Group警告は、実機共有試験とは区別。コピー画面の実機操作は未確認。
生成一致、文書存在/リンク/行数の代替Verify、git diff --check成功。PowerShellの標準Verifyは未実行。
## Files Changed
Core/InputEngine/Composition.swift、Core/InputEngine/WordReconversion.swift、Core/Layout/LayoutPreferences.swift
KeyboardExtension/Input/AzooKeyConversion.swift、KeyboardExtension/KeyboardViewController.swift、KeyboardExtension/UI/FlickButton.swift
DesignSystem/Theme/ThemeRendering.swift、DesignSystem/Preview/KeyboardPreview.swift
App/Settings/SettingsView.swift、App/Theme/ThemeViews.swift
Tests/Unit/WordReconversionTests.swift、Tests/Integration/LiveMarkedTextTests.swift
CURRENT.md、ARCHITECTURE.md、CODEMAP.md、TESTING.md、UI/UX・Mac手順、設計判断、この記録。
## Result
Vesperaへの更新インストール成功。
## Remaining Issues
実機でコピー取込/保存/履歴、方向ガイド、長押し、複数単語の境界・再変換・候補表示切替を網羅確認する必要がある。
境界がない候補は全体1単位として表示する。単語の修正合成は学習tokenを使用しない。
