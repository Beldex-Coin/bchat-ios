//
//  String + Ext.swift


import UIKit

extension NSAttributedString.Key {
    static let snBlockQuote = NSAttributedString.Key("snBlockQuote")
}

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
    func truncateMiddle(with prefixLength: Int = 19, suffixLength: Int = 7) -> String {
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

extension NSMutableAttributedString {
    
    func addAttributesPreservingColor(clearText: Bool) {
        
        // MARK: - Monospace
        applyPatternPreservingColor("(?<!\\w)```([^\\s][\\s\\S]*[^\\s])```(?!\\w)", clearText: clearText) { range in
            let mono = UIFont.monospacedSystemFont(
                ofSize: font(at: range.location).pointSize,
                weight: .regular
            )
            self.addAttribute(.font, value: mono, range: range)
        }
        
        // MARK: - Inline code
        applyPatternPreservingColor("(?<![`\\w])`([^\\s`\\n](?:[^`\\n]*[^\\s`\\n])?)`(?![`\\w])", clearText: clearText) { range in
            let mono = UIFont.monospacedSystemFont(
                ofSize: font(at: range.location).pointSize,
                weight: .regular
            )
            self.addAttribute(.font, value: mono, range: range)
            self.addAttribute(.backgroundColor, value: UIColor.systemGray, range: range)
        }
        
        // MARK: - Bold, Italic, Strikethrough
        applyPatternPreservingColor("\\*(\\S(?:[^\\n]*?\\S)?)\\*", clearText: clearText) { range in
            self.addFontTraitPreservingExistingTraits(.traitBold, in: range)
        }
        
        applyPatternPreservingColor("_(\\S(?:[^\\n]*?\\S)?)_", clearText: clearText) { range in
            self.addFontTraitPreservingExistingTraits(.traitItalic, in: range)
        }
        
        applyPatternPreservingColor("~(\\S(?:[^\\n]*?\\S)?)~", clearText: clearText) { range in
            self.addAttribute(.strikethroughStyle, value: 1, range: range)
        }
        
        // MARK: - Quotes
        applyQuotes(clearText: clearText)
    }
    
    private func applyGreedyOverride(
        marker: Character,
        clearText: Bool,
        apply: (NSRange) -> Void
    ) {
        let text = self.string
        let chars = Array(text)
        
        var positions: [Int] = []
        
        for (i, c) in chars.enumerated() {
            if c == marker {
                positions.append(i)
            }
        }
        
        guard positions.count >= 2 else { return }
        
        let start = positions.first!
        let end = positions.last!
        
        guard end > start else { return }
        
        let range = NSRange(location: start + 1,
                            length: end - start - 1)
        
        apply(range)
        
        if clearText {
            self.deleteCharacters(in: NSRange(location: end, length: 1))
            self.deleteCharacters(in: NSRange(location: start, length: 1))
        }
    }
    
    
    // MARK: - Pattern Processor (Preserves Color + Attributes)
    private func applyPatternPreservingColor(_ pattern: String, clearText: Bool,
                                             apply: (NSRange) -> Void) {
        let regex = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        
        let matches = regex.matches(in: self.string,
                                    range: NSRange(location: 0, length: self.length))
        
        for match in matches.reversed() {
            let full = match.range(at: 0)   // with markers
            var inner = match.range(at: 1)  // inside markers
            
            // Apply attributes BEFORE removing markers
            apply(inner)
            
            if clearText {
                // Remove right marker(s)
                let trailingCount = pattern.contains("```") ? 3 : 1
                self.deleteCharacters(in: NSRange(location: inner.location + inner.length, length: trailingCount))
                
                // Remove left marker(s)
                let leadingCount = pattern.contains("```") ? 3 : 1
                self.deleteCharacters(in: NSRange(location: inner.location - leadingCount, length: leadingCount))
            }
        }
    }
    
    // MARK: - Quotes (> text)
    private func applyQuotes(clearText: Bool) {
        _ = clearText
        
        let fullRange = NSRange(location: 0, length: self.length)
        self.removeAttribute(.snBlockQuote, range: fullRange)
        
        let ns = self.string as NSString
        let lines = ns.components(separatedBy: "\n")
        var offset = 0
        
        for (index, line) in lines.enumerated() {
            let lineLength = (line as NSString).length
            defer {
                offset += lineLength
                if index < lines.count - 1 { offset += 1 }
            }
            
            guard line.hasPrefix("> "), lineLength >= 2 else { continue }
            
            let lineRange = NSRange(location: offset, length: lineLength)
            let markerRange = NSRange(location: offset, length: 2)
            let contentRange = NSRange(location: offset + 2, length: max(0, lineLength - 2))
            
            self.addAttribute(.foregroundColor, value: UIColor.clear, range: markerRange)
            self.addAttribute(.snBlockQuote, value: true, range: lineRange)
            
            // Quote text color.
            if contentRange.length > 0 {
                self.addAttribute(.foregroundColor, value: UIColor.lightGray, range: contentRange)
            }
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.firstLineHeadIndent = 0
            paragraph.headIndent = 12
            self.addAttribute(.paragraphStyle, value: paragraph, range: lineRange)
        }
    }
    
    // MARK: - Extract Current Font Safely
    private func font(at location: Int) -> UIFont {
        let attrs = attributes(at: location, effectiveRange: nil)
        return attrs[.font] as? UIFont ?? UIFont.systemFont(ofSize: 17)
    }
    
    private func addFontTraitPreservingExistingTraits(_ trait: UIFontDescriptor.SymbolicTraits, in range: NSRange) {
        enumerateAttributes(in: range, options: []) { attrs, subrange, _ in
            let currentFont = attrs[.font] as? UIFont ?? self.font(at: subrange.location)
            
            var wantsBold = self.isBoldFont(currentFont)
            var wantsItalic = self.isItalicFont(currentFont, attributes: attrs)
            
            if trait == .traitBold {
                wantsBold = true
            } else if trait == .traitItalic {
                wantsItalic = true
            }
            
            let resolved = self.resolvedFont(from: currentFont, wantsBold: wantsBold, wantsItalic: wantsItalic)
            self.addAttribute(.font, value: resolved.font, range: subrange)
            
            if let obliqueness = resolved.syntheticObliqueness {
                self.addAttribute(.obliqueness, value: obliqueness, range: subrange)
            } else {
                self.removeAttribute(.obliqueness, range: subrange)
            }
        }
    }
    
    private func isBoldFont(_ font: UIFont) -> Bool {
        let name = font.fontName.lowercased()
        return font.fontDescriptor.symbolicTraits.contains(.traitBold)
            || name.contains("bold")
            || name.contains("semibold")
            || name.contains("heavy")
            || name.contains("black")
    }
    
    private func isItalicFont(_ font: UIFont, attributes: [NSAttributedString.Key: Any]) -> Bool {
        let name = font.fontName.lowercased()
        let hasObliqueness = (attributes[.obliqueness] as? NSNumber)?.doubleValue ?? 0 > 0
        return font.fontDescriptor.symbolicTraits.contains(.traitItalic)
            || name.contains("italic")
            || name.contains("oblique")
            || hasObliqueness
    }
    
    private func resolvedFont(from currentFont: UIFont, wantsBold: Bool, wantsItalic: Bool) -> (font: UIFont, syntheticObliqueness: CGFloat?) {
        let size = currentFont.pointSize
        let isOpenSans = currentFont.fontName.lowercased().contains("opensans")
        
        if isOpenSans {
            if wantsBold && wantsItalic {
                if let boldItalic = UIFont(name: "OpenSans-BoldItalic", size: size) {
                    return (boldItalic, nil)
                }
                if let descriptor = UIFont.systemFont(ofSize: size, weight: .bold).fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
                    return (UIFont(descriptor: descriptor, size: size), nil)
                }
                return (UIFont.boldSystemFont(ofSize: size), 0.2)
            }
            if wantsBold {
                return (Fonts.boldOpenSans(ofSize: size), nil)
            }
            if wantsItalic {
                return (UIFont(name: "OpenSans-Italic", size: size) ?? currentFont, nil)
            }
            return (currentFont, nil)
        }
        
        var traits: UIFontDescriptor.SymbolicTraits = []
        if wantsBold { traits.insert(.traitBold) }
        if wantsItalic { traits.insert(.traitItalic) }
        
        if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
            return (UIFont(descriptor: descriptor, size: size), nil)
        }
        
        if wantsBold && wantsItalic {
            if let descriptor = UIFont.systemFont(ofSize: size, weight: .bold).fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
                return (UIFont(descriptor: descriptor, size: size), nil)
            }
            return (UIFont.boldSystemFont(ofSize: size), 0.2)
        }
        if wantsBold {
            return (UIFont.boldSystemFont(ofSize: size), nil)
        }
        if wantsItalic {
            if let descriptor = UIFont.systemFont(ofSize: size).fontDescriptor.withSymbolicTraits(.traitItalic) {
                return (UIFont(descriptor: descriptor, size: size), nil)
            }
            return (UIFont.italicSystemFont(ofSize: size), nil)
        }
        
        return (currentFont, nil)
    }
}
