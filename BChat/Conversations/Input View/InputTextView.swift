
public final class InputTextView : UITextView, UITextViewDelegate {
    
    private static let defaultFont = Fonts.OpenSans(ofSize: Values.mediumFontSize)
    private static let defaultTextColor = Colors.text
    private static let maxMessageCharacterCount: Int = 2000
    
    private weak var snDelegate: InputTextViewDelegate?
    private let maxWidth: CGFloat
    private lazy var heightConstraint = self.set(.height, to: minHeight)
    
    public override var text: String! { didSet { handleTextChanged() } }
    
    // MARK: UI Components
    private lazy var placeholderLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("Write a message...", comment: "")
        result.font = Fonts.OpenSans(ofSize: Values.mediumFontSize)
        result.textColor = Colors.text.withAlphaComponent(Values.mediumOpacity)
        return result
    }()
    
    // MARK: Settings
    private let minHeight: CGFloat = 22
    private let maxHeight: CGFloat = 80

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

    private func setUpViewHierarchy() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        backgroundColor = .clear
        textColor = InputTextView.defaultTextColor
        font = InputTextView.defaultFont
        tintColor = Colors.bothGreenColor
        
        keyboardAppearance = isLightMode ? .light : .dark
        heightConstraint.isActive = true
        let inset: CGFloat = 2
        textContainerInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        addSubview(placeholderLabel)
        placeholderLabel.pin(.leading, to: .leading, of: self, withInset: inset + 5) // Slight visual adjustment
        placeholderLabel.pin(.top, to: .top, of: self)
        pin(.trailing, to: .trailing, of: placeholderLabel, withInset: inset)
        pin(.bottom, to: .bottom, of: placeholderLabel)
    }
    
    // MARK: - Updating
    
    public func textViewDidChange(_ textView: UITextView) {
        
        let cursorPosition = textView.selectedRange
        
        handleTextChanged()
        
        let selectedRange = textView.selectedRange
        if let startPosition = textView.position(from: textView.beginningOfDocument, offset: selectedRange.location),
           let endPosition = textView.position(from: startPosition, offset: selectedRange.length) {
            let textRange = textView.textRange(from: startPosition, to: endPosition)
            let caretRect = textView.firstRect(for: textRange!)
            
            UIView.performWithoutAnimation {
                textView.setContentOffset(CGPoint(x: 0, y: caretRect.origin.y), animated: false)
                textView.selectedRange = cursorPosition
            }
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText: String = (textView.text ?? "")
        guard let textRange: Range<String.Index> = Range(range, in: currentText) else { return true }
        
        /// Use utf16 view for proper length calculation
        let currentLength: Int = currentText.count
        let rangeLength: Int = currentText[textRange].count
        let newLength: Int = ((currentLength - rangeLength) + text.count)
        
        /// If the updated length is within the limit then just let the OS handle it (no need to do anything custom
        guard newLength > InputTextView.maxMessageCharacterCount else { return true }
        
        /// Ensure there is actually space remaining (if not then just don't allow editing)
        let remainingSpace: Int = InputTextView.maxMessageCharacterCount - (currentLength - rangeLength)
        guard remainingSpace > 0 else { return false }
        
        /// Truncate text based on character count (use `textStorage.replaceCharacters` for built in `undo` support)
        let truncatedText: String = String(text.prefix(remainingSpace))
        let offset: Int = range.location + truncatedText.count
        
        /// Pasting a value that is too large into the input will result in some odd default OS styling being applied to the text which is very
        /// different from our desired text style, in order to avoid this we need to detect this case and explicitly set the value as an attributed
        /// string with our explicit styling
        ///
        /// **Note:** If we add any additional attributes these will need to be updated to match
        if currentText.isEmpty {
            textView.textStorage.setAttributedString(
                NSAttributedString(
                    string: truncatedText,
                    attributes: [
                        .font: textView.font ?? InputTextView.defaultFont,
                        .foregroundColor: textView.textColor ?? InputTextView.defaultTextColor
                    ]
                )
            )
        }
        else {
            textView.textStorage.replaceCharacters(in: range, with: truncatedText)
        }
        
        /// Position cursor after inserted text
        ///
        /// **Note:** We need to dispatch to the next run loop because it seems that iOS might revert the `selectedTextRange`
        /// after returning `false` from this function, by dispatching we then override this reverted position with a desired final position
        if let newPosition: UITextPosition = textView.position(from: textView.beginningOfDocument, offset: offset) {
            DispatchQueue.main.async {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
        }
        
        /// We need to manually trigger the `handleTextChanged` call because returning `false` here means the
        /// `textViewDidChange(_:)`delegate won't be called
        handleTextChanged()
        
        return false
    }
    
    private func handleTextChanged() {
        defer { snDelegate?.inputTextViewDidChangeContent(self) }
        
        placeholderLabel.isHidden = !(text ?? "").isEmpty
        
        let height = frame.height
        let size = sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude))
        
        let newHeight = size.height.clamp(minHeight, maxHeight)
        
        guard newHeight != height else { return }
        
        // `textView.contentSize` isn't accurate when restoring a multiline draft, so we set it here manually
        UIView.performWithoutAnimation {
            self.contentSize = size
        }
        
        heightConstraint.constant = newHeight
        snDelegate?.inputTextViewDidChangeSize(self)
    }
}

// MARK: - InputTextViewDelegate

protocol InputTextViewDelegate : AnyObject {
    func inputTextViewDidChangeSize(_ inputTextView: InputTextView)
    func inputTextViewDidChangeContent(_ inputTextView: InputTextView)
    func didPasteImageFromPasteboard(_ inputTextView: InputTextView, image: UIImage)
}
