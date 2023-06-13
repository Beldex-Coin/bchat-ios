// Copyright © 2022 Beldex. All rights reserved.

import UIKit
import PromiseKit
import BChatUIKit

class Groupcell: UICollectionViewCell {
    
    static let identifier = "Groupcell"
    static let nib = UINib(nibName: "Groupcell", bundle: nil)
    
    @IBOutlet weak var lblname:UILabel!
    @IBOutlet weak var imgpic:UIImageView!
    @IBOutlet weak var viewBackground:UIView!
    var allroom: OpenGroupAPIV2.Info? { didSet { update() } }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewBackground.layer.cornerRadius = 6
        imgpic.layer.cornerRadius = 4
        imgpic.clipsToBounds = true
        
        self.update()
        
    }
    
    
    private func update() {
        guard let room = allroom else { return }
        let promise = OpenGroupAPIV2.getGroupImage(for: room.id, on: OpenGroupAPIV2.defaultServer)
      //  print("------ \(room.name)")
        if let imageData: Data = promise.value {
            imgpic.image = UIImage(data: imageData)
            imgpic.isHidden = (imgpic.image == nil)
        }
        else {
            imgpic.isHidden = true
            _ = promise.done { [weak self] imageData in
                DispatchQueue.main.async {
                    self?.imgpic.image = UIImage(data: imageData)
                    self?.imgpic.isHidden = (self?.imgpic.image == nil)
                }
            }
        }
        lblname.text = room.name
    }

}
