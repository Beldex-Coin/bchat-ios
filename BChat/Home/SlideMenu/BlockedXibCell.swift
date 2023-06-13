// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class BlockedXibCell: UITableViewCell {
    
    @IBOutlet weak var lblname:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
