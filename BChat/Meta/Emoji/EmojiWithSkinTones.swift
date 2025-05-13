// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation
import GRDB
import DifferenceKit
import BChatMessagingKit

public struct EmojiWithSkinTones: Hashable, Equatable, ContentEquatable, ContentIdentifiable {
    let baseEmoji: Emoji
    let skinTones: [Emoji.SkinTone]?
    
    init(baseEmoji: Emoji, skinTones: [Emoji.SkinTone]? = nil) {
        self.baseEmoji = baseEmoji

        // Deduplicate skin tones, while preserving order. This allows for
        // multi-skin tone emoji, where if you have for example the permutation
        // [.dark, .dark], it is consolidated to just [.dark], to be initialized
        // with either variant and result in the correct emoji.
        self.skinTones = skinTones?.reduce(into: [Emoji.SkinTone]()) { result, skinTone in
            guard !result.contains(skinTone) else { return }
            result.append(skinTone)
        }
    }

    var rawValue: String {
        if let skinTones = skinTones {
            return baseEmoji.emojiPerSkinTonePermutation?[skinTones] ?? baseEmoji.rawValue
        } else {
            return baseEmoji.rawValue
        }
    }
    
    var normalized: EmojiWithSkinTones {
        switch (baseEmoji, skinTones) {
        case (let base, nil) where base.normalized != base:
            return EmojiWithSkinTones(baseEmoji: base.normalized)
        default:
            return self
        }
    }

    var isNormalized: Bool { self == normalized }
}

//@available(iOS 13, *)
extension Emoji {
    private static let emojiWithPreferredSkinToneCollection = "Emoji+PreferredSkinTonePermutation"

    static func allSendableEmojiByCategoryWithPreferredSkinTones(transaction: YapDatabaseReadTransaction) -> [Category: [EmojiWithSkinTones]] {
        return Category.allCases.reduce(into: [Category: [EmojiWithSkinTones]]()) { result, category in
            result[category] = category.normalizedEmoji.filter { $0.available }.map { $0.withPreferredSkinTones(transaction: transaction) }
        }
    }

    func withPreferredSkinTones(transaction: YapDatabaseReadTransaction) -> EmojiWithSkinTones {
        guard let rawSkinTones = transaction.object(forKey: rawValue, inCollection: Self.emojiWithPreferredSkinToneCollection) as? [String] else {
            return EmojiWithSkinTones(baseEmoji: self, skinTones: nil)
        }

        return EmojiWithSkinTones(baseEmoji: self, skinTones: rawSkinTones.compactMap { SkinTone(rawValue: $0) })
    }

    func setPreferredSkinTones(_ preferredSkinTonePermutation: [SkinTone]?, transaction: YapDatabaseReadWriteTransaction) {
        if let preferredSkinTonePermutation = preferredSkinTonePermutation {
            transaction.setObject(preferredSkinTonePermutation.map { $0.rawValue }, forKey: rawValue, inCollection: Self.emojiWithPreferredSkinToneCollection)
        } else {
            transaction.removeObject(forKey: rawValue, inCollection: Self.emojiWithPreferredSkinToneCollection)
        }
    }

    init?(_ string: String) {
        guard let emojiWithSkinTonePermutation = EmojiWithSkinTones(rawValue: string) else { return nil }
        self = emojiWithSkinTonePermutation.baseEmoji
    }
}

// MARK: -

extension String {
    // This is slightly more accurate than String.isSingleEmoji,
    // but slower.
    //
    // * This will reject "lone modifiers".
    // * This will reject certain edge cases such as 🌈️.
    var isSingleEmojiUsingEmojiWithSkinTones: Bool {
        EmojiWithSkinTones(rawValue: self) != nil
    }
}
