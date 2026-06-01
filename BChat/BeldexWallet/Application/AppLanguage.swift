//
//  AppLanguage.swift
//

import Foundation
import UIKit
import ObjectiveC.runtime

private struct LocalizationPath {
    static func path(for identifier: String) -> String? {
        Bundle.main.path(forResource: identifier, ofType: "lproj")
    }
}

@objcMembers
final class AppLocalization: NSObject {
    private static var didBootstrap = false

    static func bootstrap() {
        guard !didBootstrap else { return }
        didBootstrap = true
        Bundle.swizzleAppLocalization()
    }
}

public func LocalizedString(key: String, comment: String) -> String {
    return NSLocalizedString(key, comment: comment)
}

final class AppLanguage: NSObject {

    enum Lang: String, CaseIterable {
        case english = "en"
        case spanish = "es"
        case german = "de"
        case japanese = "ja"
        case arabic = "ar"
        case portuguese = "pt"
        case russian = "ru"
        case turkish = "tr"
        case chinese = "zh-Hans"
        case korean = "ko"
        case vietnamese = "vi-VN"

        var displayName: String {
            switch self {
            case .english:
                return "English"
            case .spanish:
                return "Español"
            case .german:
                return "Deutsch"
            case .japanese:
                return "日本語"
            case .arabic:
                return "العربية"
            case .portuguese:
                return "Português"
            case .russian:
                return "Русский"
            case .turkish:
                return "Türkçe"
            case .chinese:
                return "中文"
            case .korean:
                return "한국어"
            case .vietnamese:
                return "Tiếng Việt"
            }
        }

        var bundleIdentifier: String {
            rawValue
        }

        static func language(for identifier: String) -> Lang? {
            let normalized = identifier.lowercased()

            return allCases.first { language in
                let bundleIdentifier = language.bundleIdentifier.lowercased()
                return normalized == bundleIdentifier || normalized.hasPrefix(bundleIdentifier + "-") || normalized.hasPrefix(bundleIdentifier + "_")
            }
        }
    }

    static let manager: AppLanguage = { AppLanguage() }()
    static let PreferredLanguageKey: String = "PreferredLanguage"

    // MARK: - Properties (Public)

    public var current: Lang {
        get {
            guard
                let storedValue = UserDefaults.standard.string(forKey: AppLanguage.PreferredLanguageKey),
                storedValue.isEmpty == false,
                let language = Lang.language(for: storedValue)
            else {
                return .english
            }
            return language
        }
        set {
            guard newValue != current else { return }
            lang.value = newValue
            UserDefaults.standard.set(newValue.bundleIdentifier, forKey: AppLanguage.PreferredLanguageKey)
            NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)
        }
    }

    var supportedLanguages: [Lang] {
        Lang.allCases
    }

    lazy var lang = {
        Observable<Lang>(current)
    }()

    func bundle(for language: Lang) -> Bundle? {
        guard let path = LocalizationPath.path(for: language.bundleIdentifier) else {
            return nil
        }
        return Bundle(path: path)
    }
}

extension Bundle {
    static func swizzleAppLocalization() {
        _ = appLocalizationSwizzle
    }

    private static let appLocalizationSwizzle: Void = {
        let originalSelector = #selector(Bundle.localizedString(forKey:value:table:))
        let swizzledSelector = #selector(Bundle.bchat_localizedString(forKey:value:table:))

        guard
            let originalMethod = class_getInstanceMethod(Bundle.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(Bundle.self, swizzledSelector)
        else {
            return
        }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func bchat_localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard self === Bundle.main else {
            return bchat_localizedString(forKey: key, value: value, table: tableName)
        }

        let languageManager = AppLanguage.manager
        let selectedLanguage = languageManager.current

        if let selectedBundle = languageManager.bundle(for: selectedLanguage) {
            let selectedValue = selectedBundle.bchat_localizedString(forKey: key, value: value, table: tableName)
            if selectedValue != key {
                return selectedValue
            }
        }

        if selectedLanguage != .english,
           let englishBundle = languageManager.bundle(for: .english) {
            let englishValue = englishBundle.bchat_localizedString(forKey: key, value: value, table: tableName)
            if englishValue != key {
                return englishValue
            }
        }

        return value ?? key
    }
}
