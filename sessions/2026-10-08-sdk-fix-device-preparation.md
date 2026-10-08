# SDK compatibility fix and device preparation
## Request
3アプリを指定端末へビルド・インストール。既存署名・プロビジョニングだけを使用し、新規証明書、認証情報、App Groupsの権限拡張、セキュリティ設定変更、アンインストールをしない。
## Investigation
接続端末の実名はVespera（iPhone 17e、UDID末尾0E33401C）。依頼表記Vesparaと異なるため、対象確認を提示。確認前のインストールなし。
既存ワイルドカードプロファイルは対象端末を含むがApp Groupsなし。my-keyboardの現在のgroup.org.example.mykeyboardに対応する既存プロファイルなし。
## Changes
DocumentProxyAdapter.swiftのCFLocaleCreate引数だけをCFLocaleIdentifier(rawValue:)へ修正。日本語ロケールと削除ロジックは保持。署名・entitlements・App Group設定は未変更。
## Files Changed
- KeyboardExtension/Input/DocumentProxyAdapter.swift
- CURRENT.md
- sessions/2026-10-08-sdk-fix-device-preparation.md
## Validation
修正後の署名なしDebug buildはgeneric iOS／generic iOS Simulatorとも成功。生成一致、既存13構造/SQLテスト、git diff --check、文書検査成功。
既存プロファイルで署名ビルドを試すとApp Groups capability／com.apple.security.application-groups entitlement不足を明示。Xcode管理プロファイルと手動署名の不一致、SPMリソースbundleへのprofile指定エラーも発生。設定変更でこれらを迂回していない。
photo-hub／Presentation-Viewerは既存ワイルドカードprofileと既存identityでオフラインcodesignが成功し、通常Securityサービス下のcodesign --verify --deep --strictが成功。プロジェクトの署名設定は未変更、Apple側への資産登録なし。
自動署名の再試行はauto-reviewが新規管理プロファイル作成・更新リスクを理由に拒否。既存profileでのオフライン手動署名という安全な代替を使用。初回sandbox内verifyのCSSMERR_TP_NOT_TRUSTEDは通常サービス下のread-only verifyで成功し、信頼設定は未変更。
## Result
my-keyboardのコンパイル問題は解消。既存App Groups対応profile不足のためmy-keyboardのインストール用署名は未完了。
photo-hub／Presentation-Viewerの署名済みコピーを作業成果物のvespera-installへ準備。端末名確認待ちのためインストール・起動は未実施。
## Remaining Issues
本人がVesperaが対象であることを確認する必要がある。my-keyboardは本人が既存の対応プロファイルを提供するか、新規App Group／対応プロファイル整備を別途明示承認する必要がある。今回新規作成・権限付与は行わない。Full Access、写真ライブラリ権限、Developer Mode、信頼、キーチェーン許可は操作していない。
