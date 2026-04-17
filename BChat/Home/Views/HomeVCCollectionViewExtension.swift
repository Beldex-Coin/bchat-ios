// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        messageRequestCountLabel.text = "\(Int(messageRequestCountForMessageRequest))"
        messageRequestCountLabel.isHidden = (Int(messageRequestCountForMessageRequest) <= 0)
        messageRequestLabel.isHidden = (Int(messageRequestCountForMessageRequest) <= 0)
        showOrHideMessageRequestCollectionViewButton.isHidden = (Int(messageRequestCountForMessageRequest) <= 0)
        messageCollectionView.isHidden = (Int(messageRequestCountForMessageRequest) <= 0)
        
        if messageRequestCountForMessageRequest == 0 {
            tableViewTopConstraint.isActive = false
            setTableViewTopConstraint(16)
            self.messageCollectionView.isHidden = true
            self.showOrHideMessageRequestCollectionViewButton.isSelected = false
            messageRequestCountLabel.isHidden = true
            messageRequestLabel.isHidden = true
            showOrHideMessageRequestCollectionViewButton.isHidden = true
        } else {
            tableViewTopConstraint.isActive = false
            setTableViewTopConstraint(134) //80 + 38 + 16
            self.messageCollectionView.isHidden = false
            self.showOrHideMessageRequestCollectionViewButton.isSelected = true
            messageRequestCountLabel.isHidden = false
            messageRequestLabel.isHidden = false
            showOrHideMessageRequestCollectionViewButton.isHidden = false
            if isManualyCloseMessageRequest {
                tableViewTopConstraint.isActive = false
                setTableViewTopConstraint(54) //0 + 38 + 16
                self.messageCollectionView.isHidden = true
                self.showOrHideMessageRequestCollectionViewButton.isSelected = false
            }
        }
        return Int(messageRequestCountForMessageRequest)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = messageCollectionView.dequeueReusableCell(withReuseIdentifier: MessageRequestCollectionViewCell.reuseidentifier, for: indexPath) as! MessageRequestCollectionViewCell

        cell.threadViewModel = threadViewModelForMessageRequest(at: indexPath.item)
                cell.verifiedImageView.isHidden = true
        if let thread = threadViewModel(at: indexPath.item)?.threadRecord {
            if let contactThread = thread as? TSContactThread {
                let contact: Contact? = Storage.shared.getContact(with: contactThread.contactBChatID())
                if let _ = contact, let isBnsUser = contact?.isBnsHolder {
                    cell.profileImageView.layer.borderWidth = isBnsUser ? Values.borderThickness : 0
                    cell.profileImageView.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
                    cell.verifiedImageView.isHidden = isBnsUser ? false : true
                }
            }
        }
        
        cell.removeCallback = {
            guard let thread = self.threadForMessageRequest(at: indexPath.row) else { return }
            self.deleteForMessageRequest(thread)
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 6  //number of column you want
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: 65, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = NewMessageRequestVC()
        navigationController!.pushViewController(vc, animated: true)
    }
}
