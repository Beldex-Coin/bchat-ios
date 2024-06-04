// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

extension WalletAddressBookNewVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearched == true {
            return searchfilterNameArray.count
        } else {
            return filterBeldexAddressArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AddressBookTableCell(style: .default, reuseIdentifier: "AddressBookTableCell")
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        if flagSendAddress == false {
            if isSearched == true {
                let intIndex = indexPath.row
                let index = searchfilterNameArray.index(searchfilterNameArray.startIndex, offsetBy: intIndex)
                cell.nameLabel.text = searchfilterNameArray.keys[index]
                cell.addressIDLabel.text = searchfilterNameArray.values[index]
            } else {
                cell.nameLabel.text = filterContactNameArray[indexPath.item]
                cell.addressIDLabel.text = filterBeldexAddressArray[indexPath.item]
            }
            cell.copyAndSendButton.tag = indexPath.row
            cell.copyAndSendButton.addTarget(self, action: #selector(self.copyAndSendActionTapped(_:)), for: .touchUpInside)
            
        } else {
            if isSearched == true {
                let intIndex = indexPath.item
                let index = searchfilterNameArray.index(searchfilterNameArray.startIndex, offsetBy: intIndex)
                cell.nameLabel.text = searchfilterNameArray.keys[index]
                cell.addressIDLabel.text = searchfilterNameArray.values[index]
            } else {
                cell.nameLabel.text = filterContactNameArray[indexPath.item]
                cell.addressIDLabel.text = filterBeldexAddressArray[indexPath.item]
            }
            
        }
        
        if isGoingToSendScreen{
            cell.copyAndSendButton.setImage(UIImage(named: "ic_send_bdxaddress")!, for: UIControl.State.normal)
        }else {
            cell.copyAndSendButton.setImage(UIImage(named: "ic_copy_white2")!, for: UIControl.State.normal)
            cell.copyAndSendButton.backgroundColor = Colors.bothGreenColor
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
