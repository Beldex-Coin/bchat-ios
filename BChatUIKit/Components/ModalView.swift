// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import UIKit

open class ModalView: UIViewController, UIGestureRecognizerDelegate {
    private static let cornerRadius: CGFloat = 20
    private static let borderWidth: CGFloat = 1
    
    public enum DismissType: Equatable, Hashable {
        case single
        case recursive
    }
    
    private let dismissType: DismissType
    private let afterClosed: (() -> ())?
    
    // MARK: - Components
    
    internal var contentTopConstraint: NSLayoutConstraint?
    internal var contentCenterYConstraint: NSLayoutConstraint?
    
    
    private lazy var dimmingView: UIView = {
        let result = UIVisualEffectView()
        result.effect = UIBlurEffect(style: (.dark))
        
        return result
    }()
    
    lazy var containerView: UIView = {
        let result: UIView = UIView()
        result.clipsToBounds = false
        result.backgroundColor = Colors.smallBackGroundColor
        result.layer.cornerRadius = ModalView.cornerRadius
        result.layer.borderWidth = ModalView.borderWidth
        result.layer.borderColor = Colors.borderColorNew.cgColor
        result.layer.shadowColor = UIColor.black.cgColor
        result.layer.shadowRadius = 10
        result.layer.shadowOpacity = 0.4
        
        return result
    }()
    
    public lazy var contentView: UIView = {
        let result: UIView = UIView()
        result.clipsToBounds = true
        result.layer.cornerRadius = ModalView.cornerRadius
        
        return result
    }()
    
    // MARK: - Lifecycle
    
    public init(
        targetView: UIView? = nil,
        dismissType: DismissType = .recursive,
        afterClosed: (() -> ())? = nil
    ) {
        self.dismissType = dismissType
        self.afterClosed = afterClosed
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("Use init(targetView:afterClosed:) instead")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backButtonTitle = ""
        view.backgroundColor = Colors.backGroundColorWithAlpha

        setNeedsStatusBarAppearanceUpdate()
        
        view.addSubview(dimmingView)
        view.addSubview(containerView)
        
        containerView.addSubview(contentView)
        
        dimmingView.pin(to: view)
        contentView.pin(to: containerView)
        
        containerView.leadingAnchor
            .constraint(equalTo: view.leadingAnchor, constant: Values.largeSpacing)
            .isActive = true
        view.trailingAnchor
            .constraint(equalTo: containerView.trailingAnchor, constant: Values.largeSpacing)
            .isActive = true
        
        containerView.center(.horizontal, in: view)
        contentCenterYConstraint = containerView.center(.vertical, in: view)
        contentTopConstraint = containerView
            .pin(.top, to: .top, of: view, withInset: 10)
            .setting(isActive: false)
        
        // Gestures
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(close))
        swipeGestureRecognizer.direction = .down
        dimmingView.addGestureRecognizer(swipeGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        tapGestureRecognizer.delegate = self
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
        
        populateContentView()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        afterClosed?()
    }
    
    /// To be overridden by subclasses.
    open func populateContentView() {
        preconditionFailure("populateContentView() is abstract and must be overridden.")
    }
    
    // MARK: - Interaction
    
    @objc public func cancel() {
        close()
    }
    
    @objc public final func close() {
        // Recursively dismiss all modals (ie. find the first modal presented by a non-modal
        // and get that to dismiss it's presented view controller)
        var targetViewController: UIViewController? = self
        
        switch dismissType {
            case .single: break
            
            case .recursive:
                while targetViewController?.presentingViewController is ModalView {
                    targetViewController = targetViewController?.presentingViewController
                }
        }
        
        targetViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location: CGPoint = touch.location(in: contentView)
        
        return !contentView.point(inside: location, with: nil)
    }
}
