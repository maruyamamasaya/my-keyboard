# 確定済み文字の変換
## Request
選択した文字とカーソル直前の単語、両方を変換できるようにする。
## Investigation
selectedTextはinsertTextで置換可能。未選択時は日本語単語解析を使う。漢字のLatin transcriptionから読みを得られることをローカルAPIで確認。
## Changes
- 未確定のかな/カナ/ローマ字を維持し、確定後は選択優先/直前単語へ拡張。
- 上部に再変換追加。候補を選ぶまで本文を変更せず取消可能。
- 端末内の読み推定。直前確定の単語が一致すれば元の読みを利用。
- 文書状態を捕捉し、選択変更/文書変更後の候補適用を拒否。
- 選択128文字、直前単語32文字かつ単一UTF-16単位に制限。
## Files Changed
- Core/TextEditing/CommittedTextTarget.swift
- KeyboardExtension/Input/CommittedTextReader.swift、DocumentProxyAdapter.swift、KeyboardViewController.swift
- DesignSystem/Preview/KeyboardPreview.swift、単体/統合テスト、生成Xcode設定
- CURRENT、CODEMAP、ARCHITECTURE、TESTING、UI/UX、Mac検証、課題表、設計判断0006
## Validation
- Core33テスト成功。
- iOS17.4の初回統合19テストとiOS26.5の新機能3テスト成功。上部ボタンからの連続変換でカタカナ分割の不具合を検出し、連続カタカナを一括対象へ修正。最終テスト結果は後述。
- UIKitで選択の今日→きょう、直前単語→キョウ→kyou、前後の本文/絵文字保持を確認。
- 読み/単語境界、候補プレビュー/取消、選択変更時の拒否、文書変更時の削除停止を確認。
- Python13テスト成功。PowerShell未導入のためVerifyはPython代替。
## Result
最終のCore33テスト、iOS17.4統合21テスト、iOS26.5新機能5テスト成功。上部ボタン→選択/直前単語変換→漢字候補選択、取消、カーソル変更後の古い候補の拒否まで確認。署名付き実機Releaseビルド、codesign --verify --deep --strict成功。2026-10-09 22:27 JST、Vesperaへ更新インストール・本体起動成功。生成設定一致、Python13テスト、Full相当文書リンク/行数検査、git diff --check成功。
## Remaining Issues
漢字の読みは推定。直前単語の置換は原子的ではなく、ホストの途中変更時には部分削除が残る可能性がある。実機ホストでの入力互換性は未検証。
