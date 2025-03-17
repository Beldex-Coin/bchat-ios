import UIKit
import Foundation

final class ContextMenuVC : UIViewController {
    private let snapshot: UIView
    private let viewItem: ConversationViewItem
    private let frame: CGRect
    private let dismiss: () -> Void
    private weak var delegate: ContextMenuActionDelegate?
    
    private var recentEmoji: [EmojiWithSkinTones] = []

    // MARK: UI Components
    private lazy var blurView = UIVisualEffectView(effect: nil)

    private lazy var menuView: UIView = {
        let result = UIView()
        result.layer.shadowColor = UIColor.black.cgColor
        result.layer.shadowOffset = CGSize.zero
        result.layer.shadowOpacity = 0.4
        result.layer.shadowRadius = 4
        return result
    }()
    
    private lazy var timestampLabel: UILabel = {
        let result = UILabel()
        let date = viewItem.interaction.dateForUI()
        result.text = DateUtil.formatDate(forDisplay: date)
        result.font = .systemFont(ofSize: Values.verySmallFontSize)
        result.textColor = isLightMode ? .black : .white
        return result
    }()
    
    private lazy var emojiBarView: UIView = {
            let result = UIView()
            result.layer.shadowColor = UIColor.black.cgColor
            result.layer.shadowOffset = CGSize.zero
            result.layer.shadowOpacity = 0.4
            result.layer.shadowRadius = 4
            result.backgroundColor = isLightMode ? UIColor(hex: 0xF8F8F8) : UIColor(hex: 0x2C2C3B)
            result.layer.cornerRadius = 20
            return result
        }()
        
