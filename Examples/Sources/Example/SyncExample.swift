import Foundation

enum PluralizationError: Error {
    case unknownLanguage
}

/// A "too naive" implementation of English pluralization.
/// - SeeAlso: https://www.grammarly.com/blog/irregular-plural-nouns/
public func pluralize(word: String) throws -> String {
    let isAlphabetOnly = word.unicodeScalars.allSatisfy(CharacterSet.alphanumerics.contains)
    guard isAlphabetOnly else { throw PluralizationError.unknownLanguage }

    let suffixMapping: [String: String] = [
        "f": "ves",
        "fe": "ves",
        "o": "oes",
    ]

    for (key, value) in suffixMapping where word.hasSuffix(key) {
        let start = word.index(word.endIndex, offsetBy: -key.count)
        return word.replacingCharacters(in: start ..< word.endIndex, with: value)
    }

    return word + "s"
}
