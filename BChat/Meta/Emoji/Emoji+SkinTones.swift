// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation

extension Emoji {
    enum SkinTone: String, CaseIterable, Equatable {
        case light = "🏻"
        case mediumLight = "🏼"
        case medium = "🏽"
        case mediumDark = "🏾"
        case dark = "🏿"
    }
    
    var hasSkinTones: Bool { return emojiPerSkinTonePermutation != nil }
    var allowsMultipleSkinTones: Bool { return hasSkinTones && skinToneComponentEmoji != nil }
    
    var skinToneComponentEmoji: [Emoji]? {
        switch self {
        case .handshake: return [.rightwardsHand, .leftwardsHand]
        case .peopleHoldingHands: return [.standingPerson, .standingPerson]
        case .twoWomenHoldingHands: return [.womanStanding, .womanStanding]
        case .manAndWomanHoldingHands: return [.womanStanding, .manStanding]
        case .twoMenHoldingHands: return [.manStanding, .manStanding]
        case .personKissPerson: return [.adult, .adult]
        case .womanKissMan: return [.woman, .man]
        case .manKissMan: return [.man, .man]
        case .womanKissWoman: return [.woman, .woman]
        case .personHeartPerson: return [.adult, .adult]
        case .womanHeartMan: return [.woman, .man]
        case .manHeartMan: return [.man, .man]
        case .womanHeartWoman: return [.woman, .woman]
        default: return nil
        }
    }
    
