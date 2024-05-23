// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatMessagingKit

final class OutgoingCallTableViewCell: UITableViewCell {
        
    weak var delegate: MessageCellDelegate?
    var thread: TSThread? {
        didSet {
            if viewItem != nil {
                update()
            }
        }
    }
    var viewItem: ConversationViewItem? {
        didSet {
            if thread != nil {
                update()
            }
        }
    }
    
    // MARK: - Identifier
    
    static var identifier: String = "OutgoingCallTableViewCell"
    
    // MARK: - Initialize
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpViewHierarchy()
        setUpGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpViewHierarchy()
        setUpGestureRecognizers()
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        
//        update()
//    }
    
    
    // MARK: - Properties
    
    private lazy var iconImageViewWidthConstraint = iconImageView.set(.width, to: 0)
    private lazy var iconImageViewHeightConstraint = iconImageView.set(.height, to: 0)
    
    private lazy var infoImageViewWidthConstraint = infoImageView.set(.width, to: 0)
    private lazy var infoImageViewHeightConstraint = infoImageView.set(.height, to: 0)
    
    private static let iconSize: CGFloat = 16
    private lazy var infoImageView = UIImageView(image: UIImage(named: "ic_info")?.withTint(Colors.text))
        
    // MARK: - UIElemnts
    
    /// Main Background View
    private lazy var mainContainerView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.bothGreenColor
        stackView.layer.cornerRadius = 22
        return stackView
    }()
    
    private lazy var containerView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.darkGreenColor
        stackView.layer.cornerRadius = 14
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.callCellTitle
        result.font = Fonts.boldOpenSans(ofSize: 11)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Voice call"
        return result
    }()
    
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.callCellTitle
        result.font = Fonts.OpenSans(ofSize: 10)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "No answer"
        return result
    }()
    
    private lazy var iconImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "call_outgoing")
        result.set(.width, to: 28)
        result.set(.height, to: 28)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    private lazy var timeLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.callCellTitle
        result.font = Fonts.OpenSans(ofSize: 9)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    // MARK: - UI setup
    
    /// SetUp View Hierarchy
    func setUpViewHierarchy() {
        
        backgroundColor = .clear
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = .clear
        self.selectedBackgroundView = selectedBackgroundView
        
        addSubview(mainContainerView)
        mainContainerView.addSubViews(containerView, timeLabel)
        containerView.addSubViews(iconImageView, titleLabel, discriptionLabel)
        
        discriptionLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            mainContainerView.widthAnchor.constraint(equalToConstant: 124),
            
            containerView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: 6),
            containerView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -6),
            containerView.topAnchor.constraint(equalTo: mainContainerView.topAnchor, constant: 6),
            containerView.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -6),
            containerView.widthAnchor.constraint(equalToConstant: 147),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 61),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            iconImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -7),
            
            timeLabel.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -16),
            timeLabel.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor, constant: -7),
        ])
    }
    
    /// Setup Gesture Recognizers
    func setUpGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Cell ui update
    
    /// Cell update
    func update() {
        guard let message = viewItem?.interaction as? TSInfoMessage, message.messageType == .call else { return }
        var icon: UIImage?
        if message.callState == .outgoing {
            mainContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14).isActive = true
            mainContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
            mainContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4).isActive = true
            mainContainerView.widthAnchor.constraint(equalToConstant: 124).isActive = true
            
            containerView.widthAnchor.constraint(equalToConstant: 112).isActive = true
            titleLabel.widthAnchor.constraint(equalToConstant: 21).isActive = true
            
            titleLabel.text = "Call"
            icon = UIImage(named: "call_outgoing")
        }
        
        iconImageView.image = icon
        iconImageViewWidthConstraint.constant = (icon != nil) ? OutgoingCallTableViewCell.iconSize : 0
        iconImageViewHeightConstraint.constant = (icon != nil) ? OutgoingCallTableViewCell.iconSize : 0
        
        let shouldShowInfoIcon = message.callState == .permissionDenied && !SSKPreferences.areCallsEnabled
        infoImageViewWidthConstraint.constant = shouldShowInfoIcon ? OutgoingCallTableViewCell.iconSize : 0
        infoImageViewHeightConstraint.constant = shouldShowInfoIcon ? OutgoingCallTableViewCell.iconSize : 0
        
        let date = message.dateForUI()
        let description = DateUtil.formatDate(forDisplay: date)
        timeLabel.text = description
    }
    
    /// Handle tap gesture
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let viewItem = viewItem, let message = viewItem.interaction as? TSInfoMessage, message.messageType == .call else { return }
        let shouldBeTappable = message.callState == .permissionDenied && !SSKPreferences.areCallsEnabled
        if shouldBeTappable {
            delegate?.handleViewItemTapped(viewItem, gestureRecognizer: gestureRecognizer)
        }
    }
}
