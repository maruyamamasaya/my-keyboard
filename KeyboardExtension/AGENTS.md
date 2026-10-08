# Keyboard Extension
- DocumentProxy・UI・固定版変換器はメインスレッドで使用する。
- フルアクセスなしの基本入力を維持。pasteboard・共有DB書き込みは権限と明示操作で制限する。
- 地球キー、timer/task取消、viewライフサイクルを維持する。
- 再変換・語削除は文脈を確認して拒否できるようにする。
- 検証は [課題表](../docs/07-TESTING-AND-ISSUES.md)。コンパイル・実機の未確認を隠さない。
