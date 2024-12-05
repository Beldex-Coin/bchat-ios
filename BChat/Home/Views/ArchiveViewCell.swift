// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit


class ArchiveViewCell: UITableViewCell {
    
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
    
    lazy var archivedBackGroundView: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = Colors.cellGroundColor3
        View.layer.cornerRadius = 36
        return View
    }()
    
    lazy var archivedImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 42)
        result.set(.height, to: 42)
        result.contentMode = .center
        result.image = UIImage(named: "ic_archiveBackground")
        return result
    }()
    
    lazy var archivedLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Archived Chats"
        return result
    }()
    
    lazy var archivedMessageCountLabel: UILabel = {
        let result = PaddingLabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.paddingTop = 5
        result.paddingBottom = 5
        result.paddingLeft = 8
        result.paddingRight = 8
        result.layer.masksToBounds = true
        result.layer.cornerRadius = 14
        result.backgroundColor = Colors.noBorderColor3
        result.text = "1"
        return result
    }()
    
    lazy var separatorLineView: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = Colors.separatorHomeTableViewCellColor
        return View
    }()
    
    
    
    func setUPLayout() {
        contentView.addSubview(separatorLineView)        
        contentView.addSubview(archivedBackGroundView)
        archivedBackGroundView.addSubview(archivedImageView)
        archivedBackGroundView.addSubview(archivedLabel)
        archivedBackGroundView.addSubview(archivedMessageCountLabel)
        
        NSLayoutConstraint.activate([
            archivedBackGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            archivedBackGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            archivedBackGroundView.heightAnchor.constraint(equalToConstant: 72),
            archivedBackGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            archivedBackGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            archivedImageView.centerYAnchor.constraint(equalTo: archivedBackGroundView.centerYAnchor),
            archivedImageView.leadingAnchor.constraint(equalTo: archivedBackGroundView.leadingAnchor, constant: 20),
            
            archivedLabel.centerYAnchor.constraint(equalTo: archivedBackGroundView.centerYAnchor),
            archivedLabel.leadingAnchor.constraint(equalTo: archivedImageView.trailingAnchor, constant: 17),
            
            archivedMessageCountLabel.centerYAnchor.constraint(equalTo: archivedBackGroundView.centerYAnchor),
            archivedMessageCountLabel.trailingAnchor.constraint(equalTo: archivedBackGroundView.trailingAnchor, constant: -12),
            archivedMessageCountLabel.heightAnchor.constraint(equalToConstant: 28),
            archivedMessageCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 28),
            
            separatorLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorLineView.leadingAnchor.constraint(equalTo: archivedLabel.leadingAnchor),
            separatorLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLineView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    
}
