//
//  String + Ext.swift


import UIKit

// MARK: - String <-> Decimal

extension String {
    
    func decimal() -> Decimal? {
        if Double(self) == nil {
            return nil
        }
        return Decimal.init(string: self)
    }
    
    func decimalString() -> String {
        guard let _ = Double(self) else { return "--" }
        guard let dec = self.decimal() else {
            return "--"
        }
        return "\(dec)"
    }
    
    //// 四舍五入保留小数位
    func decimalScaleString(_ scale: Int16) -> String {
        guard let dec = self.decimal() else {
            return "--"
        }
        return dec.scaleString(scale)
    }
    
    func repeatString(_ count: Int) -> String {
        var repeatStr = ""
        stride(from: 0, to: count, by: 1).forEach { (i) in
            repeatStr += self
        }
        return repeatStr
    }
    
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        // Regular expression pattern for the specified format
        let pattern = "^[0-9]{0,9}(\\.[0-9]{0,5})?$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: self)
    }
}

// MARK:  - FilePath

private struct SearchPathForDirectories {
    static let documentPath: String = {
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = allPaths[0]
        return documentDirectory + "/"
    }()
}

public struct FilePathsInDomain {
    
    private let fileName: String
    
    var document: String {
        get {
            return SearchPathForDirectories.documentPath + fileName
        }
    }
    
    init(fileName: String) {
        self.fileName = fileName
    }
}

extension String {
    
    var filePaths: FilePathsInDomain {
        get {
            return FilePathsInDomain.init(fileName: self)
        }
    }
}

extension String {
  func indexInt(of char: Character) -> Int? {
    return firstIndex(of: char)?.utf16Offset(in: self)
  }
}

extension String {
    func firstCharacterUpperCase() -> String? {
        guard !isEmpty else { return nil }
        let lowerCasedString = self.lowercased()
        return lowerCasedString.replacingCharacters(in: lowerCasedString.startIndex...lowerCasedString.startIndex, with: String(lowerCasedString[lowerCasedString.startIndex]).uppercased())
    }
}

extension String {
    func withBoldText(text: String, font: UIFont? = nil) -> NSAttributedString {
        let _font = font ?? Fonts.regularOpenSans(ofSize: 14)
        let fullString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font: _font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.boldOpenSans(ofSize: 14)]
        let range = (self as NSString).range(of: text)
        fullString.addAttributes(boldFontAttribute, range: range)
        return fullString
    }
}

public extension String {
    func setColor(_ color: UIColor, ofSubstring substring: String) -> NSMutableAttributedString {
        let range = (self as NSString).range(of: substring)
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        return attributedString
    }
}

extension String {
   func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

extension String {
    func truncateMiddle() -> String {
        let prefixLength = 19
        let suffixLength = 7
        guard self.count > prefixLength + suffixLength else { return self }

        let start = self.prefix(prefixLength)
        let end = self.suffix(suffixLength)
        return "\(start)........\(end)"
    }
}

extension String {
    
    func toStringArrayFromJSON() -> [String]? {
        guard let data = self.data(using: .utf8) else {
            print("Error: Unable to convert string to Data")
            return nil
        }

        do {
            if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [String] {
                return array
            } else {
                print("Error: JSON is not a [String] array")
                return nil
            }
        } catch {
            print("JSON parsing error: \(error)")
            return nil
        }
    }
}

extension String {
    func sharedContactNameIfAvailable() -> String? {
        guard let jsonData = self.data(using: .utf8) else {
            return nil
        }
        do {
            let contact = try JSONDecoder().decode(ContactWrapper.self, from: jsonData)
            return contact.kind.type == "SharedContact" ? contact.kind.name : nil
        } catch {
            return nil
        }
    }
}

extension String {
    var isSharedContactType: Bool {
        return sharedContactNameIfAvailable() != nil
    }
}

