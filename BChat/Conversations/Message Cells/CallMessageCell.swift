import UIKit
import BChatMessagingKit

final class CallMessageCell : MessageCell {
    private lazy var iconImageViewWidthConstraint = iconImageView.set(.width, to: 0)
    private lazy var iconImageViewHeightConstraint = iconImageView.set(.height, to: 0)
    
    private lazy var infoImageViewWidthConstraint = infoImageView.set(.width, to: 0)
    private lazy var infoImageViewHeightConstraint = infoImageView.set(.height, to: 0)
    
    // MARK: UI Components
    private lazy var iconImageView = UIImageView()
    
    private lazy var infoImageView = UIImageView(image: UIImage(named: "ic_info")?.withTint(Colors.text))
    
    private lazy var timestampLabel: UILabel = {
        let result = UILabel()
        result.font = Fonts.boldOpenSans(ofSize: Values.verySmallFontSize)
        result.textColor = Colors.messageTimeLabelColor//Colors.text
        result.textAlignment = .center
        return result
    }()
    
    private lazy var label: UILabel = {
        let result = UILabel()
        result.numberOfLines = 1
        result.lineBreakMode = .byWordWrapping
        result.font = Fonts.semiOpenSans(ofSize: 11)
        result.textColor = Colors.messageTimeLabelColor//Colors.text
        result.textAlignment = .center
        return result
    }()
    
    private lazy var container: UIView = {
        let result = UIView()
        result.set(.height, to: 25)
        result.layer.cornerRadius = 12.5
        result.backgroundColor = Colors.bchatMessageRequestsBubble
        result.addSubview(label)
        label.autoCenterInSuperview()
        result.addSubview(iconImageView)
        iconImageView.autoVCenterInSuperview()
        iconImageView.pin(.left, to: .left, of: result, withInset: CallMessageCell.inset)
        result.addSubview(infoImageView)
        infoImageView.autoVCenterInSuperview()
        infoImageView.pin(.right, to: .right, of: result, withInset: -CallMessageCell.inset)
        label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(equalTo: infoImageView.leadingAnchor, constant: -8).isActive = true
        return result
    }()
    
    private lazy var stackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ timestampLabel, container ])
        result.axis = .vertical
        result.alignment = .center
        result.spacing = Values.smallSpacing
        return result
    }()
    
    // MARK: Settings
    private static let iconSize: CGFloat = 16
    private static let inset = Values.mediumSpacing
    private static let margin = UIScreen.main.bounds.width * 0.2 //UIScreen.main.bounds.width * 0.1
    
    override class var identifier: String { "CallMessageCell" }
    
    // MARK: Lifecycle
    override func setUpViewHierarchy() {
        super.setUpViewHierarchy()
        iconImageViewWidthConstraint.isActive = true
        iconImageViewHeightConstraint.isActive = true
        addSubview(stackView)
        
        // Add left line view
        let leftLineView = UIView()
        leftLineView.backgroundColor = Colors.borderColor
        leftLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftLineView)
        leftLineView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        leftLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        leftLineView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        leftLineView.trailingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true

        // Add right line view
        let rightLineView = UIView()
        rightLineView.backgroundColor = Colors.borderColor
        rightLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightLineView)
        rightLineView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        rightLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        rightLineView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        rightLineView.leadingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        
        container.autoPinWidthToSuperview()
        stackView.pin(.left, to: .left, of: self, withInset: CallMessageCell.margin)
        stackView.pin(.top, to: .top, of: self, withInset: CallMessageCell.inset)
        stackView.pin(.right, to: .right, of: self, withInset: -CallMessageCell.margin)
        stackView.pin(.bottom, to: .bottom, of: self, withInset: -CallMessageCell.inset)
    }
    
    override func setUpGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: Updating
    override func update() {
        guard let message = viewItem?.interaction as? TSInfoMessage, message.messageType == .call else { return }
        let icon: UIImage?
        switch message.callState {
        case .outgoing: icon = UIImage(named: "CallOutgoing")?.withTint(Colors.text)
        case .incoming: icon = UIImage(named: "CallIncoming")?.withTint(Colors.text)
        case .missed, .permissionDenied: icon = UIImage(named: "CallMissed")?.withTint(Colors.destructive)
        default: icon = nil
        }
        iconImageView.image = icon
        iconImageViewWidthConstraint.constant = (icon != nil) ? CallMessageCell.iconSize : 0
        iconImageViewHeightConstraint.constant = (icon != nil) ? CallMessageCell.iconSize : 0
        
        let shouldShowInfoIcon = message.callState == .permissionDenied && !SSKPreferences.areCallsEnabled
        infoImageViewWidthConstraint.constant = shouldShowInfoIcon ? CallMessageCell.iconSize : 0
        infoImageViewHeightConstraint.constant = shouldShowInfoIcon ? CallMessageCell.iconSize : 0
        
        Storage.read { transaction in
            self.label.text = message.previewText(with: transaction)
        }
        
        let date = message.dateForUI()
        let description = DateUtil.formatDate(forDisplay: date)
        timestampLabel.text = description
    }
    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let viewItem = viewItem, let message = viewItem.interaction as? TSInfoMessage, message.messageType == .call else { return }
        let shouldBeTappable = message.callState == .permissionDenied && !SSKPreferences.areCallsEnabled
        if shouldBeTappable {
            delegate?.handleViewItemTapped(viewItem, gestureRecognizer: gestureRecognizer)
        }
    }

}



