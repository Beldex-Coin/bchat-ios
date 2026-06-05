//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit
import BChatUIKit

// Coincides with Android's max text message length
let kMaxMessageBodyCharacterCount = 2000

protocol AttachmentTextToolbarDelegate: class {
    func attachmentTextToolbarDidTapSend(_ attachmentTextToolbar: AttachmentTextToolbar)
    func attachmentTextToolbarDidBeginEditing(_ attachmentTextToolbar: AttachmentTextToolbar)
    func attachmentTextToolbarDidEndEditing(_ attachmentTextToolbar: AttachmentTextToolbar)
    func attachmentTextToolbarDidChange(_ attachmentTextToolbar: AttachmentTextToolbar)
}

// MARK: -

class AttachmentTextToolbar: UIView, UITextViewDelegate {

    weak var attachmentTextToolbarDelegate: AttachmentTextToolbarDelegate?
    private var isApplyingFormatting = false
    private var bulletMarkerByLineStart: [Int: String] = [:]

    var messageText: String? {
        get { return textView.text }

        set {
            textView.text = newValue
            applyTextFormatting(in: textView, preserveSelection: false)
            updatePlaceholderTextViewVisibility()
        }
    }

    // Layout Constants
    
    static let kToolbarMargin: CGFloat = 8
    static let kMinTextViewHeight: CGFloat = 40
    var maxTextViewHeight: CGFloat {
        // About ~4 lines in portrait and ~3 lines in landscape.
        // Otherwise we risk obscuring too much of the content.
        return UIDevice.current.orientation.isPortrait ? 160 : 100
    }
    var textViewHeightConstraint: NSLayoutConstraint!
    var textViewHeight: CGFloat

    // MARK: - Initializers

    init() {
        self.sendButton = UIButton(type: .system)
        self.textViewHeight = AttachmentTextToolbar.kMinTextViewHeight

        super.init(frame: CGRect.zero)
        
        let isAppThemeLight = CurrentAppContext().appUserDefaults().bool(forKey: appThemeIsLight)
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = isAppThemeLight ? .light : .dark
        } else {
            // Fallback on earlier versions
        }

        // Specifying autorsizing mask and an intrinsic content size allows proper
        // sizing when used as an input accessory view.
        self.autoresizingMask = .flexibleHeight
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.clear

        textView.delegate = self

