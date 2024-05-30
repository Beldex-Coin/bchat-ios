//
//  MTSlideToOpenControl.swift
//  MTSlideToOpen
//
//  Created by Martin Lee on 10/12/17.
//  Copyright © 2017 Martin Le. All rights reserved.
//

import UIKit
import BChatUIKit

@objc public protocol MTSlideToOpenDelegate {
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView)
}

@objcMembers public class MTSlideToOpenView: UIView {
    // MARK: All Views
    public let textLabel: UILabel = {
        let label = UILabel.init()
        return label
    }()
    public let sliderTextLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    public let thumnailImageView: UIImageView = {
        let view = MTRoundImageView()
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    public let thumnailImageViewRight: UIImageView = {
        let view = MTRoundImageView()
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleAspectFit
        view.tintColor = Colors.bchatViewBackgroundColor
        return view
    }()
    
    public let sliderHolderView: UIView = {
        let view = UIView()
        return view
    }()
    public let draggedView: UIView = {
        let view = UIView()
        return view
    }()
    public let view: UIView = {
        let view = UIView()
        return view
    }()
    // MARK: Public properties
    public weak var delegate: MTSlideToOpenDelegate?
    public var animationVelocity: Double = 0.2
    public var sliderViewTopDistance: CGFloat = 8.0 {
        didSet {
            topSliderConstraint?.constant = sliderViewTopDistance
            layoutIfNeeded()
        }
    }
    public var thumbnailViewTopDistance: CGFloat = 0.0 {
        didSet {
            topThumbnailViewConstraint?.constant = thumbnailViewTopDistance
            layoutIfNeeded()
        }
    }
    public var thumbnailViewStartingDistance: CGFloat = 5 {
        didSet {
            leadingThumbnailViewConstraint?.constant = thumbnailViewStartingDistance
            trailingDraggedViewConstraint?.constant = thumbnailViewStartingDistance
            setNeedsLayout()
        }
    }
    public var textLabelLeadingDistance: CGFloat = 0 {
        didSet {
            leadingTextLabelConstraint?.constant = textLabelLeadingDistance
            setNeedsLayout()
        }
    }
    public var isEnabled:Bool = true {
        didSet {
            animationChangedEnabledBlock?(isEnabled)
        }
    }
    public var showSliderText:Bool = false {
        didSet {
            sliderTextLabel.isHidden = !showSliderText
        }
    }
    public var animationChangedEnabledBlock:((Bool) -> Void)?
    // MARK: Default styles
    public var sliderCornerRadius: CGFloat = 30.0 {
        didSet {
            sliderHolderView.layer.cornerRadius = sliderCornerRadius
            draggedView.layer.cornerRadius = sliderCornerRadius
        }
    }
    public var sliderBackgroundColor: UIColor = UIColor(red:0.1, green:0.61, blue:0.84, alpha:0.1) {
        didSet {
            sliderHolderView.backgroundColor = Colors.bchatViewBackgroundColor//sliderBackgroundColor
            sliderTextLabel.textColor = sliderBackgroundColor
        }
    }
    
    public var textColor:UIColor = .white {
        didSet {
            textLabel.textColor = textColor
        }
    }
    
    public var slidingColor:UIColor = UIColor(red:25.0/255, green:155.0/255, blue:215.0/255, alpha:0.7) {
        didSet {
            draggedView.backgroundColor = slidingColor
        }
    }
    public var thumbnailColor:UIColor = UIColor(red:25.0/255, green:155.0/255, blue:215.0/255, alpha:1) {
        didSet {
            thumnailImageView.backgroundColor = thumbnailColor
        }
    }
    public var labelText: String = "Swipe to send BDX" {
        didSet {
            textLabel.text = labelText
            sliderTextLabel.text = labelText
        }
    }
    public var textFont: UIFont = Fonts.semiOpenSans(ofSize: 14) {
        didSet {
            textLabel.font = textFont
            sliderTextLabel.font = textFont
        }
    }
    // MARK: Private Properties
    private var leadingThumbnailViewConstraint: NSLayoutConstraint?
    private var leadingTextLabelConstraint: NSLayoutConstraint?
    private var topSliderConstraint: NSLayoutConstraint?
    private var topThumbnailViewConstraint: NSLayoutConstraint?
    private var trailingDraggedViewConstraint: NSLayoutConstraint?
    private var xPositionInThumbnailView: CGFloat = 0
    private var xEndingPoint: CGFloat {
        get {
            return (self.view.frame.maxX - thumnailImageView.bounds.width - thumbnailViewStartingDistance)
        }
    }
    private var isFinished: Bool = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupView()        
    }
    
