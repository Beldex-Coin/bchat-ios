// Copyright © 2026 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

final class LanguageSelectionViewController: BaseVC {
    
    private let languages = AppLanguage.manager.supportedLanguages
    
    /// tableView
    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.backgroundColor = Colors.mainBackGroundColor2
        result.separatorStyle = .none
        result.register(LanguageTableViewCell.self, forCellReuseIdentifier: LanguageTableViewCell.identifier)
        result.showsVerticalScrollIndicator = false
        result.dataSource = self
        result.delegate = self
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBarStyle()
        setUpLayout()
        self.title = NSLocalizedString("MY_ACCOUNT_SELECT_LANGUAGE_TITLE", comment: "")
    }
    
    private func setUpLayout() {
        
        view.backgroundColor = Colors.mainBackGroundColor2
        view.addSubview(tableView)
        
        tableView.pin(.top, to: .top, of: view, withInset: 15)
        tableView.pin(.leading, to: .leading, of: view, withInset: 16)
        tableView.pin(.trailing, to: .trailing, of: view, withInset: -16)
        tableView.pin(.bottom, to: .bottom, of: view)
    }
    
    private func reloadApp() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.reloadRootViewController()
    }
    
    private func isSelectedLanguage(_ language: AppLanguage.Lang) -> Bool {
        return AppLanguage.manager.current == language
    }
}

extension LanguageSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LanguageTableViewCell.identifier) as! LanguageTableViewCell
        
        let language = languages[indexPath.row]
        cell.configure(
            with: language.displayName,
            isSelected: isSelectedLanguage(language)
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = languages[indexPath.row]
        guard AppLanguage.manager.current != language else { return }
        AppLanguage.manager.current = language
        reloadApp()
    }
}
