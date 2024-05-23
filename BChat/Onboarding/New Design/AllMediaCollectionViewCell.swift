// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class AllMediaCollectionViewCell: UICollectionViewCell {
    
    
    private lazy var mediaPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "ic_placeholder_media")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        contentView.addSubview(mediaPreviewImageView)
        
        NSLayoutConstraint.activate([
            mediaPreviewImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            mediaPreviewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            mediaPreviewImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            mediaPreviewImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        ])
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
}
