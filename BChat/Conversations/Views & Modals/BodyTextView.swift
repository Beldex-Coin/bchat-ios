
// Requirements:
// • Links should show up properly and be tappable.
// • Text should * not * be selectable.
// • The long press interaction that shows the context menu should still work.

final class BodyTextView : UITextView {
    private let snDelegate: BodyTextViewDelegate
    
    override var selectedTextRange: UITextRange? {
        get { return nil }
        set { }
    }
    
    init(snDelegate: BodyTextViewDelegate) {
        self.snDelegate = snDelegate
        super.init(frame: CGRect.zero, textContainer: nil)
        setUpGestureRecognizers()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        preconditionFailure("Use init(snDelegate:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(snDelegate:) instead.")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawBlockQuoteBars()
    }
    
    private func setUpGestureRecognizers() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        addGestureRecognizer(longPressGestureRecognizer)
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UITapGestureRecognizer) {
        snDelegate.handleLongPress(gestureRecognizer)
    }
    
    @objc private func handleDoubleTap() {
        // Do nothing
    }
    
    private func drawBlockQuoteBars() {
        guard let attributed = attributedText, attributed.length > 0 else { return }
        let fullRange = NSRange(location: 0, length: attributed.length)
        let nsText = attributed.string as NSString
        
        attributed.enumerateAttribute(.snBlockQuote, in: fullRange, options: []) { value, range, _ in
            guard let isQuote = value as? Bool, isQuote, range.length > 0 else { return }
            if range.location + 3 <= nsText.length {
                let prefix = nsText.substring(with: NSRange(location: range.location, length: 3))
                if prefix == ">  " { return }
            }
            
            let glyphRange = self.layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            self.layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { _, usedRect, _, _, _ in
                let barX = self.textContainerInset.left + self.textContainer.lineFragmentPadding - self.contentOffset.x + 2
                let barY = usedRect.minY + self.textContainerInset.top - self.contentOffset.y + 1
                let barHeight = max(usedRect.height + 1, 5)
                let barRect = CGRect(x: barX, y: barY, width: 3, height: barHeight)
                let path = UIBezierPath(roundedRect: barRect, cornerRadius: 1.5)
                UIColor.systemGray.setFill()
                path.fill()
            }
        }
    }
}

protocol BodyTextViewDelegate {
    
    func handleLongPress(_ gestureRecognizer: UITapGestureRecognizer)
}
