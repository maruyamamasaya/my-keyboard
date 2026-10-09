import Foundation

public enum FlickDirection: Int, Sendable { case center, left, up, right, down }
public struct FlickKey: Sendable {
    public let characters: [String]
    public let label: String
    public init(_ characters: [String], label: String? = nil) {
        self.characters = characters; self.label = label ?? characters[0]
    }
    public func text(_ direction: FlickDirection) -> String {
        characters.indices.contains(direction.rawValue) ? characters[direction.rawValue] : ""
    }
}
public enum FlickMap {
    // center, left, up, right, down; empty entries deliberately produce no character.
    public static let japanese = [
        FlickKey(["あ", "い", "う", "え", "お"]), FlickKey(["か", "き", "く", "け", "こ"]), FlickKey(["さ", "し", "す", "せ", "そ"]),
        FlickKey(["た", "ち", "つ", "て", "と"]), FlickKey(["な", "に", "ぬ", "ね", "の"]), FlickKey(["は", "ひ", "ふ", "へ", "ほ"]),
        FlickKey(["ま", "み", "む", "め", "も"]), FlickKey(["や", "", "ゆ", "", "よ"]), FlickKey(["ら", "り", "る", "れ", "ろ"]),
        FlickKey(["゛小", "", "", "", ""]), FlickKey(["わ", "を", "ん", "ー", "〜"]), FlickKey(["、", "。", "？", "！", "…"])
    ]
    public static let engineeringSymbols = [
        FlickKey(["://", ":", ".", "/", "https://"]), FlickKey(["@", "#", "＠", "&", "_"]), FlickKey(["`", "'", "\"", "\\", "|"]),
        FlickKey(["/", "\\", ":", ".", "?"]), FlickKey(["{", "}", "<", ">", "$"]), FlickKey(["}", "{", "[", "]", "~"]),
        FlickKey(["[", "]", "<", "{", "!"]), FlickKey(["]", "[", ">", "}", "#"]), FlickKey(["(", ")", "?", "!", "^"]),
        FlickKey([")", "(", "*", "%", "&"]), FlickKey(["=", "+", "-", "*", "/"]), FlickKey([";", ":", "_", "$", ","])
    ]
    /// Markdown, code operators, and shell fragments; center, left, up, right, down.
    public static let developerSymbols = [
        FlickKey(["# ", "## ", "### ", "#### ", "> "], label: "#"),
        FlickKey(["**", "*", "__", "_", "~~"]),
        FlickKey(["```", "`", "```swift\n", "```sh\n", "```json\n"]),
        FlickKey(["- ", "* ", "1. ", "- [ ] ", "- [x] "], label: "- [ ]"),
        FlickKey(["[]()", "![]()", "[]", "()", "{}"]),
        FlickKey(["---", "***", "___", "<!--", "-->"]),
        FlickKey(["=>", "->", "<-", "::", "..."]),
        FlickKey(["==", "!=", "===", "!==", ":="]),
        FlickKey(["&&", "||", "??", "?.", "!!"]),
        FlickKey(["../", "./", "~/", "../../", "/"]),
        FlickKey(["--", " -", " --", "=", "$ "]),
        FlickKey(["|", " > ", " >> ", " < ", " 2>&1"])
    ]
    public static func english(uppercase: Bool) -> [FlickKey] {
        ["@#/&_", "abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz", "⇧", "'\"()", ".,?!"].map { group in
            if group == "⇧" { return FlickKey([group], label: "a/A") }
            let letters = uppercase ? group.uppercased() : group
            return FlickKey(letters.map { String($0) }, label: letters)
        }
    }
    public static func direction(dx: Double, dy: Double, threshold: Double = 18) -> FlickDirection {
        guard max(abs(dx), abs(dy)) >= threshold else { return .center }
        if abs(dx) > abs(dy) { return dx < 0 ? .left : .right }
        return dy < 0 ? .up : .down
    }
}
