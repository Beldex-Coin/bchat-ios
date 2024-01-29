// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewMessageRequestTableViewCell: UITableViewCell {

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
       let stackView = UIView()
       stackView.translatesAutoresizingMaskIntoConstraints = false
       stackView.backgroundColor = UIColor(hex: 0x1C1C26)
       stackView.layer.cornerRadius = 30
       return stackView
   }()
    
    lazy var profileImageView: UIImageView = {
       let result = UIImageView()
       result.image = UIImage(named: "ic_test")
        result.set(.width, to: 36)
        result.set(.height, to: 36)
       result.layer.masksToBounds = true
       result.contentMode = .scaleToFill
        result.layer.cornerRadius = 18
       return result
   }()
   
    lazy var nameLabel: UILabel = {
       let result = UILabel()
       result.textColor = UIColor(hex: 0xEBEBEB)
       result.font = Fonts.boldOpenSans(ofSize: 14)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    lazy var buttonStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 7
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()

    lazy var acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.addTarget(self, action: #selector(selectionButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_accept"), for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    lazy var declineButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x2C2C3B)
        button.addTarget(self, action: #selector(selectionButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_decline"), for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x2C2C3B)
        button.addTarget(self, action: #selector(selectionButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_delete"), for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    
    func setUPLayout() {
        nameLabel.text = "Contact 1"
        
        contentView.addSubview(backGroundView)
        backGroundView.addSubViews(profileImageView, nameLabel, buttonStackView)
        buttonStackView.addArrangedSubview(deleteButton)
        buttonStackView.addArrangedSubview(declineButton)
        buttonStackView.addArrangedSubview(acceptButton)
        
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            profileImageView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 14),
            profileImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            
            nameLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 11),
            
            buttonStackView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -22),
            buttonStackView.heightAnchor.constraint(equalToConstant: 32),
            deleteButton.heightAnchor.constraint(equalToConstant: 32),
            deleteButton.widthAnchor.constraint(equalToConstant: 32),
            declineButton.heightAnchor.constraint(equalToConstant: 32),
            declineButton.widthAnchor.constraint(equalToConstant: 32),
            acceptButton.heightAnchor.constraint(equalToConstant: 32),
            acceptButton.widthAnchor.constraint(equalToConstant: 32)
            
            
        ])
    }
    
    
    
    @objc private func selectionButtonTapped(_ sender: UIButton) {
        
    }
    

}
