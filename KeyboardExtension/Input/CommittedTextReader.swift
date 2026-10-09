import Foundation
import CoreFoundation
import KeyboardCore

/// Local Japanese tokenization. Ambiguous kanji use the system's estimated reading.
enum CommittedTextReader {
    static func wordBeforeCursor(_ text: String) -> String? {
        guard !text.isEmpty else { return nil }
        // The system dictionary may split an unfamiliar katakana word (e.g. キョウ).
        // Keep a continuous katakana run together when converting its script.
        let katakana = text.reversed().prefix { character in
            character.unicodeScalars.allSatisfy {
                (0x30A1...0x30FA).contains($0.value) || $0.value == 0x30FC || (0xFF66...0xFF9F).contains($0.value)
            }
        }
        if !katakana.isEmpty { return String(katakana.reversed()) }
        let tokenizer = makeTokenizer(text)
        var last = CFRange(location: kCFNotFound, length: 0)
        while !CFStringTokenizerAdvanceToNextToken(tokenizer).isEmpty {
            last = CFStringTokenizerGetCurrentTokenRange(tokenizer)
        }
        guard last.location != kCFNotFound, last.location + last.length == text.utf16.count,
              let range = Range(NSRange(location: last.location, length: last.length), in: text) else { return nil }
        return String(text[range])
    }

    static func reading(_ text: String) -> String? {
        guard !text.isEmpty, text.count <= 128 else { return nil }
        let tokenizer = makeTokenizer(text)
        var result = "", end = text.startIndex
        while !CFStringTokenizerAdvanceToNextToken(tokenizer).isEmpty {
            let tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            guard let range = Range(NSRange(location: tokenRange.location, length: tokenRange.length), in: text) else { return nil }
            result += text[end..<range.lowerBound]
            let token = String(text[range])
            if token.unicodeScalars.contains(where: isKanji) {
                guard let latin = CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription) as? String,
                      let kana = latin.applyingTransform(.latinToKatakana, reverse: false) else { return nil }
                let reading = KanaModifier.hiragana(kana)
                guard reading != token, !reading.unicodeScalars.contains(where: isKanji) else { return nil }
                result += reading
            } else { result += KanaModifier.hiragana(token) }
            end = range.upperBound
        }
        result += text[end...]
        guard !result.unicodeScalars.contains(where: isKanji) else { return nil }
        return result
    }

    private static func isKanji(_ scalar: UnicodeScalar) -> Bool {
        (0x3400...0x9FFF).contains(scalar.value) || (0xF900...0xFAFF).contains(scalar.value)
            || (0x20000...0x323AF).contains(scalar.value) || scalar.value == 0x3005
    }
    private static func makeTokenizer(_ text: String) -> CFStringTokenizer {
        CFStringTokenizerCreate(nil, text as CFString, CFRange(location: 0, length: text.utf16.count),
                                kCFStringTokenizerUnitWord, CFLocaleCreate(nil, CFLocaleIdentifier(rawValue: "ja_JP" as CFString)))
    }
}
