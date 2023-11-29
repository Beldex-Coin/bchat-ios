// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit

class MyWalletSettingsXibCell3: UICollectionViewCell {
    static let identifier = "MyWalletSettingsXibCell3"
    static let nib = UINib(nibName: "MyWalletSettingsXibCell3", bundle: nil)
    
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var btnDisplayNameAS:UIButton!
    @IBOutlet weak var btnDecimals:UIButton!
    @IBOutlet weak var btnCurrency:UIButton!
    @IBOutlet weak var btnFeepriority:UIButton!
    @IBOutlet weak var btnSaveRecipientAddress:UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.cornerRadius = 6
    }
    
    

}
