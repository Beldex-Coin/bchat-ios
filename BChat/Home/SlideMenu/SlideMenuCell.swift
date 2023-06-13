//
//  SlideMenuCell.swift
//  Partea
//
//  Created by Blockhash on 30/08/21.
//

import UIKit

class SlideMenuCell: UITableViewCell {
    
    @IBOutlet weak var lblname:UILabel!
    @IBOutlet weak var img:UIImageView!
    @IBOutlet weak var backgroundview:UIView!
    @IBOutlet weak var sampleSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundview.layer.cornerRadius = 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
