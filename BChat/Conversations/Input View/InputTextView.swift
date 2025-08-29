
public final class InputTextView : UITextView, UITextViewDelegate {
    
    private static let defaultFont = Fonts.OpenSans(ofSize: Values.mediumFontSize)
    private static let defaultTextColor = Colors.text
    private static let maxMessageCharacterCount: Int = 2000
    
    private weak var snDelegate: InputTextViewDelegate?
    private let maxWidth: CGFloat
    
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
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        isScrollEnabled = intrinsicContentSize.height >= maxHeight
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
        
        UIView.performWithoutAnimation {
            textView.scrollRangeToVisible(selectedRange)
            textView.selectedRange = selectedRange
        }
        
        handleTextChanged()
    }
    
    private func handleTextChanged() {
        defer { snDelegate?.inputTextViewDidChangeContent(self) }
        placeholderLabel.isHidden = !text.isEmpty
    }
}

// MARK: - InputTextViewDelegate

protocol InputTextViewDelegate : AnyObject {
    func inputTextViewDidChangeSize(_ inputTextView: InputTextView)
    func inputTextViewDidChangeContent(_ inputTextView: InputTextView)
    func didPasteImageFromPasteboard(_ inputTextView: InputTextView, image: UIImage)
}
