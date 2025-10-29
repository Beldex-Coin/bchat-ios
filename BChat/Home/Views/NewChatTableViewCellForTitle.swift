// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import UIKit

class NewChatTableViewCellForTitle: UITableViewCell {
    
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
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(Colors.noDataLabelColor, for: .normal)
        button.titleLabel!.font = Fonts.regularOpenSans(ofSize: 14)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    func setUPLayout() {
        contentView.addSubViews(titleButton)
        NSLayoutConstraint.activate([
            titleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            titleButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
