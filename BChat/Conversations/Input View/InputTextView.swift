
public final class InputTextView : UITextView, UITextViewDelegate {
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
        textColor = Colors.text
        font = Fonts.OpenSans(ofSize: Values.mediumFontSize)
        tintColor = Colors.bothGreenColor
        keyboardAppearance = isLightMode ? .light : .dark
        heightConstraint.isActive = true
        let horizontalInset: CGFloat = 2
        textContainerInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        addSubview(placeholderLabel)
        placeholderLabel.pin(.leading, to: .leading, of: self, withInset: horizontalInset + 5) // Slight visual adjustment
        placeholderLabel.pin(.top, to: .top, of: self)
        pin(.trailing, to: .trailing, of: placeholderLabel, withInset: horizontalInset)
        pin(.bottom, to: .bottom, of: placeholderLabel)
    }

    // MARK: Updating
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
    
    private func handleTextChanged() {
        defer { snDelegate?.inputTextViewDidChangeContent(self) }
        
        placeholderLabel.isHidden = !(text ?? "").isEmpty
        
        let height = frame.height
        let size = sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        // CGSize(width: contentSize.width, height: contentSize.height)
        
        // `textView.contentSize` isn't accurate when restoring a multiline draft, so we set it here manually
        self.contentSize = size
        let newHeight = size.height.clamp(minHeight, maxHeight)
        
        guard newHeight != height else { return }
        
        heightConstraint.constant = newHeight
        snDelegate?.inputTextViewDidChangeSize(self)
    }
}

// MARK: Delegate
protocol InputTextViewDelegate : AnyObject {
    
    func inputTextViewDidChangeSize(_ inputTextView: InputTextView)
    func inputTextViewDidChangeContent(_ inputTextView: InputTextView)
    func didPasteImageFromPasteboard(_ inputTextView: InputTextView, image: UIImage)
}
