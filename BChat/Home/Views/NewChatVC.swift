// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewChatVC: BaseVC, UITextFieldDelegate {
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.semiOpenSans(ofSize: 20)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "New"
        return result
    }()
    
    private lazy var searchTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(
            string: "Search people and groups",
            attributes: [NSAttributedString.Key.foregroundColor: Colors.textFieldPlaceHolderColor]
        )
        result.font = Fonts.OpenSans(ofSize: 14)
        result.layer.borderColor = Colors.borderColorNew.cgColor
        result.backgroundColor = Colors.unlockButtonBackgroundColor
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 24
        result.layer.borderWidth = 0
        result.textColor = Colors.titleColor3
        result.textAlignment = .left
        
        // Add left padding
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 17 + 16 + 10, height: 16))
        result.leftView = paddingViewLeft
        result.leftViewMode = .always
        
        // Add right padding
        let paddingViewRight = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 12))
        result.rightView = paddingViewRight
        result.rightViewMode = .always
        
        // Create an UIImageView and set its image for search icon
        let searchIconImageView = UIImageView(image: UIImage(named: "ic_Search_Vector_New"))
        searchIconImageView.frame = CGRect(x: 17, y: 0, width: 16, height: 16)
        searchIconImageView.contentMode = .scaleAspectFit
        paddingViewLeft.addSubview(searchIconImageView)
        
        // Create an UIImageView for close icon initially hidden
        let closeIconImageView = UIImageView(image: UIImage(named: "ic_closeNew"))
        closeIconImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 14)
        closeIconImageView.contentMode = .scaleAspectFit
        closeIconImageView.tag = 1 // Set a tag to distinguish it from the search icon
        closeIconImageView.isHidden = true
        paddingViewRight.addSubview(closeIconImageView)
        
        // Add tap gesture recognizer to closeIconImageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeIconTapped))
        closeIconImageView.isUserInteractionEnabled = true
        closeIconImageView.addGestureRecognizer(tapGestureRecognizer)
        result.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return result
    }()
    
    
    lazy var newChatImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "new_chat")
        result.set(.width, to: 36)
        result.set(.height, to: 36)
        result.layer.masksToBounds = true
        result.contentMode = .center
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(newChatButtonTapped))
        result.isUserInteractionEnabled = true
        result.addGestureRecognizer(tapGestureRecognizer)
        return result
    }()
    
    private lazy var newChatButton: UIButton = {
        let button = UIButton()
        button.setTitle("New Chat", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(UIColor(hex: 0x00BD40), for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(newChatButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var scanerImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_qrNewChat")
        result.set(.width, to: 28)
        result.set(.height, to: 28)
        result.layer.masksToBounds = true
        result.contentMode = .center
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scannerImageViewTapped))
        result.isUserInteractionEnabled = true
        result.addGestureRecognizer(tapGestureRecognizer)
        return result
    }()
    
    lazy var secretGroupImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "scrt_grp")
        result.set(.width, to: 36)
        result.set(.height, to: 36)
        result.layer.masksToBounds = true
        result.contentMode = .center
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(secretGroupButtonTapped))
        result.isUserInteractionEnabled = true
        result.addGestureRecognizer(tapGestureRecognizer)
        return result
    }()
    
    private lazy var secretGroupButton: UIButton = {
        let button = UIButton()
        button.setTitle("Secret Group", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(secretGroupButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var socialGroupImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "social_grp")
        result.set(.width, to: 36)
        result.set(.height, to: 36)
        result.layer.masksToBounds = true
        result.contentMode = .center
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(socialGroupButtonTapped))
        result.isUserInteractionEnabled = true
        result.addGestureRecognizer(tapGestureRecognizer)
        return result
    }()
    
    private lazy var socialGroupButton: UIButton = {
        let button = UIButton()
        button.setTitle("Social Group", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(socialGroupButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var noteToSelfImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_newNote")
        result.set(.width, to: 36)
        result.set(.height, to: 36)
        result.layer.masksToBounds = true
        result.contentMode = .center
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(noteToSelfButtonTapped))
        result.isUserInteractionEnabled = true
        result.addGestureRecognizer(tapGestureRecognizer)
        return result
    }()
    
    private lazy var noteToSelfButton: UIButton = {
        let button = UIButton()
        button.setTitle("Note to Self", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(noteToSelfButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var contactListLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.noDataLabelColor
        result.font = Fonts.OpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Contact list"
        return result
    }()
    
    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.backgroundColor = Colors.mainBackGroundColor2
        result.separatorStyle = .none
        result.register(NewChatTableViewCell.self, forCellReuseIdentifier: "NewChatTableViewCell")
        result.showsVerticalScrollIndicator = false
        return result
    }()
    
    lazy var inviteFriendImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 36)
        result.set(.height, to: 36)
        result.contentMode = .center
        result.image = UIImage(named: "ic_inviteFriend")
        return result
    }()
    
    private lazy var inviteFriendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Invite a friend", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(inviteFriendButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    internal var threadCount: UInt {
        threads.numberOfItems(inGroup: TSInboxGroup)
    }
    
    @objc public var searchText = "" {
        didSet {
            AssertIsOnMainThread()
            // Use a slight delay to debounce updates.
            refreshSearchResults()
        }
    }
    
    var recentSearchResults: [String] = Array(Storage.shared.getRecentSearchResults().reversed())
    var defaultSearchResults: HomeScreenSearchResultSet = HomeScreenSearchResultSet.noteToSelfOnly
    var searchResultSet: HomeScreenSearchResultSet = HomeScreenSearchResultSet.empty
    private var lastSearchText: String?
    var searcher: FullTextSearcher {
        return FullTextSearcher.shared
    }
    var isLoading = false
    
    enum SearchSection: Int {
        case contacts
    }
    
    var dbReadConnection: YapDatabaseConnection {
        return OWSPrimaryStorage.shared().dbReadConnection
    }
    
    private func reloadTableData() {
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2
        
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "New"
        
        view.addSubviews([ searchTextField, newChatImageView, newChatButton, scanerImageView, secretGroupImageView, secretGroupButton, socialGroupImageView, socialGroupButton, noteToSelfImageView, noteToSelfButton])
        view.addSubview(contactListLabel)
        view.addSubview(inviteFriendImageView)
        view.addSubview(inviteFriendButton)
        
        searchTextField.delegate = self
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 17),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            searchTextField.heightAnchor.constraint(equalToConstant: 48),
            
            newChatImageView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 15),
            newChatImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            newChatButton.leadingAnchor.constraint(equalTo: newChatImageView.trailingAnchor, constant: 13),
            newChatButton.centerYAnchor.constraint(equalTo: newChatImageView.centerYAnchor),
            scanerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scanerImageView.centerYAnchor.constraint(equalTo: newChatImageView.centerYAnchor),
            
            
            secretGroupImageView.topAnchor.constraint(equalTo: newChatImageView.bottomAnchor, constant: 15),
            secretGroupImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            secretGroupButton.leadingAnchor.constraint(equalTo: secretGroupImageView.trailingAnchor, constant: 13),
            secretGroupButton.centerYAnchor.constraint(equalTo: secretGroupImageView.centerYAnchor),
            
            socialGroupImageView.topAnchor.constraint(equalTo: secretGroupImageView.bottomAnchor, constant: 15),
            socialGroupImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            socialGroupButton.leadingAnchor.constraint(equalTo: socialGroupImageView.trailingAnchor, constant: 13),
            socialGroupButton.centerYAnchor.constraint(equalTo: socialGroupImageView.centerYAnchor),
            
            noteToSelfImageView.topAnchor.constraint(equalTo: socialGroupImageView.bottomAnchor, constant: 15),
            noteToSelfImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            noteToSelfButton.leadingAnchor.constraint(equalTo: noteToSelfImageView.trailingAnchor, constant: 13),
            noteToSelfButton.centerYAnchor.constraint(equalTo: noteToSelfImageView.centerYAnchor),
            
            contactListLabel.topAnchor.constraint(equalTo: noteToSelfImageView.bottomAnchor, constant: 16),
            contactListLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            
            inviteFriendImageView.topAnchor.constraint(equalTo: contactListLabel.bottomAnchor, constant: 16),
            inviteFriendImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            
            inviteFriendButton.centerYAnchor.constraint(equalTo: inviteFriendImageView.centerYAnchor),
            inviteFriendButton.leadingAnchor.constraint(equalTo: inviteFriendImageView.trailingAnchor, constant: 14),
        ])
        
        // Table view
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.pin(.leading, to: .leading, of: view)
        tableView.pin(.top, to: .bottom, of: contactListLabel, withInset: 16 + 36 + 8)
        tableView.pin(.trailing, to: .trailing, of: view)
        tableView.pin(.bottom, to: .bottom, of: view)
        
        dbConnection.beginLongLivedReadTransaction()
        // Notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleYapDatabaseModifiedNotification(_:)), name: .YapDatabaseModified, object: OWSPrimaryStorage.shared().dbNotificationObject)
        
        threads = YapDatabaseViewMappings(groups: [ TSMessageRequestGroup, TSInboxGroup ], view: TSThreadDatabaseViewExtensionName) // The extension should be registered at this point
        threads.setIsReversed(true, forGroup: TSInboxGroup)
        dbConnection.read { transaction in
            self.threads.update(with: transaction) // Perform the initial update
        }
    }
    
    
    @objc private func handleYapDatabaseModifiedNotification(_ yapDatabase: YapDatabase) {
        AssertIsOnMainThread()
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reload()
    }
    
    @objc func newChatButtonTapped(_ sender: UIButton) {
        let vc = NewChatPopUpVC()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func secretGroupButtonTapped(_ sender: UIButton) {
        let vc = CreateSecretGroupScreenVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func socialGroupButtonTapped(_ sender: UIButton) {
        let vc = SocialGroupNewVC()
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func noteToSelfButtonTapped(_ sender: UIButton) {
        
        DispatchMainThreadSafe {
            if let presentedVC = self.presentedViewController {
                presentedVC.dismiss(animated: false, completion: nil)
            }
            let conversationVC = ConversationVC(thread: HomeScreenSearchResultSet.noteToSelfOnly.conversations[0].thread.threadRecord, focusedMessageID: nil)
            var viewControllers = self.navigationController?.viewControllers
            viewControllers?.append(conversationVC)
            self.navigationController?.setViewControllers(viewControllers!, animated: true)
        }
    }
    
    @objc func scannerImageViewTapped() {
        let vc = ScanNewVC()
        vc.newChatScanflag = false
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func inviteFriendButtonTapped(_ sender: UIButton) {
        let appStoreURL = "https://apps.apple.com/app/id1626066143"
        let shareVC = UIActivityViewController(activityItems: [ appStoreURL ], applicationActivities: nil)
        self.navigationController!.present(shareVC, animated: true, completion: nil)
    }
    
    @objc func show(_ thread: TSThread, with action: ConversationViewAction, highlightedMessageID: String?, animated: Bool) {
        DispatchMainThreadSafe {
            if let presentedVC = self.presentedViewController {
                presentedVC.dismiss(animated: false, completion: nil)
            }
        }
        let conversationVC = ConversationVC(thread: thread)
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController!.pushViewController(conversationVC, animated: true)
    }
    
    private var threads: YapDatabaseViewMappings!
    internal var threadViewModelCache: [String:ThreadViewModel] = [:]
    private lazy var dbConnection: YapDatabaseConnection = {
        let result = OWSPrimaryStorage.shared().newDatabaseConnection()
        result.objectCacheLimit = 500
        return result
    }()
    private var isReloading = false
    
    private func reload() {
        AssertIsOnMainThread()
        guard !isReloading else { return }
        isReloading = true
        dbConnection.beginLongLivedReadTransaction() // Jump to the latest commit
        dbConnection.read { transaction in
            self.threads.update(with: transaction)
        }
        threadViewModelCache.removeAll()
        tableView.reloadData()
        isReloading = false
    }
    
    func thread(at index: Int) -> TSThread? {
        var thread: TSThread? = nil
        dbConnection.read { transaction in
            // Note: Section needs to be '1' as we now have 'TSMessageRequests' as the 0th section
            let ext = transaction.ext(TSThreadDatabaseViewExtensionName) as! YapDatabaseViewTransaction
            thread = ext.object(atRow: UInt(index), inSection: 1, with: self.threads) as? TSThread
        }
        return thread
    }
    
    func threadViewModel(at index: Int) -> ThreadViewModel? {
        guard let thread = thread(at: index) else { return nil }
        if let cachedThreadViewModel = threadViewModelCache[thread.uniqueId!] {
            return cachedThreadViewModel
        } else {
            var threadViewModel: ThreadViewModel? = nil
            dbConnection.read { transaction in
                threadViewModel = ThreadViewModel(thread: thread, transaction: transaction)
            }
            threadViewModelCache[thread.uniqueId!] = threadViewModel
            return threadViewModel
        }
    }
    
    @objc func closeIconTapped() {
        searchTextField.text = ""
        tableView.reloadData()
        // Get the right view of the search text field
        if let rightView = searchTextField.rightView {
            // Iterate through subviews of the right view to find the close icon image view
            for subview in rightView.subviews {
                if let closeIconImageView = subview as? UIImageView, closeIconImageView.tag == 1 {
                    // Hide the close icon image view
                    closeIconImageView.isHidden = true
                    self.updateSearchText()
                }
            }
        }
        // Get the right view of the search text field
        if let rightView = searchTextField.rightView {
            // Iterate through subviews of the right view to find the search icon image view
            for subview in rightView.subviews {
                if let searchIconImageView = subview as? UIImageView, searchIconImageView.tag != 1 {
                    // Show the search icon image view
                    searchIconImageView.isHidden = false
                    self.updateSearchText()
                }
            }
        }
    }
    
    //Text Enter Action
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Show/hide search and close icons based on text
        if let rightView = textField.rightView {
            if let searchIconImageView = rightView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                searchIconImageView.isHidden = !textField.text!.isEmpty
                self.updateSearchText()
            }
            if let closeIconImageView = rightView.subviews.first(where: { $0 is UIImageView && $0.tag == 1 }) as? UIImageView {
                closeIconImageView.isHidden = textField.text!.isEmpty
                self.updateSearchText()
            }
        }
    }
    
    
    // MARK: Update Search Results
    
    var refreshTimer: Timer?
    
    private func refreshSearchResults() {
        refreshTimer?.invalidate()
        refreshTimer = WeakTimer.scheduledTimer(timeInterval: 0.1, target: self, userInfo: nil, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.updateSearchResults(searchText: self.searchText)
        }
    }
    
    private func updateSearchResults(searchText rawSearchText: String) {
        
        let searchText = rawSearchText.stripped
        guard searchText.count > 0 else {
            searchResultSet = HomeScreenSearchResultSet.empty//defaultSearchResults
            lastSearchText = nil
            reloadTableData()
            return
        }
        guard lastSearchText != searchText else { return }
        
        lastSearchText = searchText
        
        var searchResults: HomeScreenSearchResultSet?
        self.dbReadConnection.asyncRead({[weak self] transaction in
            guard let self = self else { return }
            self.isLoading = true
            // The max search result count is set according to the keyword length. This is just a workaround for performance issue.
            // The longer and more accurate the keyword is, the less search results should there be.
            searchResults = self.searcher.searchForHomeScreen(searchText: searchText, maxSearchResults: 500,  transaction: transaction)
        }, completionBlock: { [weak self] in
            AssertIsOnMainThread()
            guard let self = self, let results = searchResults, self.lastSearchText == searchText else { return }
            self.searchResultSet = results
            self.isLoading = false
            self.reloadTableData()
            self.refreshTimer = nil
        })
    }
    
    
    func updateSearchText() {
        guard let searchText = searchTextField.text?.ows_stripped() else { return }
        self.searchText = searchText
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.updateSearchText()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.updateSearchText()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
}


extension NewChatVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchText.count == 0 {
            return Int(threadCount)
        }
        return searchResultSet.conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewChatTableViewCell") as! NewChatTableViewCell
        
        if self.searchText.count == 0 {
            cell.threadViewModel = threadViewModel(at: indexPath.row)
        } else {
            let sectionResults = searchResultSet.conversations
            let searchResult = sectionResults[safe: indexPath.row]
            cell.threadViewModel = searchResult?.thread
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.searchText.count == 0 {
            guard let thread = self.thread(at: indexPath.row) else { return }
            show(thread, with: ConversationViewAction.none, highlightedMessageID: nil, animated: true)
        } else {
            let sectionResults = searchResultSet.conversations
            guard let searchResult = sectionResults[safe: indexPath.row] else { return }
            show(searchResult.thread.threadRecord, with: ConversationViewAction.none, highlightedMessageID: nil, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}
