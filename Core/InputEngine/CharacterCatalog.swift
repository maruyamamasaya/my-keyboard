import Foundation

public enum CharacterPalette: String, CaseIterable, Sendable {
    case emoji, symbol
    public var title: String { self == .emoji ? "絵文字" : "記号" }
}

public struct CharacterCategory: Equatable, Sendable {
    public let id: String
    public let title: String
    public let characters: [String]
    init(_ id: String, _ title: String, _ characters: String) {
        self.id = id; self.title = title
        self.characters = characters.split(separator: " ").map(String.init)
    }
}

/// Curated Unicode text, bundled locally; no remote rankings or downloads.
public enum CharacterCatalog {
    public static func categories(for palette: CharacterPalette) -> [CharacterCategory] {
        palette == .emoji ? emoji : symbols
    }
    public static func contains(_ text: String, in palette: CharacterPalette) -> Bool {
        categories(for: palette).contains { $0.characters.contains(text) }
    }
    public static let emoji: [CharacterCategory] = [
        .init("faces", "😀 表情", "😀 😃 😄 😁 😆 😅 😂 🤣 😊 😇 🙂 🙃 😉 😌 😍 🥰 😘 😗 😙 😚 😋 😛 😝 😜 🤪 🤨 🧐 🤓 😎 🥸 🤩 🥳 😏 😒 😞 😔 😟 😕 🙁 ☹️ 😣 😖 😫 😩 🥺 😢 😭 😤 😠 😡 🤬 🤯 😳 🥵 🥶 😱 😨 😰 😥 😓 🤗 🤔 🫢 🤭 🤫 🤥 😶 😐 😑 😬 🙄 😯 😦 😧 😮 😲 🥱 😴 🤤 😪 😵 😵‍💫 🤐 🥴 🤢 🤮 🤧 😷 🤒 🤕 🤑 🤠 😈 👿 👻 💀 ☠️ 👽 🤖 💩 🎃 😺 😸 😹 😻 😼 😽 🙀 😿 😾"),
        .init("people", "👍 人・手", "👋 🤚 🖐️ ✋ 🖖 👌 🤌 🤏 ✌️ 🤞 🤟 🤘 🤙 👈 👉 👆 👇 ☝️ 👍 👎 ✊ 👊 🤛 🤜 👏 🙌 👐 🤲 🤝 🙏 💪 🦾 🦿 🦵 🦶 👂 👃 🧠 👀 👁️ 👅 👄 👶 🧒 👦 👧 🧑 👨 👩 🧓 👴 👵 🙍 🙎 🙅 🙆 💁 🙋 🧏 🙇 🤦 🤷 👮 🧑‍⚕️ 🧑‍🍳 🧑‍🎓 🧑‍💻 🧑‍🚀 👰 🤵 🤰 👼 🦸 🦹 🧙 🧚 🧛 🧜 🧝 🧞 🧟 💃 🕺 🚶 🏃 🧘 🛀 🛌 👍🏻 👍🏼 👍🏽 👍🏾 👍🏿 🙏🏻 🙏🏼 🙏🏽 🙏🏾 🙏🏿 👋🏻 👋🏼 👋🏽 👋🏾 👋🏿"),
        .init("hearts", "❤️ 気持ち", "❤️ 🧡 💛 💚 💙 💜 🖤 🤍 🤎 💔 ❣️ 💕 💞 💓 💗 💖 💘 💝 💟 ❤️‍🔥 ❤️‍🩹 💋 💌 💯 💢 💥 💫 💦 💨 💤 🥹 🫶 🫶🏻 🫶🏼 🫶🏽 🫶🏾 🫶🏿 🫰 🫰🏻 🫰🏼 🫰🏽 🫰🏾 🫰🏿"),
        .init("nature", "🌸 動物・自然", "🐶 🐱 🐭 🐹 🐰 🦊 🐻 🐼 🐻‍❄️ 🐨 🐯 🦁 🐮 🐷 🐸 🐵 🙈 🙉 🙊 🐔 🐧 🐦 🐤 🦆 🦉 🦇 🐺 🐗 🐴 🦄 🐝 🐛 🦋 🐌 🐞 🐜 🪲 🦗 🕷️ 🦂 🐢 🐍 🦎 🦖 🐙 🦑 🦐 🦀 🐠 🐟 🐡 🐬 🐳 🦈 🐊 🐘 🦒 🦓 🦍 🦧 🐪 🦙 🦘 🦥 🦦 🦔 🐾 🌸 💐 🌷 🌹 🥀 🌺 🌻 🌼 🌿 🍀 🍁 🍂 🍃 🌱 🌲 🌳 🌴 🌵 🍄 🌎 🌙 ⭐ 🌟 ✨ ☀️ 🌤️ ☁️ 🌧️ ⛈️ 🌈 ❄️ ⛄ 🔥 💧 🌊"),
        .init("food", "🍎 食べ物", "🍎 🍏 🍐 🍊 🍋 🍌 🍉 🍇 🍓 🫐 🍈 🍒 🍑 🥭 🍍 🥥 🥝 🍅 🍆 🥑 🥦 🥬 🥒 🌶️ 🫑 🌽 🥕 🧄 🧅 🥔 🍠 🥐 🥯 🍞 🥖 🥨 🧀 🥚 🍳 🧈 🥞 🧇 🥓 🥩 🍗 🍖 🌭 🍔 🍟 🍕 🥪 🌮 🌯 🥙 🥗 🍝 🍜 🍲 🍛 🍣 🍱 🥟 🍙 🍚 🍘 🍢 🍡 🍧 🍨 🍦 🥧 🧁 🍰 🎂 🍮 🍭 🍬 🍫 🍿 🍩 🍪 🥜 🍯 🥛 ☕ 🍵 🧃 🥤 🧋 🍶 🍺 🍻 🥂 🍷 🍸 🍹 🍾 🧊 🥄 🍴 🥢"),
        .init("travel", "🚗 乗り物・場所", "🚗 🚕 🚙 🚌 🚎 🏎️ 🚓 🚑 🚒 🚐 🛻 🚚 🚛 🚜 🛵 🏍️ 🚲 🛴 🛹 🛼 🚂 🚆 🚇 🚊 🚉 🚅 🚄 ✈️ 🛫 🛬 🛩️ 🚀 🛸 🚁 ⛵ 🚤 🛥️ 🛳️ 🚢 ⚓ ⛽ 🚦 🚥 🗺️ 🗿 🗽 🗼 🏰 🏯 🏟️ 🎡 🎢 🎠 ⛲ ⛱️ 🏖️ 🏝️ 🏜️ 🌋 🏔️ 🗻 🏕️ 🏠 🏡 🏢 🏬 🏥 🏦 🏨 🏪 🏫 ⛩️ 💒 🌃 🌆 🌇 🌉 🎆 🎇"),
        .init("activities", "🎉 遊び・お祝い", "🎉 🎊 🎈 🎁 🎀 🎄 🎋 🎍 🎎 🎏 🎐 🧧 🪄 🎃 🎗️ 🎟️ 🎫 🏆 🥇 🥈 🥉 🏅 ⚽ 🏀 🏈 ⚾ 🥎 🎾 🏐 🏉 🥏 🎱 🏓 🏸 🏒 🏑 🥍 🏏 🥅 ⛳ 🏹 🎣 🤿 🥊 🥋 🎽 🛷 ⛸️ 🥌 🎿 ⛷️ 🏂 🏋️ 🤼 🤸 ⛹️ 🤺 🤾 🏌️ 🏇 🧗 🏊 🚣 🏄 🚴 🎮 🕹️ 🎲 ♟️ 🧩 🎭 🎨 🎬 🎤 🎧 🎼 🎹 🥁 🎷 🎺 🎸 🎻"),
        .init("objects", "💡 道具・マーク", "⌚ 📱 💻 ⌨️ 🖥️ 🖨️ 🖱️ 💾 💿 📷 📸 🎥 📺 📻 ☎️ 📞 🔋 🔌 💡 🔦 🕯️ 🪔 🧯 🛢️ 💸 💵 💴 💶 💷 💰 💳 💎 ⚖️ 🔧 🔨 🛠️ ⚙️ 🧱 🔫 💣 🔪 🛡️ 🔮 🧿 💈 ⚗️ 🧪 🧬 🔬 🔭 💊 💉 🩹 🩺 🚪 🛏️ 🛋️ 🪑 🚿 🛁 🧼 🪥 🧽 🧹 🧺 🧻 🗑️ 🔑 🗝️ 🔒 🔓 📦 ✉️ 📧 📮 📚 📖 📝 ✏️ 🖊️ 📌 📍 📎 ✂️ 📅 ✅ ☑️ ✔️ ❌ ❎ ❓ ❗ ❕ ❔ ⚠️ 🚫 ⛔ 🔞 ♻️ 🔰 🔱 🔴 🟠 🟡 🟢 🔵 🟣 ⚫ ⚪ 🟥 🟧 🟨 🟩 🟦 🟪 ⬛ ⬜ 🔶 🔷 🔸 🔹 🔺 🔻 🏁 🚩 🎌 🏳️ 🏴 🇯🇵 🇺🇸 🇬🇧 🇫🇷 🇩🇪 🇮🇹 🇨🇦 🇦🇺 🇰🇷 🇨🇳")
    ]
    public static let symbols: [CharacterCategory] = [
        .init("punctuation", "句読点", "、 。 ， ． ・ ： ； ？ ！ … ‥ 〜 ～ ー — – _ ＿ / ／ \\ ＼ | ｜ ‖ ' ’ ‘ \" ” “ 〃 ゛ ゜ 々 〆 〇 ※ 〒 § ¶ † ‡"),
        .init("brackets", "括弧", "( ) （ ） [ ] ［ ］ { } ｛ ｝ < > ＜ ＞ 「 」 『 』 【 】 〔 〕 〈 〉 《 》 ｟ ｠ ⦅ ⦆ ⌈ ⌉ ⌊ ⌋ () [] {} （） 「」 『』 【】 〈〉 《》"),
        .init("decorative", "星・ハート", "☆ ★ ✦ ✧ ✩ ✪ ✫ ✬ ✭ ✮ ✯ ✰ ⋆ ♡ ♥ ❤ ❥ ❦ ❧ ❀ ✿ ❁ ✾ ✽ ❃ ❋ ✼ ✺ ✹ ✸ ✷ ✶ ✵ ✴ ✳ ✲ ✱ ✻ ○ ● ◎ ◯ ◉ ◌ ◍ ◐ ◑ ◒ ◓ ◔ ◕ □ ■ ▢ ▣ ▤ ▥ ▦ ▧ ▨ ▩ △ ▲ ▽ ▼ ◇ ◆ ◈ ♠ ♣ ♦ ♤ ♧ ♢ ♪ ♫ ♬ ♩ ♭ ♮ ♯ ☀ ☁ ☂ ☃ ☾ ☽"),
        .init("arrows", "矢印", "← → ↑ ↓ ↔ ↕ ↖ ↗ ↘ ↙ ⇒ ⇐ ⇑ ⇓ ⇔ ⇕ ↩ ↪ ↶ ↷ ↺ ↻ ⇦ ⇨ ⇧ ⇩ ⇄ ⇆ ⇋ ⇌ ↼ ⇀ ↽ ⇁ ↿ ⇂ ↾ ⇃ ➜ ➝ ➞ ➟ ➠ ➡ ➢ ➣ ➤ ➥ ➦ ➧ ➨ ➩ ➪ ➫ ➬ ➭ ➮ ➯ ➱ ➲ ⤴ ⤵"),
        .init("math", "数学・通貨", "+ − ± ∓ × ÷ = ≠ ≒ ≈ ≡ < > ≤ ≥ ≦ ≧ ∞ ∝ √ ∛ ∜ ∑ ∏ ∫ ∬ ∭ ∮ ∂ ∇ ∆ ∴ ∵ ∠ ⊥ ∥ ∈ ∉ ∋ ⊂ ⊃ ⊆ ⊇ ∪ ∩ ∅ ∀ ∃ ¬ ∧ ∨ ⊕ ⊗ ∘ ′ ″ ‰ ‱ % ％ ° ℃ ℉ ¥ ￥ $ ＄ € £ ¢ ₩ ₹ ₽ α β γ δ ε ζ η θ ι κ λ μ ν ξ ο π ρ σ τ υ φ χ ψ ω"),
        .init("numbers", "数字・単位", "① ② ③ ④ ⑤ ⑥ ⑦ ⑧ ⑨ ⑩ ⑪ ⑫ ⑬ ⑭ ⑮ ⑯ ⑰ ⑱ ⑲ ⑳ ❶ ❷ ❸ ❹ ❺ ❻ ❼ ❽ ❾ ❿ Ⅰ Ⅱ Ⅲ Ⅳ Ⅴ Ⅵ Ⅶ Ⅷ Ⅸ Ⅹ ⅰ ⅱ ⅲ ⅳ ⅴ ⅵ ⅶ ⅷ ⅸ ⅹ ⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ ₀ ₁ ₂ ₃ ₄ ₅ ₆ ₇ ₈ ₉ ㎜ ㎝ ㎞ ㎡ ㎥ ㎎ ㎏ ㏄ ㍉ ㌢ ㌔ ㌘ ㌧ ㍍ ㍑ ㌫ ㌻ ㍻ ㋿"),
        .init("code", "半角・コード", "! ? , . : ; @ # $ % & * + - = _ ~ ^ | \\ / ` ' \" ( ) [ ] { } < > :// https:// http:// @gmail.com -> => == != <= >= && || ++ -- /* */ <!-- --> © ® ™ ℠ № ℡")
    ]
}

public struct RecentCharacters: Sendable {
    public private(set) var items: [String]
    public init(_ items: [String] = []) {
        var seen = Set<String>()
        self.items = Array(items.filter { !$0.isEmpty && seen.insert($0).inserted }.prefix(40))
    }
    public mutating func record(_ text: String) {
        guard !text.isEmpty else { return }
        items.removeAll { $0 == text }; items.insert(text, at: 0)
        items = Array(items.prefix(40))
    }
}
