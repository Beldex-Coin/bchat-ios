import UIKit

final class InputViewButton : UIView {
    private let icon: UIImage
    private let isSendButton: Bool
    private weak var delegate: InputViewButtonDelegate?
    private let hasOpaqueBackground: Bool
    private lazy var widthConstraint = set(.width, to: InputViewButton.size)
    private lazy var heightConstraint = set(.height, to: InputViewButton.size)
    private var longPressTimer: Timer?
    private var isLongPress = false
    private let isPayButton: Bool
    private let isAttachmentButton: Bool
    
    // MARK: UI Components
    private lazy var backgroundView = UIView()
    
    // MARK: Settings
    static let size = CGFloat(48)
    static let circularSize = CGFloat(33)
    static let expandedSize = CGFloat(48)
    static let expandedNewSize = CGFloat(15)
    static let iconSize: CGFloat = 20
    
    // MARK: Lifecycle
    init(icon: UIImage, isSendButton: Bool = false, delegate: InputViewButtonDelegate, hasOpaqueBackground: Bool = false, isPayButton: Bool = false, isAttachmentButton: Bool = false) {
        self.isAttachmentButton = isAttachmentButton
        self.icon = icon
        self.isSendButton = isSendButton
        self.delegate = delegate
        self.hasOpaqueBackground = hasOpaqueBackground
        self.isPayButton = isPayButton
        super.init(frame: CGRect.zero)
        setUpViewHierarchy()
        self.isAccessibilityElement = true
    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(icon:delegate:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(icon:delegate:) instead.")
    }
    
    private func setUpViewHierarchy() {
        backgroundColor = .clear
        if hasOpaqueBackground {
            let backgroundView = UIView()
            backgroundView.backgroundColor = Colors.bothGreenColor
            addSubview(backgroundView)
            backgroundView.pin(to: self)
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
            addSubview(blurView)
            blurView.pin(to: self)
            layer.borderWidth = Values.separatorThickness
            let borderColor = (isLightMode ? UIColor.black : UIColor.white).withAlphaComponent(Values.veryLowOpacity)
            layer.borderColor = borderColor.cgColor
        }
        backgroundView.backgroundColor = isSendButton ? Colors.bothGreenColor : UIColor.clear
        addSubview(backgroundView)
        backgroundView.pin(to: self)
        layer.cornerRadius = isSendButton ? 24 : 24
        if isAttachmentButton {
            layer.cornerRadius = 18
        }
        layer.masksToBounds = true
        isUserInteractionEnabled = true
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        let iconImageView = UIImageView(image: icon)
        iconImageView.contentMode = .scaleAspectFit
        let iconSize = InputViewButton.iconSize
        iconImageView.set(.width, to: iconSize)
        iconImageView.set(.height, to: iconSize)
        addSubview(iconImageView)

        iconImageView.center(in: self)
        
    }
    
    // MARK: Animation
    private func animate(to size: CGFloat, glowColor: UIColor, backgroundColor: UIColor) {
        let frame = CGRect(center: center, size: CGSize(width: size, height: size))
        widthConstraint.constant = size
        heightConstraint.constant = size
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
            self.frame = frame
            self.layer.cornerRadius = self.isSendButton ? 24 : 24
            if self.isAttachmentButton {
                self.layer.cornerRadius = 18
            }
            let glowConfiguration = UIView.CircularGlowConfiguration(size: size, color: glowColor, isAnimated: true, radius: isLightMode ? 4 : 6)
            self.setCircularGlow(with: glowConfiguration)
            self.backgroundView.backgroundColor = backgroundColor
        }
    }
    
    private func expand() {
        let size = InputViewButton.size
        animate(to: size, glowColor: UIColor.clear, backgroundColor: UIColor.clear)
    }
    
    private func collapse() {
        let backgroundColor = isSendButton ? Colors.bothGreenColor : Colors.text.withAlphaComponent(0)
        animate(to: InputViewButton.size, glowColor: .clear, backgroundColor: backgroundColor)
    }
    
    // MARK: Interaction
    
    // We want to detect both taps and long presses
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isUserInteractionEnabled else { return }
        
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        expand()
        invalidateLongPressIfNeeded()
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            self.isLongPress = true
            self.delegate?.handleInputViewButtonLongPressBegan(self)
        })
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isUserInteractionEnabled else { return }
        
        if isLongPress {
            delegate?.handleInputViewButtonLongPressMoved(self, with: touches.first!)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isUserInteractionEnabled else { return }
        
        collapse()
        if !isLongPress {
            delegate?.handleInputViewButtonTapped(self)
        } else {
            delegate?.handleInputViewButtonLongPressEnded(self, with: touches.first!)
        }
        invalidateLongPressIfNeeded()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        collapse()
        invalidateLongPressIfNeeded()
    }

    private func invalidateLongPressIfNeeded() {
        longPressTimer?.invalidate()
        isLongPress = false
    }
}

// MARK: Delegate
protocol InputViewButtonDelegate : class {
    
    func handleInputViewButtonTapped(_ inputViewButton: InputViewButton)
    func handleInputViewButtonLongPressBegan(_ inputViewButton: InputViewButton)
    func handleInputViewButtonLongPressMoved(_ inputViewButton: InputViewButton, with touch: UITouch)
    func handleInputViewButtonLongPressEnded(_ inputViewButton: InputViewButton, with touch: UITouch)
}

extension InputViewButtonDelegate {
    
    func handleInputViewButtonLongPressBegan(_ inputViewButton: InputViewButton) { }
    func handleInputViewButtonLongPressMoved(_ inputViewButton: InputViewButton, with touch: UITouch) { }
    func handleInputViewButtonLongPressEnded(_ inputViewButton: InputViewButton, with touch: UITouch) { }
}