final class CallMessageCellNew : MessageCell {
    
    private lazy var iconImageViewWidthConstraint = iconImageView.set(.width, to: 0)
    private lazy var iconImageViewHeightConstraint = iconImageView.set(.height, to: 0)
    
    private lazy var infoImageViewWidthConstraint = infoImageView.set(.width, to: 0)
    private lazy var infoImageViewHeightConstraint = infoImageView.set(.height, to: 0)
    private static let iconSize: CGFloat = 16
    private static let margin = UIScreen.main.bounds.width * 0.2
    private static let inset = Values.mediumSpacing
    override class var identifier: String { "CallMessageCellNew" }
    private lazy var infoImageView = UIImageView(image: UIImage(named: "ic_info")?.withTint(Colors.text))
    
    private lazy var mainBackGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.bothGreenColor
        stackView.layer.cornerRadius = 22
        return stackView
    }()
    
    private lazy var smallBackGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.darkGreenColor
        stackView.layer.cornerRadius = 14
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.offWhiteColor
        result.font = Fonts.boldOpenSans(ofSize: 11)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Voice call"
        return result
    }()
    
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.offWhiteColor
        result.font = Fonts.OpenSans(ofSize: 10)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "No answer"
        return result
    }()
    
    private lazy var iconImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "call_outgoing") //call_incoming  //call_missed
        result.set(.width, to: 28)
        result.set(.height, to: 28)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    private lazy var timeLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.offWhiteColor
        result.font = Fonts.OpenSans(ofSize: 9)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    
    
    // MARK: Lifecycle
    override func setUpViewHierarchy() {
        super.setUpViewHierarchy()
        addSubview(mainBackGroundView)
        mainBackGroundView.addSubViews(smallBackGroundView, timeLabel)
        smallBackGroundView.addSubViews(iconImageView, titleLabel, discriptionLabel)
        
        
        discriptionLabel.isHidden = true
        
        NSLayoutConstraint.activate([
//            mainBackGroundView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            mainBackGroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14),
//            mainBackGroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
//            mainBackGroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
            
            timeLabel.trailingAnchor.constraint(equalTo: mainBackGroundView.trailingAnchor, constant: -16),
            timeLabel.bottomAnchor.constraint(equalTo: mainBackGroundView.bottomAnchor, constant: -7),
            
            smallBackGroundView.leadingAnchor.constraint(equalTo: mainBackGroundView.leadingAnchor, constant: 6),
            smallBackGroundView.trailingAnchor.constraint(equalTo: mainBackGroundView.trailingAnchor, constant: -6),
            smallBackGroundView.topAnchor.constraint(equalTo: mainBackGroundView.topAnchor, constant: 6),
            smallBackGroundView.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -6),
            
            
            iconImageView.leadingAnchor.constraint(equalTo: smallBackGroundView.leadingAnchor, constant: 6),
            iconImageView.topAnchor.constraint(equalTo: smallBackGroundView.topAnchor, constant: 6),
            iconImageView.bottomAnchor.constraint(equalTo: smallBackGroundView.bottomAnchor, constant: -7),
            
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: smallBackGroundView.trailingAnchor, constant: -18),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
                        
            
            
//            titleLabel.topAnchor.constraint(equalTo: smallBackGroundView.topAnchor, constant: 5),
//            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
//            titleLabel.trailingAnchor.constraint(equalTo: smallBackGroundView.trailingAnchor, constant: -18),
            
//            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
//            discriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            discriptionLabel.bottomAnchor.constraint(equalTo: smallBackGroundView.bottomAnchor, constant: -6),
            
        ])
        
        
    }
    
    
    
    override func setUpGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: Updating
    override func update() {
        guard let message = viewItem?.interaction as? TSInfoMessage, message.messageType == .call else { return }
        if message.callState.rawValue == 0 {//0 is incoming
            mainBackGroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14).isActive = true
            mainBackGroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
            mainBackGroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4).isActive = true
            mainBackGroundView.backgroundColor = Colors.incomingMessageColor
            smallBackGroundView.backgroundColor = Colors.smallBackGroundViewCellColor
            timeLabel.textColor = UIColor(hex: 0xA7A7BA)
            titleLabel.textColor = Colors.messageTimeLabelColor//Colors.text
        }else if message.callState.rawValue == 1 {//1 is outgoiing
            mainBackGroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14).isActive = true
            mainBackGroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
            mainBackGroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4).isActive = true
        }else {//2 is missed call
            mainBackGroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14).isActive = true
            mainBackGroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
            mainBackGroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4).isActive = true
            mainBackGroundView.backgroundColor = Colors.incomingMessageColor
            smallBackGroundView.backgroundColor = Colors.smallBackGroundViewCellColor
            timeLabel.textColor = UIColor(hex: 0xA7A7BA)
            titleLabel.textColor = Colors.messageTimeLabelColor//Colors.text
        }
        let icon: UIImage?
        let incomimglogoImage = isLightMode ? "call_incoming_new_white" : "call_incoming_new"
        let missedlogoImage = isLightMode ? "call_missed_new_white" : "call_missed_new"
        switch message.callState {
        case .outgoing: icon = UIImage(named: "call_outgoing")//?.withTint(Colors.text)
        case .incoming: icon = UIImage(named: incomimglogoImage)//?.withTint(Colors.text)
        case .missed, .permissionDenied: icon = UIImage(named: missedlogoImage)//?.withTint(Colors.destructive)
        default: icon = nil
        }
        iconImageView.image = icon
        iconImageViewWidthConstraint.constant = (icon != nil) ? CallMessageCellNew.iconSize : 0
        iconImageViewHeightConstraint.constant = (icon != nil) ? CallMessageCellNew.iconSize : 0
        
        let shouldShowInfoIcon = message.callState == .permissionDenied && !SSKPreferences.areCallsEnabled
        infoImageViewWidthConstraint.constant = shouldShowInfoIcon ? CallMessageCellNew.iconSize : 0
        infoImageViewHeightConstraint.constant = shouldShowInfoIcon ? CallMessageCellNew.iconSize : 0
        
        Storage.read { transaction in
            self.titleLabel.text = message.previewText(with: transaction)
        }
        
        let date = message.dateForUI()
        let description = DateUtil.formatDate(forDisplay: date)
        timeLabel.text = description
    }
    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let viewItem = viewItem, let message = viewItem.interaction as? TSInfoMessage, message.messageType == .call else { return }
        let shouldBeTappable = message.callState == .permissionDenied && !SSKPreferences.areCallsEnabled
        if shouldBeTappable {
            delegate?.handleViewItemTapped(viewItem, gestureRecognizer: gestureRecognizer)
        }
    }

}
