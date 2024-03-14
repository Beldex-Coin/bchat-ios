// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class HomeTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        self.setUPLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    lazy var backGroundView: UIView = {
       let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = .clear//Colors.cellGroundColor3
        View.layer.cornerRadius = 36
       return View
   }()
    
    lazy var iconImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_test")
        result.set(.width, to: 42)
        result.set(.height, to: 42)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    lazy var nameLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.titleColor3
       result.font = Fonts.boldOpenSans(ofSize: 16)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    lazy var lastMessageLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.titleColor3
       result.font = Fonts.OpenSans(ofSize: 12)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    
    lazy var messageCountAndDateStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .trailing
        result.distribution = .fill
        result.spacing = 4
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var messageCountLabel: UILabel = {
       let result = PaddingLabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
       result.font = Fonts.boldOpenSans(ofSize: 11)
       result.textAlignment = .center
       result.translatesAutoresizingMaskIntoConstraints = false
        result.paddingTop = 3
        result.paddingBottom = 3
        result.paddingLeft = 5
        result.paddingRight = 5
        result.layer.masksToBounds = true
        result.layer.cornerRadius = 11
        result.backgroundColor = Colors.bothGreenColor
       return result
   }()
    
    lazy var dateLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.textFieldPlaceHolderColor
       result.font = Fonts.OpenSans(ofSize: 12)
       result.textAlignment = .center
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    
    func setUPLayout() {
        
        contentView.addSubview(backGroundView)
        backGroundView.addSubViews(iconImageView, nameLabel, lastMessageLabel, messageCountAndDateStackView)
        
        messageCountAndDateStackView.addArrangedSubview(messageCountLabel)
        messageCountAndDateStackView.addArrangedSubview(dateLabel)
        
        
        nameLabel.text = "john"
        lastMessageLabel.text = "Lorem ipsum dolor sit amet..."
        messageCountLabel.text = "2"
        dateLabel.text = "2/2/23"
        
        NSLayoutConstraint.activate([
            backGroundView.heightAnchor.constraint(equalToConstant: 72),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            iconImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            
            nameLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 17),
            
            lastMessageLabel.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor),
            lastMessageLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 17),
            lastMessageLabel.trailingAnchor.constraint(lessThanOrEqualTo: messageCountAndDateStackView.leadingAnchor, constant: -8),
            
            messageCountLabel.heightAnchor.constraint(equalToConstant: 22),
            messageCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 22),
            
            messageCountAndDateStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            messageCountAndDateStackView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 15),
            messageCountAndDateStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -15),
            messageCountAndDateStackView.widthAnchor.constraint(equalToConstant: 46),
            
        ])
    }
    
    
    

}






class MessageRequestCollectionViewCell: UICollectionViewCell {


    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 22
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "ic_test", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    
    lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_close_new"), for: .normal)
        return button
    }()
    
    lazy var nameLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.titleColor3
       result.font = Fonts.boldOpenSans(ofSize: 12)
       result.textAlignment = .center
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    var removeCallback: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(removeButton)
        contentView.addSubview(nameLabel)
        
        nameLabel.text = "john"
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            profileImageView.heightAnchor.constraint(equalToConstant: 44),
            profileImageView.widthAnchor.constraint(equalToConstant: 44),
            
            removeButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -4),
            removeButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 6),
//            removeButton.heightAnchor.constraint(equalToConstant: 16),
//            removeButton.widthAnchor.constraint(equalToConstant: 16),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
            
        ])
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func removeButtonTapped(_ sender: UIButton) {
        removeCallback?()
    }


}
