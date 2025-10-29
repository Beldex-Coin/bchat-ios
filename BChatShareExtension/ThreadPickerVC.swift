import UIKit
import SignalUtilitiesKit
import BChatUIKit
import BChatMessagingKit
import BChatUtilitiesKit

final class ThreadPickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate, AttachmentApprovalViewControllerDelegate {
    private var threads: YapDatabaseViewMappings!
    private var threadViewModelCache: [String: ThreadViewModel] = [:] // Thread ID to ThreadViewModel
    private var selectedThread: TSThread?
    var shareVC: ShareViewController?
    
    private var threadCount: UInt {
        threads.numberOfItems(inGroup: TSShareExtensionGroup)
    }
    
    private lazy var dbConnection: YapDatabaseConnection = {
        let result = OWSPrimaryStorage.shared().newDatabaseConnection()
        result.objectCacheLimit = 500
        return result
    }()
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let titleLabel: UILabel = UILabel()
        titleLabel.text = "vc_share_title".localized()
        titleLabel.textColor = Colors.text
        titleLabel.font = Fonts.boldOpenSans(ofSize: Values.veryLargeFontSize)
        
        return titleLabel
    }()
    
    private lazy var databaseErrorLabel: UILabel = {
        let result: UILabel = UILabel()
        result.font = .systemFont(ofSize: Values.mediumFontSize)
        result.text = "shareExtensionDatabaseError".localized()
        result.textAlignment = .center
        result.textColor = Colors.text
        result.numberOfLines = 0
        result.isHidden = true
        
        return result
    }()
    
    private lazy var noAccountErrorLabel: UILabel = {
        let result: UILabel = UILabel()
        result.font = .systemFont(ofSize: Values.mediumFontSize)
        result.text = "shareExtensionNoAccountError".localized()
        result.textAlignment = .center
        result.textColor = Colors.text
        result.numberOfLines = 0
        result.isHidden = true
        
        return result
    }()

    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView()
        tableView.backgroundColor = Colors.mainBackGroundColor2
        tableView.separatorStyle = .none
        tableView.register(view: SimplifiedConversationCell.self)
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    private lazy var fadeView: UIView = {
        let view = UIView()
        let gradient = Gradients.homeVCFade
        view.setGradient(gradient)
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isAppThemeLight = CurrentAppContext().appUserDefaults().bool(forKey: appThemeIsLight)
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = isAppThemeLight ? .light : .dark
        } else {
            // Fallback on earlier versions
        }
        
        view.backgroundColor = Colors.viewBackgroundColorNew
        view.addSubview(databaseErrorLabel)
        view.addSubview(noAccountErrorLabel)
        
        setupNavBar()
        
        // Threads
        dbConnection.beginLongLivedReadTransaction() // Freeze the connection for use on the main thread (this gives us a stable data source that doesn't change until we tell it to)
        threads = YapDatabaseViewMappings(groups: [ TSShareExtensionGroup ], view: TSThreadShareExtensionDatabaseViewExtensionName) // The extension should be registered at this point
        threads.setIsReversed(true, forGroup: TSShareExtensionGroup)
        dbConnection.read { transaction in
            self.threads.update(with: transaction) // Perform the initial update
        }
        
        // Save thread
        Storage.read { transaction in
            let thread = TSContactThread.fetch(for: getUserHexEncodedPublicKey(), using: transaction)
            thread?.save()
        }
        
        // Title
        navigationItem.titleView = titleLabel
        
        // Table view
        view.addSubview(tableView)
        
        setupLayout()
        
        // Reload
        reload()
        
        // Re-populate snode pool if needed
        SnodeAPI.getSnodePool().retainUntilComplete()
    }
    
    private func setupNavBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Colors.navigationBarBackground
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        }

        // Cancel button to left side
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(handleCancel)
        )
        navigationItem.leftBarButtonItem?.tintColor = Colors.text
    }
    
    @objc private func handleCancel() {
        // Close the share extension
        self.extensionContext?.cancelRequest(withError: NSError(domain: "UserCancelled", code: 0))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
//        view.setGradient(Gradients.defaultBackground)
//        fadeView.setGradient(Gradients.homeVCFade)
    }
    
    // MARK: Layout
    
    private func setupLayout() {        
        tableView.pin(to: view)
        
        databaseErrorLabel.pin(.top, to: .top, of: view, withInset: Values.massiveSpacing)
        databaseErrorLabel.pin(.leading, to: .leading, of: view, withInset: Values.veryLargeSpacing)
        databaseErrorLabel.pin(.trailing, to: .trailing, of: view, withInset: -Values.veryLargeSpacing)
        
        noAccountErrorLabel.pin(.top, to: .top, of: view, withInset: Values.massiveSpacing)
        noAccountErrorLabel.pin(.leading, to: .leading, of: view, withInset: Values.veryLargeSpacing)
        noAccountErrorLabel.pin(.trailing, to: .trailing, of: view, withInset: -Values.veryLargeSpacing)
    }
    
    // MARK: - Updating
    
    private func reload() {
        AssertIsOnMainThread()
        dbConnection.beginLongLivedReadTransaction()
        dbConnection.read { transaction in
            self.threads.update(with: transaction)
        }
        threadViewModelCache.removeAll()
        tableView.reloadData()
        
        tableView.isHidden = threads.isEmpty()
        noAccountErrorLabel.isHidden = !threads.isEmpty()
    }
    
    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(threadCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SimplifiedConversationCell = tableView.dequeue(type: SimplifiedConversationCell.self, for: indexPath)
        cell.threadViewModel = threadViewModel(at: indexPath.row)
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let thread = self.thread(at: indexPath.row), let attachments = ShareViewController.attachmentPrepPromise?.value else {
            return
        }
        
        self.selectedThread = thread
        
        let approvalVC = AttachmentApprovalViewController.wrappedInNavController(attachments: attachments, approvalDelegate: self)
        navigationController!.present(approvalVC, animated: true, completion: nil)
    }
    
    // MARK: -
    
    func attachmentApproval(_ attachmentApproval: AttachmentApprovalViewController, didApproveAttachments attachments: [SignalAttachment], messageText: String?) {
        // Sharing a URL or plain text will populate the 'messageText' field so in those
        // cases we should ignore the attachments
        let isSharingUrl: Bool = (attachments.count == 1 && attachments[0].isUrl)
        let isSharingText: Bool = (attachments.count == 1 && attachments[0].isText)
        let finalAttachments: [SignalAttachment] = (isSharingUrl || isSharingText ? [] : attachments)
        
        let message = VisibleMessage()
        message.sentTimestamp = NSDate.millisecondTimestamp()
        message.text = (isSharingUrl && (messageText?.isEmpty == true || attachments[0].linkPreviewDraft == nil) ?
            (
                (messageText?.isEmpty == true || (attachments[0].text() == messageText) ?
                    attachments[0].text() :
                    "\(attachments[0].text() ?? "")\n\n\(messageText ?? "")"
                )
            ) :
            messageText
        )

        let tsMessage = TSOutgoingMessage.from(message, associatedWith: selectedThread!)
        Storage.write(
            with: { transaction in
                if isSharingUrl {
                    message.linkPreview = VisibleMessage.LinkPreview.from(
                        attachments[0].linkPreviewDraft,
                        using: transaction
                    )
                } else {
                    tsMessage.save(with: transaction)
                }
            },
            completion: {
                if isSharingUrl {
                    tsMessage.linkPreview = OWSLinkPreview.from(message.linkPreview)
                    
                    Storage.write { transaction in
                        tsMessage.save(with: transaction)
                    }
                }
            }
        )
        
        shareVC?.dismiss(animated: true, completion: nil)
        
        ModalActivityIndicatorViewController.present(fromViewController: shareVC!, canCancel: false, message: "vc_share_sending_message".localized()) { activityIndicator in
            DispatchQueue.global(qos: .userInitiated).async {
                MessageSender.sendNonDurably(message, with: finalAttachments, in: self.selectedThread!)
                    .done { [weak self] _ in
                        DispatchQueue.main.async {
                            activityIndicator.dismiss { }
                            self?.shareVC?.shareViewWasCompleted()
                        }
                    }
                    .catch { [weak self] error in
                        DispatchQueue.main.async {
                            activityIndicator.dismiss { }
                            self?.shareVC?.shareViewFailed(error: error)
                        }
                    }
            }
        }
    }

    func attachmentApprovalDidCancel(_ attachmentApproval: AttachmentApprovalViewController) {
        dismiss(animated: true, completion: nil)
    }

    func attachmentApproval(_ attachmentApproval: AttachmentApprovalViewController, didChangeMessageText newMessageText: String?) {
        // Do nothing
    }
    
    // MARK: - Convenience
    
    private func thread(at index: Int) -> TSThread? {
        var thread: TSThread? = nil
        dbConnection.read { transaction in
            let ext = transaction.ext(TSThreadShareExtensionDatabaseViewExtensionName) as! YapDatabaseViewTransaction
            thread = ext.object(atRow: UInt(index), inSection: 0, with: self.threads) as! TSThread?
        }
        return thread
    }
    
    private func threadViewModel(at index: Int) -> ThreadViewModel? {
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
}
