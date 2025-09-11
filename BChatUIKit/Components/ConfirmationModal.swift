// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import UIKit

public class ConfirmationModal: ModalView {
    
    public private(set) var info: Info
    private var internalOnConfirm: ((ConfirmationModal) -> ())? = nil
    private var internalOnCancel: ((ConfirmationModal) -> ())? = nil
    private var internalOnBodyTap: ((@escaping (ValueUpdate) -> Void) -> Void)? = nil
    
    // MARK: - Components
    
    private lazy var contentTapGestureRecognizer: UITapGestureRecognizer = {
        let result: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(contentViewTapped)
        )
        contentView.addGestureRecognizer(result)
        result.isEnabled = false
        
        return result
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let result: UILabel = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        result.numberOfLines = 0
        
        return result
    }()
    
    private lazy var explanationLabel: ScrollableLabel = {
        let result: ScrollableLabel = ScrollableLabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.regularOpenSans(ofSize: 14)
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        result.numberOfLines = 0
        
        return result
    }()
    
    private lazy var cancelButton: UIButton = {
        let result: UIButton = UIButton()
        result.setTitle("Cancel", for: .normal)
        result.layer.cornerRadius = Values.buttonRadius
        result.layer.borderColor = Colors.bothGreenColor.cgColor
        result.backgroundColor = Colors.bothGreenWithAlpha10
        result.titleLabel?.font = Fonts.regularOpenSans(ofSize: 14)
        result.layer.borderWidth = 1
        result.layer.borderColor = Colors.bothGreenColor.cgColor
        result.setTitleColor(Colors.titleColor3, for: .normal)
        result.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        result.set(.height, to: Values.alertButtonHeight)
        
        return result
    }()
    
    private lazy var confirmButton: UIButton = {
        let result: UIButton = UIButton()
        result.setTitle("Ok", for: .normal)
        result.layer.cornerRadius = Values.buttonRadius
        result.backgroundColor = Colors.bothGreenColor
        result.titleLabel!.font = Fonts.regularOpenSans(ofSize: 14)
        result.setTitleColor(Colors.bothWhiteColor, for: .normal)
        result.addTarget(self, action: #selector(confirmationPressed), for: .touchUpInside)
        result.set(.height, to: Values.alertButtonHeight)
        
        return result
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ cancelButton, confirmButton ])
        result.axis = .horizontal
        result.spacing = Values.smallSpacing
        result.layoutMargins = UIEdgeInsets(
            top: Values.smallSpacing,
            left: Values.smallSpacing,
            bottom: Values.mediumSpacing,
            right: Values.smallSpacing
        )
        
        result.distribution = .fillEqually
        result.isLayoutMarginsRelativeArrangement = true
        
        return result
    }()
    
    private lazy var contentStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ imageView, titleLabel, explanationLabel ])
        result.axis = .vertical
        result.spacing = Values.smallSpacing
        result.isLayoutMarginsRelativeArrangement = true
        
        result.layoutMargins = UIEdgeInsets(
            top: Values.largeSpacing,
            left: Values.veryLargeSpacing,
            bottom: Values.verySmallSpacing,
            right: Values.veryLargeSpacing
        )
        
        return result
    }()
    
    private lazy var mainStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ contentStackView, buttonStackView ])
        result.axis = .vertical
        
        return result
    }()
    
    // MARK: - Lifecycle
    
    public init(targetView: UIView? = nil, info: Info, modalImageType: ConfirmationModalType = .none) {
        self.info = info
        
        super.init(targetView: targetView, dismissType: info.dismissType, afterClosed: info.afterClosed)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        self.updateContent(with: info, modalImageType: modalImageType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func populateContentView() {
        let gestureRecogniser: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(contentViewTapped)
        )
        contentView.addGestureRecognizer(gestureRecogniser)
        contentView.addSubview(mainStackView)
        
        mainStackView.pin(to: contentView)
    }
    
    // MARK: - Content
    
    public func updateContent(with info: Info, modalImageType: ConfirmationModalType) {
        self.info = info
        
        internalOnBodyTap = nil
        internalOnConfirm = { modal in
            if info.dismissOnConfirm {
                modal.close()
            }
            
            info.onConfirm?(modal)
        }
        internalOnCancel = { modal in
            guard info.onCancel != nil else { return modal.close() }
            
            info.onCancel?(modal)
        }
        contentTapGestureRecognizer.isEnabled = true
        
        // Set the content based on the provided info
        titleLabel.text = info.title
        
        if info.modalType.isShowImage {
            imageView.isHidden = false
            imageView.image = UIImage(named: info.modalType.imageName)
        } else {
            imageView.isHidden = true
            imageView.image = nil
        }
        
        switch info.body {
            case .none:
                mainStackView.spacing = Values.smallSpacing
                
            case .text(let text, let scrollMode):
                mainStackView.spacing = Values.smallSpacing
                explanationLabel.text = text
                explanationLabel.isHidden = false
                
            case .attributedText(let attributedText, let scrollMode):
                mainStackView.spacing = Values.smallSpacing
                explanationLabel.attributedText = attributedText
                explanationLabel.isHidden = false
        }
        
        confirmButton.accessibilityIdentifier = info.confirmTitle
        confirmButton.isAccessibilityElement = true
        confirmButton.backgroundColor = info.modalType.confirmationButtonBgColor
        confirmButton.setTitle(info.confirmTitle, for: .normal)
        confirmButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
        confirmButton.isHidden = (info.confirmTitle == nil)
        confirmButton.isEnabled = info.confirmEnabled.isValid(with: info)
        
        cancelButton.accessibilityIdentifier = info.cancelTitle
        cancelButton.isAccessibilityElement = true
        cancelButton.setTitle(info.cancelTitle, for: .normal)
        cancelButton.setTitleColor(Colors.titleColor3, for: .normal)
        cancelButton.isEnabled = info.cancelEnabled.isValid(with: info)
        
        if info.modalType == .missedCall {
            cancelButton.layer.borderWidth = 0
            cancelButton.layer.borderColor = UIColor.clear.cgColor
            cancelButton.backgroundColor = Colors.bothGreenColor
        }
        
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityIdentifier = "Modal heading"
        titleLabel.accessibilityLabel = titleLabel.text
        
        explanationLabel.isAccessibilityElement = true
        explanationLabel.accessibilityIdentifier = "Modal description"
        explanationLabel.accessibilityLabel = explanationLabel.text
    }
    
    // MARK: - Interaction
    
    @objc private func contentViewTapped() {
        internalOnBodyTap?({ _ in })
    }
    
    @objc internal func confirmationPressed(_ sender: UIButton) {
        internalOnConfirm?(self)
    }
    
    @objc internal func cancelPressed(_ sender: UIButton) {
        internalOnCancel?(self)
    }
}

