// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation
import BChatUIKit

class EmojiPickerSheet: BaseVC {
    let completionHandler: (EmojiWithSkinTones?) -> Void
    // MARK: Components
    
    private lazy var bottomConstraint: NSLayoutConstraint = contentView.pin(.bottom, to: .bottom, of: view)
    
    private lazy var contentView: UIView = {
        let result = UIView()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .darkGray
        backgroundView.alpha = Values.lowOpacity
        result.addSubview(backgroundView)
        backgroundView.pin(to: result)

        let blurView: UIVisualEffectView = UIVisualEffectView()
        result.addSubview(blurView)
        blurView.pin(to: result)
        
        let line = UIView()
        line.backgroundColor = .darkGray
        result.addSubview(line)
        line.set(.height, to: Values.separatorThickness)
        line.pin([ UIView.HorizontalEdge.leading, UIView.HorizontalEdge.trailing, UIView.VerticalEdge.top ], to: result)
        
        return result
    }()

    private let collectionView = EmojiPickerCollectionView()

    private lazy var searchBar: SearchBar = {
        let result = SearchBar()
        result.tintColor = Colors.titleColor
        if UIScreen.main.traitCollection.userInterfaceStyle == .light && !isLightMode {
            result.tintColor = Colors.callCellTitle
        }
        if UIScreen.main.traitCollection.userInterfaceStyle == .dark && isLightMode {
            result.tintColor = Colors.darkThemeTextBoxColor
        }
        result.backgroundColor = isLightMode ? .white : .black
        result.delegate = self
        
        return result
    }()
    private let dismiss: () -> Void

    // MARK: - Initialization

    init(completionHandler: @escaping (EmojiWithSkinTones?) -> Void, dismiss: @escaping () -> Void) {
        self.completionHandler = completionHandler
        self.dismiss = dismiss
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
    }

    public required init() {
        fatalError("init() has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        setUpViewHierarchy()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShowNotification(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHideNotification(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func setUpViewHierarchy() {
        view.addSubview(contentView)
        
        contentView.pin(.leading, to: .leading, of: view)
        contentView.pin(.trailing, to: .trailing, of: view)
        contentView.set(.height, to: 350)
        bottomConstraint.isActive = true
        
        let topStackView = UIStackView()
        topStackView.axis = .horizontal
        topStackView.isLayoutMarginsRelativeArrangement = true
        topStackView.spacing = 8
        contentView.addSubview(topStackView)
        topStackView.set(.width, to: .width, of: contentView)
        topStackView.pin(.top, to: .top, of: contentView)
        
        topStackView.addArrangedSubview(searchBar)

        contentView.addSubview(collectionView)
        collectionView.pin(.top, to: .bottom, of: searchBar)
        collectionView.pin(.bottom, to: .bottom, of: contentView)
        collectionView.set(.width, to: .width, of: contentView)
        collectionView.pickerDelegate = self
        collectionView.alwaysBounceVertical = true
        
        searchBar.resignFirstResponder()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.reloadData()
        }, completion: nil)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Ensure the scrollView's layout has completed
        // as we're about to use its bounds to calculate
        // the masking view and contentOffset.
        contentView.layoutIfNeeded()
    }
    
    // MARK: - Keyboard Avoidance
    
    @objc func handleKeyboardWillShowNotification(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            // Only move view if it's not already moved
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardFrame.height // tweak this if too much/little
            }
        }
    }

    @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
        self.view.frame.origin.y = 0
    }
    
    // MARK: Interaction
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let touch: UITouch = touches.first,
            contentView.frame.contains(touch.location(in: view))
        else {
            close()
            return
        }
        
        super.touchesBegan(touches, with: event)
    }

    @objc func close() {
        NotificationCenter.default.post(name: .hideOrShowInputViewNotification, object: nil)
        self.dismiss()
    }
}

extension EmojiPickerSheet: EmojiPickerCollectionViewDelegate {
    func emojiPickerWillBeginDragging(_ emojiPicker: EmojiPickerCollectionView) {
        searchBar.resignFirstResponder()
    }
    
    func emojiPicker(_ emojiPicker: EmojiPickerCollectionView?, didSelectEmoji emoji: EmojiWithSkinTones) {
        completionHandler(emoji)
        NotificationCenter.default.post(name: .hideOrShowInputViewNotification, object: nil)
        self.dismiss()
    }
}

extension EmojiPickerSheet: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        collectionView.searchText = searchText
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        close()
    }
}