        let sendTitle = NSLocalizedString("SEND", comment: "Label for 'send' button in the 'attachment approval' dialog.")
        sendButton.setTitle(sendTitle, for: .normal)
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)

        sendButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: Values.mediumFontSize)
        sendButton.titleLabel?.textAlignment = .center
        sendButton.tintColor = Colors.bothGreenColor

        // Increase hit area of send button
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)

        let contentView = UIView()
        contentView.addSubview(sendButton)
        contentView.addSubview(textContainer)
        contentView.addSubview(lengthLimitLabel)
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()

        // Layout

        // We have to wrap the toolbar items in a content view because iOS (at least on iOS10.3) assigns the inputAccessoryView.layoutMargins
        // when resigning first responder (verified by auditing with `layoutMarginsDidChange`).
        // The effect of this is that if we were to assign these margins to self.layoutMargins, they'd be blown away if the
        // user dismisses the keyboard, giving the input accessory view a wonky layout.
        contentView.layoutMargins = UIEdgeInsets(
            top: AttachmentTextToolbar.kToolbarMargin,
            left: AttachmentTextToolbar.kToolbarMargin,
            bottom: AttachmentTextToolbar.kToolbarMargin,
            right: AttachmentTextToolbar.kToolbarMargin
        )

        self.textViewHeightConstraint = textView.autoSetDimension(.height, toSize: AttachmentTextToolbar.kMinTextViewHeight)

        // We pin all three edges explicitly rather than doing something like:
        //  textView.autoPinEdges(toSuperviewMarginsExcludingEdge: .right)
        // because that method uses `leading` / `trailing` rather than `left` vs. `right`.
        // So it doesn't work as expected with RTL layouts when we explicitly want something
        // to be on the right side for both RTL and LTR layouts, like with the send button.
        // I believe this is a bug in PureLayout. Filed here: https://github.com/PureLayout/PureLayout/issues/209
        textContainer.autoPinEdge(toSuperviewMargin: .top)
        textContainer.autoPinEdge(toSuperviewMargin: .bottom)
        textContainer.autoPinEdge(toSuperviewMargin: .left)

        sendButton.autoPinEdge(.left, to: .right, of: textContainer, withOffset: AttachmentTextToolbar.kToolbarMargin)
        sendButton.autoPinEdge(.bottom, to: .bottom, of: textContainer, withOffset: -3)

        sendButton.autoPinEdge(toSuperviewMargin: .right)
        sendButton.setContentHuggingHigh()
        sendButton.setCompressionResistanceHigh()

        lengthLimitLabel.autoPinEdge(toSuperviewMargin: .left)
        lengthLimitLabel.autoPinEdge(toSuperviewMargin: .right)
        lengthLimitLabel.autoPinEdge(.bottom, to: .top, of: textContainer, withOffset: -6)
        lengthLimitLabel.setContentHuggingHigh()
        lengthLimitLabel.setCompressionResistanceHigh()
        
        textContainer.layer.borderColor = Colors.border.cgColor
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    // MARK: - UIView Overrides

    override var intrinsicContentSize: CGSize {
        get {
            // Since we have `self.autoresizingMask = UIViewAutoresizingFlexibleHeight`, we must specify
            // an intrinsicContentSize. Specifying CGSize.zero causes the height to be determined by autolayout.
            return CGSize.zero
        }
    }

    // MARK: - Subviews

    private let sendButton: UIButton

    private lazy var lengthLimitLabel: UILabel = {
        let lengthLimitLabel = UILabel()

        // Length Limit Label shown when the user inputs too long of a message
        lengthLimitLabel.textColor = Colors.text
        lengthLimitLabel.text = NSLocalizedString("ATTACHMENT_APPROVAL_MESSAGE_LENGTH_LIMIT_REACHED", comment: "One-line label indicating the user can add no more text to the media message field.")
        lengthLimitLabel.textAlignment = .center

        // Add shadow in case overlayed on white content
        lengthLimitLabel.layer.shadowColor = Colors.text.cgColor
        lengthLimitLabel.layer.shadowOffset = .zero
        lengthLimitLabel.layer.shadowOpacity = 0.8
        lengthLimitLabel.layer.shadowRadius = 2.0
        lengthLimitLabel.isHidden = true

        return lengthLimitLabel
    }()

    lazy var textView: UITextView = {
        let textView = buildTextView()

        textView.returnKeyType = .done
        textView.scrollIndicatorInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 3)

        return textView
    }()

    private lazy var placeholderTextView: UITextView = {
        let placeholderTextView = buildTextView()

        placeholderTextView.textColor = Colors.text
        placeholderTextView.text = NSLocalizedString("Message", comment: "")
        placeholderTextView.isEditable = false

        return placeholderTextView
    }()

    private lazy var textContainer: UIView = {
        let textContainer = UIView()

        textContainer.layer.borderColor = Colors.text.cgColor
        textContainer.layer.borderWidth = Values.separatorThickness
        textContainer.layer.cornerRadius = (AttachmentTextToolbar.kMinTextViewHeight / 2)
        textContainer.clipsToBounds = true

        textContainer.addSubview(placeholderTextView)
        placeholderTextView.autoPinEdgesToSuperviewEdges()

        textContainer.addSubview(textView)
        textView.autoPinEdgesToSuperviewEdges()

        return textContainer
    }()

    private func buildTextView() -> UITextView {
        let textView = AttachmentTextView()

        textView.keyboardAppearance = isLightMode ? .default : .dark
        textView.backgroundColor = .clear
        textView.tintColor = Colors.text

        textView.font = Fonts.regularOpenSans(ofSize: Values.mediumFontSize)
        textView.textColor = Colors.text
        textView.showsVerticalScrollIndicator = false
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        return textView
    }

    // MARK: - Actions

    @objc func didTapSend() {
        attachmentTextToolbarDelegate?.attachmentTextToolbarDidTapSend(self)
    }

    // MARK: - UITextViewDelegate

    public func textViewDidChange(_ textView: UITextView) {
        guard !isApplyingFormatting else { return }
        applyTextFormatting(in: textView)
        updateHeight(textView: textView)
        attachmentTextToolbarDelegate?.attachmentTextToolbarDidChange(self)
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if !FeatureFlags.sendingMediaWithOversizeText {
            let existingText: String = textView.text ?? ""
            let proposedText: String = (existingText as NSString).replacingCharacters(in: range, with: text)

            // Don't complicate things by mixing media attachments with oversize text attachments
            guard proposedText.utf8.count < kOversizeTextMessageSizeThreshold else {
                Logger.debug("long text was truncated")
                self.lengthLimitLabel.isHidden = false

                // `range` represents the section of the existing text we will replace. We can re-use that space.
                // Range is in units of NSStrings's standard UTF-16 characters. Since some of those chars could be
                // represented as single bytes in utf-8, while others may be 8 or more, the only way to be sure is
                // to just measure the utf8 encoded bytes of the replaced substring.
                let bytesAfterDelete: Int = (existingText as NSString).replacingCharacters(in: range, with: "").utf8.count

                // Accept as much of the input as we can
                let byteBudget: Int = Int(kOversizeTextMessageSizeThreshold) - bytesAfterDelete
                if byteBudget >= 0, let acceptableNewText = text.truncated(toByteCount: UInt(byteBudget)) {
                    textView.text = (existingText as NSString).replacingCharacters(in: range, with: acceptableNewText)
                }

                return false
            }
            self.lengthLimitLabel.isHidden = true

            // After verifying the byte-length is sufficiently small, verify the character count is within bounds.
            guard proposedText.count < kMaxMessageBodyCharacterCount else {
                Logger.debug("hit attachment message body character count limit")

                self.lengthLimitLabel.isHidden = false

                // `range` represents the section of the existing text we will replace. We can re-use that space.
                let charsAfterDelete: Int = (existingText as NSString).replacingCharacters(in: range, with: "").count

                // Accept as much of the input as we can
                let charBudget: Int = Int(kMaxMessageBodyCharacterCount) - charsAfterDelete
                if charBudget >= 0 {
                    let acceptableNewText = String(text.prefix(charBudget))
                    textView.text = (existingText as NSString).replacingCharacters(in: range, with: acceptableNewText)
                }

                return false
            }
        }
        
        if text == " " {
            if handleBulletStart(textView, range: range) {
                return false
            }
        }
        
        if text.isEmpty {
            if handleBulletSpaceRemoval(textView, range: range) {
                return false
            }
        }

        // Though we can wrap the text, we don't want to encourage multline captions, plus a "done" button
        // allows the user to get the keyboard out of the way while in the attachment approval view.
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        } else {
            return true
        }
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        attachmentTextToolbarDelegate?.attachmentTextToolbarDidBeginEditing(self)
        updatePlaceholderTextViewVisibility()
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        attachmentTextToolbarDelegate?.attachmentTextToolbarDidEndEditing(self)
        updatePlaceholderTextViewVisibility()
    }

    // MARK: - Helpers

    func updatePlaceholderTextViewVisibility() {
        let isHidden: Bool = {
            guard !self.textView.isFirstResponder else {
                return true
            }

            guard let text = self.textView.text else {
                return false
            }

            guard text.count > 0 else {
                return false
            }

            return true
        }()

        placeholderTextView.isHidden = isHidden
    }

    private func updateHeight(textView: UITextView) {
        // compute new height assuming width is unchanged
        let currentSize = textView.frame.size
        let newHeight = clampedTextViewHeight(fixedWidth: currentSize.width)

        if newHeight != textViewHeight {
            Logger.debug("TextView height changed: \(textViewHeight) -> \(newHeight)")
            textViewHeight = newHeight
            textViewHeightConstraint?.constant = textViewHeight
            invalidateIntrinsicContentSize()
        }
    }

    private func clampedTextViewHeight(fixedWidth: CGFloat) -> CGFloat {
        let contentSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return CGFloatClamp(contentSize.height, AttachmentTextToolbar.kMinTextViewHeight, maxTextViewHeight)
    }
    
    private func handleBulletStart(_ textView: UITextView, range: NSRange) -> Bool {
        let nsText = textView.text as NSString? ?? ""
        let lineRange = nsText.lineRange(for: range)
        let cursorPosition = range.location - lineRange.location
        
        let prefix = nsText.substring(with: NSRange(location: lineRange.location, length: cursorPosition))
        guard (prefix == "*" || prefix == "-"), cursorPosition == 1 else { return false }
        
        bulletMarkerByLineStart[lineRange.location] = prefix
        replaceCurrentLinePrefix(textView, lineRange: lineRange, prefixLength: 1)
        applyTextFormatting(in: textView)
        updateHeight(textView: textView)
        attachmentTextToolbarDelegate?.attachmentTextToolbarDidChange(self)
        return true
    }
    
    private func handleBulletSpaceRemoval(_ textView: UITextView, range: NSRange) -> Bool {
        guard range.length == 1 else { return false }
        
        let nsText = textView.text as NSString? ?? ""
        let lineRange = nsText.lineRange(for: range)
        guard lineRange.location + 1 < nsText.length else { return false }
        
        let bulletPrefixRange = NSRange(location: lineRange.location, length: 2)
        let bulletPrefix = nsText.substring(with: bulletPrefixRange)
        guard bulletPrefix == "• " else { return false }
        guard range.location == lineRange.location + 1 else { return false }
        
        let marker = bulletMarkerByLineStart[lineRange.location] ?? "-"
        if let replaceRange = Range(bulletPrefixRange, in: textView.text) {
            textView.text.replaceSubrange(replaceRange, with: marker)
            textView.selectedRange = NSRange(location: lineRange.location + marker.count, length: 0)
            bulletMarkerByLineStart.removeValue(forKey: lineRange.location)
            applyTextFormatting(in: textView)
            updateHeight(textView: textView)
            attachmentTextToolbarDelegate?.attachmentTextToolbarDidChange(self)
            return true
        }
        
        return false
    }
    
    private func replaceCurrentLinePrefix(_ textView: UITextView, lineRange: NSRange, prefixLength: Int) {
        let nsText = textView.text as NSString? ?? ""
        let lineText = nsText.substring(with: lineRange)
        let clean = (lineText as NSString).substring(from: prefixLength).trimmingCharacters(in: .whitespaces)
        let newLine = "• \(clean)"
        
        if let textRange = Range(lineRange, in: textView.text) {
            textView.text.replaceSubrange(textRange, with: newLine)
            textView.selectedRange = NSRange(location: lineRange.location + 2, length: 0)
        }
    }
    
    private func applyTextFormatting(in textView: UITextView, preserveSelection: Bool = true) {
        isApplyingFormatting = true
        defer { isApplyingFormatting = false }
        
        let selectedRange = textView.selectedRange
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.regularOpenSans(ofSize: Values.mediumFontSize),
            .foregroundColor: Colors.text
        ]
        let attributedString = NSMutableAttributedString(string: textView.text ?? "", attributes: attributes)
        attributedString.applyAttachmentToolbarFormatting()
        textView.attributedText = attributedString
        
        if preserveSelection {
            let safeLocation = min(selectedRange.location, attributedString.length)
            let safeLength = min(selectedRange.length, max(0, attributedString.length - safeLocation))
            textView.selectedRange = NSRange(location: safeLocation, length: safeLength)
        }
        
        textView.layoutManager.ensureLayout(for: textView.textContainer)
        textView.setNeedsDisplay()
    }
}

