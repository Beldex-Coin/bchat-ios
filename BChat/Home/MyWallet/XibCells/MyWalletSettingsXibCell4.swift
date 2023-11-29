// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit

class MyWalletSettingsXibCell4: UICollectionViewCell {
    static let identifier = "MyWalletSettingsXibCell4"
    static let nib = UINib(nibName: "MyWalletSettingsXibCell4", bundle: nil)
    
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var btnAddress:UIButton!
    @IBOutlet weak var btnchangePin:UIButton!
    @IBOutlet weak var img1:UIImageView!
    @IBOutlet weak var img2:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.cornerRadius = 6
        let logoName = isLightMode ? "arrowmsg1" : "arrowmsg2"
        img1.image = UIImage(named: logoName)!
        img2.image = UIImage(named: logoName)!
        
    }
    
}
