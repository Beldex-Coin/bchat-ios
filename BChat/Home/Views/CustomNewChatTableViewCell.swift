// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import UIKit

class CustomNewChatTableViewCell: UITableViewCell {
    
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
    
    
    lazy var leftImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "")
        result.set(.width, to: 36)
        result.set(.height, to: 36)
        result.layer.masksToBounds = true
        result.contentMode = .center
        return result
    }()
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(UIColor(hex: 0x00BD40), for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 14)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    lazy var rightImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_qrNewChat")
        result.set(.width, to: 28)
        result.set(.height, to: 28)
        result.layer.masksToBounds = true
        result.contentMode = .center
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scannerImageViewTapped))
        result.isUserInteractionEnabled = true
        result.addGestureRecognizer(tapGestureRecognizer)
        return result
    }()
    
    var scannerCallback: (() -> Void)?
    
    func setUPLayout() {
        
        contentView.addSubViews(leftImageView, titleButton, rightImageView)
        NSLayoutConstraint.activate([
            leftImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            leftImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
            leftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            titleButton.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: 13),
            titleButton.centerYAnchor.constraint(equalTo: leftImageView.centerYAnchor),
            rightImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            rightImageView.centerYAnchor.constraint(equalTo: leftImageView.centerYAnchor),
        ])
    }
    
    @objc func scannerImageViewTapped() {
        scannerCallback?()
    }
    
}

