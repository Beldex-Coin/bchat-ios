// Copyright © 2022 Beldex. All rights reserved.

import Foundation




struct SaveUserDefaultsData {
    static var messageString = NSLocalizedString("Message", comment: "")
    
    static var isSignedIn : Bool {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.isSignedIn) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.isSignedIn) as? Bool ?? false }
    }
    
    static var viewtype : Bool {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.viewtype) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.viewtype) as? Bool ?? false }
    }
    
    static var WalletpublicAddress : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.WalletpublicAddress) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.WalletpublicAddress) as? String ?? "" }
    }
    static var WalletSeed : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.WalletSeed) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.WalletSeed) as? String ?? "" }
    }
    static var WalletName : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.WalletName) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.WalletName) as? String ?? "" }
    }
    static var WalletRecoverSeed : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.WalletRecoverSeed) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.WalletRecoverSeed) as? String ?? "" }
    }
    static var BChatPassword : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.BChatPassword) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.BChatPassword) as? String ?? "" }
    }
    static var WalletRestoreHeight : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.WalletRestoreHeight) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.WalletRestoreHeight) as? String ?? "" }
    }
    static var lastname : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.lastname) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.lastname) as? String ?? "" }
    }
    static var WalletPassword : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.WalletPassword) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.WalletPassword) as? String ?? "" }
    }
    static var FinalWallet_node : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.FinalWallet_node) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.FinalWallet_node) as? String ?? "" }
    }
    
    static var SelectedNode : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.SelectedNode) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.SelectedNode) as? String ?? "" }
    }
    static var SwitchNode : Bool {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.SwitchNode) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.SwitchNode) as? Bool ?? false }
    }
    static var NameForWallet : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.NameForWallet) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.NameForWallet) as? String ?? "" }
    }
    static var SaveReceipeinetSwitch : Bool {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.SaveReceipeinetSwitch) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.SaveReceipeinetSwitch) as? Bool ?? false }
    }
    static var FeePriority : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.FeePriority) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.FeePriority) as? String ?? "" }
    }
    static var SelectedDecimal : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.SelectedDecimal) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.SelectedDecimal) as? String ?? "" }
    }
    static var SelectedBalance : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.SelectedBalance) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.SelectedBalance) as? String ?? "" }
    }
    
    static var SaveLocalNodelist : [String] {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.SaveLocalNodelist) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.SaveLocalNodelist) as? [String] ?? [] }
    }
    static var SelectedCurrency : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.SelectedCurrency) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.SelectedCurrency) as? String ?? "usd" }
    }
    
}


//MARK:- Userdefault Keys
struct UserDefaultsKeys {
    static let WalletpublicAddress = "WalletpublicAddress"
    static let WalletSeed = "WalletSeed"
    static let WalletRecoverSeed = "WalletRecoverSeed"
    static let BChatPassword = "BChatPassword"
    static let lastname = "lastname"
    static let isSignedIn = "isSignedIn"
    static let viewtype = "viewtype"
    static let WalletName = "WalletName"
    static let WalletRestoreHeight = "WalletRestoreHeight"
    static let WalletPassword = "WalletPassword"
    static let FinalWallet_node = "FinalWallet_node"
    static let SelectedNode = "SelectedNode"
    static let SwitchNode = "SwitchNode"
    static let NameForWallet = "NameForWallet"
    static let SaveReceipeinetSwitch = "SaveReceipeinetSwitch"
    static let FeePriority = "FeePriority"
    static let SelectedDecimal = "SelectedDecimal"
    static let SelectedBalance = "SelectedBalance"
    static let SaveLocalNodelist = "SaveLocalNodelist"
    static let SelectedCurrency = "SelectedCurrency"
}
