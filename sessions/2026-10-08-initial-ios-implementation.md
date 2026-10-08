# iOS初期実装

## Request
ロードマップに沿ってXcodeなしで実装を継続し、未検証項目とMac手順を作成する。

## Investigation
ルートルール・設計6文書・ロードマップ・検証方法を確認。Swift・Xcodeなし、Python/Gitあり。
変換器v0.8.5のcommit・manifest・API・学習保存・MIT、辞書と絵文字の由来を確認。

## Changes
Phase 1〜5の初期ソース、Phase 6の検証準備を作成。
本体、Extension、Core Package、SPM参照、SQLite手動履歴、設定・辞書、生成Xcodeプロジェクト。
実験的再変換・語削除は既定無効。子AGENTSは本体と拡張にのみ追加。

## Files Changed
App、KeyboardExtension、Core、Storage、Shared、Config、Resources、Tests、MyKeyboard.xcodeproj、Package.swift、.gitignore。
scripts/generate_project.py、verify.ps1、docs/07〜09、設計文書とルート案内、判断0003、本記録。

## Validation
Pythonの10構造/実SQLスキーマテスト成功。生成一致・文書Fast/Full検証。
SQLiteファイルテストの一時フォルダーをワークスペースへ変更して環境権限の失敗を解消。
Swift型検査・Core 8テスト・iOS統合3テスト・Xcodeビルド・実機は未実行。

## Result
Macへ移してビルド・検証に着手できるソース・設定・手順を作成。動作完成とは扱わない。
コミット・Pushは行っていない。

## Remaining Issues
T-001〜019。最初はSwift Core testとXcode依存解決・Debug/Releaseビルド。
署名、ホスト編集、資源同梱、権限、UI、性能、全ライセンス・Privacy Reportを後日検証。
