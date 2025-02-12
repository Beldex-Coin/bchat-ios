// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit


class ChatSettingsSearchTableViewCell: UITableViewCell, UITextFieldDelegate {

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
    
    lazy var memberCountLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.textFieldPlaceHolderColor
       result.font = Fonts.OpenSans(ofSize: 14)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setBackgroundImage(UIImage(named: "ic_Search_Vector_New"), for: .normal)
        button.addTarget(self, action: #selector(searchIconTapped), for: .touchUpInside)
        return button
    }()

    var searchCallback: (() -> Void)?
    
    func setUPLayout() {
        
        contentView.addSubview(backGroundView)
        backGroundView.addSubViews(memberCountLabel, searchButton)
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            memberCountLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            memberCountLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 17),
            memberCountLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -33),
            
            searchButton.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            searchButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -17),
            searchButton.widthAnchor.constraint(equalToConstant: 16),
            searchButton.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    @objc func searchIconTapped() {
        searchCallback?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        false
    }

}
