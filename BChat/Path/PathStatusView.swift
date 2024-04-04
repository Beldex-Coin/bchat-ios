import UIKit

final class PathStatusView : UIView {
    
    static let size = CGFloat(10)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViewHierarchy()
        registerObservers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViewHierarchy()
        registerObservers()
    }
    
//    private func setUpViewHierarchy() {
//        layer.cornerRadius = PathStatusView.size / 2
//        layer.masksToBounds = false
//        if OnionRequestAPI.paths.isEmpty {
//            OnionRequestAPI.paths = Storage.shared.getOnionRequestPaths()
//        }
//        let color = (!OnionRequestAPI.paths.isEmpty) ? Colors.accent : Colors.pathsBuilding
//        setColor(to: color, isAnimated: false)
//    }
    
    private func setUpViewHierarchy() {
        layer.cornerRadius = PathStatusView.size / 2
        layer.masksToBounds = false
        if NetworkReachabilityStatus.isConnectedToNetworkSignal(){
            setColor(to: UIColor(red: 0.07, green: 0.55, blue: 0.08, alpha: 1.00), isAnimated: true)
        }else{
            OnionRequestAPI.paths = Storage.shared.getOnionRequestPaths()
            setColor(to: UIColor(red: 1.00, green: 0.81, blue: 0.23, alpha: 1.00), isAnimated: true)
        }
    }

    private func registerObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleBuildingPathsNotification), name: .buildingPaths, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handlePathsBuiltNotification), name: .pathsBuilt, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setColor(to color: UIColor, isAnimated: Bool) {
        backgroundColor = color
        let size = PathStatusView.size
        let glowConfiguration = UIView.CircularGlowConfiguration(size: size, color: color, isAnimated: isAnimated, radius: isLightMode ? 6 : 8)
        setCircularGlow(with: glowConfiguration)
    }

    @objc private func handleBuildingPathsNotification() {
        setColor(to: Colors.pathsBuilding, isAnimated: true)
    }

    @objc private func handlePathsBuiltNotification() {
        setColor(to: UIColor(hex: 0x00FF05), isAnimated: true)
    }
}
public class NetworkReachabilityStatus {
    class func isConnectedToNetworkSignal() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         return isReachable && !needsConnection
         */
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        return ret
    }
}