private extension NSMutableAttributedString {
    func applyAttachmentToolbarFormatting() {
        applyPatternPreservingColor("_(\\S(?:[^\\n]*?\\S)?)_") { range in
            self.addFontTraitPreservingExistingTraits(.traitItalic, in: range)
        }
        
        applyPatternPreservingColor("\\*(\\S(?:[^\\n]*?\\S)?)\\*") { range in
            self.addFontTraitPreservingExistingTraits(.traitBold, in: range)
        }
        
        applyPatternPreservingColor("~(\\S(?:[^\\n]*?\\S)?)~") { range in
            self.addAttribute(.strikethroughStyle, value: 1, range: range)
        }
        
        applyPatternPreservingColor("(?<!\\w)```([^\\s][\\s\\S]*[^\\s])```(?!\\w)") { range in
            let monoFont = UIFont.monospacedSystemFont(ofSize: self.font(at: range.location).pointSize, weight: .regular)
            self.addAttribute(.font, value: monoFont, range: range)
        }
        
        applyQuotes()
        
        applyPatternPreservingColor("(?<![`\\w])`([^\\s`\\n](?:[^`\\n]*[^\\s`\\n])?)`(?![`\\w])") { range in
            let monoFont = UIFont.monospacedSystemFont(ofSize: self.font(at: range.location).pointSize, weight: .regular)
            self.addAttribute(.font, value: monoFont, range: range)
            self.addAttribute(.backgroundColor, value: UIColor.systemGray, range: range)
        }
    }
    
