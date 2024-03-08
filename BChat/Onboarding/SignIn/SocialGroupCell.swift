// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import PromiseKit
import BChatUIKit

class SocialGroupCell: UICollectionViewCell {

    static let identifier = "SocialGroupCell"

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "ic_Newqr", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var titleLable: UILabel = {
        let label = UILabel()
        label.font = Fonts.OpenSans(ofSize: 12)
        label.textAlignment = .center
        label.textColor = Colors.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 10
        stackView.backgroundColor = Colors.cellBackgroundColor2
        return stackView
    }()
    
    var allroom: OpenGroupAPIV2.Info? { didSet { update() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(titleLable)
        backGroundView.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            titleLable.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 5),
            titleLable.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -15),
            titleLable.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -5),
            logoImageView.widthAnchor.constraint(equalToConstant: 52),
            logoImageView.heightAnchor.constraint(equalToConstant: 52),
            logoImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: -16),
            logoImageView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
        ])
        self.update()
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update() {
        guard let room = allroom else { return }
        let placeholderImage = UIImage(named: "placeholder_image_name")
        let promise = OpenGroupAPIV2.getGroupImage(for: room.id, on: OpenGroupAPIV2.defaultServer)
        if let imageData: Data = promise.value {
            logoImageView.image = UIImage(data: imageData)
            logoImageView.isHidden = (logoImageView.image == nil)
        } else {
            logoImageView.image = placeholderImage
            logoImageView.isHidden = false
            _ = promise.done { [weak self] imageData in
                DispatchQueue.main.async {
                    self?.logoImageView.image = UIImage(data: imageData)
                    self?.logoImageView.isHidden = (self?.logoImageView.image == nil)
                }
            }
        }
        titleLable.text = room.name
    }


}
