// Copyright © 2022 Beldex. All rights reserved.

import Foundation




struct UserDefaultsData {
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
    static var WalletRecoverSeed : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.WalletRecoverSeed) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.WalletRecoverSeed) as? String ?? "" }
    }
    static var BChatPassword : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.BChatPassword) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.BChatPassword) as? String ?? "" }
    }
    static var lastname : String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.lastname) }
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.lastname) as? String ?? "" }
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
}