    private let emojiPlusButton: UIButton = {
        let result = UIButton()
            result.translatesAutoresizingMaskIntoConstraints = false
            result.layer.masksToBounds = true
            result.layer.cornerRadius = 20
            let image = UIImage(named: "more_reactions")?.withRenderingMode(.alwaysTemplate)
            result.setImage(image, for: .normal)
            result.addTarget(self, action: #selector(addEmojiButtonTapped), for: .touchUpInside)
            return result
        }()
    
    // MARK: Settings
    private static let actionViewHeight: CGFloat = 40
    private static let menuCornerRadius: CGFloat = 8

    // MARK: Lifecycle
    init(snapshot: UIView, viewItem: ConversationViewItem, frame: CGRect, delegate: ContextMenuActionDelegate, dismiss: @escaping () -> Void) {
        self.snapshot = snapshot
        self.viewItem = viewItem
        self.frame = frame
        self.delegate = delegate
        self.dismiss = dismiss
        super.init(nibName: nil, bundle: nil)
        
        Storage.read { transaction in
            self.recentEmoji = Array(Storage.shared.getRecentEmoji(withDefaultEmoji: true, transaction: transaction))
            //Array(Storage.shared.getRecentEmoji(withDefaultEmoji: true, transaction: transaction)[...5])
            //??????????
        }
    }

    override init(nibName: String?, bundle: Bundle?) {
        preconditionFailure("Use init(snapshot:) instead.")
    }

    required init?(coder: NSCoder) {
        preconditionFailure("Use init(coder:) instead.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Background color
        view.backgroundColor = .clear
        // Blur
        view.addSubview(blurView)
        blurView.pin(to: view)
        
        // Emoji view
        view.addSubview(emojiBarView)
        
        // Snapshot
        snapshot.layer.shadowColor = UIColor.black.cgColor
        snapshot.layer.shadowOffset = CGSize.zero
        snapshot.layer.shadowOpacity = 0.4
        snapshot.layer.shadowRadius = 4
        view.addSubview(snapshot)
        snapshot.pin(.left, to: .left, of: view, withInset: frame.origin.x)
        snapshot.pin(.top, to: .top, of: view, withInset: frame.origin.y)
        snapshot.set(.width, to: frame.width)
        snapshot.set(.height, to: frame.height)
        // Timestamp
        view.addSubview(timestampLabel)
        timestampLabel.center(.vertical, in: snapshot)
        let isOutgoing = (viewItem.interaction.interactionType() == .outgoingMessage)
        if isOutgoing {
            timestampLabel.pin(.right, to: .left, of: snapshot, withInset: -Values.smallSpacing)
        } else {
            timestampLabel.pin(.left, to: .right, of: snapshot, withInset: Values.smallSpacing)
        }
        // Menu
        let menuBackgroundView = UIView()
        menuBackgroundView.backgroundColor = UIColor(hex: 0x2C2C3B)//Colors.receivedMessageBackground
        menuBackgroundView.layer.cornerRadius = ContextMenuVC.menuCornerRadius
        menuBackgroundView.layer.masksToBounds = true
        menuView.addSubview(menuBackgroundView)
        menuBackgroundView.pin(to: menuView)
        let actionViews = ContextMenuVC.actions(for: viewItem, delegate: delegate).map { ActionView(for: $0, dismiss: snDismiss) }
        let menuStackView = UIStackView(arrangedSubviews: actionViews)
        menuStackView.axis = .vertical
        menuView.addSubview(menuStackView)
        menuStackView.pin(to: menuView)
        view.addSubview(menuView)
        let menuHeight = CGFloat(actionViews.count) * ContextMenuVC.actionViewHeight
        let spacing = Values.smallSpacing
        let margin = max(UIApplication.shared.keyWindow!.safeAreaInsets.bottom, Values.mediumSpacing)
        if frame.maxY + spacing + menuHeight > UIScreen.main.bounds.height - margin {
            menuView.pin(.bottom, to: .top, of: snapshot, withInset: -spacing)
            emojiBarView.pin(.top, to: .bottom, of: snapshot, withInset: spacing)
        } else {
            menuView.pin(.top, to: .bottom, of: snapshot, withInset: spacing)
            emojiBarView.pin(.bottom, to: .top, of: snapshot, withInset: -spacing)
        }
        switch viewItem.interaction.interactionType() {
            case .outgoingMessage:
                menuView.pin(.right, to: .right, of: snapshot)
                emojiBarView.pin(.right, to: .right, of: snapshot)
            case .incomingMessage:
                menuView.pin(.left, to: .left, of: snapshot)
                emojiBarView.pin(.left, to: .left, of: snapshot)
            default: break // Should never occur
        }
        
        // Tap gesture
        let mainTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(mainTapGestureRecognizer)
        
        emojiBarView.set(.width, to: 220)
        emojiBarView.set(.height, to: 40)
        
        emojiPlusButton.set(.width, to: 40)
        emojiPlusButton.set(.height, to: 40)
        emojiBarView.addSubview(emojiPlusButton)
        emojiPlusButton.pin(.right, to: .right, of: emojiBarView)
        
        let emojiLabels = recentEmoji.map { emoji -> EmojiReactsView in
            EmojiReactsView(for: emoji, dismiss: snDismiss) {
                self.delegate?.react(self.viewItem, with: emoji)
            }
        }
        
        let emojiBarStackView = UIStackView(arrangedSubviews: emojiLabels)
        emojiBarStackView.axis = .horizontal
        emojiBarStackView.spacing = Values.smallSpacing
        emojiBarStackView.layoutMargins = UIEdgeInsets(top: 0, left: Values.smallSpacing, bottom: 0, right: Values.smallSpacing)
        emojiBarStackView.isLayoutMarginsRelativeArrangement = true
        emojiBarView.addSubview(emojiBarStackView)
        emojiBarStackView.pin([ UIView.HorizontalEdge.left, UIView.VerticalEdge.top, UIView.VerticalEdge.bottom ], to: emojiBarView)
        emojiBarStackView.pin(.right, to: .left, of: emojiPlusButton)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) {
            self.blurView.effect = UIBlurEffect(style: .regular)
            self.menuView.alpha = 1
        }
    }

    // MARK: Updating
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuView.layer.shadowPath = UIBezierPath(roundedRect: menuView.bounds, cornerRadius: ContextMenuVC.menuCornerRadius).cgPath
        emojiBarView.layer.shadowPath = UIBezierPath(roundedRect: emojiBarView.bounds, cornerRadius: (ContextMenuVC.actionViewHeight / 2)).cgPath
    }

    // MARK: Interaction
    @objc private func handleTap() {
        snDismiss()
    }
    
    func snDismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurView.effect = nil
            self.menuView.alpha = 0
            self.timestampLabel.alpha = 0
        }, completion: { _ in
            self.dismiss()
            self.delegate?.contextMenuDismissed()
        })
    }
    
    @objc
    private func addEmojiButtonTapped() {
        snDismiss()
        delegate?.showFullEmojiKeyboard(viewItem)
    }
}
