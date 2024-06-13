
import UIKit

class CustomSwitch: UIControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        contentView.layer.cornerRadius = frame.height / 2
        thumbnailView.frame.size = CGSize(width: frame.height - UIConstant.ThumbnailInset.double,
                                          height: frame.height - UIConstant.ThumbnailInset.double)
        thumbnailView.layer.cornerRadius = thumbnailView.frame.height / 2
        calculatePositions()
        updateImages()
        setOn(isOn, animated: false)
    }
    
    /// changes `isOn`,  `completion` is called after animation finishes if `animated`
    func setOn(_ isOn: Bool,
               animated: Bool = false,
               completion: (() -> Void)? = nil) {
        self.isOn = isOn
        let block = { [weak self] in
            guard let self else { return }
            self.onStateChange(to: isOn)
            self.thumbnailView.frame.origin = isOn ? self.onPoint : self.offPoint
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: block) { _ in
                completion?()
            }
        } else {
            block()
            completion?()
        }
    }
    
    // MARK: - @IBInspectables
    /// tint color for case `isOn == true`
    @IBInspectable var onTintColor: UIColor = .systemGreen
    /// tint color for case `isOn == false`
    @IBInspectable var offTintColor: UIColor = .blue
    /// thumb color for case `isOn == true`
    @IBInspectable var onThumbColor: UIColor = .white
    /// thumb color for case `isOn == false`
    @IBInspectable var offThumbColor: UIColor?
    /// thumb image for case `isOn == true`
    @IBInspectable var onThumbImage: UIImage? {
        didSet { setNeedsLayout() }
    }
    /// thumb image for case `isOn == false`
    @IBInspectable var offThumbImage: UIImage? {
        didSet { setNeedsLayout() }
    }
    /// image located in opposite to current `isOn` value origin
    /// regarding switch's contentView
    ///  - note: image for `isOn == true`
    @IBInspectable var onBackImage: UIImage? {
        didSet { setNeedsLayout() }
    }
    /// image located in opposite to current `isOn` value origin
    /// regarding switch's contentView
    ///  - note: image for `isOn == false`
    @IBInspectable var offBackImage: UIImage? {
        didSet { setNeedsLayout() }
    }
    
    var isOn: Bool = false
    
    // MARK: - subviews
    private let contentView = UIView()
    private let thumbnailView = UIView().then { $0.clipsToBounds = true }
    private lazy var thumbImageView = UIImageView()
    private lazy var backOnImageView = UIImageView()
    private lazy var backOffImageView = UIImageView()
    
    private var currentThumbImage: UIImage? { isOn ? onThumbImage : offThumbImage }
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    
    /// thumb view`'isOn == true` origin
    private var onPoint: CGPoint!
    /// thumb view `isOn == false` origin
    private var offPoint: CGPoint!
}

// MARK: - ui ocnfigurations
private extension CustomSwitch {
    func pinViews() {
        addSubview(contentView)
        contentView.addSubview(thumbnailView)
    }
    
    func onStateChange(to isOn: Bool) {
        contentView.backgroundColor = isOn ? onTintColor : offTintColor
        thumbnailView.backgroundColor = isOn ? onThumbColor : (offThumbColor ?? onThumbColor)
        if let currentThumbImage { thumbImageView.image = currentThumbImage }
    }
    
    func updateImages() {
        defer { contentView.bringSubviewToFront(thumbnailView) }
        let constImageViewSize = CGSize(width: thumbnailView.frame.width - UIConstant.ThumbnailInset.standart,
                                        height: thumbnailView.frame.height - UIConstant.ThumbnailInset.standart)
        // thumb part
        if let image = currentThumbImage {
            if !thumbnailView.subviews.contains(thumbImageView) {
                thumbnailView.addSubview(thumbImageView)
                thumbImageView.bounds.size = constImageViewSize
                thumbImageView.center = thumbnailView.center
            }
            thumbImageView.image = image
            thumbImageView.isHidden = false
        } else {
            thumbImageView.isHidden = true
        }
        // back images part
        if let image = offBackImage {
            if !contentView.subviews.contains(backOffImageView) {
                contentView.addSubview(backOffImageView)
                backOffImageView.bounds.size = constImageViewSize
                backOffImageView.frame.origin.x = onPoint.x + UIConstant.ThumbnailInset.standart
                backOffImageView.center.y = contentView.center.y
            }
            backOffImageView.image = image
            backOffImageView.isHidden = false
        } else {
            backOffImageView.isHidden = true
        }
        if let image = onBackImage {
            if !contentView.subviews.contains(backOnImageView) {
                contentView.addSubview(backOnImageView)
                backOnImageView.bounds.size = constImageViewSize
                backOnImageView.frame.origin.x = offPoint.x
                backOnImageView.center.y = contentView.center.y
            }
            backOnImageView.image = image
            backOnImageView.isHidden = false
        } else {
            backOnImageView.isHidden = true
        }
    }
}

