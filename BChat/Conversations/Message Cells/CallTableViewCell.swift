// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatMessagingKit

final class CallTableViewCell: UITableViewCell {
    
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
    
    static var identifier: String = "CallTableViewCell"
    
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
        result.textColor = Colors.noDataLabelColor
        result.font = Fonts.OpenSans(ofSize: 10)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Tap to call back"
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
    
    lazy var stackViewContainer: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .fill
        result.distribution = .fill
        result.spacing = 2
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
        containerView.addSubViews(iconImageView, stackViewContainer)
        
        
        containerView.addSubview(stackViewContainer)
        stackViewContainer.addArrangedSubview(titleLabel)
        stackViewContainer.addArrangedSubview( discriptionLabel)
        
        
        
        discriptionLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            mainContainerView.widthAnchor.constraint(equalToConstant: 124),
            
            containerView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: 6),
            containerView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -6),
            containerView.topAnchor.constraint(equalTo: mainContainerView.topAnchor, constant: 6),
            containerView.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -6),
            containerView.widthAnchor.constraint(equalToConstant: 147),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            stackViewContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            stackViewContainer.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            stackViewContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            stackViewContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
            
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
        let incomimglogoImage = isLightMode ? "call_incoming_new_white" : "call_incoming_new"
        let missedlogoImage = isLightMode ? "call_missed_new_white" : "call_missed_new"
        
        switch message.callState {
        case .incoming:
            discriptionLabel.isHidden = true
            mainContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14).isActive = true
            mainContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
            mainContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4).isActive = true
            mainContainerView.widthAnchor.constraint(equalToConstant: 124).isActive = true
            
            mainContainerView.backgroundColor = Colors.incomingMessageColor
            containerView.backgroundColor = Colors.smallBackGroundViewCellColor
            
            containerView.widthAnchor.constraint(equalToConstant: 112).isActive = true
            titleLabel.widthAnchor.constraint(equalToConstant: 21).isActive = true
            
            timeLabel.textColor = UIColor(hex: 0xA7A7BA)
            titleLabel.textColor = Colors.messageTimeLabelColor
            self.titleLabel.text = "Call"
            icon = UIImage(named: incomimglogoImage)
        case .outgoing:
            debugPrint("outgoing call")
        case .missed:
            discriptionLabel.isHidden = false
            mainContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14).isActive = true
            mainContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
            mainContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4).isActive = true
            mainContainerView.widthAnchor.constraint(equalToConstant: 159).isActive = true
            
            containerView.widthAnchor.constraint(equalToConstant: 147).isActive = true
            titleLabel.widthAnchor.constraint(equalToConstant: 61).isActive = true
            
            mainContainerView.backgroundColor = Colors.incomingMessageColor
            containerView.backgroundColor = Colors.smallBackGroundViewCellColor
            
            timeLabel.textColor = UIColor(hex: 0xA7A7BA)
            titleLabel.textColor = Colors.messageTimeLabelColor
            
            self.titleLabel.text = "Missed call"
            icon = UIImage(named: missedlogoImage)
        case .permissionDenied, .unknown:
            icon = UIImage(named: missedlogoImage)
        default:
            icon = nil
        }
        
        iconImageView.image = icon
        iconImageViewWidthConstraint.constant = (icon != nil) ? CallTableViewCell.iconSize : 0
        iconImageViewHeightConstraint.constant = (icon != nil) ? CallTableViewCell.iconSize : 0
        
        let shouldShowInfoIcon = message.callState == .permissionDenied && !SSKPreferences.areCallsEnabled
        infoImageViewWidthConstraint.constant = shouldShowInfoIcon ? CallTableViewCell.iconSize : 0
        infoImageViewHeightConstraint.constant = shouldShowInfoIcon ? CallTableViewCell.iconSize : 0
        
        let date = message.dateForUI()
        let description = DateUtil.formatDate(forDisplay: date)
        timeLabel.text = description
    }
    
    /// Handle tap gesture
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let viewItem = viewItem, let message = viewItem.interaction as? TSInfoMessage, message.messageType == .call else { return }
        
        if message.callState == .missed {
            delegate?.handleTapToCallback()
        }
        
        let shouldBeTappable = message.callState == .permissionDenied && !SSKPreferences.areCallsEnabled
        if shouldBeTappable {
            delegate?.handleViewItemTapped(viewItem, gestureRecognizer: gestureRecognizer)
        }
    }
}