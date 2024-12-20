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
