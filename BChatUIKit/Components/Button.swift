import UIKit

public final class Button : UIButton {
    private let style: Style
    private let size: Size
    private var heightConstraint: NSLayoutConstraint!
    
    public enum Style {
        case unimportant, regular, prominentOutline, prominentFilled, regularBorderless, destructiveOutline, unimportant2, prominentFilled2, prominentFilled3
    }
    
    public enum Size {
        case medium, large, small
    }
    
    public init(style: Style, size: Size) {
        self.style = style
        self.size = size
        super.init(frame: .zero)
        setUpStyle()
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppModeChangedNotification(_:)), name: .appModeChanged, object: nil)
    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(style:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(style:) instead.")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setUpStyle() {
        let fillColor: UIColor
        switch style {
        case .unimportant: fillColor = isLightMode ? UIColor.clear : Colors.unimportantButtonBackground
        case .unimportant2: fillColor = isLightMode ? Colors.unimportantButtonBackgroundColor : Colors.unimportantButtonBackgroundColor
        case .regular: fillColor = UIColor.clear
        case .prominentOutline: fillColor = UIColor.clear
        case .prominentFilled: fillColor = isLightMode ? Colors.text : Colors.accent
        case .prominentFilled2: fillColor = isLightMode ? Colors.accentColor : Colors.accentColor
        case .prominentFilled3: fillColor = isLightMode ? Colors.accentFullColor : Colors.accentFullColor
        case .regularBorderless: fillColor = UIColor.clear
        case .destructiveOutline: fillColor = UIColor.clear
        }
        let borderColor: UIColor
        switch style {
        case .unimportant: borderColor = isLightMode ? Colors.text : Colors.unimportantButtonBackground
        case .unimportant2: borderColor = isLightMode ? Colors.text : Colors.unimportantButtonBackgroundColor
        case .regular: borderColor = Colors.text
        case .prominentOutline: borderColor = isLightMode ? Colors.text : Colors.accent
        case .prominentFilled: borderColor = isLightMode ? Colors.text : Colors.accent
        case .prominentFilled2: borderColor = isLightMode ? Colors.text : Colors.accentColor
        case .prominentFilled3: borderColor = isLightMode ? Colors.text : Colors.accentColor
        case .regularBorderless: borderColor = UIColor.clear
        case .destructiveOutline: borderColor = Colors.destructive
        }
        let textColor: UIColor
        switch style {
        case .unimportant: textColor = Colors.text
        case .unimportant2: textColor = UIColor.white
        case .regular: textColor = Colors.text
        case .prominentOutline: textColor = isLightMode ? Colors.text : Colors.accent
        case .prominentFilled: textColor = isLightMode ? UIColor.white : Colors.text
        case .prominentFilled2: textColor = isLightMode ? UIColor.white : Colors.text
        case .prominentFilled3: textColor = isLightMode ? UIColor.white : UIColor.white
        case .regularBorderless: textColor = Colors.text
        case .destructiveOutline: textColor = Colors.destructive
        }
        let height: CGFloat
        switch size {
        case .small: height = Values.smallButtonHeight
        case .medium: height = Values.mediumButtonHeight
        case .large: height = Values.largeButtonHeight
        }
        if heightConstraint == nil { heightConstraint = set(.height, to: height) }
        layer.cornerRadius = 6
        backgroundColor = fillColor
        if #available(iOS 13.0, *) {
            layer.borderColor = borderColor
                .resolvedColor(
                    // Note: This is needed for '.cgColor' to support dark mode
                    with: UITraitCollection(userInterfaceStyle: isDarkMode ? .dark : .light)
                ).cgColor
        } else {
            layer.borderColor = borderColor.cgColor
        }
        layer.borderWidth = 0
        let fontSize = (size == .small) ? Values.smallFontSize : Values.mediumFontSize
        titleLabel!.font = Fonts.boldOpenSans(ofSize: fontSize)
        setTitleColor(textColor, for: UIControl.State.normal)
    }

    @objc private func handleAppModeChangedNotification(_ notification: Notification) {
        setUpStyle()
    }
}