// MARK: - Types

public extension ConfirmationModal {
    enum ValueUpdate {
        case input(String)
        case image(Data?)
    }
    
    struct Info: Equatable, Hashable {
        internal var modalType: ConfirmationModalType
        internal let title: String
        public let body: Body
        public let showCondition: ShowCondition
        internal let confirmTitle: String?
        let confirmEnabled: ButtonValidator
        internal let cancelTitle: String
        let cancelEnabled: ButtonValidator
        let hasCloseButton: Bool
        let dismissOnConfirm: Bool
        let dismissType: ModalView.DismissType
        public let onConfirm: ((ConfirmationModal) -> ())?
        let onCancel: ((ConfirmationModal) -> ())?
        let afterClosed: (() -> ())?
        
        // MARK: - Initialization
        
        public init(
            modalType: ConfirmationModalType = .none,
            title: String,
            body: Body = .none,
            showCondition: ShowCondition = .none,
            confirmTitle: String? = nil,
            confirmEnabled: ButtonValidator = true,
            cancelTitle: String = "Cancel",
            cancelEnabled: ButtonValidator = true,
            hasCloseButton: Bool = false,
            dismissOnConfirm: Bool = true,
            dismissType: DismissType = .recursive,
            onConfirm: ((ConfirmationModal) -> ())? = nil,
            onCancel: ((ConfirmationModal) -> ())? = nil,
            afterClosed: (() -> ())? = nil
            
        ) {
            self.modalType = modalType
            self.title = title
            self.body = body
            self.showCondition = showCondition
            self.confirmTitle = confirmTitle
            self.confirmEnabled = confirmEnabled
            self.cancelTitle = cancelTitle
            self.cancelEnabled = cancelEnabled
            self.hasCloseButton = hasCloseButton
            self.dismissOnConfirm = dismissOnConfirm
            self.dismissType = dismissType
            self.onConfirm = onConfirm
            self.onCancel = onCancel
            self.afterClosed = afterClosed
        }
        
        // MARK: - Mutation
        
        public func with(
            body: Body? = nil,
            onConfirm: ((ConfirmationModal) -> ())? = nil,
            onCancel: ((ConfirmationModal) -> ())? = nil,
            afterClosed: (() -> ())? = nil
        ) -> Info {
            return Info(
                modalType: self.modalType,
                title: self.title,
                body: (body ?? self.body),
                showCondition: self.showCondition,
                confirmTitle: self.confirmTitle,
                confirmEnabled: self.confirmEnabled,
                cancelTitle: self.cancelTitle,
                cancelEnabled: self.cancelEnabled,
                hasCloseButton: self.hasCloseButton,
                dismissOnConfirm: self.dismissOnConfirm,
                dismissType: self.dismissType,
                onConfirm: (onConfirm ?? self.onConfirm),
                onCancel: (onCancel ?? self.onCancel),
                afterClosed: (afterClosed ?? self.afterClosed)
            )
        }
        
        // MARK: - Confirmance
        
