// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class DocumentCollectionViewCell: UICollectionViewCell {
    
    static let reuseidentifier = "DocumentCollectionViewCell"
    
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.boldOpenSans(ofSize: 17)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var sizeLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.OpenSans(ofSize: 13)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var dateLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.OpenSans(ofSize: 13)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var documentImageView: UIImageView = {
        let result = UIImageView()
        result.contentMode = .scaleAspectFit
        result.image = UIImage(named: "user_dark")
        result.translatesAutoresizingMaskIntoConstraints = false
        result.clipsToBounds = true
        return result
    }()
    
    lazy var separatorLine: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = Colors.titleColor3
        return View
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(documentImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(separatorLine)
        
        documentImageView.image = UIImage(named: "user_dark")
        
        NSLayoutConstraint.activate([
            
            documentImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            documentImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            documentImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            documentImageView.heightAnchor.constraint(equalToConstant: 60),
            documentImageView.widthAnchor.constraint(equalToConstant: 45),
            
            titleLabel.leadingAnchor.constraint(equalTo: documentImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: documentImageView.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            sizeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            sizeLabel.bottomAnchor.constraint(equalTo: documentImageView.bottomAnchor, constant: -6),
            
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            dateLabel.bottomAnchor.constraint(equalTo: documentImageView.bottomAnchor, constant: -8),
            
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
