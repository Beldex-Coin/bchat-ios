// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewSettingsTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuserIdentifier = "NewSettingsTableViewCell"
    
    // MARK: -
    
    /// Awake from nib
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    /// Set selected
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    /// Initialize
    /// - Parameters:
    ///   - style: UITableViewCell style
    ///   - reuseIdentifier: the Reuse Identifier
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        self.setUPLayout()
    }
    
    /// Initialize
    /// - Parameter coder: the Coder
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    // MARK: - UIElements
    
    /// BackGroundView
    lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    /// Dot View
    lazy var dotView: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = Colors.bothGreenColor
        View.isHidden = true
        View.layer.cornerRadius = 4
        return View
    }()
    
    /// Icon Image View
    lazy var iconImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 20)
        result.set(.height, to: 20)
        result.layer.masksToBounds = true
        result.contentMode = .center
        return result
    }()
    
    /// Title label
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.regularOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Arrow button
    lazy var arrowButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setBackgroundImage(UIImage(named: "ic_arrow"), for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    // MARK: - Private methods
    
    /// Setup layout
    func setUPLayout() {
        contentView.addSubview(backGroundView)
        backGroundView.addSubViews(iconImageView, titleLabel, arrowButton, dotView)
        
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            iconImageView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 29),
            iconImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 20),
            
            dotView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            dotView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 6),
            dotView.heightAnchor.constraint(equalToConstant: 8),
            dotView.widthAnchor.constraint(equalToConstant: 8),
            
            arrowButton.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            arrowButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -31),
            
        ])
    }
}
