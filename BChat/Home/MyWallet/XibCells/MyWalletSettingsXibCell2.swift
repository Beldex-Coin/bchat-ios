// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit

class MyWalletSettingsXibCell2: UICollectionViewCell {
    static let identifier = "MyWalletSettingsXibCell2"
    static let nib = UINib(nibName: "MyWalletSettingsXibCell2", bundle: nil)
    
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var img:UIImageView!
    @IBOutlet weak var lblnodename:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.cornerRadius = 6
        let logoName = isLightMode ? "arrowmsg1" : "arrowmsg2"
        img.image = UIImage(named: logoName)!
        
    }

}
