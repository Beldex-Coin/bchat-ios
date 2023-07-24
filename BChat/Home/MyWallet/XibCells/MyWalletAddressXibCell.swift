// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit

class MyWalletAddressXibCell: UICollectionViewCell {
    static let identifier = "MyWalletAddressXibCell"
    static let nib = UINib(nibName: "MyWalletAddressXibCell", bundle: nil)
    
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var subView:UIView!
    @IBOutlet weak var lblmyaddress:UILabel!
    @IBOutlet weak var img:UIImageView!
    @IBOutlet weak var lblname:UILabel!
    @IBOutlet weak var btncopy:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.cornerRadius = 6
        subView.layer.cornerRadius = 4
        lblmyaddress.layer.cornerRadius = 4
        lblmyaddress.clipsToBounds = true
        let logoName = isLightMode ? "copy-dark" : "copy_white"
        img.image = UIImage(named: logoName)!
    }

}