    private func setupView() {
        self.addSubview(view)
        view.addSubview(thumnailImageView)
        view.addSubview(thumnailImageViewRight)
        view.addSubview(sliderHolderView)
        view.addSubview(draggedView)
        draggedView.addSubview(sliderTextLabel)
        sliderHolderView.addSubview(textLabel)
        view.bringSubviewToFront(self.thumnailImageViewRight)
        view.bringSubviewToFront(self.thumnailImageView)
        setupConstraint()
        setStyle()
        thumnailImageViewRight.frame = CGRect(x: 237, y: 17, width: 15, height: 15)
        // Add pan gesture
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        thumnailImageView.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func setupConstraint() {
        view.translatesAutoresizingMaskIntoConstraints = false
        thumnailImageView.translatesAutoresizingMaskIntoConstraints = false
        sliderHolderView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderTextLabel.translatesAutoresizingMaskIntoConstraints = false
        draggedView.translatesAutoresizingMaskIntoConstraints = false
        // Setup for view
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        // Setup for circle View
        leadingThumbnailViewConstraint = thumnailImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        leadingThumbnailViewConstraint?.isActive = true
        topThumbnailViewConstraint = thumnailImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: thumbnailViewTopDistance)
        topThumbnailViewConstraint?.isActive = true
        thumnailImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        thumnailImageView.heightAnchor.constraint(equalTo: thumnailImageView.widthAnchor).isActive = true
        // Setup for slider holder view
        topSliderConstraint = sliderHolderView.topAnchor.constraint(equalTo: view.topAnchor, constant: sliderViewTopDistance)
        topSliderConstraint?.isActive = true
        sliderHolderView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sliderHolderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        sliderHolderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        // Setup for textLabel
        textLabel.topAnchor.constraint(equalTo: sliderHolderView.topAnchor).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: sliderHolderView.centerYAnchor).isActive = true
        leadingTextLabelConstraint = textLabel.leadingAnchor.constraint(equalTo: sliderHolderView.leadingAnchor, constant: textLabelLeadingDistance)
        leadingTextLabelConstraint?.isActive = true
        textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: CGFloat(-8)).isActive = true
        // Setup for sliderTextLabel
        sliderTextLabel.topAnchor.constraint(equalTo: textLabel.topAnchor).isActive = true
        sliderTextLabel.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor).isActive = true
        sliderTextLabel.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor).isActive = true
        sliderTextLabel.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor).isActive = true
        // Setup for Dragged View
        draggedView.leadingAnchor.constraint(equalTo: sliderHolderView.leadingAnchor).isActive = true
        draggedView.topAnchor.constraint(equalTo: sliderHolderView.topAnchor).isActive = true
        draggedView.centerYAnchor.constraint(equalTo: sliderHolderView.centerYAnchor).isActive = true
        trailingDraggedViewConstraint = draggedView.trailingAnchor.constraint(equalTo: thumnailImageView.trailingAnchor, constant: thumbnailViewStartingDistance)
        trailingDraggedViewConstraint?.isActive = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateBdxAmountSlider),
                                               name: Notification.Name("bdxAmountPassingSliderView"),
                                               object: nil)
        
    }
    
    private func setStyle() {
        textLabel.text = labelText
        textLabel.font = textFont
        textLabel.textColor = Colors.cancelButtonTitleColor1
        textLabel.textAlignment = .center

        sliderTextLabel.text = labelText
        sliderTextLabel.font = textFont
        sliderTextLabel.textColor = sliderBackgroundColor
        sliderTextLabel.textAlignment = .center
        sliderTextLabel.isHidden = !showSliderText
        
        if isOnRightToLeftLanguage() {
            textLabel.mt_flipView()
            sliderTextLabel.mt_flipView()
        }

        sliderHolderView.backgroundColor = sliderBackgroundColor
        sliderHolderView.layer.cornerRadius = sliderCornerRadius
        sliderHolderView.layer.borderWidth = 0.5
        sliderHolderView.layer.borderColor = UIColor(hex: 0xACACAC).cgColor
        draggedView.backgroundColor = slidingColor
        draggedView.layer.cornerRadius = sliderCornerRadius
        draggedView.clipsToBounds = true
        draggedView.layer.masksToBounds = true
    }
    
    private func isTapOnThumbnailViewWithPoint(_ point: CGPoint) -> Bool{
        return self.thumnailImageView.frame.contains(point)
    }
    
    private func updateThumbnailXPosition(_ x: CGFloat) {
        leadingThumbnailViewConstraint?.constant = x
        setNeedsLayout()
    }
    
    /// Update BDX Amount Value Label
    @objc func updateBdxAmountSlider(notification: NSNotification) {
        if let dict = notification.object as? NSDictionary {
            if let myMessage = dict["bdxAmount"] as? String{
                textLabel.text = "Swipe to send \(myMessage) BDX"
                sliderTextLabel.text = "Swipe to send \(myMessage) BDX"
            }
        }
    }
    
    // MARK: UIPanGestureRecognizer
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if isFinished || !isEnabled {
            return
        }
        let translatedPoint = sender.translation(in: view).x * (self.isOnRightToLeftLanguage() ? -1 : 1)
        switch sender.state {
        case .began:
            break
        case .changed:
            if translatedPoint >= xEndingPoint {
                updateThumbnailXPosition(xEndingPoint)
                return
            }
            if translatedPoint <= thumbnailViewStartingDistance {
                textLabel.alpha = 1
                updateThumbnailXPosition(thumbnailViewStartingDistance)
                return
            }
            thumnailImageView.transform = CGAffineTransform(rotationAngle: CGFloat(translatedPoint * 2 * .pi / xEndingPoint))
            updateThumbnailXPosition(translatedPoint)
            textLabel.alpha = (xEndingPoint - translatedPoint) / xEndingPoint
            break
        case .ended:
            thumnailImageView.transform = .identity
            if translatedPoint >= xEndingPoint {
                textLabel.alpha = 0
                updateThumbnailXPosition(xEndingPoint)
                // Finish action
                isFinished = true
                delegate?.mtSlideToOpenDelegateDidFinish(self)
                return
            }
            if translatedPoint <= thumbnailViewStartingDistance {
                textLabel.alpha = 1
                updateThumbnailXPosition(thumbnailViewStartingDistance)
                return
            }
            UIView.animate(withDuration: animationVelocity) {
                self.leadingThumbnailViewConstraint?.constant = self.thumbnailViewStartingDistance
                self.textLabel.alpha = 1
                self.layoutIfNeeded()
            }
            break
        default:
            break
        }
    }
    // Others
    public func resetStateWithAnimation(_ animated: Bool) {
        let action = {
            self.leadingThumbnailViewConstraint?.constant = self.thumbnailViewStartingDistance
            self.textLabel.alpha = 1
            self.layoutIfNeeded()
            //
            self.isFinished = false
        }
        if animated {
            UIView.animate(withDuration: animationVelocity) {
               action()
            }
        } else {
            action()
        }
    }
    
    // MARK: Helpers
    
    func isOnRightToLeftLanguage() -> Bool {
        return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
    }
}

extension UIView {
   func mt_flipView() {
       self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
   }
}

class MTRoundImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
    }
}
