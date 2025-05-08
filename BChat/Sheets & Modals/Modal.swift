import UIKit

@objc(LKModal)
class Modal: BaseVC, UIGestureRecognizerDelegate {
    
    // MARK: Components
    lazy var contentView: UIView = {
        let result = UIView()
        result.backgroundColor = Colors.modalBackground
        result.layer.cornerRadius = 20
        result.layer.masksToBounds = false
        result.layer.borderColor = Colors.borderColorNew.cgColor
        result.layer.borderWidth = 1
        result.layer.shadowColor = UIColor.black.cgColor
        result.layer.shadowRadius = isLightMode ? 2 : 8
        result.layer.shadowOpacity = isLightMode ? 0.1 : 0.64
        return result
    }()
    
    lazy var cancelButton: UIButton = {
        let result = UIButton()
        result.set(.height, to: 52)
        result.layer.cornerRadius = Values.buttonRadius
        result.layer.borderWidth = 0.5
        result.layer.borderColor = Colors.bothGreenColor.cgColor
        result.backgroundColor = Colors.bothGreenWithAlpha10
        result.titleLabel!.font = Fonts.OpenSans(ofSize: 14)
        result.setTitleColor(Colors.bothGrayColor, for: UIControl.State.normal)
        result.setTitle(NSLocalizedString("Cancel", comment: ""), for: UIControl.State.normal)
        return result
    }()
    
    // MARK: Settings
    private static let cornerRadius: CGFloat = 10
    static let buttonCornerRadius = CGFloat(5)
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let alpha = isLightMode ? CGFloat(0.1) : Values.highOpacity
        view.backgroundColor = UIColor(hex: 0x000000).withAlphaComponent(alpha)
        cancelButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(close))
        swipeGestureRecognizer.direction = .down
        view.addGestureRecognizer(swipeGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
        
        setUpViewHierarchy()
    }
    
    private func setUpViewHierarchy() {
        view.addSubview(contentView)
        if UIDevice.current.isIPad {
            contentView.set(.width, to: Values.iPadModalWidth)
            contentView.center(in: view)
        } else {
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Values.veryLargeSpacing).isActive = true
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Values.veryLargeSpacing).isActive = true
            contentView.center(.vertical, in: view)
        }
        populateContentView()
    }
    
    /// To be overridden by subclasses.
    func populateContentView() {
        preconditionFailure("populateContentView() is abstract and must be overridden.")
    }
    
    // MARK: - Interaction
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location: CGPoint = touch.location(in: contentView)
        
        return !contentView.point(inside: location, with: nil)
    }
}
