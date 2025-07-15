// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit

class ShareContactTableViewCell: UITableViewCell {

    static let identifier = "ShareContactTableViewCell"
    
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let addressLabel = UILabel()
    let checkbox = UIButton(type: .custom)
    
    var toggleSelection: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none

        profileImageView.layer.cornerRadius = 24
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = .lightGray

        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        addressLabel.textColor = .lightGray
        addressLabel.font = UIFont.systemFont(ofSize: 12)

        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)

        let labelsStack = UIStackView(arrangedSubviews: [nameLabel, addressLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [profileImageView, labelsStack, checkbox])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkbox.widthAnchor.constraint(equalToConstant: 24),
            checkbox.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    func configure(with contact: ShareContact) {
        nameLabel.text = contact.name
        addressLabel.text = contact.address
        profileImageView.image = UIImage(named: contact.imageName)

        let imageName = contact.isSelected ? "contact_check" : "contact_uncheck"
        checkbox.setImage(UIImage(named: imageName), for: .normal)
    }

    @objc private func checkboxTapped() {
        toggleSelection?()
    }
}