        public static func == (lhs: ConfirmationModal.Info, rhs: ConfirmationModal.Info) -> Bool {
            return (
                lhs.modalType == rhs.modalType &&
                lhs.title == rhs.title &&
                lhs.body == rhs.body &&
                lhs.showCondition == rhs.showCondition &&
                lhs.confirmTitle == rhs.confirmTitle &&
                lhs.confirmEnabled.isValid(with: lhs) == rhs.confirmEnabled.isValid(with: rhs) &&
                lhs.cancelTitle == rhs.cancelTitle &&
                lhs.cancelEnabled.isValid(with: lhs) == rhs.cancelEnabled.isValid(with: rhs) &&
                lhs.hasCloseButton == rhs.hasCloseButton &&
                lhs.dismissOnConfirm == rhs.dismissOnConfirm &&
                lhs.dismissType == rhs.dismissType
            )
        }
        
        public func hash(into hasher: inout Hasher) {
            modalType.hash(into: &hasher)
            title.hash(into: &hasher)
            body.hash(into: &hasher)
            showCondition.hash(into: &hasher)
            confirmTitle.hash(into: &hasher)
            confirmEnabled.isValid(with: self).hash(into: &hasher)
            cancelTitle.hash(into: &hasher)
            cancelEnabled.isValid(with: self).hash(into: &hasher)
            hasCloseButton.hash(into: &hasher)
            dismissOnConfirm.hash(into: &hasher)
            dismissType.hash(into: &hasher)
        }
    }
}

public extension ConfirmationModal.Info {
    // MARK: - ButtonValidator
    
    class ButtonValidator: ExpressibleByBooleanLiteral {
        public typealias BooleanLiteralType = Bool
        
        /// Storage for the bool literal - should only ever access this via the `isValid` function which allows us to
        /// override the result for other validator types
        private let boolValue: Bool
        
        required public init(booleanLiteral value: BooleanLiteralType) {
            boolValue = value
        }
        
        func isValid(with info: ConfirmationModal.Info) -> Bool { boolValue }
    }
    
    /// The `AfterChangeValidator` will also return `false` for the initial validity check and will use the provided
    /// value for subsequent checks
    class AfterChangeValidator: ButtonValidator {
        private(set) var hasDoneInitialValidCheck: Bool = false
        let isValid: (ConfirmationModal.Info) -> Bool
        
        required public init(booleanLiteral value: BooleanLiteralType) {
            isValid = { _ in value }
            
            super.init(booleanLiteral: value)
        }
        
        public init(isValid: @escaping (ConfirmationModal.Info) -> Bool) {
            self.isValid = isValid
            
            /// Default this value to false (we won't use it directly anywhere
            super.init(booleanLiteral: false)
        }
        
        public override func isValid(with info: ConfirmationModal.Info) -> Bool {
            guard hasDoneInitialValidCheck else {
                hasDoneInitialValidCheck = true
                return false
            }
            
            return self.isValid(info)
        }
    }
        
    // MARK: - ShowCondition
    
    enum ShowCondition {
        case none
        case enabled
        case disabled
        
        public func shouldShow(for value: Bool) -> Bool {
            switch self {
                case .none: return true
                case .enabled: return (value == true)
                case .disabled: return (value == false)
            }
        }
    }
    
    // MARK: - Body
    
    enum Body: Equatable, Hashable {
        public struct InputInfo: Equatable, Hashable {
            public let placeholder: String
            public let initialValue: String?
            public let clearButton: Bool
            public let accessibility: Accessibility?
            
            public init(
                placeholder: String,
                initialValue: String? = nil,
                clearButton: Bool = false,
                accessibility: Accessibility? = nil
            ) {
                self.placeholder = placeholder
                self.initialValue = initialValue
                self.clearButton = clearButton
                self.accessibility = accessibility
            }
        }
        
        case none
        case text(
            _ text: String,
            scrollMode: ScrollableLabel.ScrollMode = .automatic
        )
        case attributedText(
            _ attributedText: NSAttributedString,
            scrollMode: ScrollableLabel.ScrollMode = .automatic
        )
        
        public static func == (lhs: ConfirmationModal.Info.Body, rhs: ConfirmationModal.Info.Body) -> Bool {
            switch (lhs, rhs) {
                case (.none, .none): return true
                case (.text(let lhsText, _), .text(let rhsText, _)): return (lhsText == rhsText)
                case (.attributedText(let lhsText, _), .attributedText(let rhsText, _)): return (lhsText == rhsText)
                default: return false
            }
        }
        
        public func hash(into hasher: inout Hasher) {
            switch self {
                case .none: break
                case .text(let text, _): text.hash(into: &hasher)
                case .attributedText(let text, _): text.hash(into: &hasher)
            }
        }
    }
}

// MARK: - DSL

public extension ConfirmationModal.Info.ButtonValidator {
    static func bool(_ isValid: Bool) -> ConfirmationModal.Info.ButtonValidator {
        return ConfirmationModal.Info.ButtonValidator(booleanLiteral: isValid)
    }
    
    static func afterChange(isValid: @escaping (ConfirmationModal.Info) -> Bool) -> ConfirmationModal.Info.AfterChangeValidator {
        return ConfirmationModal.Info.AfterChangeValidator(isValid: isValid)
    }
}