private extension CustomSwitch {
    func commonInit() {
        pinViews()
        addPanGesture()
        addTapGesture()
    }
}

// MARK: - math
private extension CustomSwitch {
    func calculatePositions() {
        offPoint = CGPoint(x: UIConstant.ThumbnailInset.standart,
                           y: UIConstant.ThumbnailInset.standart)
        onPoint = CGPoint(x: bounds.width - thumbnailView.bounds.width - UIConstant.ThumbnailInset.standart,
                          y: UIConstant.ThumbnailInset.standart)
    }
}

// MARK: - switch gestures
private extension CustomSwitch {
    func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: nil) { [weak self] pan in
            guard let self else { return }
            self.feedbackGenerator.prepare()
            switch pan.state {
            case .changed, .cancelled, .ended:
                let targetState = pan.location(in: self).x > self.bounds.size.width / 2
                let shallPassControl = targetState != self.isOn
                self.setOn(targetState,
                           animated: true) { [weak self] in
                    guard let self, shallPassControl else { return }
                    self.feedbackGenerator.selectionChanged()
                }
                if shallPassControl { self.sendActions(for: .valueChanged) }
            default:
                break
            }
        }
        addGestureRecognizer(pan)
    }
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: nil) { [weak self] _ in
            guard let self else { return }
            self.feedbackGenerator.prepare()
            self.setOn(!self.isOn, animated: true) { [weak self] in
                self?.feedbackGenerator.selectionChanged()
            }
            self.sendActions(for: .valueChanged)
        }
        addGestureRecognizer(tap)
    }
}

protocol Then {}

extension NSObject: Then {}

extension Then where Self: UIView {
    
    @discardableResult
    func then(_ block: (Self) -> Void ) -> Self {
        block(self)
        return self
    }
}

extension Optional {
    
    @discardableResult
    func then<T>( _ block: ( Wrapped ) throws -> T ) rethrows -> T? {
        switch self {
        case .none: return nil
        case .some( let value ): return try block( value )
        }
    }
}

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
}

extension UIEdgeInsets {
    init(constantInset inset: CGFloat) {
        self.init( top: inset, left: inset, bottom: inset, right: inset )
    }
}

extension CGSize {
    func inset(by value: CGFloat) -> Self {
        return CGSize(width: width - value, height: height - value)
    }
}

extension UIGestureRecognizer {
    convenience init<T: UIGestureRecognizer>( target: Any?, handler: @escaping ( T ) -> Void ) {
        let wrapper = HandlerWrapper<T>( handler )
        self.init( target: wrapper, action: #selector( HandlerWrapper.invoke ))
        wrapper.recognizer = self as? T
        objc_setAssociatedObject( target ?? self,
                                  &UIGestureRecognizer.AssociatedObjectHandle,
                                  wrapper,
                                  .OBJC_ASSOCIATION_RETAIN )
    }
    
    /// Wrapper class used to store closure.
    private final class HandlerWrapper<T: UIGestureRecognizer> {
        let handler: ( T ) -> Void
        weak var recognizer: T?
        init ( _ handler: @escaping ( T ) -> Void ) { self.handler = handler }
        @objc func invoke() { recognizer.then { handler( $0 ) }}
    }
    
    static private var AssociatedObjectHandle: UInt8 = 0
}


struct UIConstant {
    struct ThumbnailInset {
        static let standart: CGFloat = 3
        static let double: CGFloat = 6
    }
}


protocol LayoutGuideProtocol {
    var owningView: UIView? { get }
    
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: LayoutGuideProtocol {
    var owningView: UIView? { superview }
}

extension UILayoutGuide: LayoutGuideProtocol {}

extension LayoutGuideProtocol {
    @discardableResult
    func constrainToSuperview( insets: UIEdgeInsets = .zero, constrainToMargins: Bool = false ) -> [ NSLayoutConstraint ] {
        
        let secondItem: LayoutGuideProtocol = constrainToMargins ? owningView!.layoutMarginsGuide : owningView!
        
        let constraints = [
            topAnchor.constraint( equalTo: secondItem.topAnchor, constant: insets.top ),
            leadingAnchor.constraint( equalTo: secondItem.leadingAnchor, constant: insets.left ),
            secondItem.bottomAnchor.constraint( equalTo: bottomAnchor, constant: insets.bottom ),
            secondItem.trailingAnchor.constraint( equalTo: trailingAnchor, constant: insets.right ),
        ]
        
        NSLayoutConstraint.activate( constraints )
        return constraints
    }
}
