// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit

class MyAccountXibCell: UICollectionViewCell {
    
    static let identifier = "MyAccountXibCell"
    static let nib = UINib(nibName: "MyAccountXibCell", bundle: nil)
    
    @IBOutlet weak var imgpic:UIImageView!
    @IBOutlet weak var lblname:UILabel!
    @IBOutlet weak var sublblname:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
