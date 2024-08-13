// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

final class EmojiSectionHeader: UICollectionReusableView {
    static let reuseIdentifier = "EmojiSectionHeader"

    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layoutMargins = UIEdgeInsets(
            top: 16,
            leading: EmojiPickerCollectionView.margins,
            bottom: 6,
            trailing: EmojiPickerCollectionView.margins
        )

        label.font = .systemFont(ofSize: Values.smallFontSize)
        label.backgroundColor = .clear
        addSubview(label)
        label.autoPinEdgesToSuperviewMargins()
        label.setCompressionResistanceHigh()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var labelSize = label.sizeThatFits(size)
        labelSize.width += layoutMargins.left + layoutMargins.right
        labelSize.height += layoutMargins.top + layoutMargins.bottom
        
        return labelSize
    }
}
