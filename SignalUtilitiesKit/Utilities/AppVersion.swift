// Copyright © 2025 Beldex International Limited OU. All rights reserved.

/*
let kNSUserDefaults_FirstAppVersion = "kNSUserDefaults_FirstAppVersion"
let kNSUserDefaults_LastAppVersion = "kNSUserDefaults_LastVersion"
let kNSUserDefaults_LastCompletedLaunchAppVersion = "kNSUserDefaults_LastCompletedLaunchAppVersion"
let kNSUserDefaults_LastCompletedLaunchAppVersion_MainApp = "kNSUserDefaults_LastCompletedLaunchAppVersion_MainApp"
let kNSUserDefaults_LastCompletedLaunchAppVersion_SAE = "kNSUserDefaults_LastCompletedLaunchAppVersion_SAE"

@objc class AppVersion: NSObject {
    
    private var firstAppVersion: String?
    private var lastAppVersion: String?
    private var currentAppVersion: String?
    private var lastCompletedLaunchAppVersion: String?
    private var lastCompletedLaunchMainAppVersion: String?
    private var lastCompletedLaunchSAEAppVersion: String?
    
    // MARK: - Properties
    
    static let sharedInstance = AppVersion()
    
    // Force usage as a singleton
    override private init() {
        super.init()
        
        configure()
    }
    
    func configure() {
        
        currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        firstAppVersion = UserDefaults.standard.string(forKey: kNSUserDefaults_FirstAppVersion)
        lastAppVersion = UserDefaults.standard.string(forKey: kNSUserDefaults_LastAppVersion)
        lastCompletedLaunchAppVersion = UserDefaults.standard.string(forKey: kNSUserDefaults_LastCompletedLaunchAppVersion)
        lastCompletedLaunchMainAppVersion = UserDefaults.standard.string(forKey: kNSUserDefaults_LastCompletedLaunchAppVersion_MainApp)
        lastCompletedLaunchSAEAppVersion = UserDefaults.standard.string(forKey: kNSUserDefaults_LastCompletedLaunchAppVersion_SAE)
    }
}
*/