    private func applyPatternPreservingColor(_ pattern: String, apply: (NSRange) -> Void) {
        let regex = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        let matches = regex.matches(in: self.string, range: NSRange(location: 0, length: self.length))
        
        for match in matches.reversed() {
            let inner = match.range(at: 1)
            guard inner.location != NSNotFound else { continue }
            guard NSMaxRange(inner) <= self.length else { continue }
            apply(inner)
        }
    }
    
    private func applyQuotes() {
        let fullRange = NSRange(location: 0, length: self.length)
        self.removeAttribute(.attachmentBlockQuote, range: fullRange)
        
        let ns = self.string as NSString
        let lines = ns.components(separatedBy: "\n")
        var offset = 0
        
        for (index, line) in lines.enumerated() {
            let lineLength = (line as NSString).length
            defer {
                offset += lineLength
                if index < lines.count - 1 { offset += 1 }
            }
            
            guard line.hasPrefix("> "), lineLength >= 3 else { continue }
            
            let lineRange = NSRange(location: offset, length: lineLength)
            let markerRange = NSRange(location: offset, length: 2)
            let contentRange = NSRange(location: offset + 2, length: max(0, lineLength - 2))
            
            self.addAttribute(.foregroundColor, value: UIColor.clear, range: markerRange)
            self.addAttribute(.attachmentBlockQuote, value: true, range: lineRange)
            if contentRange.length > 0 {
                self.addAttribute(.foregroundColor, value: UIColor.systemGray3, range: contentRange)
            }
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.firstLineHeadIndent = 0
            paragraph.headIndent = 12
            self.addAttribute(.paragraphStyle, value: paragraph, range: lineRange)
        }
    }
    
    private func font(at location: Int) -> UIFont {
        guard self.length > 0 else {
            return Fonts.regularOpenSans(ofSize: Values.mediumFontSize)
        }
        
        let safeIndex = min(max(location, 0), self.length - 1)
        let attrs = self.attributes(at: safeIndex, effectiveRange: nil)
        return attrs[.font] as? UIFont ?? Fonts.regularOpenSans(ofSize: Values.mediumFontSize)
    }
    
    private func addFontTraitPreservingExistingTraits(_ trait: UIFontDescriptor.SymbolicTraits, in range: NSRange) {
        self.enumerateAttributes(in: range, options: []) { attrs, subrange, _ in
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
