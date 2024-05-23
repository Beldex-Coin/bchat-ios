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
            cell.copyButton.tag = indexPath.row
            cell.copyButton.addTarget(self, action: #selector(self.copyActionTapped(_:)), for: .touchUpInside)
            
            cell.shareButton.tag = indexPath.row
            cell.shareButton.addTarget(self, action: #selector(self.shareActionTapped(_:)), for: .touchUpInside)
            
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
