//
//  ProfileCell.swift
//  Partea
//
//  Created by Blockhash on 18/09/21.
//

import UIKit

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var imgpic:UIImageView!
    @IBOutlet weak var loginBtn:UIButton!
    @IBOutlet weak var lblname:UILabel!
    @IBOutlet weak var imgPic:UIImageView!
    @IBOutlet weak var lblIDName:UILabel!
    @IBOutlet weak var MCRef:UIButton!
    @IBOutlet weak var scanRef:UIButton!
    @IBOutlet weak var v1:UIView!
    @IBOutlet weak var SettingsRef:UIButton!
    @IBOutlet weak var FreelanceRef:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgpic.layer.masksToBounds = false
        imgpic.layer.cornerRadius = 4
        imgpic.clipsToBounds = true
        
        v1.layer.cornerRadius = 10
        
        if isLightMode {
            let origImage = UIImage(named: "icons8-qr_code@3x")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            scanRef.setImage(tintedImage, for: .normal)
            scanRef.tintColor = .black
        }else {
            let origImage = UIImage(named: "qr_code_menu@3x")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            scanRef.setImage(tintedImage, for: .normal)
            scanRef.tintColor = .white
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
