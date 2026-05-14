
public final class InputTextView : UITextView, UITextViewDelegate {
    
    private static let defaultFont = Fonts.regularOpenSans(ofSize: Values.mediumFontSize)
    private static let defaultTextColor = Colors.text
    private static let maxMessageCharacterCount: Int = 2000
    
    private weak var snDelegate: InputTextViewDelegate?
    private let maxWidth: CGFloat
    private var bulletMarkerByLineStart: [Int: String] = [:]
    public var lastBulletSymbol: String = "-"
    
    public override var text: String! { didSet { handleTextChanged() } }
    
    // MARK: UI Components
    private lazy var placeholderLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("Write a message...", comment: "")
        result.font = Fonts.regularOpenSans(ofSize: Values.mediumFontSize)
        result.textColor = Colors.text.withAlphaComponent(Values.mediumOpacity)
        return result
    }()
    
    // MARK: Settings
    private let minHeight: CGFloat = 22
    private let maxHeight: CGFloat = 100

    // MARK: Lifecycle
    init(delegate: InputTextViewDelegate, maxWidth: CGFloat) {
        snDelegate = delegate
        self.maxWidth = maxWidth
        
        super.init(frame: CGRect.zero, textContainer: nil)
        setUpViewHierarchy()
        self.delegate = self
        self.isAccessibilityElement = true
        self.accessibilityLabel = NSLocalizedString("vc_conversation_input_prompt", comment: "")
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        preconditionFailure("Use init(delegate:) instead.")
    }

    public required init?(coder: NSCoder) {
        preconditionFailure("Use init(delegate:) instead.")
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            if let _ = UIPasteboard.general.image {
                return true
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    public override func paste(_ sender: Any?) {
        if let image = UIPasteboard.general.image {
            snDelegate?.didPasteImageFromPasteboard(self, image: image)
        }
        super.paste(sender)
    }
    
    public override var intrinsicContentSize: CGSize {
        let clampedHeight = min(max(textSize.height, minHeight), maxHeight)
        return CGSize(width: bounds.width, height: clampedHeight)
    }
    
    public override var contentSize: CGSize {
        didSet {
            // Notify layout system only when size changes
            if oldValue != contentSize {
                invalidateIntrinsicContentSize()
                setNeedsDisplay()
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        isScrollEnabled = intrinsicContentSize.height >= maxHeight
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawBlockQuoteBars()
    }
    
    public override var contentOffset: CGPoint {
        didSet {
            if oldValue != contentOffset {
                setNeedsDisplay()
            }
        }
    }
    
    var numberOfVisibleLines: Int {
        let lineHeight = InputTextView.defaultFont.lineHeight
        return Int(textSize.height / lineHeight)
    }
    
    var textSize: CGSize {
        return sizeThatFits(CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude))
    }

    private func setUpViewHierarchy() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        backgroundColor = .clear
        textColor = InputTextView.defaultTextColor
        font = InputTextView.defaultFont
        tintColor = Colors.bothGreenColor
        isScrollEnabled = false
        
        keyboardAppearance = isLightMode ? .light : .dark
        let inset: CGFloat = 2
        textContainerInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: inset)
        addSubview(placeholderLabel)
        placeholderLabel.pin(.leading, to: .leading, of: self, withInset: inset + 3) // Slight visual adjustment
        placeholderLabel.pin(.top, to: .top, of: self)
        pin(.trailing, to: .trailing, of: placeholderLabel, withInset: inset)
        pin(.bottom, to: .bottom, of: placeholderLabel)
    }
    
    // MARK: - Updating
    
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        // Restore caret and scroll range to visible (no flicker)
        let selectedRange = textView.selectedRange
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.regularOpenSans(ofSize: Values.mediumFontSize),
            .foregroundColor: Colors.text
        ]
        let attributedString = NSMutableAttributedString(string: textView.text, attributes: attributes)
        
        // Apply your markdown-style formatting
        attributedString.addAttributesPreservingColor(clearText: false)
        
        // Assign back to textView
        textView.attributedText = attributedString
        let safeLocation = min(max(selectedRange.location, 0), attributedString.length)
        let safeLength = min(max(selectedRange.length, 0), max(0, attributedString.length - safeLocation))
        let safeRange = NSRange(location: safeLocation, length: safeLength)
        UIView.performWithoutAnimation {
            textView.scrollRangeToVisible(safeRange)
            textView.selectedRange = safeRange
        }
        
        // Force quote stripe redraw for the just-typed state (e.g. exactly "> ").
        textView.layoutManager.ensureLayout(for: textView.textContainer)
        textView.setNeedsDisplay()
        handleTextChanged()
    }
    
   public func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                        replacementText text: String) -> Bool {
       if revertBulletIfTypingBefore(textView, range: range, replacementText: text) {
           return false
       }
       
       // Handle ENTER (already done before)
       if text == "\n" {
           let nsText = textView.text as NSString
           let cursorLocation = range.location           
           let lineRange = nsText.lineRange(for: NSRange(location: cursorLocation, length: 0))
           let lineText = nsText.substring(with: lineRange)
           let trimmed = lineText.trimmingCharacters(in: .whitespacesAndNewlines)
           
           let bulletPrefixes = ["•", "-", "*"]
           
           // Check empty bullet line
           let isOnlyBullet = bulletPrefixes.contains { prefix in
               trimmed == prefix
           }
           
           if isOnlyBullet {
               // Remove bullet and STAY in same line
               textView.text = nsText.replacingCharacters(in: lineRange, with: "")
               // Keep cursor at same position
               textView.selectedRange = NSRange(location: lineRange.location, length: 0)
               return false
           } else {
               handleListContinuation(textView, range: range)
           }
           
           // Continue bullet if valid text exists
           for prefix in bulletPrefixes {
               if lineText.hasPrefix(prefix + " ") && !lineText.hasPrefix(prefix + "  ") {
                   let insertion = "\n\(prefix) "
                   textView.text = nsText.replacingCharacters(in: range, with: insertion)
                   textView.selectedRange = NSRange(location: range.location + insertion.count, length: 0)
                   return false
               }
           }
           
           return false
       }
       
       if text == " " {
           lastBulletSymbol = textView.text
           if handleBulletStart(textView, range: range) {
               return false
           }
           if revertSecondBulletSpace(textView, range: range) {
               return false
           }
       }
       
       if text.isEmpty {
           if handleBulletSpaceRemoval(textView, range: range) {
               return false
           }
       }
       
       return true
   }
    
    private func revertBulletIfTypingBefore(_ textView: UITextView, range: NSRange, replacementText text: String) -> Bool {
        guard !text.isEmpty else { return false }

        let nsText = textView.text as NSString
        let lineRange = nsText.lineRange(for: range)

        guard lineRange.location + 2 <= nsText.length else { return false }

        let prefixRange = NSRange(location: lineRange.location, length: 2)
        let prefix = nsText.substring(with: prefixRange)

        // Only act if line starts with bullet
        guard prefix == "• " else { return false }

        // If user is typing BEFORE bullet
        if range.location <= lineRange.location {
            let marker = bulletMarkerByLineStart[lineRange.location] ?? "-"
            let newPrefix = "\(text)\(marker) "

            if let replaceRange = Range(prefixRange, in: textView.text) {
                textView.text.replaceSubrange(replaceRange, with: newPrefix)

                // Adjust cursor position
                let newCursor = range.location + (newPrefix.count - 2)
                textView.selectedRange = NSRange(location: max(0, newCursor), length: 0)

                bulletMarkerByLineStart.removeValue(forKey: lineRange.location)
                textViewDidChange(textView)
                return true
            }
        }

        return false
    }
    
    private func handleBulletStart(_ textView: UITextView, range: NSRange) -> Bool {
        let nsText = textView.text as NSString
        let lineRange = nsText.lineRange(for: range)
        
        let cursorPosition = range.location - lineRange.location
        guard cursorPosition >= 0 else { return false }
        guard lineRange.location + cursorPosition <= nsText.length else { return false }
        
        // Get text before cursor
        let prefix = nsText.substring(with: NSRange(location: lineRange.location, length: cursorPosition))
        
        if (prefix == "*" || prefix == "-") && cursorPosition == 1 {
            // Ensure nothing exists before marker (no spaces)
            if lineRange.location < nsText.length {
                let fullLinePrefix = nsText.substring(with: NSRange(location: lineRange.location, length: cursorPosition))
                if fullLinePrefix.hasPrefix(" ") {
                    return false
                }
            }

            bulletMarkerByLineStart[lineRange.location] = prefix
            replaceCurrentLinePrefix(textView, lineRange: lineRange, prefixLength: 1)
            return true
        }
        
        return false
    }
    
    private func handleBulletSpaceRemoval(_ textView: UITextView, range: NSRange) -> Bool {
        guard range.length == 1 else { return false }
        
        let nsText = textView.text as NSString
        let lineRange = nsText.lineRange(for: range)
        guard lineRange.location + 1 < nsText.length else { return false }
        
        let bulletPrefixRange = NSRange(location: lineRange.location, length: 2)
        let bulletPrefix = nsText.substring(with: bulletPrefixRange)
        guard bulletPrefix == "• " else { return false }
        
        // Backspace target is the space in "• "
        guard range.location == lineRange.location + 1 else { return false }
        
        let marker = bulletMarkerByLineStart[lineRange.location] ?? "-"
        if let replaceRange = Range(bulletPrefixRange, in: textView.text) {
            textView.text.replaceSubrange(replaceRange, with: marker)
            textView.selectedRange = NSRange(location: lineRange.location + marker.count, length: 0)
            bulletMarkerByLineStart.removeValue(forKey: lineRange.location)
            textViewDidChange(textView)
            return true
        }
        
        return false
    }
    
    private func revertSecondBulletSpace(_ textView: UITextView, range: NSRange) -> Bool {
        guard range.length == 0 else { return false }
        
        let nsText = textView.text as NSString
        let lineRange = nsText.lineRange(for: range)
        guard lineRange.location + 2 <= nsText.length else { return false }
        
        let bulletPrefixRange = NSRange(location: lineRange.location, length: 2)
        let bulletPrefix = nsText.substring(with: bulletPrefixRange)
        guard bulletPrefix == "• " else { return false }
        
        guard range.location == lineRange.location + 2 else { return false }
        
        let lineText = nsText.substring(with: lineRange).trimmingCharacters(in: .newlines)
        guard lineText == "• " else { return false }
        
        let marker = bulletMarkerByLineStart[lineRange.location] ?? "-"
        let replacement = "\(marker)  "
        
        if let replaceRange = Range(bulletPrefixRange, in: textView.text) {
            textView.text.replaceSubrange(replaceRange, with: replacement)
            textView.selectedRange = NSRange(location: lineRange.location + replacement.count, length: 0)
            bulletMarkerByLineStart.removeValue(forKey: lineRange.location)
            textViewDidChange(textView)
            return true
        }
        
        return false
    }
    
    private func replaceCurrentLinePrefix(_ textView: UITextView,
                                          lineRange: NSRange,
                                          prefixLength: Int) {
        
        let nsText = textView.text as NSString
        guard lineRange.location + lineRange.length <= nsText.length else { return }
        let lineText = nsText.substring(with: lineRange)
        let lineNSString = lineText as NSString
        guard lineNSString.length >= prefixLength else { return }
        
        // Remove "-"/"*"
        let clean = lineNSString.substring(from: prefixLength).trimmingCharacters(in: .whitespaces)
        
        let newLine = "• \(clean)"
        
        if let textRange = Range(lineRange, in: textView.text) {
            textView.text.replaceSubrange(textRange, with: newLine)
            
            // Move cursor after bullet
            let newCursor = lineRange.location + 2
            textView.selectedRange = NSRange(location: newCursor, length: 0)
            textViewDidChange(textView)
        }
    }
    
    private func handleListContinuation(_ textView: UITextView, range: NSRange) {
        let nsText = textView.text as NSString
        
        // Get current line
        let lineRange = nsText.lineRange(for: range)
        let lineText = nsText.substring(with: lineRange)
        let currentLine = lineText.trimmingCharacters(in: .whitespacesAndNewlines)
        // MARK: Numbered List (1. 2. 3.)
        if let regex = try? NSRegularExpression(pattern: #"^(\d+)\.\s.+"#),
           let match = regex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.utf16.count)),
           match.numberOfRanges > 1,
           let numberRange = Range(match.range(at: 1), in: lineText),
           let number = Int(String(lineText[numberRange])),
           number < 99 {
            let nextNumber = number + 1
            let newText = "\n\(nextNumber). "
            insertText(newText, textView: textView, range: range)
            return
        }
        
        // MARK: Bullet List (- * •)
        if currentLine.hasPrefix("• ") {
            let marker = bulletMarkerByLineStart[lineRange.location] ?? "-"
            
            let newText = "\n• "
            insertText(newText, textView: textView, range: range)
            bulletMarkerByLineStart[range.location + 1] = marker
            return
        }
        
        // Default newline
        insertText("\n", textView: textView, range: range)
    }
    
    private func insertText(_ newText: String, textView: UITextView, range: NSRange) {
        if let textRange = Range(range, in: textView.text) {
            textView.text.replaceSubrange(textRange, with: newText)
            textView.selectedRange = NSRange(location: range.location + newText.count, length: 0)
            textViewDidChange(textView)
        }
    }
    
    
    private func handleTextChanged() {
        defer { snDelegate?.inputTextViewDidChangeContent(self) }
        placeholderLabel.isHidden = !text.isEmpty
        self.layoutManager.ensureLayout(for: self.textContainer)
        self.setNeedsDisplay()
    }
    
    private func drawBlockQuoteBars() {
        guard let attributed = attributedText, attributed.length > 0 else { return }
        let nsText = attributed.string as NSString
        let fullRange = NSRange(location: 0, length: attributed.length)
        
        attributed.enumerateAttribute(.snBlockQuote, in: fullRange, options: []) { value, range, _ in
            guard let isQuote = value as? Bool, isQuote, range.length > 0 else { return }
            if range.location + 3 <= nsText.length {
                let prefix = nsText.substring(with: NSRange(location: range.location, length: 3))
                if prefix == ">  " { return }
            }
            
            let glyphRange = self.layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            self.layoutManager.ensureLayout(forGlyphRange: glyphRange)
            self.layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { lineRect, _, _, _, _ in
                let barX = self.textContainerInset.left + self.textContainer.lineFragmentPadding + 2
                let barY = lineRect.minY + self.textContainerInset.top + 1
                let barHeight = max(lineRect.height + 1, 5)
                let barRect = CGRect(x: barX, y: barY, width: 3, height: barHeight)
                let path = UIBezierPath(roundedRect: barRect, cornerRadius: 1.5)
                UIColor.systemGray.setFill()
                path.fill()
            }
        }
    }
}

// MARK: - InputTextViewDelegate

protocol InputTextViewDelegate : AnyObject {
    func inputTextViewDidChangeSize(_ inputTextView: InputTextView)
    func inputTextViewDidChangeContent(_ inputTextView: InputTextView)
    func didPasteImageFromPasteboard(_ inputTextView: InputTextView, image: UIImage)
}