    var emojiPerSkinTonePermutation: [[SkinTone]: String]? {
        switch self {
        case .wave:
            return [
                [.light]: "👋🏻",
                [.mediumLight]: "👋🏼",
                [.medium]: "👋🏽",
                [.mediumDark]: "👋🏾",
                [.dark]: "👋🏿",
            ]
        case .raisedBackOfHand:
            return [
                [.light]: "🤚🏻",
                [.mediumLight]: "🤚🏼",
                [.medium]: "🤚🏽",
                [.mediumDark]: "🤚🏾",
                [.dark]: "🤚🏿",
            ]
        case .raisedHandWithFingersSplayed:
            return [
                [.light]: "🖐🏻",
                [.mediumLight]: "🖐🏼",
                [.medium]: "🖐🏽",
                [.mediumDark]: "🖐🏾",
                [.dark]: "🖐🏿",
            ]
        case .hand:
            return [
                [.light]: "✋🏻",
                [.mediumLight]: "✋🏼",
                [.medium]: "✋🏽",
                [.mediumDark]: "✋🏾",
                [.dark]: "✋🏿",
            ]
        case .spockHand:
            return [
                [.light]: "🖖🏻",
                [.mediumLight]: "🖖🏼",
                [.medium]: "🖖🏽",
                [.mediumDark]: "🖖🏾",
                [.dark]: "🖖🏿",
            ]
        case .rightwardsHand:
            return [
                [.light]: "🫱🏻",
                [.mediumLight]: "🫱🏼",
                [.medium]: "🫱🏽",
                [.mediumDark]: "🫱🏾",
                [.dark]: "🫱🏿",
            ]
        case .leftwardsHand:
            return [
                [.light]: "🫲🏻",
                [.mediumLight]: "🫲🏼",
                [.medium]: "🫲🏽",
                [.mediumDark]: "🫲🏾",
                [.dark]: "🫲🏿",
            ]
        case .palmDownHand:
            return [
                [.light]: "🫳🏻",
                [.mediumLight]: "🫳🏼",
                [.medium]: "🫳🏽",
                [.mediumDark]: "🫳🏾",
                [.dark]: "🫳🏿",
            ]
        case .palmUpHand:
            return [
                [.light]: "🫴🏻",
                [.mediumLight]: "🫴🏼",
                [.medium]: "🫴🏽",
                [.mediumDark]: "🫴🏾",
                [.dark]: "🫴🏿",
            ]
        case .leftwardsPushingHand:
            return [
                [.light]: "🫷🏻",
                [.mediumLight]: "🫷🏼",
                [.medium]: "🫷🏽",
                [.mediumDark]: "🫷🏾",
                [.dark]: "🫷🏿",
            ]
        case .rightwardsPushingHand:
            return [
                [.light]: "🫸🏻",
                [.mediumLight]: "🫸🏼",
                [.medium]: "🫸🏽",
                [.mediumDark]: "🫸🏾",
                [.dark]: "🫸🏿",
            ]
        case .okHand:
            return [
                [.light]: "👌🏻",
                [.mediumLight]: "👌🏼",
                [.medium]: "👌🏽",
                [.mediumDark]: "👌🏾",
                [.dark]: "👌🏿",
            ]
        case .pinchedFingers:
            return [
                [.light]: "🤌🏻",
                [.mediumLight]: "🤌🏼",
                [.medium]: "🤌🏽",
                [.mediumDark]: "🤌🏾",
                [.dark]: "🤌🏿",
            ]
        case .pinchingHand:
            return [
                [.light]: "🤏🏻",
                [.mediumLight]: "🤏🏼",
                [.medium]: "🤏🏽",
                [.mediumDark]: "🤏🏾",
                [.dark]: "🤏🏿",
            ]
        case .v:
            return [
                [.light]: "✌🏻",
                [.mediumLight]: "✌🏼",
                [.medium]: "✌🏽",
                [.mediumDark]: "✌🏾",
                [.dark]: "✌🏿",
            ]
        case .crossedFingers:
            return [
                [.light]: "🤞🏻",
                [.mediumLight]: "🤞🏼",
                [.medium]: "🤞🏽",
                [.mediumDark]: "🤞🏾",
                [.dark]: "🤞🏿",
            ]
        case .handWithIndexFingerAndThumbCrossed:
            return [
                [.light]: "🫰🏻",
                [.mediumLight]: "🫰🏼",
                [.medium]: "🫰🏽",
                [.mediumDark]: "🫰🏾",
                [.dark]: "🫰🏿",
            ]
        case .iLoveYouHandSign:
            return [
                [.light]: "🤟🏻",
                [.mediumLight]: "🤟🏼",
                [.medium]: "🤟🏽",
                [.mediumDark]: "🤟🏾",
                [.dark]: "🤟🏿",
            ]
        case .theHorns:
            return [
                [.light]: "🤘🏻",
                [.mediumLight]: "🤘🏼",
                [.medium]: "🤘🏽",
                [.mediumDark]: "🤘🏾",
                [.dark]: "🤘🏿",
            ]
        case .callMeHand:
            return [
                [.light]: "🤙🏻",
                [.mediumLight]: "🤙🏼",
                [.medium]: "🤙🏽",
                [.mediumDark]: "🤙🏾",
                [.dark]: "🤙🏿",
            ]
        case .pointLeft:
            return [
                [.light]: "👈🏻",
                [.mediumLight]: "👈🏼",
                [.medium]: "👈🏽",
                [.mediumDark]: "👈🏾",
                [.dark]: "👈🏿",
            ]
        case .pointRight:
            return [
                [.light]: "👉🏻",
                [.mediumLight]: "👉🏼",
                [.medium]: "👉🏽",
                [.mediumDark]: "👉🏾",
                [.dark]: "👉🏿",
            ]
        case .pointUp2:
            return [
                [.light]: "👆🏻",
                [.mediumLight]: "👆🏼",
                [.medium]: "👆🏽",
                [.mediumDark]: "👆🏾",
                [.dark]: "👆🏿",
            ]
        case .middleFinger:
            return [
                [.light]: "🖕🏻",
                [.mediumLight]: "🖕🏼",
                [.medium]: "🖕🏽",
                [.mediumDark]: "🖕🏾",
                [.dark]: "🖕🏿",
            ]
        case .pointDown:
            return [
                [.light]: "👇🏻",
                [.mediumLight]: "👇🏼",
                [.medium]: "👇🏽",
                [.mediumDark]: "👇🏾",
                [.dark]: "👇🏿",
            ]
        case .pointUp:
            return [
                [.light]: "☝🏻",
                [.mediumLight]: "☝🏼",
                [.medium]: "☝🏽",
                [.mediumDark]: "☝🏾",
                [.dark]: "☝🏿",
            ]
        case .indexPointingAtTheViewer:
            return [
                [.light]: "🫵🏻",
                [.mediumLight]: "🫵🏼",
                [.medium]: "🫵🏽",
                [.mediumDark]: "🫵🏾",
                [.dark]: "🫵🏿",
            ]
        case .plusOne:
            return [
                [.light]: "👍🏻",
                [.mediumLight]: "👍🏼",
                [.medium]: "👍🏽",
                [.mediumDark]: "👍🏾",
                [.dark]: "👍🏿",
            ]
        case .negativeOne:
            return [
                [.light]: "👎🏻",
                [.mediumLight]: "👎🏼",
                [.medium]: "👎🏽",
                [.mediumDark]: "👎🏾",
                [.dark]: "👎🏿",
            ]
        case .fist:
            return [
                [.light]: "✊🏻",
                [.mediumLight]: "✊🏼",
                [.medium]: "✊🏽",
                [.mediumDark]: "✊🏾",
                [.dark]: "✊🏿",
            ]
        case .facepunch:
            return [
                [.light]: "👊🏻",
                [.mediumLight]: "👊🏼",
                [.medium]: "👊🏽",
                [.mediumDark]: "👊🏾",
                [.dark]: "👊🏿",
            ]
        case .leftFacingFist:
            return [
                [.light]: "🤛🏻",
                [.mediumLight]: "🤛🏼",
                [.medium]: "🤛🏽",
                [.mediumDark]: "🤛🏾",
                [.dark]: "🤛🏿",
            ]
        case .rightFacingFist:
            return [
                [.light]: "🤜🏻",
                [.mediumLight]: "🤜🏼",
                [.medium]: "🤜🏽",
                [.mediumDark]: "🤜🏾",
                [.dark]: "🤜🏿",
            ]
        case .clap:
            return [
                [.light]: "👏🏻",
                [.mediumLight]: "👏🏼",
                [.medium]: "👏🏽",
                [.mediumDark]: "👏🏾",
                [.dark]: "👏🏿",
            ]
        case .raisedHands:
            return [
                [.light]: "🙌🏻",
                [.mediumLight]: "🙌🏼",
                [.medium]: "🙌🏽",
                [.mediumDark]: "🙌🏾",
                [.dark]: "🙌🏿",
            ]
        case .heartHands:
            return [
                [.light]: "🫶🏻",
                [.mediumLight]: "🫶🏼",
                [.medium]: "🫶🏽",
                [.mediumDark]: "🫶🏾",
                [.dark]: "🫶🏿",
            ]
        case .openHands:
            return [
                [.light]: "👐🏻",
                [.mediumLight]: "👐🏼",
                [.medium]: "👐🏽",
                [.mediumDark]: "👐🏾",
                [.dark]: "👐🏿",
            ]
        case .palmsUpTogether:
            return [
                [.light]: "🤲🏻",
                [.mediumLight]: "🤲🏼",
                [.medium]: "🤲🏽",
                [.mediumDark]: "🤲🏾",
                [.dark]: "🤲🏿",
            ]
        case .handshake:
            return [
                [.light]: "🤝🏻",
                [.light, .mediumLight]: "🫱🏻‍🫲🏼",
                [.light, .medium]: "🫱🏻‍🫲🏽",
                [.light, .mediumDark]: "🫱🏻‍🫲🏾",
                [.light, .dark]: "🫱🏻‍🫲🏿",
                [.mediumLight]: "🤝🏼",
                [.mediumLight, .light]: "🫱🏼‍🫲🏻",
                [.mediumLight, .medium]: "🫱🏼‍🫲🏽",
                [.mediumLight, .mediumDark]: "🫱🏼‍🫲🏾",
                [.mediumLight, .dark]: "🫱🏼‍🫲🏿",
                [.medium]: "🤝🏽",
                [.medium, .light]: "🫱🏽‍🫲🏻",
                [.medium, .mediumLight]: "🫱🏽‍🫲🏼",
                [.medium, .mediumDark]: "🫱🏽‍🫲🏾",
                [.medium, .dark]: "🫱🏽‍🫲🏿",
                [.mediumDark]: "🤝🏾",
                [.mediumDark, .light]: "🫱🏾‍🫲🏻",
                [.mediumDark, .mediumLight]: "🫱🏾‍🫲🏼",
                [.mediumDark, .medium]: "🫱🏾‍🫲🏽",
                [.mediumDark, .dark]: "🫱🏾‍🫲🏿",
                [.dark]: "🤝🏿",
                [.dark, .light]: "🫱🏿‍🫲🏻",
                [.dark, .mediumLight]: "🫱🏿‍🫲🏼",
                [.dark, .medium]: "🫱🏿‍🫲🏽",
                [.dark, .mediumDark]: "🫱🏿‍🫲🏾",
            ]
        case .pray:
            return [
                [.light]: "🙏🏻",
                [.mediumLight]: "🙏🏼",
                [.medium]: "🙏🏽",
                [.mediumDark]: "🙏🏾",
                [.dark]: "🙏🏿",
            ]
        case .writingHand:
            return [
                [.light]: "✍🏻",
                [.mediumLight]: "✍🏼",
                [.medium]: "✍🏽",
                [.mediumDark]: "✍🏾",
                [.dark]: "✍🏿",
            ]
        case .nailCare:
            return [
                [.light]: "💅🏻",
                [.mediumLight]: "💅🏼",
                [.medium]: "💅🏽",
                [.mediumDark]: "💅🏾",
                [.dark]: "💅🏿",
            ]
        case .selfie:
            return [
                [.light]: "🤳🏻",
                [.mediumLight]: "🤳🏼",
                [.medium]: "🤳🏽",
                [.mediumDark]: "🤳🏾",
                [.dark]: "🤳🏿",
            ]
        case .muscle:
            return [
                [.light]: "💪🏻",
                [.mediumLight]: "💪🏼",
                [.medium]: "💪🏽",
                [.mediumDark]: "💪🏾",
                [.dark]: "💪🏿",
            ]
        case .leg:
            return [
                [.light]: "🦵🏻",
                [.mediumLight]: "🦵🏼",
                [.medium]: "🦵🏽",
                [.mediumDark]: "🦵🏾",
                [.dark]: "🦵🏿",
            ]
        case .foot:
            return [
                [.light]: "🦶🏻",
                [.mediumLight]: "🦶🏼",
                [.medium]: "🦶🏽",
                [.mediumDark]: "🦶🏾",
                [.dark]: "🦶🏿",
            ]
        case .ear:
            return [
                [.light]: "👂🏻",
                [.mediumLight]: "👂🏼",
                [.medium]: "👂🏽",
                [.mediumDark]: "👂🏾",
                [.dark]: "👂🏿",
            ]
        case .earWithHearingAid:
            return [
                [.light]: "🦻🏻",
                [.mediumLight]: "🦻🏼",
                [.medium]: "🦻🏽",
                [.mediumDark]: "🦻🏾",
                [.dark]: "🦻🏿",
            ]
        case .nose:
            return [
                [.light]: "👃🏻",
                [.mediumLight]: "👃🏼",
                [.medium]: "👃🏽",
                [.mediumDark]: "👃🏾",
                [.dark]: "👃🏿",
            ]
        case .baby:
            return [
                [.light]: "👶🏻",
                [.mediumLight]: "👶🏼",
                [.medium]: "👶🏽",
                [.mediumDark]: "👶🏾",
                [.dark]: "👶🏿",
            ]
        case .child:
            return [
                [.light]: "🧒🏻",
                [.mediumLight]: "🧒🏼",
                [.medium]: "🧒🏽",
                [.mediumDark]: "🧒🏾",
                [.dark]: "🧒🏿",
            ]
        case .boy:
            return [
                [.light]: "👦🏻",
                [.mediumLight]: "👦🏼",
                [.medium]: "👦🏽",
                [.mediumDark]: "👦🏾",
                [.dark]: "👦🏿",
            ]
        case .girl:
            return [
                [.light]: "👧🏻",
                [.mediumLight]: "👧🏼",
                [.medium]: "👧🏽",
                [.mediumDark]: "👧🏾",
                [.dark]: "👧🏿",
            ]
        case .adult:
            return [
                [.light]: "🧑🏻",
                [.mediumLight]: "🧑🏼",
                [.medium]: "🧑🏽",
                [.mediumDark]: "🧑🏾",
                [.dark]: "🧑🏿",
            ]
        case .personWithBlondHair:
            return [
                [.light]: "👱🏻",
                [.mediumLight]: "👱🏼",
                [.medium]: "👱🏽",
                [.mediumDark]: "👱🏾",
                [.dark]: "👱🏿",
            ]
        case .man:
            return [
                [.light]: "👨🏻",
                [.mediumLight]: "👨🏼",
                [.medium]: "👨🏽",
                [.mediumDark]: "👨🏾",
                [.dark]: "👨🏿",
            ]
        case .beardedPerson:
            return [
                [.light]: "🧔🏻",
                [.mediumLight]: "🧔🏼",
                [.medium]: "🧔🏽",
                [.mediumDark]: "🧔🏾",
                [.dark]: "🧔🏿",
            ]
        case .manWithBeard:
            return [
                [.light]: "🧔🏻‍♂️",
                [.mediumLight]: "🧔🏼‍♂️",
                [.medium]: "🧔🏽‍♂️",
                [.mediumDark]: "🧔🏾‍♂️",
                [.dark]: "🧔🏿‍♂️",
            ]
        case .womanWithBeard:
            return [
                [.light]: "🧔🏻‍♀️",
                [.mediumLight]: "🧔🏼‍♀️",
                [.medium]: "🧔🏽‍♀️",
                [.mediumDark]: "🧔🏾‍♀️",
                [.dark]: "🧔🏿‍♀️",
            ]
        case .redHairedMan:
            return [
                [.light]: "👨🏻‍🦰",
                [.mediumLight]: "👨🏼‍🦰",
                [.medium]: "👨🏽‍🦰",
                [.mediumDark]: "👨🏾‍🦰",
                [.dark]: "👨🏿‍🦰",
            ]
        case .curlyHairedMan:
            return [
                [.light]: "👨🏻‍🦱",
                [.mediumLight]: "👨🏼‍🦱",
                [.medium]: "👨🏽‍🦱",
                [.mediumDark]: "👨🏾‍🦱",
                [.dark]: "👨🏿‍🦱",
            ]
        case .whiteHairedMan:
            return [
                [.light]: "👨🏻‍🦳",
                [.mediumLight]: "👨🏼‍🦳",
                [.medium]: "👨🏽‍🦳",
                [.mediumDark]: "👨🏾‍🦳",
                [.dark]: "👨🏿‍🦳",
            ]
        case .baldMan:
            return [
                [.light]: "👨🏻‍🦲",
                [.mediumLight]: "👨🏼‍🦲",
                [.medium]: "👨🏽‍🦲",
                [.mediumDark]: "👨🏾‍🦲",
                [.dark]: "👨🏿‍🦲",
            ]
        case .woman:
            return [
                [.light]: "👩🏻",
                [.mediumLight]: "👩🏼",
                [.medium]: "👩🏽",
                [.mediumDark]: "👩🏾",
                [.dark]: "👩🏿",
            ]
        case .redHairedWoman:
            return [
                [.light]: "👩🏻‍🦰",
                [.mediumLight]: "👩🏼‍🦰",
                [.medium]: "👩🏽‍🦰",
                [.mediumDark]: "👩🏾‍🦰",
                [.dark]: "👩🏿‍🦰",
            ]
        case .redHairedPerson:
            return [
                [.light]: "🧑🏻‍🦰",
                [.mediumLight]: "🧑🏼‍🦰",
                [.medium]: "🧑🏽‍🦰",
                [.mediumDark]: "🧑🏾‍🦰",
                [.dark]: "🧑🏿‍🦰",
            ]
        case .curlyHairedWoman:
            return [
                [.light]: "👩🏻‍🦱",
                [.mediumLight]: "👩🏼‍🦱",
                [.medium]: "👩🏽‍🦱",
                [.mediumDark]: "👩🏾‍🦱",
                [.dark]: "👩🏿‍🦱",
            ]
        case .curlyHairedPerson:
            return [
                [.light]: "🧑🏻‍🦱",
                [.mediumLight]: "🧑🏼‍🦱",
                [.medium]: "🧑🏽‍🦱",
                [.mediumDark]: "🧑🏾‍🦱",
                [.dark]: "🧑🏿‍🦱",
            ]
        case .whiteHairedWoman:
            return [
                [.light]: "👩🏻‍🦳",
                [.mediumLight]: "👩🏼‍🦳",
                [.medium]: "👩🏽‍🦳",
                [.mediumDark]: "👩🏾‍🦳",
                [.dark]: "👩🏿‍🦳",
            ]
        case .whiteHairedPerson:
            return [
                [.light]: "🧑🏻‍🦳",
                [.mediumLight]: "🧑🏼‍🦳",
                [.medium]: "🧑🏽‍🦳",
                [.mediumDark]: "🧑🏾‍🦳",
                [.dark]: "🧑🏿‍🦳",
            ]
        case .baldWoman:
            return [
                [.light]: "👩🏻‍🦲",
                [.mediumLight]: "👩🏼‍🦲",
                [.medium]: "👩🏽‍🦲",
                [.mediumDark]: "👩🏾‍🦲",
                [.dark]: "👩🏿‍🦲",
            ]
        case .baldPerson:
            return [
                [.light]: "🧑🏻‍🦲",
                [.mediumLight]: "🧑🏼‍🦲",
                [.medium]: "🧑🏽‍🦲",
                [.mediumDark]: "🧑🏾‍🦲",
                [.dark]: "🧑🏿‍🦲",
            ]
        case .blondHairedWoman:
            return [
                [.light]: "👱🏻‍♀️",
                [.mediumLight]: "👱🏼‍♀️",
                [.medium]: "👱🏽‍♀️",
                [.mediumDark]: "👱🏾‍♀️",
                [.dark]: "👱🏿‍♀️",
            ]
        case .blondHairedMan:
            return [
                [.light]: "👱🏻‍♂️",
                [.mediumLight]: "👱🏼‍♂️",
                [.medium]: "👱🏽‍♂️",
                [.mediumDark]: "👱🏾‍♂️",
                [.dark]: "👱🏿‍♂️",
            ]
        case .olderAdult:
            return [
                [.light]: "🧓🏻",
                [.mediumLight]: "🧓🏼",
                [.medium]: "🧓🏽",
                [.mediumDark]: "🧓🏾",
                [.dark]: "🧓🏿",
            ]
        case .olderMan:
            return [
                [.light]: "👴🏻",
                [.mediumLight]: "👴🏼",
                [.medium]: "👴🏽",
                [.mediumDark]: "👴🏾",
                [.dark]: "👴🏿",
            ]
        case .olderWoman:
            return [
                [.light]: "👵🏻",
                [.mediumLight]: "👵🏼",
                [.medium]: "👵🏽",
                [.mediumDark]: "👵🏾",
                [.dark]: "👵🏿",
            ]
        case .personFrowning:
            return [
                [.light]: "🙍🏻",
                [.mediumLight]: "🙍🏼",
                [.medium]: "🙍🏽",
                [.mediumDark]: "🙍🏾",
                [.dark]: "🙍🏿",
            ]
        case .manFrowning:
            return [
                [.light]: "🙍🏻‍♂️",
                [.mediumLight]: "🙍🏼‍♂️",
                [.medium]: "🙍🏽‍♂️",
                [.mediumDark]: "🙍🏾‍♂️",
                [.dark]: "🙍🏿‍♂️",
            ]
        case .womanFrowning:
            return [
                [.light]: "🙍🏻‍♀️",
                [.mediumLight]: "🙍🏼‍♀️",
                [.medium]: "🙍🏽‍♀️",
                [.mediumDark]: "🙍🏾‍♀️",
                [.dark]: "🙍🏿‍♀️",
            ]
        case .personWithPoutingFace:
            return [
                [.light]: "🙎🏻",
                [.mediumLight]: "🙎🏼",
                [.medium]: "🙎🏽",
                [.mediumDark]: "🙎🏾",
                [.dark]: "🙎🏿",
            ]
        case .manPouting:
            return [
                [.light]: "🙎🏻‍♂️",
                [.mediumLight]: "🙎🏼‍♂️",
                [.medium]: "🙎🏽‍♂️",
                [.mediumDark]: "🙎🏾‍♂️",
                [.dark]: "🙎🏿‍♂️",
            ]
        case .womanPouting:
            return [
                [.light]: "🙎🏻‍♀️",
                [.mediumLight]: "🙎🏼‍♀️",
                [.medium]: "🙎🏽‍♀️",
                [.mediumDark]: "🙎🏾‍♀️",
                [.dark]: "🙎🏿‍♀️",
            ]
        case .noGood:
            return [
                [.light]: "🙅🏻",
                [.mediumLight]: "🙅🏼",
                [.medium]: "🙅🏽",
                [.mediumDark]: "🙅🏾",
                [.dark]: "🙅🏿",
            ]
        case .manGesturingNo:
            return [
                [.light]: "🙅🏻‍♂️",
                [.mediumLight]: "🙅🏼‍♂️",
                [.medium]: "🙅🏽‍♂️",
                [.mediumDark]: "🙅🏾‍♂️",
                [.dark]: "🙅🏿‍♂️",
            ]
        case .womanGesturingNo:
            return [
                [.light]: "🙅🏻‍♀️",
                [.mediumLight]: "🙅🏼‍♀️",
                [.medium]: "🙅🏽‍♀️",
                [.mediumDark]: "🙅🏾‍♀️",
                [.dark]: "🙅🏿‍♀️",
            ]
        case .okWoman:
            return [
                [.light]: "🙆🏻",
                [.mediumLight]: "🙆🏼",
                [.medium]: "🙆🏽",
                [.mediumDark]: "🙆🏾",
                [.dark]: "🙆🏿",
            ]
        case .manGesturingOk:
            return [
                [.light]: "🙆🏻‍♂️",
                [.mediumLight]: "🙆🏼‍♂️",
                [.medium]: "🙆🏽‍♂️",
                [.mediumDark]: "🙆🏾‍♂️",
                [.dark]: "🙆🏿‍♂️",
            ]
        case .womanGesturingOk:
            return [
                [.light]: "🙆🏻‍♀️",
                [.mediumLight]: "🙆🏼‍♀️",
                [.medium]: "🙆🏽‍♀️",
                [.mediumDark]: "🙆🏾‍♀️",
                [.dark]: "🙆🏿‍♀️",
            ]
        case .informationDeskPerson:
            return [
                [.light]: "💁🏻",
                [.mediumLight]: "💁🏼",
                [.medium]: "💁🏽",
                [.mediumDark]: "💁🏾",
                [.dark]: "💁🏿",
            ]
        case .manTippingHand:
            return [
                [.light]: "💁🏻‍♂️",
                [.mediumLight]: "💁🏼‍♂️",
                [.medium]: "💁🏽‍♂️",
                [.mediumDark]: "💁🏾‍♂️",
                [.dark]: "💁🏿‍♂️",
            ]
        case .womanTippingHand:
            return [
                [.light]: "💁🏻‍♀️",
                [.mediumLight]: "💁🏼‍♀️",
                [.medium]: "💁🏽‍♀️",
                [.mediumDark]: "💁🏾‍♀️",
                [.dark]: "💁🏿‍♀️",
            ]
        case .raisingHand:
            return [
                [.light]: "🙋🏻",
                [.mediumLight]: "🙋🏼",
                [.medium]: "🙋🏽",
                [.mediumDark]: "🙋🏾",
                [.dark]: "🙋🏿",
            ]
        case .manRaisingHand:
            return [
                [.light]: "🙋🏻‍♂️",
                [.mediumLight]: "🙋🏼‍♂️",
                [.medium]: "🙋🏽‍♂️",
                [.mediumDark]: "🙋🏾‍♂️",
                [.dark]: "🙋🏿‍♂️",
            ]
        case .womanRaisingHand:
            return [
                [.light]: "🙋🏻‍♀️",
                [.mediumLight]: "🙋🏼‍♀️",
                [.medium]: "🙋🏽‍♀️",
                [.mediumDark]: "🙋🏾‍♀️",
                [.dark]: "🙋🏿‍♀️",
            ]
        case .deafPerson:
            return [
                [.light]: "🧏🏻",
                [.mediumLight]: "🧏🏼",
                [.medium]: "🧏🏽",
                [.mediumDark]: "🧏🏾",
                [.dark]: "🧏🏿",
            ]
        case .deafMan:
            return [
                [.light]: "🧏🏻‍♂️",
                [.mediumLight]: "🧏🏼‍♂️",
                [.medium]: "🧏🏽‍♂️",
                [.mediumDark]: "🧏🏾‍♂️",
                [.dark]: "🧏🏿‍♂️",
            ]
        case .deafWoman:
            return [
                [.light]: "🧏🏻‍♀️",
                [.mediumLight]: "🧏🏼‍♀️",
                [.medium]: "🧏🏽‍♀️",
                [.mediumDark]: "🧏🏾‍♀️",
                [.dark]: "🧏🏿‍♀️",
            ]
        case .bow:
            return [
                [.light]: "🙇🏻",
                [.mediumLight]: "🙇🏼",
                [.medium]: "🙇🏽",
                [.mediumDark]: "🙇🏾",
                [.dark]: "🙇🏿",
            ]
        case .manBowing:
            return [
                [.light]: "🙇🏻‍♂️",
                [.mediumLight]: "🙇🏼‍♂️",
                [.medium]: "🙇🏽‍♂️",
                [.mediumDark]: "🙇🏾‍♂️",
                [.dark]: "🙇🏿‍♂️",
            ]
        case .womanBowing:
            return [
                [.light]: "🙇🏻‍♀️",
                [.mediumLight]: "🙇🏼‍♀️",
                [.medium]: "🙇🏽‍♀️",
                [.mediumDark]: "🙇🏾‍♀️",
                [.dark]: "🙇🏿‍♀️",
            ]
        case .facePalm:
            return [
                [.light]: "🤦🏻",
                [.mediumLight]: "🤦🏼",
                [.medium]: "🤦🏽",
                [.mediumDark]: "🤦🏾",
                [.dark]: "🤦🏿",
            ]
        case .manFacepalming:
            return [
                [.light]: "🤦🏻‍♂️",
                [.mediumLight]: "🤦🏼‍♂️",
                [.medium]: "🤦🏽‍♂️",
                [.mediumDark]: "🤦🏾‍♂️",
                [.dark]: "🤦🏿‍♂️",
            ]
        case .womanFacepalming:
            return [
                [.light]: "🤦🏻‍♀️",
                [.mediumLight]: "🤦🏼‍♀️",
                [.medium]: "🤦🏽‍♀️",
                [.mediumDark]: "🤦🏾‍♀️",
                [.dark]: "🤦🏿‍♀️",
            ]
        case .shrug:
            return [
                [.light]: "🤷🏻",
                [.mediumLight]: "🤷🏼",
                [.medium]: "🤷🏽",
                [.mediumDark]: "🤷🏾",
                [.dark]: "🤷🏿",
            ]
        case .manShrugging:
            return [
                [.light]: "🤷🏻‍♂️",
                [.mediumLight]: "🤷🏼‍♂️",
                [.medium]: "🤷🏽‍♂️",
                [.mediumDark]: "🤷🏾‍♂️",
                [.dark]: "🤷🏿‍♂️",
            ]
        case .womanShrugging:
            return [
                [.light]: "🤷🏻‍♀️",
                [.mediumLight]: "🤷🏼‍♀️",
                [.medium]: "🤷🏽‍♀️",
                [.mediumDark]: "🤷🏾‍♀️",
                [.dark]: "🤷🏿‍♀️",
            ]
        case .healthWorker:
            return [
                [.light]: "🧑🏻‍⚕️",
                [.mediumLight]: "🧑🏼‍⚕️",
                [.medium]: "🧑🏽‍⚕️",
                [.mediumDark]: "🧑🏾‍⚕️",
                [.dark]: "🧑🏿‍⚕️",
            ]
        case .maleDoctor:
            return [
                [.light]: "👨🏻‍⚕️",
                [.mediumLight]: "👨🏼‍⚕️",
                [.medium]: "👨🏽‍⚕️",
                [.mediumDark]: "👨🏾‍⚕️",
                [.dark]: "👨🏿‍⚕️",
            ]
        case .femaleDoctor:
            return [
                [.light]: "👩🏻‍⚕️",
                [.mediumLight]: "👩🏼‍⚕️",
                [.medium]: "👩🏽‍⚕️",
                [.mediumDark]: "👩🏾‍⚕️",
                [.dark]: "👩🏿‍⚕️",
            ]
        case .student:
            return [
                [.light]: "🧑🏻‍🎓",
                [.mediumLight]: "🧑🏼‍🎓",
                [.medium]: "🧑🏽‍🎓",
                [.mediumDark]: "🧑🏾‍🎓",
                [.dark]: "🧑🏿‍🎓",
            ]
        case .maleStudent:
            return [
                [.light]: "👨🏻‍🎓",
                [.mediumLight]: "👨🏼‍🎓",
                [.medium]: "👨🏽‍🎓",
                [.mediumDark]: "👨🏾‍🎓",
                [.dark]: "👨🏿‍🎓",
            ]
        case .femaleStudent:
            return [
                [.light]: "👩🏻‍🎓",
                [.mediumLight]: "👩🏼‍🎓",
                [.medium]: "👩🏽‍🎓",
                [.mediumDark]: "👩🏾‍🎓",
                [.dark]: "👩🏿‍🎓",
            ]
        case .teacher:
            return [
                [.light]: "🧑🏻‍🏫",
                [.mediumLight]: "🧑🏼‍🏫",
                [.medium]: "🧑🏽‍🏫",
                [.mediumDark]: "🧑🏾‍🏫",
                [.dark]: "🧑🏿‍🏫",
            ]
        case .maleTeacher:
            return [
                [.light]: "👨🏻‍🏫",
                [.mediumLight]: "👨🏼‍🏫",
                [.medium]: "👨🏽‍🏫",
                [.mediumDark]: "👨🏾‍🏫",
                [.dark]: "👨🏿‍🏫",
            ]
        case .femaleTeacher:
            return [
                [.light]: "👩🏻‍🏫",
                [.mediumLight]: "👩🏼‍🏫",
                [.medium]: "👩🏽‍🏫",
                [.mediumDark]: "👩🏾‍🏫",
                [.dark]: "👩🏿‍🏫",
            ]
        case .judge:
            return [
                [.light]: "🧑🏻‍⚖️",
                [.mediumLight]: "🧑🏼‍⚖️",
                [.medium]: "🧑🏽‍⚖️",
                [.mediumDark]: "🧑🏾‍⚖️",
                [.dark]: "🧑🏿‍⚖️",
            ]
        case .maleJudge:
            return [
                [.light]: "👨🏻‍⚖️",
                [.mediumLight]: "👨🏼‍⚖️",
                [.medium]: "👨🏽‍⚖️",
                [.mediumDark]: "👨🏾‍⚖️",
                [.dark]: "👨🏿‍⚖️",
            ]
        case .femaleJudge:
            return [
                [.light]: "👩🏻‍⚖️",
                [.mediumLight]: "👩🏼‍⚖️",
                [.medium]: "👩🏽‍⚖️",
                [.mediumDark]: "👩🏾‍⚖️",
                [.dark]: "👩🏿‍⚖️",
            ]
        case .farmer:
            return [
                [.light]: "🧑🏻‍🌾",
                [.mediumLight]: "🧑🏼‍🌾",
                [.medium]: "🧑🏽‍🌾",
                [.mediumDark]: "🧑🏾‍🌾",
                [.dark]: "🧑🏿‍🌾",
            ]
        case .maleFarmer:
            return [
                [.light]: "👨🏻‍🌾",
                [.mediumLight]: "👨🏼‍🌾",
                [.medium]: "👨🏽‍🌾",
                [.mediumDark]: "👨🏾‍🌾",
                [.dark]: "👨🏿‍🌾",
            ]
        case .femaleFarmer:
            return [
                [.light]: "👩🏻‍🌾",
                [.mediumLight]: "👩🏼‍🌾",
                [.medium]: "👩🏽‍🌾",
                [.mediumDark]: "👩🏾‍🌾",
                [.dark]: "👩🏿‍🌾",
            ]
        case .cook:
            return [
                [.light]: "🧑🏻‍🍳",
                [.mediumLight]: "🧑🏼‍🍳",
                [.medium]: "🧑🏽‍🍳",
                [.mediumDark]: "🧑🏾‍🍳",
                [.dark]: "🧑🏿‍🍳",
            ]
        case .maleCook:
            return [
                [.light]: "👨🏻‍🍳",
                [.mediumLight]: "👨🏼‍🍳",
                [.medium]: "👨🏽‍🍳",
                [.mediumDark]: "👨🏾‍🍳",
                [.dark]: "👨🏿‍🍳",
            ]
        case .femaleCook:
            return [
                [.light]: "👩🏻‍🍳",
                [.mediumLight]: "👩🏼‍🍳",
                [.medium]: "👩🏽‍🍳",
                [.mediumDark]: "👩🏾‍🍳",
                [.dark]: "👩🏿‍🍳",
            ]
        case .mechanic:
            return [
                [.light]: "🧑🏻‍🔧",
                [.mediumLight]: "🧑🏼‍🔧",
                [.medium]: "🧑🏽‍🔧",
                [.mediumDark]: "🧑🏾‍🔧",
                [.dark]: "🧑🏿‍🔧",
            ]
        case .maleMechanic:
            return [
                [.light]: "👨🏻‍🔧",
                [.mediumLight]: "👨🏼‍🔧",
                [.medium]: "👨🏽‍🔧",
                [.mediumDark]: "👨🏾‍🔧",
                [.dark]: "👨🏿‍🔧",
            ]
        case .femaleMechanic:
            return [
                [.light]: "👩🏻‍🔧",
                [.mediumLight]: "👩🏼‍🔧",
                [.medium]: "👩🏽‍🔧",
                [.mediumDark]: "👩🏾‍🔧",
                [.dark]: "👩🏿‍🔧",
            ]
        case .factoryWorker:
            return [
                [.light]: "🧑🏻‍🏭",
                [.mediumLight]: "🧑🏼‍🏭",
                [.medium]: "🧑🏽‍🏭",
                [.mediumDark]: "🧑🏾‍🏭",
                [.dark]: "🧑🏿‍🏭",
            ]
        case .maleFactoryWorker:
            return [
                [.light]: "👨🏻‍🏭",
                [.mediumLight]: "👨🏼‍🏭",
                [.medium]: "👨🏽‍🏭",
                [.mediumDark]: "👨🏾‍🏭",
                [.dark]: "👨🏿‍🏭",
            ]
        case .femaleFactoryWorker:
            return [
                [.light]: "👩🏻‍🏭",
                [.mediumLight]: "👩🏼‍🏭",
                [.medium]: "👩🏽‍🏭",
                [.mediumDark]: "👩🏾‍🏭",
                [.dark]: "👩🏿‍🏭",
            ]
        case .officeWorker:
            return [
                [.light]: "🧑🏻‍💼",
                [.mediumLight]: "🧑🏼‍💼",
                [.medium]: "🧑🏽‍💼",
                [.mediumDark]: "🧑🏾‍💼",
                [.dark]: "🧑🏿‍💼",
            ]
        case .maleOfficeWorker:
            return [
                [.light]: "👨🏻‍💼",
                [.mediumLight]: "👨🏼‍💼",
                [.medium]: "👨🏽‍💼",
                [.mediumDark]: "👨🏾‍💼",
                [.dark]: "👨🏿‍💼",
            ]
        case .femaleOfficeWorker:
            return [
                [.light]: "👩🏻‍💼",
                [.mediumLight]: "👩🏼‍💼",
                [.medium]: "👩🏽‍💼",
                [.mediumDark]: "👩🏾‍💼",
                [.dark]: "👩🏿‍💼",
            ]
        case .scientist:
            return [
                [.light]: "🧑🏻‍🔬",
                [.mediumLight]: "🧑🏼‍🔬",
                [.medium]: "🧑🏽‍🔬",
                [.mediumDark]: "🧑🏾‍🔬",
                [.dark]: "🧑🏿‍🔬",
            ]
        case .maleScientist:
            return [
                [.light]: "👨🏻‍🔬",
                [.mediumLight]: "👨🏼‍🔬",
                [.medium]: "👨🏽‍🔬",
                [.mediumDark]: "👨🏾‍🔬",
                [.dark]: "👨🏿‍🔬",
            ]
        case .femaleScientist:
            return [
                [.light]: "👩🏻‍🔬",
                [.mediumLight]: "👩🏼‍🔬",
                [.medium]: "👩🏽‍🔬",
                [.mediumDark]: "👩🏾‍🔬",
                [.dark]: "👩🏿‍🔬",
            ]
        case .technologist:
            return [
                [.light]: "🧑🏻‍💻",
                [.mediumLight]: "🧑🏼‍💻",
                [.medium]: "🧑🏽‍💻",
                [.mediumDark]: "🧑🏾‍💻",
                [.dark]: "🧑🏿‍💻",
            ]
        case .maleTechnologist:
            return [
                [.light]: "👨🏻‍💻",
                [.mediumLight]: "👨🏼‍💻",
                [.medium]: "👨🏽‍💻",
                [.mediumDark]: "👨🏾‍💻",
                [.dark]: "👨🏿‍💻",
            ]
        case .femaleTechnologist:
            return [
                [.light]: "👩🏻‍💻",
                [.mediumLight]: "👩🏼‍💻",
                [.medium]: "👩🏽‍💻",
                [.mediumDark]: "👩🏾‍💻",
                [.dark]: "👩🏿‍💻",
            ]
        case .singer:
            return [
                [.light]: "🧑🏻‍🎤",
                [.mediumLight]: "🧑🏼‍🎤",
                [.medium]: "🧑🏽‍🎤",
                [.mediumDark]: "🧑🏾‍🎤",
                [.dark]: "🧑🏿‍🎤",
            ]
        case .maleSinger:
            return [
                [.light]: "👨🏻‍🎤",
                [.mediumLight]: "👨🏼‍🎤",
                [.medium]: "👨🏽‍🎤",
                [.mediumDark]: "👨🏾‍🎤",
                [.dark]: "👨🏿‍🎤",
            ]
        case .femaleSinger:
            return [
                [.light]: "👩🏻‍🎤",
                [.mediumLight]: "👩🏼‍🎤",
                [.medium]: "👩🏽‍🎤",
                [.mediumDark]: "👩🏾‍🎤",
                [.dark]: "👩🏿‍🎤",
            ]
        case .artist:
            return [
                [.light]: "🧑🏻‍🎨",
                [.mediumLight]: "🧑🏼‍🎨",
                [.medium]: "🧑🏽‍🎨",
                [.mediumDark]: "🧑🏾‍🎨",
                [.dark]: "🧑🏿‍🎨",
            ]
        case .maleArtist:
            return [
                [.light]: "👨🏻‍🎨",
                [.mediumLight]: "👨🏼‍🎨",
                [.medium]: "👨🏽‍🎨",
                [.mediumDark]: "👨🏾‍🎨",
                [.dark]: "👨🏿‍🎨",
            ]
        case .femaleArtist:
            return [
                [.light]: "👩🏻‍🎨",
                [.mediumLight]: "👩🏼‍🎨",
                [.medium]: "👩🏽‍🎨",
                [.mediumDark]: "👩🏾‍🎨",
                [.dark]: "👩🏿‍🎨",
            ]
        case .pilot:
            return [
                [.light]: "🧑🏻‍✈️",
                [.mediumLight]: "🧑🏼‍✈️",
                [.medium]: "🧑🏽‍✈️",
                [.mediumDark]: "🧑🏾‍✈️",
                [.dark]: "🧑🏿‍✈️",
            ]
        case .malePilot:
            return [
                [.light]: "👨🏻‍✈️",
                [.mediumLight]: "👨🏼‍✈️",
                [.medium]: "👨🏽‍✈️",
                [.mediumDark]: "👨🏾‍✈️",
                [.dark]: "👨🏿‍✈️",
            ]
        case .femalePilot:
            return [
                [.light]: "👩🏻‍✈️",
                [.mediumLight]: "👩🏼‍✈️",
                [.medium]: "👩🏽‍✈️",
                [.mediumDark]: "👩🏾‍✈️",
                [.dark]: "👩🏿‍✈️",
            ]
        case .astronaut:
            return [
                [.light]: "🧑🏻‍🚀",
                [.mediumLight]: "🧑🏼‍🚀",
                [.medium]: "🧑🏽‍🚀",
                [.mediumDark]: "🧑🏾‍🚀",
                [.dark]: "🧑🏿‍🚀",
            ]
        case .maleAstronaut:
            return [
                [.light]: "👨🏻‍🚀",
                [.mediumLight]: "👨🏼‍🚀",
                [.medium]: "👨🏽‍🚀",
                [.mediumDark]: "👨🏾‍🚀",
                [.dark]: "👨🏿‍🚀",
            ]
        case .femaleAstronaut:
            return [
                [.light]: "👩🏻‍🚀",
                [.mediumLight]: "👩🏼‍🚀",
                [.medium]: "👩🏽‍🚀",
                [.mediumDark]: "👩🏾‍🚀",
                [.dark]: "👩🏿‍🚀",
            ]
        case .firefighter:
            return [
                [.light]: "🧑🏻‍🚒",
                [.mediumLight]: "🧑🏼‍🚒",
                [.medium]: "🧑🏽‍🚒",
                [.mediumDark]: "🧑🏾‍🚒",
                [.dark]: "🧑🏿‍🚒",
            ]
        case .maleFirefighter:
            return [
                [.light]: "👨🏻‍🚒",
                [.mediumLight]: "👨🏼‍🚒",
                [.medium]: "👨🏽‍🚒",
                [.mediumDark]: "👨🏾‍🚒",
                [.dark]: "👨🏿‍🚒",
            ]
        case .femaleFirefighter:
            return [
                [.light]: "👩🏻‍🚒",
                [.mediumLight]: "👩🏼‍🚒",
                [.medium]: "👩🏽‍🚒",
                [.mediumDark]: "👩🏾‍🚒",
                [.dark]: "👩🏿‍🚒",
            ]
        case .cop:
            return [
                [.light]: "👮🏻",
                [.mediumLight]: "👮🏼",
                [.medium]: "👮🏽",
                [.mediumDark]: "👮🏾",
                [.dark]: "👮🏿",
            ]
        case .malePoliceOfficer:
            return [
                [.light]: "👮🏻‍♂️",
                [.mediumLight]: "👮🏼‍♂️",
                [.medium]: "👮🏽‍♂️",
                [.mediumDark]: "👮🏾‍♂️",
                [.dark]: "👮🏿‍♂️",
            ]
        case .femalePoliceOfficer:
            return [
                [.light]: "👮🏻‍♀️",
                [.mediumLight]: "👮🏼‍♀️",
                [.medium]: "👮🏽‍♀️",
                [.mediumDark]: "👮🏾‍♀️",
                [.dark]: "👮🏿‍♀️",
            ]
        case .sleuthOrSpy:
            return [
                [.light]: "🕵🏻",
                [.mediumLight]: "🕵🏼",
                [.medium]: "🕵🏽",
                [.mediumDark]: "🕵🏾",
                [.dark]: "🕵🏿",
            ]
        case .maleDetective:
            return [
                [.light]: "🕵🏻‍♂️",
                [.mediumLight]: "🕵🏼‍♂️",
                [.medium]: "🕵🏽‍♂️",
                [.mediumDark]: "🕵🏾‍♂️",
                [.dark]: "🕵🏿‍♂️",
            ]
        case .femaleDetective:
            return [
                [.light]: "🕵🏻‍♀️",
                [.mediumLight]: "🕵🏼‍♀️",
                [.medium]: "🕵🏽‍♀️",
                [.mediumDark]: "🕵🏾‍♀️",
                [.dark]: "🕵🏿‍♀️",
            ]
        case .guardsman:
            return [
                [.light]: "💂🏻",
                [.mediumLight]: "💂🏼",
                [.medium]: "💂🏽",
                [.mediumDark]: "💂🏾",
                [.dark]: "💂🏿",
            ]
        case .maleGuard:
            return [
                [.light]: "💂🏻‍♂️",
                [.mediumLight]: "💂🏼‍♂️",
                [.medium]: "💂🏽‍♂️",
                [.mediumDark]: "💂🏾‍♂️",
                [.dark]: "💂🏿‍♂️",
            ]
        case .femaleGuard:
            return [
                [.light]: "💂🏻‍♀️",
                [.mediumLight]: "💂🏼‍♀️",
                [.medium]: "💂🏽‍♀️",
                [.mediumDark]: "💂🏾‍♀️",
                [.dark]: "💂🏿‍♀️",
            ]
        case .ninja:
            return [
                [.light]: "🥷🏻",
                [.mediumLight]: "🥷🏼",
                [.medium]: "🥷🏽",
                [.mediumDark]: "🥷🏾",
                [.dark]: "🥷🏿",
            ]
        case .constructionWorker:
            return [
                [.light]: "👷🏻",
                [.mediumLight]: "👷🏼",
                [.medium]: "👷🏽",
                [.mediumDark]: "👷🏾",
                [.dark]: "👷🏿",
            ]
        case .maleConstructionWorker:
            return [
                [.light]: "👷🏻‍♂️",
                [.mediumLight]: "👷🏼‍♂️",
                [.medium]: "👷🏽‍♂️",
                [.mediumDark]: "👷🏾‍♂️",
                [.dark]: "👷🏿‍♂️",
            ]
        case .femaleConstructionWorker:
            return [
                [.light]: "👷🏻‍♀️",
                [.mediumLight]: "👷🏼‍♀️",
                [.medium]: "👷🏽‍♀️",
                [.mediumDark]: "👷🏾‍♀️",
                [.dark]: "👷🏿‍♀️",
            ]
        case .personWithCrown:
            return [
                [.light]: "🫅🏻",
                [.mediumLight]: "🫅🏼",
                [.medium]: "🫅🏽",
                [.mediumDark]: "🫅🏾",
                [.dark]: "🫅🏿",
            ]
        case .prince:
            return [
                [.light]: "🤴🏻",
                [.mediumLight]: "🤴🏼",
                [.medium]: "🤴🏽",
                [.mediumDark]: "🤴🏾",
                [.dark]: "🤴🏿",
            ]
        case .princess:
            return [
                [.light]: "👸🏻",
                [.mediumLight]: "👸🏼",
                [.medium]: "👸🏽",
                [.mediumDark]: "👸🏾",
                [.dark]: "👸🏿",
            ]
        case .manWithTurban:
            return [
                [.light]: "👳🏻",
                [.mediumLight]: "👳🏼",
                [.medium]: "👳🏽",
                [.mediumDark]: "👳🏾",
                [.dark]: "👳🏿",
            ]
        case .manWearingTurban:
            return [
                [.light]: "👳🏻‍♂️",
                [.mediumLight]: "👳🏼‍♂️",
                [.medium]: "👳🏽‍♂️",
                [.mediumDark]: "👳🏾‍♂️",
                [.dark]: "👳🏿‍♂️",
            ]
        case .womanWearingTurban:
            return [
                [.light]: "👳🏻‍♀️",
                [.mediumLight]: "👳🏼‍♀️",
                [.medium]: "👳🏽‍♀️",
                [.mediumDark]: "👳🏾‍♀️",
                [.dark]: "👳🏿‍♀️",
            ]
        case .manWithGuaPiMao:
            return [
                [.light]: "👲🏻",
                [.mediumLight]: "👲🏼",
                [.medium]: "👲🏽",
                [.mediumDark]: "👲🏾",
                [.dark]: "👲🏿",
            ]
        case .personWithHeadscarf:
            return [
                [.light]: "🧕🏻",
                [.mediumLight]: "🧕🏼",
                [.medium]: "🧕🏽",
                [.mediumDark]: "🧕🏾",
                [.dark]: "🧕🏿",
            ]
        case .personInTuxedo:
            return [
                [.light]: "🤵🏻",
                [.mediumLight]: "🤵🏼",
                [.medium]: "🤵🏽",
                [.mediumDark]: "🤵🏾",
                [.dark]: "🤵🏿",
            ]
        case .manInTuxedo:
            return [
                [.light]: "🤵🏻‍♂️",
                [.mediumLight]: "🤵🏼‍♂️",
                [.medium]: "🤵🏽‍♂️",
                [.mediumDark]: "🤵🏾‍♂️",
                [.dark]: "🤵🏿‍♂️",
            ]
        case .womanInTuxedo:
            return [
                [.light]: "🤵🏻‍♀️",
                [.mediumLight]: "🤵🏼‍♀️",
                [.medium]: "🤵🏽‍♀️",
                [.mediumDark]: "🤵🏾‍♀️",
                [.dark]: "🤵🏿‍♀️",
            ]
        case .brideWithVeil:
            return [
                [.light]: "👰🏻",
                [.mediumLight]: "👰🏼",
                [.medium]: "👰🏽",
                [.mediumDark]: "👰🏾",
                [.dark]: "👰🏿",
            ]
        case .manWithVeil:
            return [
                [.light]: "👰🏻‍♂️",
                [.mediumLight]: "👰🏼‍♂️",
                [.medium]: "👰🏽‍♂️",
                [.mediumDark]: "👰🏾‍♂️",
                [.dark]: "👰🏿‍♂️",
            ]
        case .womanWithVeil:
            return [
                [.light]: "👰🏻‍♀️",
                [.mediumLight]: "👰🏼‍♀️",
                [.medium]: "👰🏽‍♀️",
                [.mediumDark]: "👰🏾‍♀️",
                [.dark]: "👰🏿‍♀️",
            ]
        case .pregnantWoman:
            return [
                [.light]: "🤰🏻",
                [.mediumLight]: "🤰🏼",
                [.medium]: "🤰🏽",
                [.mediumDark]: "🤰🏾",
                [.dark]: "🤰🏿",
            ]
        case .pregnantMan:
            return [
                [.light]: "🫃🏻",
                [.mediumLight]: "🫃🏼",
                [.medium]: "🫃🏽",
                [.mediumDark]: "🫃🏾",
                [.dark]: "🫃🏿",
            ]
        case .pregnantPerson:
            return [
                [.light]: "🫄🏻",
                [.mediumLight]: "🫄🏼",
                [.medium]: "🫄🏽",
                [.mediumDark]: "🫄🏾",
                [.dark]: "🫄🏿",
            ]
        case .breastFeeding:
            return [
                [.light]: "🤱🏻",
                [.mediumLight]: "🤱🏼",
                [.medium]: "🤱🏽",
                [.mediumDark]: "🤱🏾",
                [.dark]: "🤱🏿",
            ]
        case .womanFeedingBaby:
            return [
                [.light]: "👩🏻‍🍼",
                [.mediumLight]: "👩🏼‍🍼",
                [.medium]: "👩🏽‍🍼",
                [.mediumDark]: "👩🏾‍🍼",
                [.dark]: "👩🏿‍🍼",
            ]
        case .manFeedingBaby:
            return [
                [.light]: "👨🏻‍🍼",
                [.mediumLight]: "👨🏼‍🍼",
                [.medium]: "👨🏽‍🍼",
                [.mediumDark]: "👨🏾‍🍼",
                [.dark]: "👨🏿‍🍼",
            ]
        case .personFeedingBaby:
            return [
                [.light]: "🧑🏻‍🍼",
                [.mediumLight]: "🧑🏼‍🍼",
                [.medium]: "🧑🏽‍🍼",
                [.mediumDark]: "🧑🏾‍🍼",
                [.dark]: "🧑🏿‍🍼",
            ]
        case .angel:
            return [
                [.light]: "👼🏻",
                [.mediumLight]: "👼🏼",
                [.medium]: "👼🏽",
                [.mediumDark]: "👼🏾",
                [.dark]: "👼🏿",
            ]
        case .santa:
            return [
                [.light]: "🎅🏻",
                [.mediumLight]: "🎅🏼",
                [.medium]: "🎅🏽",
                [.mediumDark]: "🎅🏾",
                [.dark]: "🎅🏿",
            ]
        case .mrsClaus:
            return [
                [.light]: "🤶🏻",
                [.mediumLight]: "🤶🏼",
                [.medium]: "🤶🏽",
                [.mediumDark]: "🤶🏾",
                [.dark]: "🤶🏿",
            ]
        case .mxClaus:
            return [
                [.light]: "🧑🏻‍🎄",
                [.mediumLight]: "🧑🏼‍🎄",
                [.medium]: "🧑🏽‍🎄",
                [.mediumDark]: "🧑🏾‍🎄",
                [.dark]: "🧑🏿‍🎄",
            ]
        case .superhero:
            return [
                [.light]: "🦸🏻",
                [.mediumLight]: "🦸🏼",
                [.medium]: "🦸🏽",
                [.mediumDark]: "🦸🏾",
                [.dark]: "🦸🏿",
            ]
        case .maleSuperhero:
            return [
                [.light]: "🦸🏻‍♂️",
                [.mediumLight]: "🦸🏼‍♂️",
                [.medium]: "🦸🏽‍♂️",
                [.mediumDark]: "🦸🏾‍♂️",
                [.dark]: "🦸🏿‍♂️",
            ]
        case .femaleSuperhero:
            return [
                [.light]: "🦸🏻‍♀️",
                [.mediumLight]: "🦸🏼‍♀️",
                [.medium]: "🦸🏽‍♀️",
                [.mediumDark]: "🦸🏾‍♀️",
                [.dark]: "🦸🏿‍♀️",
            ]
        case .supervillain:
            return [
                [.light]: "🦹🏻",
                [.mediumLight]: "🦹🏼",
                [.medium]: "🦹🏽",
                [.mediumDark]: "🦹🏾",
                [.dark]: "🦹🏿",
            ]
        case .maleSupervillain:
            return [
                [.light]: "🦹🏻‍♂️",
                [.mediumLight]: "🦹🏼‍♂️",
                [.medium]: "🦹🏽‍♂️",
                [.mediumDark]: "🦹🏾‍♂️",
                [.dark]: "🦹🏿‍♂️",
            ]
        case .femaleSupervillain:
            return [
                [.light]: "🦹🏻‍♀️",
                [.mediumLight]: "🦹🏼‍♀️",
                [.medium]: "🦹🏽‍♀️",
                [.mediumDark]: "🦹🏾‍♀️",
                [.dark]: "🦹🏿‍♀️",
            ]
        case .mage:
            return [
                [.light]: "🧙🏻",
                [.mediumLight]: "🧙🏼",
                [.medium]: "🧙🏽",
                [.mediumDark]: "🧙🏾",
                [.dark]: "🧙🏿",
            ]
        case .maleMage:
            return [
                [.light]: "🧙🏻‍♂️",
                [.mediumLight]: "🧙🏼‍♂️",
                [.medium]: "🧙🏽‍♂️",
                [.mediumDark]: "🧙🏾‍♂️",
                [.dark]: "🧙🏿‍♂️",
            ]
        case .femaleMage:
            return [
                [.light]: "🧙🏻‍♀️",
                [.mediumLight]: "🧙🏼‍♀️",
                [.medium]: "🧙🏽‍♀️",
                [.mediumDark]: "🧙🏾‍♀️",
                [.dark]: "🧙🏿‍♀️",
            ]
        case .fairy:
            return [
                [.light]: "🧚🏻",
                [.mediumLight]: "🧚🏼",
                [.medium]: "🧚🏽",
                [.mediumDark]: "🧚🏾",
                [.dark]: "🧚🏿",
            ]
        case .maleFairy:
            return [
                [.light]: "🧚🏻‍♂️",
                [.mediumLight]: "🧚🏼‍♂️",
                [.medium]: "🧚🏽‍♂️",
                [.mediumDark]: "🧚🏾‍♂️",
                [.dark]: "🧚🏿‍♂️",
            ]
        case .femaleFairy:
            return [
                [.light]: "🧚🏻‍♀️",
                [.mediumLight]: "🧚🏼‍♀️",
                [.medium]: "🧚🏽‍♀️",
                [.mediumDark]: "🧚🏾‍♀️",
                [.dark]: "🧚🏿‍♀️",
            ]
        case .vampire:
            return [
                [.light]: "🧛🏻",
                [.mediumLight]: "🧛🏼",
                [.medium]: "🧛🏽",
                [.mediumDark]: "🧛🏾",
                [.dark]: "🧛🏿",
            ]
        case .maleVampire:
            return [
                [.light]: "🧛🏻‍♂️",
                [.mediumLight]: "🧛🏼‍♂️",
                [.medium]: "🧛🏽‍♂️",
                [.mediumDark]: "🧛🏾‍♂️",
                [.dark]: "🧛🏿‍♂️",
            ]
        case .femaleVampire:
            return [
                [.light]: "🧛🏻‍♀️",
                [.mediumLight]: "🧛🏼‍♀️",
                [.medium]: "🧛🏽‍♀️",
                [.mediumDark]: "🧛🏾‍♀️",
                [.dark]: "🧛🏿‍♀️",
            ]
        case .merperson:
            return [
                [.light]: "🧜🏻",
                [.mediumLight]: "🧜🏼",
                [.medium]: "🧜🏽",
                [.mediumDark]: "🧜🏾",
                [.dark]: "🧜🏿",
            ]
        case .merman:
            return [
                [.light]: "🧜🏻‍♂️",
                [.mediumLight]: "🧜🏼‍♂️",
                [.medium]: "🧜🏽‍♂️",
                [.mediumDark]: "🧜🏾‍♂️",
                [.dark]: "🧜🏿‍♂️",
            ]
        case .mermaid:
            return [
                [.light]: "🧜🏻‍♀️",
                [.mediumLight]: "🧜🏼‍♀️",
                [.medium]: "🧜🏽‍♀️",
                [.mediumDark]: "🧜🏾‍♀️",
                [.dark]: "🧜🏿‍♀️",
            ]
        case .elf:
            return [
                [.light]: "🧝🏻",
                [.mediumLight]: "🧝🏼",
                [.medium]: "🧝🏽",
                [.mediumDark]: "🧝🏾",
                [.dark]: "🧝🏿",
            ]
        case .maleElf:
            return [
                [.light]: "🧝🏻‍♂️",
                [.mediumLight]: "🧝🏼‍♂️",
                [.medium]: "🧝🏽‍♂️",
                [.mediumDark]: "🧝🏾‍♂️",
                [.dark]: "🧝🏿‍♂️",
            ]
        case .femaleElf:
            return [
                [.light]: "🧝🏻‍♀️",
                [.mediumLight]: "🧝🏼‍♀️",
                [.medium]: "🧝🏽‍♀️",
                [.mediumDark]: "🧝🏾‍♀️",
                [.dark]: "🧝🏿‍♀️",
            ]
        case .massage:
            return [
                [.light]: "💆🏻",
                [.mediumLight]: "💆🏼",
                [.medium]: "💆🏽",
                [.mediumDark]: "💆🏾",
                [.dark]: "💆🏿",
            ]
        case .manGettingMassage:
            return [
                [.light]: "💆🏻‍♂️",
                [.mediumLight]: "💆🏼‍♂️",
                [.medium]: "💆🏽‍♂️",
                [.mediumDark]: "💆🏾‍♂️",
                [.dark]: "💆🏿‍♂️",
            ]
        case .womanGettingMassage:
            return [
                [.light]: "💆🏻‍♀️",
                [.mediumLight]: "💆🏼‍♀️",
                [.medium]: "💆🏽‍♀️",
                [.mediumDark]: "💆🏾‍♀️",
                [.dark]: "💆🏿‍♀️",
            ]
        case .haircut:
            return [
                [.light]: "💇🏻",
                [.mediumLight]: "💇🏼",
                [.medium]: "💇🏽",
                [.mediumDark]: "💇🏾",
                [.dark]: "💇🏿",
            ]
        case .manGettingHaircut:
            return [
                [.light]: "💇🏻‍♂️",
                [.mediumLight]: "💇🏼‍♂️",
                [.medium]: "💇🏽‍♂️",
                [.mediumDark]: "💇🏾‍♂️",
                [.dark]: "💇🏿‍♂️",
            ]
        case .womanGettingHaircut:
            return [
                [.light]: "💇🏻‍♀️",
                [.mediumLight]: "💇🏼‍♀️",
                [.medium]: "💇🏽‍♀️",
                [.mediumDark]: "💇🏾‍♀️",
                [.dark]: "💇🏿‍♀️",
            ]
        case .walking:
            return [
                [.light]: "🚶🏻",
                [.mediumLight]: "🚶🏼",
                [.medium]: "🚶🏽",
                [.mediumDark]: "🚶🏾",
                [.dark]: "🚶🏿",
            ]
        case .manWalking:
            return [
                [.light]: "🚶🏻‍♂️",
                [.mediumLight]: "🚶🏼‍♂️",
                [.medium]: "🚶🏽‍♂️",
                [.mediumDark]: "🚶🏾‍♂️",
                [.dark]: "🚶🏿‍♂️",
            ]
        case .womanWalking:
            return [
                [.light]: "🚶🏻‍♀️",
                [.mediumLight]: "🚶🏼‍♀️",
                [.medium]: "🚶🏽‍♀️",
                [.mediumDark]: "🚶🏾‍♀️",
                [.dark]: "🚶🏿‍♀️",
            ]
        case .standingPerson:
            return [
                [.light]: "🧍🏻",
                [.mediumLight]: "🧍🏼",
                [.medium]: "🧍🏽",
                [.mediumDark]: "🧍🏾",
                [.dark]: "🧍🏿",
            ]
        case .manStanding:
            return [
                [.light]: "🧍🏻‍♂️",
                [.mediumLight]: "🧍🏼‍♂️",
                [.medium]: "🧍🏽‍♂️",
                [.mediumDark]: "🧍🏾‍♂️",
                [.dark]: "🧍🏿‍♂️",
            ]
        case .womanStanding:
            return [
                [.light]: "🧍🏻‍♀️",
                [.mediumLight]: "🧍🏼‍♀️",
                [.medium]: "🧍🏽‍♀️",
                [.mediumDark]: "🧍🏾‍♀️",
                [.dark]: "🧍🏿‍♀️",
            ]
        case .kneelingPerson:
            return [
                [.light]: "🧎🏻",
                [.mediumLight]: "🧎🏼",
                [.medium]: "🧎🏽",
                [.mediumDark]: "🧎🏾",
                [.dark]: "🧎🏿",
            ]
        case .manKneeling:
            return [
                [.light]: "🧎🏻‍♂️",
                [.mediumLight]: "🧎🏼‍♂️",
                [.medium]: "🧎🏽‍♂️",
                [.mediumDark]: "🧎🏾‍♂️",
                [.dark]: "🧎🏿‍♂️",
            ]
        case .womanKneeling:
            return [
                [.light]: "🧎🏻‍♀️",
                [.mediumLight]: "🧎🏼‍♀️",
                [.medium]: "🧎🏽‍♀️",
                [.mediumDark]: "🧎🏾‍♀️",
                [.dark]: "🧎🏿‍♀️",
            ]
        case .personWithProbingCane:
            return [
                [.light]: "🧑🏻‍🦯",
                [.mediumLight]: "🧑🏼‍🦯",
                [.medium]: "🧑🏽‍🦯",
                [.mediumDark]: "🧑🏾‍🦯",
                [.dark]: "🧑🏿‍🦯",
            ]
        case .manWithProbingCane:
            return [
                [.light]: "👨🏻‍🦯",
                [.mediumLight]: "👨🏼‍🦯",
                [.medium]: "👨🏽‍🦯",
                [.mediumDark]: "👨🏾‍🦯",
                [.dark]: "👨🏿‍🦯",
            ]
        case .womanWithProbingCane:
            return [
                [.light]: "👩🏻‍🦯",
                [.mediumLight]: "👩🏼‍🦯",
                [.medium]: "👩🏽‍🦯",
                [.mediumDark]: "👩🏾‍🦯",
                [.dark]: "👩🏿‍🦯",
            ]
        case .personInMotorizedWheelchair:
            return [
                [.light]: "🧑🏻‍🦼",
                [.mediumLight]: "🧑🏼‍🦼",
                [.medium]: "🧑🏽‍🦼",
                [.mediumDark]: "🧑🏾‍🦼",
                [.dark]: "🧑🏿‍🦼",
            ]
        case .manInMotorizedWheelchair:
            return [
                [.light]: "👨🏻‍🦼",
                [.mediumLight]: "👨🏼‍🦼",
                [.medium]: "👨🏽‍🦼",
                [.mediumDark]: "👨🏾‍🦼",
                [.dark]: "👨🏿‍🦼",
            ]
        case .womanInMotorizedWheelchair:
            return [
                [.light]: "👩🏻‍🦼",
                [.mediumLight]: "👩🏼‍🦼",
                [.medium]: "👩🏽‍🦼",
                [.mediumDark]: "👩🏾‍🦼",
                [.dark]: "👩🏿‍🦼",
            ]
        case .personInManualWheelchair:
            return [
                [.light]: "🧑🏻‍🦽",
                [.mediumLight]: "🧑🏼‍🦽",
                [.medium]: "🧑🏽‍🦽",
                [.mediumDark]: "🧑🏾‍🦽",
                [.dark]: "🧑🏿‍🦽",
            ]
        case .manInManualWheelchair:
            return [
                [.light]: "👨🏻‍🦽",
                [.mediumLight]: "👨🏼‍🦽",
                [.medium]: "👨🏽‍🦽",
                [.mediumDark]: "👨🏾‍🦽",
                [.dark]: "👨🏿‍🦽",
            ]
        case .womanInManualWheelchair:
            return [
                [.light]: "👩🏻‍🦽",
                [.mediumLight]: "👩🏼‍🦽",
                [.medium]: "👩🏽‍🦽",
                [.mediumDark]: "👩🏾‍🦽",
                [.dark]: "👩🏿‍🦽",
            ]
        case .runner:
            return [
                [.light]: "🏃🏻",
                [.mediumLight]: "🏃🏼",
                [.medium]: "🏃🏽",
                [.mediumDark]: "🏃🏾",
                [.dark]: "🏃🏿",
            ]
        case .manRunning:
            return [
                [.light]: "🏃🏻‍♂️",
                [.mediumLight]: "🏃🏼‍♂️",
                [.medium]: "🏃🏽‍♂️",
                [.mediumDark]: "🏃🏾‍♂️",
                [.dark]: "🏃🏿‍♂️",
            ]
        case .womanRunning:
            return [
                [.light]: "🏃🏻‍♀️",
                [.mediumLight]: "🏃🏼‍♀️",
                [.medium]: "🏃🏽‍♀️",
                [.mediumDark]: "🏃🏾‍♀️",
                [.dark]: "🏃🏿‍♀️",
            ]
        case .dancer:
            return [
                [.light]: "💃🏻",
                [.mediumLight]: "💃🏼",
                [.medium]: "💃🏽",
                [.mediumDark]: "💃🏾",
                [.dark]: "💃🏿",
            ]
        case .manDancing:
            return [
                [.light]: "🕺🏻",
                [.mediumLight]: "🕺🏼",
                [.medium]: "🕺🏽",
                [.mediumDark]: "🕺🏾",
                [.dark]: "🕺🏿",
            ]
        case .manInBusinessSuitLevitating:
            return [
                [.light]: "🕴🏻",
                [.mediumLight]: "🕴🏼",
                [.medium]: "🕴🏽",
                [.mediumDark]: "🕴🏾",
                [.dark]: "🕴🏿",
            ]
        case .personInSteamyRoom:
            return [
                [.light]: "🧖🏻",
                [.mediumLight]: "🧖🏼",
                [.medium]: "🧖🏽",
                [.mediumDark]: "🧖🏾",
                [.dark]: "🧖🏿",
            ]
        case .manInSteamyRoom:
            return [
                [.light]: "🧖🏻‍♂️",
                [.mediumLight]: "🧖🏼‍♂️",
                [.medium]: "🧖🏽‍♂️",
                [.mediumDark]: "🧖🏾‍♂️",
                [.dark]: "🧖🏿‍♂️",
            ]
        case .womanInSteamyRoom:
            return [
                [.light]: "🧖🏻‍♀️",
                [.mediumLight]: "🧖🏼‍♀️",
                [.medium]: "🧖🏽‍♀️",
                [.mediumDark]: "🧖🏾‍♀️",
                [.dark]: "🧖🏿‍♀️",
            ]
        case .personClimbing:
            return [
                [.light]: "🧗🏻",
                [.mediumLight]: "🧗🏼",
                [.medium]: "🧗🏽",
                [.mediumDark]: "🧗🏾",
                [.dark]: "🧗🏿",
            ]
        case .manClimbing:
            return [
                [.light]: "🧗🏻‍♂️",
                [.mediumLight]: "🧗🏼‍♂️",
                [.medium]: "🧗🏽‍♂️",
                [.mediumDark]: "🧗🏾‍♂️",
                [.dark]: "🧗🏿‍♂️",
            ]
        case .womanClimbing:
            return [
                [.light]: "🧗🏻‍♀️",
                [.mediumLight]: "🧗🏼‍♀️",
                [.medium]: "🧗🏽‍♀️",
                [.mediumDark]: "🧗🏾‍♀️",
                [.dark]: "🧗🏿‍♀️",
            ]
        case .horseRacing:
            return [
                [.light]: "🏇🏻",
                [.mediumLight]: "🏇🏼",
                [.medium]: "🏇🏽",
                [.mediumDark]: "🏇🏾",
                [.dark]: "🏇🏿",
            ]
        case .snowboarder:
            return [
                [.light]: "🏂🏻",
                [.mediumLight]: "🏂🏼",
                [.medium]: "🏂🏽",
                [.mediumDark]: "🏂🏾",
                [.dark]: "🏂🏿",
            ]
        case .golfer:
            return [
                [.light]: "🏌🏻",
                [.mediumLight]: "🏌🏼",
                [.medium]: "🏌🏽",
                [.mediumDark]: "🏌🏾",
                [.dark]: "🏌🏿",
            ]
        case .manGolfing:
            return [
                [.light]: "🏌🏻‍♂️",
                [.mediumLight]: "🏌🏼‍♂️",
                [.medium]: "🏌🏽‍♂️",
                [.mediumDark]: "🏌🏾‍♂️",
                [.dark]: "🏌🏿‍♂️",
            ]
        case .womanGolfing:
            return [
                [.light]: "🏌🏻‍♀️",
                [.mediumLight]: "🏌🏼‍♀️",
                [.medium]: "🏌🏽‍♀️",
                [.mediumDark]: "🏌🏾‍♀️",
                [.dark]: "🏌🏿‍♀️",
            ]
        case .surfer:
            return [
                [.light]: "🏄🏻",
                [.mediumLight]: "🏄🏼",
                [.medium]: "🏄🏽",
                [.mediumDark]: "🏄🏾",
                [.dark]: "🏄🏿",
            ]
        case .manSurfing:
            return [
                [.light]: "🏄🏻‍♂️",
                [.mediumLight]: "🏄🏼‍♂️",
                [.medium]: "🏄🏽‍♂️",
                [.mediumDark]: "🏄🏾‍♂️",
                [.dark]: "🏄🏿‍♂️",
            ]
        case .womanSurfing:
            return [
                [.light]: "🏄🏻‍♀️",
                [.mediumLight]: "🏄🏼‍♀️",
                [.medium]: "🏄🏽‍♀️",
                [.mediumDark]: "🏄🏾‍♀️",
                [.dark]: "🏄🏿‍♀️",
            ]
        case .rowboat:
            return [
                [.light]: "🚣🏻",
                [.mediumLight]: "🚣🏼",
                [.medium]: "🚣🏽",
                [.mediumDark]: "🚣🏾",
                [.dark]: "🚣🏿",
            ]
        case .manRowingBoat:
            return [
                [.light]: "🚣🏻‍♂️",
                [.mediumLight]: "🚣🏼‍♂️",
                [.medium]: "🚣🏽‍♂️",
                [.mediumDark]: "🚣🏾‍♂️",
                [.dark]: "🚣🏿‍♂️",
            ]
        case .womanRowingBoat:
            return [
                [.light]: "🚣🏻‍♀️",
                [.mediumLight]: "🚣🏼‍♀️",
                [.medium]: "🚣🏽‍♀️",
                [.mediumDark]: "🚣🏾‍♀️",
                [.dark]: "🚣🏿‍♀️",
            ]
        case .swimmer:
            return [
                [.light]: "🏊🏻",
                [.mediumLight]: "🏊🏼",
                [.medium]: "🏊🏽",
                [.mediumDark]: "🏊🏾",
                [.dark]: "🏊🏿",
            ]
        case .manSwimming:
            return [
                [.light]: "🏊🏻‍♂️",
                [.mediumLight]: "🏊🏼‍♂️",
                [.medium]: "🏊🏽‍♂️",
                [.mediumDark]: "🏊🏾‍♂️",
                [.dark]: "🏊🏿‍♂️",
            ]
        case .womanSwimming:
            return [
                [.light]: "🏊🏻‍♀️",
                [.mediumLight]: "🏊🏼‍♀️",
                [.medium]: "🏊🏽‍♀️",
                [.mediumDark]: "🏊🏾‍♀️",
                [.dark]: "🏊🏿‍♀️",
            ]
        case .personWithBall:
            return [
                [.light]: "⛹🏻",
                [.mediumLight]: "⛹🏼",
                [.medium]: "⛹🏽",
                [.mediumDark]: "⛹🏾",
                [.dark]: "⛹🏿",
            ]
        case .manBouncingBall:
            return [
                [.light]: "⛹🏻‍♂️",
                [.mediumLight]: "⛹🏼‍♂️",
                [.medium]: "⛹🏽‍♂️",
                [.mediumDark]: "⛹🏾‍♂️",
                [.dark]: "⛹🏿‍♂️",
            ]
        case .womanBouncingBall:
            return [
                [.light]: "⛹🏻‍♀️",
                [.mediumLight]: "⛹🏼‍♀️",
                [.medium]: "⛹🏽‍♀️",
                [.mediumDark]: "⛹🏾‍♀️",
                [.dark]: "⛹🏿‍♀️",
            ]
        case .weightLifter:
            return [
                [.light]: "🏋🏻",
                [.mediumLight]: "🏋🏼",
                [.medium]: "🏋🏽",
                [.mediumDark]: "🏋🏾",
                [.dark]: "🏋🏿",
            ]
        case .manLiftingWeights:
            return [
                [.light]: "🏋🏻‍♂️",
                [.mediumLight]: "🏋🏼‍♂️",
                [.medium]: "🏋🏽‍♂️",
                [.mediumDark]: "🏋🏾‍♂️",
                [.dark]: "🏋🏿‍♂️",
            ]
        case .womanLiftingWeights:
            return [
                [.light]: "🏋🏻‍♀️",
                [.mediumLight]: "🏋🏼‍♀️",
                [.medium]: "🏋🏽‍♀️",
                [.mediumDark]: "🏋🏾‍♀️",
                [.dark]: "🏋🏿‍♀️",
            ]
        case .bicyclist:
            return [
                [.light]: "🚴🏻",
                [.mediumLight]: "🚴🏼",
                [.medium]: "🚴🏽",
                [.mediumDark]: "🚴🏾",
                [.dark]: "🚴🏿",
            ]
        case .manBiking:
            return [
                [.light]: "🚴🏻‍♂️",
                [.mediumLight]: "🚴🏼‍♂️",
                [.medium]: "🚴🏽‍♂️",
                [.mediumDark]: "🚴🏾‍♂️",
                [.dark]: "🚴🏿‍♂️",
            ]
        case .womanBiking:
            return [
                [.light]: "🚴🏻‍♀️",
                [.mediumLight]: "🚴🏼‍♀️",
                [.medium]: "🚴🏽‍♀️",
                [.mediumDark]: "🚴🏾‍♀️",
                [.dark]: "🚴🏿‍♀️",
            ]
        case .mountainBicyclist:
            return [
                [.light]: "🚵🏻",
                [.mediumLight]: "🚵🏼",
                [.medium]: "🚵🏽",
                [.mediumDark]: "🚵🏾",
                [.dark]: "🚵🏿",
            ]
        case .manMountainBiking:
            return [
                [.light]: "🚵🏻‍♂️",
                [.mediumLight]: "🚵🏼‍♂️",
                [.medium]: "🚵🏽‍♂️",
                [.mediumDark]: "🚵🏾‍♂️",
                [.dark]: "🚵🏿‍♂️",
            ]
        case .womanMountainBiking:
            return [
                [.light]: "🚵🏻‍♀️",
                [.mediumLight]: "🚵🏼‍♀️",
                [.medium]: "🚵🏽‍♀️",
                [.mediumDark]: "🚵🏾‍♀️",
                [.dark]: "🚵🏿‍♀️",
            ]
        case .personDoingCartwheel:
            return [
                [.light]: "🤸🏻",
                [.mediumLight]: "🤸🏼",
                [.medium]: "🤸🏽",
                [.mediumDark]: "🤸🏾",
                [.dark]: "🤸🏿",
            ]
        case .manCartwheeling:
            return [
                [.light]: "🤸🏻‍♂️",
                [.mediumLight]: "🤸🏼‍♂️",
                [.medium]: "🤸🏽‍♂️",
                [.mediumDark]: "🤸🏾‍♂️",
                [.dark]: "🤸🏿‍♂️",
            ]
        case .womanCartwheeling:
            return [
                [.light]: "🤸🏻‍♀️",
                [.mediumLight]: "🤸🏼‍♀️",
                [.medium]: "🤸🏽‍♀️",
                [.mediumDark]: "🤸🏾‍♀️",
                [.dark]: "🤸🏿‍♀️",
            ]
        case .waterPolo:
            return [
                [.light]: "🤽🏻",
                [.mediumLight]: "🤽🏼",
                [.medium]: "🤽🏽",
                [.mediumDark]: "🤽🏾",
                [.dark]: "🤽🏿",
            ]
        case .manPlayingWaterPolo:
            return [
                [.light]: "🤽🏻‍♂️",
                [.mediumLight]: "🤽🏼‍♂️",
                [.medium]: "🤽🏽‍♂️",
                [.mediumDark]: "🤽🏾‍♂️",
                [.dark]: "🤽🏿‍♂️",
            ]
        case .womanPlayingWaterPolo:
            return [
                [.light]: "🤽🏻‍♀️",
                [.mediumLight]: "🤽🏼‍♀️",
                [.medium]: "🤽🏽‍♀️",
                [.mediumDark]: "🤽🏾‍♀️",
                [.dark]: "🤽🏿‍♀️",
            ]
        case .handball:
            return [
                [.light]: "🤾🏻",
                [.mediumLight]: "🤾🏼",
                [.medium]: "🤾🏽",
                [.mediumDark]: "🤾🏾",
                [.dark]: "🤾🏿",
            ]
        case .manPlayingHandball:
            return [
                [.light]: "🤾🏻‍♂️",
                [.mediumLight]: "🤾🏼‍♂️",
                [.medium]: "🤾🏽‍♂️",
                [.mediumDark]: "🤾🏾‍♂️",
                [.dark]: "🤾🏿‍♂️",
            ]
        case .womanPlayingHandball:
            return [
                [.light]: "🤾🏻‍♀️",
                [.mediumLight]: "🤾🏼‍♀️",
                [.medium]: "🤾🏽‍♀️",
                [.mediumDark]: "🤾🏾‍♀️",
                [.dark]: "🤾🏿‍♀️",
            ]
        case .juggling:
            return [
                [.light]: "🤹🏻",
                [.mediumLight]: "🤹🏼",
                [.medium]: "🤹🏽",
                [.mediumDark]: "🤹🏾",
                [.dark]: "🤹🏿",
            ]
        case .manJuggling:
            return [
                [.light]: "🤹🏻‍♂️",
                [.mediumLight]: "🤹🏼‍♂️",
                [.medium]: "🤹🏽‍♂️",
                [.mediumDark]: "🤹🏾‍♂️",
                [.dark]: "🤹🏿‍♂️",
            ]
        case .womanJuggling:
            return [
                [.light]: "🤹🏻‍♀️",
                [.mediumLight]: "🤹🏼‍♀️",
                [.medium]: "🤹🏽‍♀️",
                [.mediumDark]: "🤹🏾‍♀️",
                [.dark]: "🤹🏿‍♀️",
            ]
        case .personInLotusPosition:
            return [
                [.light]: "🧘🏻",
                [.mediumLight]: "🧘🏼",
                [.medium]: "🧘🏽",
                [.mediumDark]: "🧘🏾",
                [.dark]: "🧘🏿",
            ]
        case .manInLotusPosition:
            return [
                [.light]: "🧘🏻‍♂️",
                [.mediumLight]: "🧘🏼‍♂️",
                [.medium]: "🧘🏽‍♂️",
                [.mediumDark]: "🧘🏾‍♂️",
                [.dark]: "🧘🏿‍♂️",
            ]
        case .womanInLotusPosition:
            return [
                [.light]: "🧘🏻‍♀️",
                [.mediumLight]: "🧘🏼‍♀️",
                [.medium]: "🧘🏽‍♀️",
                [.mediumDark]: "🧘🏾‍♀️",
                [.dark]: "🧘🏿‍♀️",
            ]
        case .bath:
            return [
                [.light]: "🛀🏻",
                [.mediumLight]: "🛀🏼",
                [.medium]: "🛀🏽",
                [.mediumDark]: "🛀🏾",
                [.dark]: "🛀🏿",
            ]
        case .sleepingAccommodation:
            return [
                [.light]: "🛌🏻",
                [.mediumLight]: "🛌🏼",
                [.medium]: "🛌🏽",
                [.mediumDark]: "🛌🏾",
                [.dark]: "🛌🏿",
            ]
        case .peopleHoldingHands:
            return [
                [.light]: "🧑🏻‍🤝‍🧑🏻",
                [.light, .mediumLight]: "🧑🏻‍🤝‍🧑🏼",
                [.light, .medium]: "🧑🏻‍🤝‍🧑🏽",
                [.light, .mediumDark]: "🧑🏻‍🤝‍🧑🏾",
                [.light, .dark]: "🧑🏻‍🤝‍🧑🏿",
                [.mediumLight]: "🧑🏼‍🤝‍🧑🏼",
                [.mediumLight, .light]: "🧑🏼‍🤝‍🧑🏻",
                [.mediumLight, .medium]: "🧑🏼‍🤝‍🧑🏽",
                [.mediumLight, .mediumDark]: "🧑🏼‍🤝‍🧑🏾",
                [.mediumLight, .dark]: "🧑🏼‍🤝‍🧑🏿",
                [.medium]: "🧑🏽‍🤝‍🧑🏽",
                [.medium, .light]: "🧑🏽‍🤝‍🧑🏻",
                [.medium, .mediumLight]: "🧑🏽‍🤝‍🧑🏼",
                [.medium, .mediumDark]: "🧑🏽‍🤝‍🧑🏾",
                [.medium, .dark]: "🧑🏽‍🤝‍🧑🏿",
                [.mediumDark]: "🧑🏾‍🤝‍🧑🏾",
                [.mediumDark, .light]: "🧑🏾‍🤝‍🧑🏻",
                [.mediumDark, .mediumLight]: "🧑🏾‍🤝‍🧑🏼",
                [.mediumDark, .medium]: "🧑🏾‍🤝‍🧑🏽",
                [.mediumDark, .dark]: "🧑🏾‍🤝‍🧑🏿",
                [.dark]: "🧑🏿‍🤝‍🧑🏿",
                [.dark, .light]: "🧑🏿‍🤝‍🧑🏻",
                [.dark, .mediumLight]: "🧑🏿‍🤝‍🧑🏼",
                [.dark, .medium]: "🧑🏿‍🤝‍🧑🏽",
                [.dark, .mediumDark]: "🧑🏿‍🤝‍🧑🏾",
            ]
        case .twoWomenHoldingHands:
            return [
                [.light]: "👭🏻",
                [.light, .mediumLight]: "👩🏻‍🤝‍👩🏼",
                [.light, .medium]: "👩🏻‍🤝‍👩🏽",
                [.light, .mediumDark]: "👩🏻‍🤝‍👩🏾",
                [.light, .dark]: "👩🏻‍🤝‍👩🏿",
                [.mediumLight]: "👭🏼",
                [.mediumLight, .light]: "👩🏼‍🤝‍👩🏻",
                [.mediumLight, .medium]: "👩🏼‍🤝‍👩🏽",
                [.mediumLight, .mediumDark]: "👩🏼‍🤝‍👩🏾",
                [.mediumLight, .dark]: "👩🏼‍🤝‍👩🏿",
                [.medium]: "👭🏽",
                [.medium, .light]: "👩🏽‍🤝‍👩🏻",
                [.medium, .mediumLight]: "👩🏽‍🤝‍👩🏼",
                [.medium, .mediumDark]: "👩🏽‍🤝‍👩🏾",
                [.medium, .dark]: "👩🏽‍🤝‍👩🏿",
                [.mediumDark]: "👭🏾",
                [.mediumDark, .light]: "👩🏾‍🤝‍👩🏻",
                [.mediumDark, .mediumLight]: "👩🏾‍🤝‍👩🏼",
                [.mediumDark, .medium]: "👩🏾‍🤝‍👩🏽",
                [.mediumDark, .dark]: "👩🏾‍🤝‍👩🏿",
                [.dark]: "👭🏿",
                [.dark, .light]: "👩🏿‍🤝‍👩🏻",
                [.dark, .mediumLight]: "👩🏿‍🤝‍👩🏼",
                [.dark, .medium]: "👩🏿‍🤝‍👩🏽",
                [.dark, .mediumDark]: "👩🏿‍🤝‍👩🏾",
            ]
        case .manAndWomanHoldingHands:
            return [
                [.light]: "👫🏻",
                [.light, .mediumLight]: "👩🏻‍🤝‍👨🏼",
                [.light, .medium]: "👩🏻‍🤝‍👨🏽",
                [.light, .mediumDark]: "👩🏻‍🤝‍👨🏾",
                [.light, .dark]: "👩🏻‍🤝‍👨🏿",
                [.mediumLight]: "👫🏼",
                [.mediumLight, .light]: "👩🏼‍🤝‍👨🏻",
                [.mediumLight, .medium]: "👩🏼‍🤝‍👨🏽",
                [.mediumLight, .mediumDark]: "👩🏼‍🤝‍👨🏾",
                [.mediumLight, .dark]: "👩🏼‍🤝‍👨🏿",
                [.medium]: "👫🏽",
                [.medium, .light]: "👩🏽‍🤝‍👨🏻",
                [.medium, .mediumLight]: "👩🏽‍🤝‍👨🏼",
                [.medium, .mediumDark]: "👩🏽‍🤝‍👨🏾",
                [.medium, .dark]: "👩🏽‍🤝‍👨🏿",
                [.mediumDark]: "👫🏾",
                [.mediumDark, .light]: "👩🏾‍🤝‍👨🏻",
                [.mediumDark, .mediumLight]: "👩🏾‍🤝‍👨🏼",
                [.mediumDark, .medium]: "👩🏾‍🤝‍👨🏽",
                [.mediumDark, .dark]: "👩🏾‍🤝‍👨🏿",
                [.dark]: "👫🏿",
                [.dark, .light]: "👩🏿‍🤝‍👨🏻",
                [.dark, .mediumLight]: "👩🏿‍🤝‍👨🏼",
                [.dark, .medium]: "👩🏿‍🤝‍👨🏽",
                [.dark, .mediumDark]: "👩🏿‍🤝‍👨🏾",
            ]
        case .twoMenHoldingHands:
            return [
                [.light]: "👬🏻",
                [.light, .mediumLight]: "👨🏻‍🤝‍👨🏼",
                [.light, .medium]: "👨🏻‍🤝‍👨🏽",
                [.light, .mediumDark]: "👨🏻‍🤝‍👨🏾",
                [.light, .dark]: "👨🏻‍🤝‍👨🏿",
                [.mediumLight]: "👬🏼",
                [.mediumLight, .light]: "👨🏼‍🤝‍👨🏻",
                [.mediumLight, .medium]: "👨🏼‍🤝‍👨🏽",
                [.mediumLight, .mediumDark]: "👨🏼‍🤝‍👨🏾",
                [.mediumLight, .dark]: "👨🏼‍🤝‍👨🏿",
                [.medium]: "👬🏽",
                [.medium, .light]: "👨🏽‍🤝‍👨🏻",
                [.medium, .mediumLight]: "👨🏽‍🤝‍👨🏼",
                [.medium, .mediumDark]: "👨🏽‍🤝‍👨🏾",
                [.medium, .dark]: "👨🏽‍🤝‍👨🏿",
                [.mediumDark]: "👬🏾",
                [.mediumDark, .light]: "👨🏾‍🤝‍👨🏻",
                [.mediumDark, .mediumLight]: "👨🏾‍🤝‍👨🏼",
                [.mediumDark, .medium]: "👨🏾‍🤝‍👨🏽",
                [.mediumDark, .dark]: "👨🏾‍🤝‍👨🏿",
                [.dark]: "👬🏿",
                [.dark, .light]: "👨🏿‍🤝‍👨🏻",
                [.dark, .mediumLight]: "👨🏿‍🤝‍👨🏼",
                [.dark, .medium]: "👨🏿‍🤝‍👨🏽",
                [.dark, .mediumDark]: "👨🏿‍🤝‍👨🏾",
            ]
        case .personKissPerson:
            return [
                [.light]: "💏🏻",
                [.light, .mediumLight]: "🧑🏻‍❤️‍💋‍🧑🏼",
                [.light, .medium]: "🧑🏻‍❤️‍💋‍🧑🏽",
                [.light, .mediumDark]: "🧑🏻‍❤️‍💋‍🧑🏾",
                [.light, .dark]: "🧑🏻‍❤️‍💋‍🧑🏿",
                [.mediumLight]: "💏🏼",
                [.mediumLight, .light]: "🧑🏼‍❤️‍💋‍🧑🏻",
                [.mediumLight, .medium]: "🧑🏼‍❤️‍💋‍🧑🏽",
                [.mediumLight, .mediumDark]: "🧑🏼‍❤️‍💋‍🧑🏾",
                [.mediumLight, .dark]: "🧑🏼‍❤️‍💋‍🧑🏿",
                [.medium]: "💏🏽",
                [.medium, .light]: "🧑🏽‍❤️‍💋‍🧑🏻",
                [.medium, .mediumLight]: "🧑🏽‍❤️‍💋‍🧑🏼",
                [.medium, .mediumDark]: "🧑🏽‍❤️‍💋‍🧑🏾",
                [.medium, .dark]: "🧑🏽‍❤️‍💋‍🧑🏿",
                [.mediumDark]: "💏🏾",
                [.mediumDark, .light]: "🧑🏾‍❤️‍💋‍🧑🏻",
                [.mediumDark, .mediumLight]: "🧑🏾‍❤️‍💋‍🧑🏼",
                [.mediumDark, .medium]: "🧑🏾‍❤️‍💋‍🧑🏽",
                [.mediumDark, .dark]: "🧑🏾‍❤️‍💋‍🧑🏿",
                [.dark]: "💏🏿",
                [.dark, .light]: "🧑🏿‍❤️‍💋‍🧑🏻",
                [.dark, .mediumLight]: "🧑🏿‍❤️‍💋‍🧑🏼",
                [.dark, .medium]: "🧑🏿‍❤️‍💋‍🧑🏽",
                [.dark, .mediumDark]: "🧑🏿‍❤️‍💋‍🧑🏾",
            ]
        case .womanKissMan:
            return [
                [.light]: "👩🏻‍❤️‍💋‍👨🏻",
                [.light, .mediumLight]: "👩🏻‍❤️‍💋‍👨🏼",
                [.light, .medium]: "👩🏻‍❤️‍💋‍👨🏽",
                [.light, .mediumDark]: "👩🏻‍❤️‍💋‍👨🏾",
                [.light, .dark]: "👩🏻‍❤️‍💋‍👨🏿",
                [.mediumLight]: "👩🏼‍❤️‍💋‍👨🏼",
                [.mediumLight, .light]: "👩🏼‍❤️‍💋‍👨🏻",
                [.mediumLight, .medium]: "👩🏼‍❤️‍💋‍👨🏽",
                [.mediumLight, .mediumDark]: "👩🏼‍❤️‍💋‍👨🏾",
                [.mediumLight, .dark]: "👩🏼‍❤️‍💋‍👨🏿",
                [.medium]: "👩🏽‍❤️‍💋‍👨🏽",
                [.medium, .light]: "👩🏽‍❤️‍💋‍👨🏻",
                [.medium, .mediumLight]: "👩🏽‍❤️‍💋‍👨🏼",
                [.medium, .mediumDark]: "👩🏽‍❤️‍💋‍👨🏾",
                [.medium, .dark]: "👩🏽‍❤️‍💋‍👨🏿",
                [.mediumDark]: "👩🏾‍❤️‍💋‍👨🏾",
                [.mediumDark, .light]: "👩🏾‍❤️‍💋‍👨🏻",
                [.mediumDark, .mediumLight]: "👩🏾‍❤️‍💋‍👨🏼",
                [.mediumDark, .medium]: "👩🏾‍❤️‍💋‍👨🏽",
                [.mediumDark, .dark]: "👩🏾‍❤️‍💋‍👨🏿",
                [.dark]: "👩🏿‍❤️‍💋‍👨🏿",
                [.dark, .light]: "👩🏿‍❤️‍💋‍👨🏻",
                [.dark, .mediumLight]: "👩🏿‍❤️‍💋‍👨🏼",
                [.dark, .medium]: "👩🏿‍❤️‍💋‍👨🏽",
                [.dark, .mediumDark]: "👩🏿‍❤️‍💋‍👨🏾",
            ]
        case .manKissMan:
            return [
                [.light]: "👨🏻‍❤️‍💋‍👨🏻",
                [.light, .mediumLight]: "👨🏻‍❤️‍💋‍👨🏼",
                [.light, .medium]: "👨🏻‍❤️‍💋‍👨🏽",
                [.light, .mediumDark]: "👨🏻‍❤️‍💋‍👨🏾",
                [.light, .dark]: "👨🏻‍❤️‍💋‍👨🏿",
                [.mediumLight]: "👨🏼‍❤️‍💋‍👨🏼",
                [.mediumLight, .light]: "👨🏼‍❤️‍💋‍👨🏻",
                [.mediumLight, .medium]: "👨🏼‍❤️‍💋‍👨🏽",
                [.mediumLight, .mediumDark]: "👨🏼‍❤️‍💋‍👨🏾",
                [.mediumLight, .dark]: "👨🏼‍❤️‍💋‍👨🏿",
                [.medium]: "👨🏽‍❤️‍💋‍👨🏽",
                [.medium, .light]: "👨🏽‍❤️‍💋‍👨🏻",
                [.medium, .mediumLight]: "👨🏽‍❤️‍💋‍👨🏼",
                [.medium, .mediumDark]: "👨🏽‍❤️‍💋‍👨🏾",
                [.medium, .dark]: "👨🏽‍❤️‍💋‍👨🏿",
                [.mediumDark]: "👨🏾‍❤️‍💋‍👨🏾",
                [.mediumDark, .light]: "👨🏾‍❤️‍💋‍👨🏻",
                [.mediumDark, .mediumLight]: "👨🏾‍❤️‍💋‍👨🏼",
                [.mediumDark, .medium]: "👨🏾‍❤️‍💋‍👨🏽",
                [.mediumDark, .dark]: "👨🏾‍❤️‍💋‍👨🏿",
                [.dark]: "👨🏿‍❤️‍💋‍👨🏿",
                [.dark, .light]: "👨🏿‍❤️‍💋‍👨🏻",
                [.dark, .mediumLight]: "👨🏿‍❤️‍💋‍👨🏼",
                [.dark, .medium]: "👨🏿‍❤️‍💋‍👨🏽",
                [.dark, .mediumDark]: "👨🏿‍❤️‍💋‍👨🏾",
            ]
        case .womanKissWoman:
            return [
                [.light]: "👩🏻‍❤️‍💋‍👩🏻",
                [.light, .mediumLight]: "👩🏻‍❤️‍💋‍👩🏼",
                [.light, .medium]: "👩🏻‍❤️‍💋‍👩🏽",
                [.light, .mediumDark]: "👩🏻‍❤️‍💋‍👩🏾",
                [.light, .dark]: "👩🏻‍❤️‍💋‍👩🏿",
                [.mediumLight]: "👩🏼‍❤️‍💋‍👩🏼",
                [.mediumLight, .light]: "👩🏼‍❤️‍💋‍👩🏻",
                [.mediumLight, .medium]: "👩🏼‍❤️‍💋‍👩🏽",
                [.mediumLight, .mediumDark]: "👩🏼‍❤️‍💋‍👩🏾",
                [.mediumLight, .dark]: "👩🏼‍❤️‍💋‍👩🏿",
                [.medium]: "👩🏽‍❤️‍💋‍👩🏽",
                [.medium, .light]: "👩🏽‍❤️‍💋‍👩🏻",
                [.medium, .mediumLight]: "👩🏽‍❤️‍💋‍👩🏼",
                [.medium, .mediumDark]: "👩🏽‍❤️‍💋‍👩🏾",
                [.medium, .dark]: "👩🏽‍❤️‍💋‍👩🏿",
                [.mediumDark]: "👩🏾‍❤️‍💋‍👩🏾",
                [.mediumDark, .light]: "👩🏾‍❤️‍💋‍👩🏻",
                [.mediumDark, .mediumLight]: "👩🏾‍❤️‍💋‍👩🏼",
                [.mediumDark, .medium]: "👩🏾‍❤️‍💋‍👩🏽",
                [.mediumDark, .dark]: "👩🏾‍❤️‍💋‍👩🏿",
                [.dark]: "👩🏿‍❤️‍💋‍👩🏿",
                [.dark, .light]: "👩🏿‍❤️‍💋‍👩🏻",
                [.dark, .mediumLight]: "👩🏿‍❤️‍💋‍👩🏼",
                [.dark, .medium]: "👩🏿‍❤️‍💋‍👩🏽",
                [.dark, .mediumDark]: "👩🏿‍❤️‍💋‍👩🏾",
            ]
        case .personHeartPerson:
            return [
                [.light]: "💑🏻",
                [.light, .mediumLight]: "🧑🏻‍❤️‍🧑🏼",
                [.light, .medium]: "🧑🏻‍❤️‍🧑🏽",
                [.light, .mediumDark]: "🧑🏻‍❤️‍🧑🏾",
                [.light, .dark]: "🧑🏻‍❤️‍🧑🏿",
                [.mediumLight]: "💑🏼",
                [.mediumLight, .light]: "🧑🏼‍❤️‍🧑🏻",
                [.mediumLight, .medium]: "🧑🏼‍❤️‍🧑🏽",
                [.mediumLight, .mediumDark]: "🧑🏼‍❤️‍🧑🏾",
                [.mediumLight, .dark]: "🧑🏼‍❤️‍🧑🏿",
                [.medium]: "💑🏽",
                [.medium, .light]: "🧑🏽‍❤️‍🧑🏻",
                [.medium, .mediumLight]: "🧑🏽‍❤️‍🧑🏼",
                [.medium, .mediumDark]: "🧑🏽‍❤️‍🧑🏾",
                [.medium, .dark]: "🧑🏽‍❤️‍🧑🏿",
                [.mediumDark]: "💑🏾",
                [.mediumDark, .light]: "🧑🏾‍❤️‍🧑🏻",
                [.mediumDark, .mediumLight]: "🧑🏾‍❤️‍🧑🏼",
                [.mediumDark, .medium]: "🧑🏾‍❤️‍🧑🏽",
                [.mediumDark, .dark]: "🧑🏾‍❤️‍🧑🏿",
                [.dark]: "💑🏿",
                [.dark, .light]: "🧑🏿‍❤️‍🧑🏻",
                [.dark, .mediumLight]: "🧑🏿‍❤️‍🧑🏼",
                [.dark, .medium]: "🧑🏿‍❤️‍🧑🏽",
                [.dark, .mediumDark]: "🧑🏿‍❤️‍🧑🏾",
            ]
        case .womanHeartMan:
            return [
                [.light]: "👩🏻‍❤️‍👨🏻",
                [.light, .mediumLight]: "👩🏻‍❤️‍👨🏼",
                [.light, .medium]: "👩🏻‍❤️‍👨🏽",
                [.light, .mediumDark]: "👩🏻‍❤️‍👨🏾",
                [.light, .dark]: "👩🏻‍❤️‍👨🏿",
                [.mediumLight]: "👩🏼‍❤️‍👨🏼",
                [.mediumLight, .light]: "👩🏼‍❤️‍👨🏻",
                [.mediumLight, .medium]: "👩🏼‍❤️‍👨🏽",
                [.mediumLight, .mediumDark]: "👩🏼‍❤️‍👨🏾",
                [.mediumLight, .dark]: "👩🏼‍❤️‍👨🏿",
                [.medium]: "👩🏽‍❤️‍👨🏽",
                [.medium, .light]: "👩🏽‍❤️‍👨🏻",
                [.medium, .mediumLight]: "👩🏽‍❤️‍👨🏼",
                [.medium, .mediumDark]: "👩🏽‍❤️‍👨🏾",
                [.medium, .dark]: "👩🏽‍❤️‍👨🏿",
                [.mediumDark]: "👩🏾‍❤️‍👨🏾",
                [.mediumDark, .light]: "👩🏾‍❤️‍👨🏻",
                [.mediumDark, .mediumLight]: "👩🏾‍❤️‍👨🏼",
                [.mediumDark, .medium]: "👩🏾‍❤️‍👨🏽",
                [.mediumDark, .dark]: "👩🏾‍❤️‍👨🏿",
                [.dark]: "👩🏿‍❤️‍👨🏿",
                [.dark, .light]: "👩🏿‍❤️‍👨🏻",
                [.dark, .mediumLight]: "👩🏿‍❤️‍👨🏼",
                [.dark, .medium]: "👩🏿‍❤️‍👨🏽",
                [.dark, .mediumDark]: "👩🏿‍❤️‍👨🏾",
            ]
        case .manHeartMan:
            return [
                [.light]: "👨🏻‍❤️‍👨🏻",
                [.light, .mediumLight]: "👨🏻‍❤️‍👨🏼",
                [.light, .medium]: "👨🏻‍❤️‍👨🏽",
                [.light, .mediumDark]: "👨🏻‍❤️‍👨🏾",
                [.light, .dark]: "👨🏻‍❤️‍👨🏿",
                [.mediumLight]: "👨🏼‍❤️‍👨🏼",
                [.mediumLight, .light]: "👨🏼‍❤️‍👨🏻",
                [.mediumLight, .medium]: "👨🏼‍❤️‍👨🏽",
                [.mediumLight, .mediumDark]: "👨🏼‍❤️‍👨🏾",
                [.mediumLight, .dark]: "👨🏼‍❤️‍👨🏿",
                [.medium]: "👨🏽‍❤️‍👨🏽",
                [.medium, .light]: "👨🏽‍❤️‍👨🏻",
                [.medium, .mediumLight]: "👨🏽‍❤️‍👨🏼",
                [.medium, .mediumDark]: "👨🏽‍❤️‍👨🏾",
                [.medium, .dark]: "👨🏽‍❤️‍👨🏿",
                [.mediumDark]: "👨🏾‍❤️‍👨🏾",
                [.mediumDark, .light]: "👨🏾‍❤️‍👨🏻",
                [.mediumDark, .mediumLight]: "👨🏾‍❤️‍👨🏼",
                [.mediumDark, .medium]: "👨🏾‍❤️‍👨🏽",
                [.mediumDark, .dark]: "👨🏾‍❤️‍👨🏿",
                [.dark]: "👨🏿‍❤️‍👨🏿",
                [.dark, .light]: "👨🏿‍❤️‍👨🏻",
                [.dark, .mediumLight]: "👨🏿‍❤️‍👨🏼",
                [.dark, .medium]: "👨🏿‍❤️‍👨🏽",
                [.dark, .mediumDark]: "👨🏿‍❤️‍👨🏾",
            ]
        case .womanHeartWoman:
            return [
                [.light]: "👩🏻‍❤️‍👩🏻",
                [.light, .mediumLight]: "👩🏻‍❤️‍👩🏼",
                [.light, .medium]: "👩🏻‍❤️‍👩🏽",
                [.light, .mediumDark]: "👩🏻‍❤️‍👩🏾",
                [.light, .dark]: "👩🏻‍❤️‍👩🏿",
                [.mediumLight]: "👩🏼‍❤️‍👩🏼",
                [.mediumLight, .light]: "👩🏼‍❤️‍👩🏻",
                [.mediumLight, .medium]: "👩🏼‍❤️‍👩🏽",
                [.mediumLight, .mediumDark]: "👩🏼‍❤️‍👩🏾",
                [.mediumLight, .dark]: "👩🏼‍❤️‍👩🏿",
                [.medium]: "👩🏽‍❤️‍👩🏽",
                [.medium, .light]: "👩🏽‍❤️‍👩🏻",
                [.medium, .mediumLight]: "👩🏽‍❤️‍👩🏼",
                [.medium, .mediumDark]: "👩🏽‍❤️‍👩🏾",
                [.medium, .dark]: "👩🏽‍❤️‍👩🏿",
                [.mediumDark]: "👩🏾‍❤️‍👩🏾",
                [.mediumDark, .light]: "👩🏾‍❤️‍👩🏻",
                [.mediumDark, .mediumLight]: "👩🏾‍❤️‍👩🏼",
                [.mediumDark, .medium]: "👩🏾‍❤️‍👩🏽",
                [.mediumDark, .dark]: "👩🏾‍❤️‍👩🏿",
                [.dark]: "👩🏿‍❤️‍👩🏿",
                [.dark, .light]: "👩🏿‍❤️‍👩🏻",
                [.dark, .mediumLight]: "👩🏿‍❤️‍👩🏼",
                [.dark, .medium]: "👩🏿‍❤️‍👩🏽",
                [.dark, .mediumDark]: "👩🏿‍❤️‍👩🏾",
            ]
        default: return nil
        }
    }
}
