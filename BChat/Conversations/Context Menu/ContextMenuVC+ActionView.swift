
extension ContextMenuVC {

    final class ActionView : UIView {
        private let action: Action
        private let dismiss: () -> Void

        // MARK: Settings
        private static let iconSize: CGFloat = 16
        private static let iconImageViewSize: CGFloat = 24
        
        // MARK: Lifecycle
        init(for action: Action, dismiss: @escaping () -> Void) {
            self.action = action
            self.dismiss = dismiss
            super.init(frame: CGRect.zero)
            setUpViewHierarchy()
        }

        override init(frame: CGRect) {
            preconditionFailure("Use init(for:) instead.")
        }

        required init?(coder: NSCoder) {
            preconditionFailure("Use init(for:) instead.")
        }

        private func setUpViewHierarchy() {
            // Icon
            let iconSize = ActionView.iconSize
            let iconImageView = UIImageView(image: action.icon.resizedImage(to: CGSize(width: iconSize, height: iconSize))/*!.withTint(Colors.text)*/)
            let iconImageViewSize = CGFloat(12)//ActionView.iconImageViewSize
            iconImageView.set(.width, to: iconImageViewSize)
            iconImageView.set(.height, to: iconImageViewSize)
            iconImageView.contentMode = .scaleAspectFit//.center
            // Title
            let titleLabel = UILabel()
            titleLabel.text = action.title
            titleLabel.textColor = UIColor(hex: 0xEBEBEB)//Colors.text
            if action.title == "Delete" {
                titleLabel.textColor = Colors.bothRedColor
            }
            titleLabel.font = Fonts.OpenSans(ofSize: 12)
            // Stack view
            let stackView = UIStackView(arrangedSubviews: [ iconImageView, titleLabel ])
            stackView.axis = .horizontal
            stackView.spacing = 10//Values.smallSpacing
            stackView.alignment = .center
            stackView.isLayoutMarginsRelativeArrangement = true
            let smallSpacing = Values.smallSpacing
            stackView.layoutMargins = UIEdgeInsets(top: smallSpacing, leading: smallSpacing, bottom: smallSpacing, trailing: Values.mediumSpacing)
            addSubview(stackView)
            stackView.pin(to: self)
            // Tap gesture recognizer
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            addGestureRecognizer(tapGestureRecognizer)
        }
        
        // MARK: Interaction
        @objc private func handleTap() {
            action.work()
            dismiss()
        }
    }
}
