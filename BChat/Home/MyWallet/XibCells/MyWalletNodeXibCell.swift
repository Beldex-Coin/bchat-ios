// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit

class MyWalletNodeXibCell: UICollectionViewCell {
    static let identifier = "MyWalletNodeXibCell"
    static let nib = UINib(nibName: "MyWalletNodeXibCell", bundle: nil)
    
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var viewcolour:UIView!
    @IBOutlet weak var lblmyaddress:UILabel!
    @IBOutlet weak var lblDetails:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.cornerRadius = 6
        viewcolour.layer.cornerRadius = viewcolour.layer.frame.width/2
        viewcolour.clipsToBounds = true
        
        //CONNECTION ERROR/Last Block:29 seconds ago
    }

}
