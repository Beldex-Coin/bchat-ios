// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit

class PopXibCell: UITableViewCell {
    @IBOutlet weak var lblname:UILabel!
    @IBOutlet weak var view1:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view1.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
