# Resume unsigned builds
## Request
本人のMac復帰後、保留中の依存解決とSimulator／実機向け署名なしビルドを再試行。認証、署名、セキュリティ、ネットワーク、依存先を変更しない。
## Investigation
既存clone・アイコンコミット・DerivedDataを保持し、二重起動せずSimulator Debug buildを再開。初期サンプルではキーチェーン応答待ちを確認。本人の確認操作後、同じプロセスが依存解決とSwiftコンパイルまで進んだ。
## Changes
アプリソースと設定は変更なし。CURRENTと今回の検証記録のみ更新。
## Files Changed
- CURRENT.md
- sessions/2026-10-08-build-resume.md
## Validation
Xcode 26.6 (17F113)。AzooKey固定revision 8278b6bと既存の依存解決が完了。Binary artifactsは239MB取得済み。generic iOS Simulator Debugとgeneric iOS Debugの署名なしbuildは、いずれも終了コード65で失敗。
共通エラー: KeyboardExtension/Input/DocumentProxyAdapter.swift:34:119 — cannot convert value of type 'CFString' to expected argument type 'CFLocaleIdentifier'。
CFLocaleCreate(nil, "ja_JP" as CFString)の引数型が現在のSDKに不適合。SDKヘッダーにはCFLocaleIdentifier CF_EXTENSIBLE_STRING_ENUMと定義されている。
隔離した/tmp最小コードでは、UIKit/CoreFoundationをimportしCFLocaleCreate(nil, CFLocaleIdentifier(rawValue: "ja_JP" as CFString))とすると実機arm64 iOS17ターゲットのswiftc -typecheck成功。アプリソースには未反映。
git diff --check・生成一致・文書チェック成功。取得時に生成されたPackage.resolvedは成果物側へ退避し今回のコミットに含めない。
## Result
キーチェーン待ちは解消し、依存取得は完了。現時点のブロッカーは既存コードのSDK型不一致。アイコン変更は保持。署名・認証情報・永続許可・セキュリティ・ネットワーク・依存先は変更なし。push・公開・インストールなし。
## Remaining Issues
DocumentProxyAdapterのCFLocaleCreate引数をCFLocaleIdentifierへ合わせ、両プラットフォームのビルドを再実行する必要がある。今回の通常ビルド再試行範囲ではソース修正を行っていない。他のエラーがないかは修正後に確認。Release、StorageTests、実機操作は未確認。
