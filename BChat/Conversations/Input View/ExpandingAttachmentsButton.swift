import BChatUIKit

var bottomConstraintOfAttachmentButton: CGFloat = 4
final class ExpandingAttachmentsButton : UIView, InputViewButtonDelegate {
    
    private weak var delegate: ExpandingAttachmentsButtonDelegate?
    var isExpanded = false { didSet { expandOrCollapse() } }
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            shareContactButton.isUserInteractionEnabled = isUserInteractionEnabled
            gifButton.isUserInteractionEnabled = isUserInteractionEnabled
            documentButton.isUserInteractionEnabled = isUserInteractionEnabled
            libraryButton.isUserInteractionEnabled = isUserInteractionEnabled
            cameraButton.isUserInteractionEnabled = isUserInteractionEnabled
            mainButton.isUserInteractionEnabled = isUserInteractionEnabled
        }
    }
    
    private lazy var attachmentBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.attachmentViewBackgroundColor
        return stackView
    }()
    
    // MARK: - Constraints
    
    private lazy var shareContactButtonContainerBottomConstraint = shareContactButtonContainer.pin(.bottom, to: .bottom, of: self)
    private lazy var gifButtonContainerBottomConstraint = gifButtonContainer.pin(.bottom, to: .bottom, of: self)
    private lazy var documentButtonContainerBottomConstraint = documentButtonContainer.pin(.bottom, to: .bottom, of: self)
    private lazy var libraryButtonContainerBottomConstraint = libraryButtonContainer.pin(.bottom, to: .bottom, of: self)
    private lazy var cameraButtonContainerBottomConstraint = cameraButtonContainer.pin(.bottom, to: .bottom, of: self)
    
    // MARK: - UI Components
    
    lazy var shareContactButton: InputViewButton = {
        let result = InputViewButton(icon: #imageLiteral(resourceName: "share_contact"), delegate: self, hasOpaqueBackground: false, isAttachmentButton: true)
        result.tintColor = UIColor.white
        result.set(.width, to: 36)
        result.set(.height, to: 36)
        result.layer.cornerRadius = 18
        result.accessibilityLabel = NSLocalizedString("accessibility_share_contact_button", comment: "")
        return result
    }()
    lazy var shareContactButtonContainer = container(for: shareContactButton)
    
    lazy var gifButton: InputViewButton = {
        let result = InputViewButton(icon: #imageLiteral(resourceName: "ic_gif"), delegate: self, hasOpaqueBackground: false, isAttachmentButton: true)
        result.tintColor = UIColor.white
        result.set(.width, to: 36)
        result.set(.height, to: 36)
        result.layer.cornerRadius = 18
        result.accessibilityLabel = NSLocalizedString("accessibility_gif_button", comment: "")
        return result
    }()
    lazy var gifButtonContainer = container(for: gifButton)
    
    lazy var documentButton: InputViewButton = {
        let result = InputViewButton(icon: #imageLiteral(resourceName: "ic_doc_new"), delegate: self, hasOpaqueBackground: false, isAttachmentButton: true)
        result.tintColor = UIColor.white
        result.set(.width, to: 36)
        result.set(.height, to: 36)
        result.layer.cornerRadius = 18
        result.accessibilityLabel = NSLocalizedString("accessibility_document_button", comment: "")
        return result
    }()
    lazy var documentButtonContainer = container(for: documentButton)
    
    lazy var libraryButton: InputViewButton = {
        let result = InputViewButton(icon: #imageLiteral(resourceName: "ic_lib_new"), delegate: self, hasOpaqueBackground: false, isAttachmentButton: true)
        result.set(.width, to: 36)
        result.set(.height, to: 36)
        result.layer.cornerRadius = 18
        result.accessibilityLabel = NSLocalizedString("accessibility_library_button", comment: "")
        return result
    }()
    lazy var libraryButtonContainer = container(for: libraryButton)
    
    lazy var cameraButton: InputViewButton = {
        let result = InputViewButton(icon: #imageLiteral(resourceName: "ic_camera_new"), delegate: self, hasOpaqueBackground: false, isAttachmentButton: true)
        result.set(.width, to: 36)
        result.set(.height, to: 36)
        result.layer.cornerRadius = 18
        result.accessibilityLabel = NSLocalizedString("accessibility_camera_button", comment: "")
        return result
    }()
    lazy var cameraButtonContainer = container(for: cameraButton)
    
    lazy var mainButton: InputViewButton = {
        let result = InputViewButton(icon: #imageLiteral(resourceName: "ic_attachment_new"), delegate: self)
        result.accessibilityLabel = NSLocalizedString("accessibility_expanding_attachments_button", comment: "")
        return result
    }()
    lazy var mainButtonContainer = container(for: mainButton)
    
    // MARK: Lifecycle
    init(delegate: ExpandingAttachmentsButtonDelegate?) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        setUpViewHierarchy()
    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(delegate:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(delegate:) instead.")
    }
    
    func setUpViewHierarchy() {
        
        backgroundColor = .clear
        
        cameraButton.backgroundColor = Colors.holdViewbackgroundColor
        documentButton.backgroundColor = Colors.holdViewbackgroundColor
        libraryButton.backgroundColor = Colors.holdViewbackgroundColor
        gifButton.backgroundColor = Colors.holdViewbackgroundColor
        shareContactButton.backgroundColor = Colors.holdViewbackgroundColor
        
        // Share Contact button
        addSubview(shareContactButtonContainer)
        shareContactButtonContainer.alpha = 0
        
        // gif button
        addSubview(gifButtonContainer)
        gifButtonContainer.alpha = 0
        
        // Document button
        addSubview(documentButtonContainer)
        documentButtonContainer.alpha = 0
        
        // Library button
        addSubview(libraryButtonContainer)
        libraryButtonContainer.alpha = 0
        
        // Camera button
        addSubview(cameraButtonContainer)
        cameraButtonContainer.alpha = 0
        
        // Main button
        addSubview(mainButtonContainer)
        
        // Constraints
        mainButtonContainer.pin(to: self)
        
        NSLayoutConstraint.activate([
            libraryButtonContainer.centerYAnchor.constraint(equalTo: cameraButtonContainer.centerYAnchor),
            libraryButtonContainer.leadingAnchor.constraint(equalTo: cameraButtonContainer.trailingAnchor),
            documentButtonContainer.centerYAnchor.constraint(equalTo: libraryButtonContainer.centerYAnchor),
            documentButtonContainer.leadingAnchor.constraint(equalTo: libraryButtonContainer.trailingAnchor),
            gifButtonContainer.centerYAnchor.constraint(equalTo: documentButtonContainer.centerYAnchor),
            gifButtonContainer.leadingAnchor.constraint(equalTo: documentButtonContainer.trailingAnchor),
            shareContactButtonContainer.centerYAnchor.constraint(equalTo: gifButtonContainer.centerYAnchor),
            shareContactButtonContainer.leadingAnchor.constraint(equalTo: gifButtonContainer.trailingAnchor)
        ])
        [ shareContactButtonContainerBottomConstraint, gifButtonContainerBottomConstraint, documentButtonContainerBottomConstraint, libraryButtonContainerBottomConstraint, cameraButtonContainerBottomConstraint].forEach {
            $0.isActive = true
        }
        
        mainButton.accessibilityLabel = NSLocalizedString("accessibility_main_button_collapse", comment: "")
        let expandedButtonSize = InputViewButton.expandedSize
        let spacing: CGFloat = bottomConstraintOfAttachmentButton
        cameraButtonContainerBottomConstraint.constant = -1 * (expandedButtonSize + spacing)
        libraryButtonContainerBottomConstraint.constant = -1 * (expandedButtonSize + spacing)
        documentButtonContainerBottomConstraint.constant = -1 * (expandedButtonSize + spacing)
        libraryButtonContainerBottomConstraint.constant = -1 * (expandedButtonSize + spacing)
        gifButtonContainerBottomConstraint.constant = -1 * (expandedButtonSize + spacing)
        shareContactButtonContainerBottomConstraint.constant = -1 * (expandedButtonSize + spacing)
        UIView.animate(withDuration: 0.25) {
            [ self.shareContactButtonContainer, self.gifButtonContainer, self.documentButtonContainer, self.libraryButtonContainer, self.cameraButtonContainer ].forEach {
                $0.alpha = 0
            }
            self.layoutIfNeeded()
        }
        
        // Add attachment background view to each button container
        let documentBackgroundView = UIView()
        documentBackgroundView.backgroundColor = attachmentBackgroundView.backgroundColor
        documentBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        documentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        documentButtonContainer.addSubview(documentBackgroundView)
        NSLayoutConstraint.activate([
            documentBackgroundView.topAnchor.constraint(equalTo: documentButtonContainer.topAnchor),
            documentBackgroundView.leadingAnchor.constraint(equalTo: documentButtonContainer.leadingAnchor),
            documentBackgroundView.trailingAnchor.constraint(equalTo: documentButtonContainer.trailingAnchor),
            documentBackgroundView.bottomAnchor.constraint(equalTo: documentButtonContainer.bottomAnchor)
        ])
        documentButtonContainer.sendSubviewToBack(documentBackgroundView)
        
        let libraryBackgroundView = UIView()
        libraryBackgroundView.backgroundColor = attachmentBackgroundView.backgroundColor
        libraryBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        libraryButtonContainer.addSubview(libraryBackgroundView)
        NSLayoutConstraint.activate([
            libraryBackgroundView.topAnchor.constraint(equalTo: libraryButtonContainer.topAnchor),
            libraryBackgroundView.leadingAnchor.constraint(equalTo: libraryButtonContainer.leadingAnchor),
            libraryBackgroundView.trailingAnchor.constraint(equalTo: libraryButtonContainer.trailingAnchor),
            libraryBackgroundView.bottomAnchor.constraint(equalTo: libraryButtonContainer.bottomAnchor)
        ])
        libraryButtonContainer.sendSubviewToBack(libraryBackgroundView)
        
        let cameraBackgroundView = UIView()
        cameraBackgroundView.backgroundColor = attachmentBackgroundView.backgroundColor
        cameraBackgroundView.layer.cornerRadius = 22
        cameraBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        cameraBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        cameraButtonContainer.addSubview(cameraBackgroundView)
        NSLayoutConstraint.activate([
            cameraBackgroundView.topAnchor.constraint(equalTo: cameraButtonContainer.topAnchor),
            cameraBackgroundView.leadingAnchor.constraint(equalTo: cameraButtonContainer.leadingAnchor),
            cameraBackgroundView.trailingAnchor.constraint(equalTo: cameraButtonContainer.trailingAnchor),
            cameraBackgroundView.bottomAnchor.constraint(equalTo: cameraButtonContainer.bottomAnchor)
        ])
        cameraButtonContainer.sendSubviewToBack(cameraBackgroundView)
        // Ensure equal width and equal height for all background views
//        NSLayoutConstraint.activate([
//            documentBackgroundView.widthAnchor.constraint(equalTo: libraryBackgroundView.widthAnchor),
//            libraryBackgroundView.widthAnchor.constraint(equalTo: cameraBackgroundView.widthAnchor),
//            documentBackgroundView.heightAnchor.constraint(equalTo: libraryBackgroundView.heightAnchor),
//            libraryBackgroundView.heightAnchor.constraint(equalTo: cameraBackgroundView.heightAnchor)
//        ])
        
        let gifBackgroundView = UIView()
        gifBackgroundView.backgroundColor = attachmentBackgroundView.backgroundColor
        gifBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        gifBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        gifButtonContainer.addSubview(gifBackgroundView)
        NSLayoutConstraint.activate([
            gifBackgroundView.topAnchor.constraint(equalTo: gifButtonContainer.topAnchor),
            gifBackgroundView.leadingAnchor.constraint(equalTo: gifButtonContainer.leadingAnchor),
            gifBackgroundView.trailingAnchor.constraint(equalTo: gifButtonContainer.trailingAnchor),
            gifBackgroundView.bottomAnchor.constraint(equalTo: gifButtonContainer.bottomAnchor)
        ])
        gifButtonContainer.sendSubviewToBack(gifBackgroundView)
        
        let shareContactBackgroundView = UIView()
        shareContactBackgroundView.backgroundColor = attachmentBackgroundView.backgroundColor
        shareContactBackgroundView.layer.cornerRadius = 22
        shareContactBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        shareContactBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        shareContactButtonContainer.addSubview(shareContactBackgroundView)
        NSLayoutConstraint.activate([
            shareContactBackgroundView.topAnchor.constraint(equalTo: shareContactButtonContainer.topAnchor),
            shareContactBackgroundView.leadingAnchor.constraint(equalTo: shareContactButtonContainer.leadingAnchor),
            shareContactBackgroundView.trailingAnchor.constraint(equalTo: shareContactButtonContainer.trailingAnchor),
            shareContactBackgroundView.bottomAnchor.constraint(equalTo: shareContactButtonContainer.bottomAnchor)
        ])
        shareContactButtonContainer.sendSubviewToBack(shareContactBackgroundView)
        
        // Set the constraints for buttons inside containers
        [shareContactButton, gifButton, documentButton, libraryButton, cameraButton].forEach { button in
            button.set(.width, to: InputViewButton.expandedSize)
            button.set(.height, to: InputViewButton.expandedSize)
            button.center(in: button.superview!)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(attachmentHiddenTapped), name: .attachmentHiddenNotification, object: nil)
    }
    
    // hide the Attachment
    @objc func attachmentHiddenTapped(notification: NSNotification) {
        hideAttachment()
    }
    
    func hideAttachment() {
        mainButton.accessibilityLabel = NSLocalizedString("accessibility_expanding_attachments_button", comment: "")
        [ shareContactButtonContainerBottomConstraint, gifButtonContainerBottomConstraint, documentButtonContainerBottomConstraint, libraryButtonContainerBottomConstraint, cameraButtonContainerBottomConstraint ].forEach {
            $0.constant = 0
        }
        UIView.animate(withDuration: 0.25) {
            [ self.shareContactButton, self.gifButtonContainer, self.documentButtonContainer, self.libraryButtonContainer, self.cameraButtonContainer ].forEach {
                $0.alpha = 0
            }
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Animation
    
    private func expandOrCollapse() {
        if isExpanded {
            let isFromExpandedValue = CustomSlideView.isFromExpandAttachment ? -2.2 : -1
            
            mainButton.accessibilityLabel = NSLocalizedString("accessibility_main_button_collapse", comment: "")
            let expandedButtonSize = InputViewButton.expandedSize
            let spacing: CGFloat = bottomConstraintOfAttachmentButton
            cameraButtonContainerBottomConstraint.constant = isFromExpandedValue * (expandedButtonSize + spacing)
            libraryButtonContainerBottomConstraint.constant = isFromExpandedValue * (expandedButtonSize + spacing)
            documentButtonContainerBottomConstraint.constant = isFromExpandedValue * (expandedButtonSize + spacing)
            gifButtonContainerBottomConstraint.constant = isFromExpandedValue * (expandedButtonSize + spacing)
            shareContactButtonContainerBottomConstraint.constant = isFromExpandedValue * (expandedButtonSize + spacing)
            UIView.animate(withDuration: 0.25) {
                [ self.documentButtonContainer, self.libraryButtonContainer, self.cameraButtonContainer, self.gifButtonContainer, self.shareContactButtonContainer ].forEach {
                    $0.alpha = 1
                }
                self.layoutIfNeeded()
            }
        } else {
            hideAttachment()
        }
    }
    
    // MARK: - Interaction
    
    func handleInputViewButtonTapped(_ inputViewButton: InputViewButton) {
        if isExpanded {
            if inputViewButton == documentButton { delegate?.handleDocumentButtonTapped(); isExpanded = false }
            if inputViewButton == libraryButton { delegate?.handleLibraryButtonTapped(); isExpanded = false }
            if inputViewButton == cameraButton { delegate?.handleCameraButtonTapped(); isExpanded = false }
            if inputViewButton == gifButton { delegate?.handleGIFButtonTapped(); isExpanded = false }
            if inputViewButton == shareContactButton { delegate?.handleShareContactButtonTapped(); isExpanded = false }
        }
        if inputViewButton == mainButton { isExpanded = !isExpanded }
    }
    
    // MARK: - Convenience
    
    private func container(for button: InputViewButton) -> UIView {
        let result = UIView()
        result.addSubview(button)
        result.set(.width, to: InputViewButton.expandedSize)
        result.set(.height, to: InputViewButton.expandedSize)
        button.center(in: result)
        return result
    }
}

// MARK: - Delegate

protocol ExpandingAttachmentsButtonDelegate: AnyObject {
    func handleShareContactButtonTapped()
    func handleGIFButtonTapped()
    func handleDocumentButtonTapped()
    func handleLibraryButtonTapped()
    func handleCameraButtonTapped()
}
