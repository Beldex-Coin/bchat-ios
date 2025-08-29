//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import UIKit
import BChatUIKit

public extension NSObject {

    func navigationBarButton(imageName: String,
                                     selector: Selector) -> UIView {
        let button = OWSButton()
        button.setImage(imageName: imageName)
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        let isAppThemeLight = CurrentAppContext().appUserDefaults().bool(forKey: appThemeIsLight)
        button.tintColor = isAppThemeLight ? .black : .white
        
        return button
    }
}

// MARK: -

public extension UIViewController {

    func updateNavigationBar(navigationBarItems: [UIView]) {
        guard navigationBarItems.count > 0 else {
            self.navigationItem.rightBarButtonItems = []
            return
        }

        let spacing: CGFloat = 16
        let stackView = UIStackView(arrangedSubviews: navigationBarItems)
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.alignment = .center
        
        // Ensure layout works on older versions of iOS.
        var stackSize = CGSize.zero
        for item in navigationBarItems {
            let itemSize = item.sizeThatFits(.zero)
            stackSize.width += itemSize.width + spacing
            stackSize.height = max(stackSize.height, itemSize.height)
        }
        if navigationBarItems.count > 0 {
            stackSize.width -= spacing
        }
        stackView.frame = CGRect(origin: .zero, size: stackSize)

        let isAppThemeLight = CurrentAppContext().appUserDefaults().bool(forKey: appThemeIsLight)
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = isAppThemeLight ? .light : .dark
        } else {
            // Fallback on earlier versions
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackView)
        
        guard let navigationBar = navigationController?.navigationBar else { return }
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = .clear
            appearance.backgroundColor = Colors.navigationBarBackground //isAppThemeLight ? .black : .white
            navigationBar.tintColor = Colors.text
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        } else {
            // Beldex: Set navigation bar background color
            let navigationBar = navigationController!.navigationBar
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
            navigationBar.isTranslucent = false
            let color = isLightMode ? UIColor(hex: 0xFCFCFC) : UIColor(hex: 0x161616)
            navigationBar.barTintColor = color
            navigationBar.backgroundColor = color
            navigationBar.tintColor = isAppThemeLight ? .black : .white
            let backgroundImage = UIImage(color: color)
            navigationBar.setBackgroundImage(backgroundImage, for: .default)
        }
    }
}
