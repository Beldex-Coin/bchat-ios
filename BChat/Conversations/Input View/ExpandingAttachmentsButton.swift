import BChatUIKit

final class ExpandingAttachmentsButton : UIView, InputViewButtonDelegate {
    private weak var delegate: ExpandingAttachmentsButtonDelegate?
    private var isExpanded = false { didSet { expandOrCollapse() } }
    
    override var isUserInteractionEnabled: Bool {
        didSet {
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
    // MARK: Constraints
    private lazy var documentButtonContainerBottomConstraint = documentButtonContainer.pin(.bottom, to: .bottom, of: self)
    private lazy var libraryButtonContainerBottomConstraint = libraryButtonContainer.pin(.bottom, to: .bottom, of: self)
    private lazy var cameraButtonContainerBottomConstraint = cameraButtonContainer.pin(.bottom, to: .bottom, of: self)
    // MARK: UI Components
    lazy var documentButton: InputViewButton = {
        let result = InputViewButton(icon: #imageLiteral(resourceName: "ic_doc_new"), delegate: self, hasOpaqueBackground: false)
        result.tintColor = UIColor.white
        result.accessibilityLabel = NSLocalizedString("accessibility_document_button", comment: "")
        return result
    }()
    lazy var documentButtonContainer = container(for: documentButton)
    lazy var libraryButton: InputViewButton = {
        let result = InputViewButton(icon: #imageLiteral(resourceName: "ic_lib_new"), delegate: self, hasOpaqueBackground: false)
        result.accessibilityLabel = NSLocalizedString("accessibility_library_button", comment: "")
        return result
    }()
    lazy var libraryButtonContainer = container(for: libraryButton)
    lazy var cameraButton: InputViewButton = {
        let result = InputViewButton(icon: #imageLiteral(resourceName: "ic_camera_new"), delegate: self, hasOpaqueBackground: false)
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
    
    private func setUpViewHierarchy() {
        documentButton.backgroundColor = Colors.bchatButtonColor
        libraryButton.backgroundColor = Colors.bchatButtonColor
        cameraButton.backgroundColor = Colors.bchatButtonColor
        
        cameraButton.backgroundColor = Colors.newChatbackgroundColor
        documentButton.backgroundColor = Colors.newChatbackgroundColor
        libraryButton.backgroundColor = Colors.newChatbackgroundColor
        
        backgroundColor = .clear
        
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
        ])
        //        documentButtonContainer.center(.horizontal, in: self)
        //        libraryButtonContainer.center(.horizontal, in: self)
        //        cameraButtonContainer.center(.horizontal, in: self)
        [ documentButtonContainerBottomConstraint, libraryButtonContainerBottomConstraint, cameraButtonContainerBottomConstraint ].forEach {
            $0.isActive = true
        }
        
        mainButton.accessibilityLabel = NSLocalizedString("accessibility_main_button_collapse", comment: "")
        let expandedButtonSize = InputViewButton.expandedSize//InputViewButton.expandedSize
        let spacing: CGFloat = 4
        cameraButtonContainerBottomConstraint.constant = -1 * (expandedButtonSize + spacing)
        libraryButtonContainerBottomConstraint.constant = -1 * (expandedButtonSize + spacing)
        documentButtonContainerBottomConstraint.constant = -1 * (expandedButtonSize + spacing)
        UIView.animate(withDuration: 0.25) {
            [ self.documentButtonContainer, self.libraryButtonContainer, self.cameraButtonContainer ].forEach {
                $0.alpha = 0
            }
            self.layoutIfNeeded()
        }
        
        // Add attachment background view to each button container
        let documentAttachmentBackgroundView = UIView()
        documentAttachmentBackgroundView.backgroundColor = attachmentBackgroundView.backgroundColor // Copy background color if needed
        documentAttachmentBackgroundView.layer.cornerRadius = 22
        documentAttachmentBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        documentAttachmentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        documentButtonContainer.addSubview(documentAttachmentBackgroundView)
        NSLayoutConstraint.activate([
            documentAttachmentBackgroundView.topAnchor.constraint(equalTo: documentButtonContainer.topAnchor),
            documentAttachmentBackgroundView.leadingAnchor.constraint(equalTo: documentButtonContainer.leadingAnchor),
            documentAttachmentBackgroundView.trailingAnchor.constraint(equalTo: documentButtonContainer.trailingAnchor),
            documentAttachmentBackgroundView.bottomAnchor.constraint(equalTo: documentButtonContainer.bottomAnchor)
        ])
        documentButtonContainer.sendSubviewToBack(documentAttachmentBackgroundView)
        let libraryAttachmentBackgroundView = UIView()
        libraryAttachmentBackgroundView.backgroundColor = attachmentBackgroundView.backgroundColor // Copy background color if needed
        libraryAttachmentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        libraryButtonContainer.addSubview(libraryAttachmentBackgroundView)
        NSLayoutConstraint.activate([
            libraryAttachmentBackgroundView.topAnchor.constraint(equalTo: libraryButtonContainer.topAnchor),
            libraryAttachmentBackgroundView.leadingAnchor.constraint(equalTo: libraryButtonContainer.leadingAnchor),
            libraryAttachmentBackgroundView.trailingAnchor.constraint(equalTo: libraryButtonContainer.trailingAnchor),
            libraryAttachmentBackgroundView.bottomAnchor.constraint(equalTo: libraryButtonContainer.bottomAnchor)
        ])
        libraryButtonContainer.sendSubviewToBack(libraryAttachmentBackgroundView)
        let cameraAttachmentBackgroundView = UIView()
        cameraAttachmentBackgroundView.backgroundColor = attachmentBackgroundView.backgroundColor // Copy background color if needed
        cameraAttachmentBackgroundView.layer.cornerRadius = 22
        cameraAttachmentBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        cameraAttachmentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        cameraButtonContainer.addSubview(cameraAttachmentBackgroundView)
        NSLayoutConstraint.activate([
            cameraAttachmentBackgroundView.topAnchor.constraint(equalTo: cameraButtonContainer.topAnchor),
            cameraAttachmentBackgroundView.leadingAnchor.constraint(equalTo: cameraButtonContainer.leadingAnchor),
            cameraAttachmentBackgroundView.trailingAnchor.constraint(equalTo: cameraButtonContainer.trailingAnchor),
            cameraAttachmentBackgroundView.bottomAnchor.constraint(equalTo: cameraButtonContainer.bottomAnchor)
        ])
        cameraButtonContainer.sendSubviewToBack(cameraAttachmentBackgroundView)
        // Ensure equal width and equal height for all background views
        NSLayoutConstraint.activate([
            documentAttachmentBackgroundView.widthAnchor.constraint(equalTo: libraryAttachmentBackgroundView.widthAnchor),
            libraryAttachmentBackgroundView.widthAnchor.constraint(equalTo: cameraAttachmentBackgroundView.widthAnchor),
            documentAttachmentBackgroundView.heightAnchor.constraint(equalTo: libraryAttachmentBackgroundView.heightAnchor),
            libraryAttachmentBackgroundView.heightAnchor.constraint(equalTo: cameraAttachmentBackgroundView.heightAnchor)
        ])
        // Set the constraints for buttons inside containers
        [documentButton, libraryButton, cameraButton].forEach { button in
            button.set(.width, to: InputViewButton.expandedSize)
            button.set(.height, to: InputViewButton.expandedSize)
            button.center(in: button.superview!)
        }
        
    }
    
    // MARK: Animation
    private func expandOrCollapse() {
        if isExpanded {
            mainButton.accessibilityLabel = NSLocalizedString("accessibility_main_button_collapse", comment: "")
            let expandedButtonSize = InputViewButton.expandedSize//InputViewButton.expandedSize
            let spacing: CGFloat = 4
            cameraButtonContainerBottomConstraint.constant = -1 * (expandedButtonSize + spacing)
            libraryButtonContainerBottomConstraint.constant = -1 * (expandedButtonSize + spacing)
            documentButtonContainerBottomConstraint.constant = -1 * (expandedButtonSize + spacing)
            UIView.animate(withDuration: 0.25) {
                [ self.documentButtonContainer, self.libraryButtonContainer, self.cameraButtonContainer ].forEach {
                    $0.alpha = 1
                }
                self.layoutIfNeeded()
            }
        } else {
            mainButton.accessibilityLabel = NSLocalizedString("accessibility_expanding_attachments_button", comment: "")
            [ documentButtonContainerBottomConstraint, libraryButtonContainerBottomConstraint, cameraButtonContainerBottomConstraint ].forEach {
                $0.constant = 0
            }
            UIView.animate(withDuration: 0.25) {
                [ self.documentButtonContainer, self.libraryButtonContainer, self.cameraButtonContainer ].forEach {
                    $0.alpha = 0
                }
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: Interaction
    func handleInputViewButtonTapped(_ inputViewButton: InputViewButton) {
        if inputViewButton == documentButton { delegate?.handleDocumentButtonTapped(); isExpanded = false }
        if inputViewButton == libraryButton { delegate?.handleLibraryButtonTapped(); isExpanded = false }
        if inputViewButton == cameraButton { delegate?.handleCameraButtonTapped(); isExpanded = false }
        if inputViewButton == mainButton { isExpanded = !isExpanded }
    }
    
    // MARK: Convenience
    private func container(for button: InputViewButton) -> UIView {
        let result = UIView()
        result.addSubview(button)
        result.set(.width, to: InputViewButton.expandedSize)
        result.set(.height, to: InputViewButton.expandedSize)
        button.center(in: result)
        return result
    }
}

// MARK: Delegate

protocol ExpandingAttachmentsButtonDelegate: AnyObject {
    func handleGIFButtonTapped()
    func handleDocumentButtonTapped()
    func handleLibraryButtonTapped()
    func handleCameraButtonTapped()
}
