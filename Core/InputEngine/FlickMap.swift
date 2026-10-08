import Foundation

public enum FlickDirection: Int, Sendable { case center, left, up, right, down }
public struct FlickKey: Sendable {
    public let characters: [String]
    public var label: String { characters[0] }
    public init(_ characters: [String]) { self.characters = characters }
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
    public static func direction(dx: Double, dy: Double, threshold: Double = 18) -> FlickDirection {
        guard max(abs(dx), abs(dy)) >= threshold else { return .center }
        if abs(dx) > abs(dy) { return dx < 0 ? .left : .right }
        return dy < 0 ? .up : .down
    }
}
