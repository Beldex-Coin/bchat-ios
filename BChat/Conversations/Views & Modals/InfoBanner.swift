
final class InfoBanner : UIView {
    private let message: String
    private let snBackgroundColor: UIColor
    
    init(message: String, backgroundColor: UIColor) {
        self.message = message
        self.snBackgroundColor = backgroundColor
        super.init(frame: CGRect.zero)
        setUpViewHierarchy()
    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(message:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(coder:) instead.")
    }
    
    private func setUpViewHierarchy() {
        backgroundColor = Colors.cellPinned
        let label = UILabel()
        label.text = message
        label.font = .boldSystemFont(ofSize: Values.smallFontSize)
        label.textColor = Colors.bchat_lbl_name
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        addSubview(label)
        label.pin(to: self, withInset: Values.mediumSpacing)
        let titleLabel1 = UILabel()
        titleLabel1.textColor = UIColor.white
        titleLabel1.font = .boldSystemFont(ofSize: Values.smallFontSize)
        titleLabel1.text = " Unblock  "
        titleLabel1.textAlignment = .center
        titleLabel1.numberOfLines = 0
        titleLabel1.backgroundColor = Colors.destructive
        titleLabel1.layer.cornerRadius = 4
        titleLabel1.layer.masksToBounds = true
        addSubview(titleLabel1)
        titleLabel1.pin(to: self, withInset: Values.mediumSpacing)
        let label2 = UILabel()
        label2.text = ""
        label2.font = .boldSystemFont(ofSize: Values.smallFontSize)
        label2.textColor = .white
        label2.numberOfLines = 0
        label.textAlignment = .center
        label2.lineBreakMode = .byWordWrapping
        addSubview(label2)
        label2.pin(to: self, withInset: Values.mediumSpacing)
        // Label stack view
        let labelStackView = UIStackView(arrangedSubviews: [ label ])
        labelStackView.axis = .vertical
        // Stack view
        let stackView = UIStackView(arrangedSubviews: [ label2, labelStackView, titleLabel1, label2 ])
        stackView.axis = .vertical
        stackView.spacing = Values.mediumSpacingBChat
        stackView.alignment = .center
        addSubview(stackView)
        stackView.pin(to: self)
    }
}
