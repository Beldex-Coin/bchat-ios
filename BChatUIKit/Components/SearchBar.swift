import UIKit

public final class SearchBar : UISearchBar {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpBChatStyle()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpBChatStyle()
    }
}

public extension UISearchBar {
    
    func setUpBChatStyle() {
        searchBarStyle = .minimal // Hide the border around the search bar
        barStyle = .black // Use Apple's black design as a base
        tintColor = Colors.titleColor // The cursor color
        let searchImage = #imageLiteral(resourceName: "searchbar_search").withTint(Colors.searchBarPlaceholder)!
        setImage(searchImage, for: .search, state: .normal)
        let clearImage = #imageLiteral(resourceName: "searchbar_clear").withTint(Colors.searchBarPlaceholder)!
        setImage(clearImage, for: .clear, state: .normal)
        let searchTextField: UITextField
        if #available(iOS 13, *) {
            searchTextField = self.searchTextField
        } else {
            searchTextField = self.value(forKey: "_searchField") as! UITextField
        }
        searchTextField.backgroundColor = Colors.searchBarBackground // The search bar background color
        searchTextField.textColor = Colors.titleColor
        if UIScreen.main.traitCollection.userInterfaceStyle == .light && !isLightMode {
            searchTextField.textColor = Colors.callCellTitle
        }
        if UIScreen.main.traitCollection.userInterfaceStyle == .dark && isLightMode {
            searchTextField.textColor = Colors.darkThemeTextBoxColor
        }
        searchTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Search", comment: ""), attributes: [ .foregroundColor : Colors.searchBarPlaceholder ])
        searchTextField.becomeFirstResponder()
        setPositionAdjustment(UIOffset(horizontal: 4, vertical: 0), for: UISearchBar.Icon.search)
        searchTextPositionAdjustment = UIOffset(horizontal: 2, vertical: 0)
        setPositionAdjustment(UIOffset(horizontal: -4, vertical: 0), for: UISearchBar.Icon.clear)
    }
}
