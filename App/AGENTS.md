# 本体アプリ
- SwiftUIで設定・辞書・手動履歴取り込みを提供する。
- SharedAppGroupとentitlementの一致を確認する。共有書き込みは本体が所有する。例外はフルアクセス有効時の明示的なキーボードカラー選択で、ThemeStoreへ原子的に保存する。
- 保存失敗は画面へ通知し、成功として扱わない。起動時にpasteboard本文を取得しない。
- 検証は [Mac手順](../docs/08-MAC-VALIDATION.md)。Swift Packageテストでは本体UIを検証できない。
