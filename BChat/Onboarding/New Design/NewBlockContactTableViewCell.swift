// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewBlockContactTableViewCell: UITableViewCell {

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
        stackView.backgroundColor = Colors.cellGroundColor2
       stackView.layer.cornerRadius = 29
       return stackView
   }()
    
    lazy var profileImageView: UIImageView = {
       let result = UIImageView()
       result.image = UIImage(named: "")
        result.set(.width, to: 36)
        result.set(.height, to: 36)
       result.layer.masksToBounds = true
       result.contentMode = .scaleToFill
        result.layer.cornerRadius = 18
       return result
   }()
    
    lazy var verifiedImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 18)
        result.set(.height, to: 18)
        result.contentMode = .center
        result.image = UIImage(named: "ic_verified_image")
        return result
    }()
   
    lazy var nameLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.titleColor
       result.font = Fonts.semiOpenSans(ofSize: 14)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    lazy var unblockButton: UIButton = {
        let button = UIButton()
        button.setTitle("Unblock", for: .normal)
        button.titleLabel?.font = Fonts.OpenSans(ofSize: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.unlockButtonBackgroundColor2
        button.addTarget(self, action: #selector(unblockButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 15
        button.setTitleColor(Colors.titleColor, for: .normal)
        return button
    }()
    
    
    lazy var selectionButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(selectionButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_button_normal"), for: .normal)
        button.setBackgroundImage(UIImage(named: "ic_button_selected"), for: .selected)
        return button
    }()
    
    lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setBackgroundImage(UIImage(named: "ic_removeUser"), for: .normal)
        button.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    var unblockCallback: (() -> Void)?
    var removeCallback: (() -> Void)?
    
    func setUPLayout() {
        
        contentView.addSubview(backGroundView)
        backGroundView.addSubViews(profileImageView, nameLabel, selectionButton, unblockButton, removeButton, verifiedImageView)
        
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            profileImageView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 12),
            profileImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            
            nameLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
//            nameLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 22),
            nameLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -100),
            
            
            selectionButton.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            selectionButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            
            unblockButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -12),
            unblockButton.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            unblockButton.heightAnchor.constraint(equalToConstant: 30),
            unblockButton.widthAnchor.constraint(equalToConstant: 82),
            
            removeButton.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            removeButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -13),
        ])
        
        verifiedImageView.pin(.trailing, to: .trailing, of: profileImageView, withInset: 2)
        verifiedImageView.pin(.bottom, to: .bottom, of: profileImageView, withInset: 3)
    }
    
    @objc private func removeButtonTapped(_ sender: UIButton) {
        removeCallback?()
    }
    
    @objc private func unblockButtonTapped(_ sender: UIButton) {
        unblockCallback?()
    }
    
    @objc private func selectionButtonTapped(_ sender: UIButton) {

    }
    

}
