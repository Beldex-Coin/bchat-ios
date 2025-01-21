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
    
    lazy var titleLabel: UILabel = {
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
        button.setBackgroundImage(UIImage(named: "ic_searchChatSetting"), for: .normal)
        return button
    }()
    
    lazy var searchTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(
            string: "Search Contact",
            attributes: [NSAttributedString.Key.foregroundColor: Colors.textFieldPlaceHolderColor]
        )
        result.font = Fonts.OpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.textColor = Colors.titleColor3
        result.textAlignment = .left
        
        // Add left padding
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 17, height: result.frame.size.height))
        result.leftView = paddingViewLeft
        result.leftViewMode = .always
        
        // Add right padding
        let paddingViewRight = UIView(frame: CGRect(x: 0, y: 0, width: 19, height: 19))
        result.rightView = paddingViewRight
        result.rightViewMode = .always
        
        // Create an UIImageView and set its image for search icon
        let searchIconImageView = UIImageView(image: UIImage(named: "ic_Search_Vector_New"))
        searchIconImageView.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        searchIconImageView.contentMode = .center
        paddingViewRight.addSubview(searchIconImageView)
        
        let tapGestureRecognizerForSearch = UITapGestureRecognizer(target: self, action: #selector(self.searchIconTapped))
        searchIconImageView.isUserInteractionEnabled = true
        searchIconImageView.addGestureRecognizer(tapGestureRecognizerForSearch)
        
        // Create an UIImageView for close icon initially hidden
        let closeIconImageView = UIImageView(image: UIImage(named: "ic_closeNew"))
        closeIconImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 14)
        closeIconImageView.contentMode = .scaleAspectFit
        closeIconImageView.tag = 1 // Set a tag to distinguish it from the search icon
        closeIconImageView.isHidden = true
        paddingViewRight.addSubview(closeIconImageView)
        

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closeIconTapped))
        closeIconImageView.isUserInteractionEnabled = true
        closeIconImageView.addGestureRecognizer(tapGestureRecognizer)
        result.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)

        return result
    }()

    var textChanged: ((String) -> Void)?
    var closeCallback: (() -> Void)?
    var searchCallback: (() -> Void)?
    
    func setUPLayout() {
        
        contentView.addSubview(backGroundView)
        backGroundView.addSubViews(searchTextField)
                
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            searchTextField.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 0),
            searchTextField.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -17),
        ])
    }
    
    @objc func closeIconTapped() {
        closeCallback?()
    }
    
    @objc func searchIconTapped() {
        searchCallback?()
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        textChanged?(textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        false
    }

}
