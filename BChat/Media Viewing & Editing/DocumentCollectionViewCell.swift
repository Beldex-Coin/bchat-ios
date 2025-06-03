// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class DocumentCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "DocumentCollectionViewCell"
    
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
        result.image = UIImage(named: "")
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
    
    private let selectedBadgeView: UIImageView
    private let selectedView: UIView
    
    override public var isSelected: Bool {
        didSet {
            self.selectedBadgeView.isHidden = !self.isSelected
            self.selectedView.isHidden = !self.isSelected
        }
    }
    
    private static let selectedBadgeImage = #imageLiteral(resourceName: "selected_blue_circle")
    
    override init(frame: CGRect) {
        
        self.selectedView = UIView()
        selectedView.alpha = 0.3
        selectedView.backgroundColor = Colors.cellSelected
        selectedView.isHidden = true
        
        
        self.selectedBadgeView = UIImageView()
        selectedBadgeView.image = DocumentCollectionViewCell.selectedBadgeImage
        selectedBadgeView.isHidden = true
        
        super.init(frame: frame)
        
        contentView.addSubview(documentImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(separatorLine)
        contentView.addSubview(selectedView)
        contentView.addSubview(selectedBadgeView)
                
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
        
        selectedView.autoPinEdgesToSuperviewEdges()
        
        let kSelectedBadgeSize = CGSize(width: 31, height: 31)
        selectedBadgeView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 0)
        selectedBadgeView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0)
        selectedBadgeView.autoSetDimensions(to: kSelectedBadgeSize)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        self.selectedView.isHidden = true
        self.selectedBadgeView.isHidden = true
    }
}
