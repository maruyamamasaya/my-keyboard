# 予測領域の固定と枠なし候補
## Request
予測変換でキーが動く問題を修正し、上側余白を増やして上部の幅を狭める。予測候補は枠にしない。
## Investigation
renderが未確定の読みの有無でreadingLabelを隠し、UIStackViewから20ptの行が消えるため、キー面の位置と高さが変化していた。
候補の装飾は入力キーと同じcharacterロールだった。
## Changes
読み・候補・ツールバーを高さ120ptの固定ヘッダーへ配置。空の読みも空欄として領域を残す。
上端余白4→16pt、ヘッダー内の左右余白を12ptに設定。主キーの横幅は維持。
候補専用candidateロールを追加し、背景・枠・影をなくす。タップ確定と44ptのタップ領域は維持。
本体の共通プレビューも余白と枠なし候補に合わせる。
## Files Changed
KeyboardExtension/KeyboardViewController.swift
DesignSystem/Theme/ThemeRendering.swift、DesignSystem/Preview/KeyboardPreview.swift
CURRENT.md、docs/10-UI-UX-AND-THEMES.md、この記録。
## Validation
最終版の署名付きDebug/Release実機ビルド、codesignのdeep/strict検証成功。
Simulator Storage5テスト、Python13テスト、生成一致、文書代替Verify、git diff --check成功。
PowerShellの標準Verifyは未実行。Core変更なしのためSwift Coreテストは再実行しない。
## Result
Vesperaへ更新インストール成功。候補の表示有無で読み行を隠す処理はなくし、上部の高さを固定。
## Remaining Issues
実機で候補開始・更新・確定を繰り返した位置の確認は未実施。ホスト側の外枠・高さ制約には依存する。
