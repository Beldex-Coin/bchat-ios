//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import BChatUIKit
import UIKit

public protocol MediaTileViewControllerDelegate: class {
    func mediaTileViewController(_ viewController: MediaTileViewController, didTapView tappedView: UIView, mediaGalleryItem: MediaGalleryItem)
}

public class MediaTileViewController: UICollectionViewController, MediaGalleryDataSourceDelegate, UICollectionViewDelegateFlowLayout {
    
    private weak var mediaGalleryDataSource: MediaGalleryDataSource?
    
    private var galleryItems: [GalleryDate: [MediaGalleryItem]] {
        guard let mediaGalleryDataSource = self.mediaGalleryDataSource else {
            owsFailDebug("mediaGalleryDataSource was unexpectedly nil")
            return [:]
        }
        return mediaGalleryDataSource.sections
    }
    
    private var galleryDates: [GalleryDate] {
        guard let mediaGalleryDataSource = self.mediaGalleryDataSource else {
            owsFailDebug("mediaGalleryDataSource was unexpectedly nil")
            return []
        }
        return mediaGalleryDataSource.sectionDates
    }
    public var focusedItem: MediaGalleryItem?
    
    private let uiDatabaseConnection: YapDatabaseConnection
    
    public weak var delegate: MediaTileViewControllerDelegate?
    var viewItems: [ConversationViewItem]?
    
    //documents
    private var documents: [Document] = []
    private var documentItems: [GalleryDate: [Document]]?
    
    deinit {
        Logger.debug("deinit")
    }
    
    fileprivate let mediaTileViewLayout: MediaTileViewLayout
    
    init(mediaGalleryDataSource: MediaGalleryDataSource, uiDatabaseConnection: YapDatabaseConnection, viewItems: [ConversationViewItem] = []) {
        
        self.mediaGalleryDataSource = mediaGalleryDataSource
        assert(uiDatabaseConnection.isInLongLivedReadTransaction())
        self.uiDatabaseConnection = uiDatabaseConnection
        
        let layout: MediaTileViewLayout = type(of: self).buildLayout()
        self.mediaTileViewLayout = layout
        self.viewItems = viewItems
        super.init(collectionViewLayout: layout)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        notImplemented()
    }
    
    // MARK: Subviews
    
    lazy var footerBar: UIToolbar = {
        let footerBar = UIToolbar()
        let footerItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            deleteButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
        footerBar.setItems(footerItems, animated: false)
        
        footerBar.barTintColor = Colors.navigationBarBackground
        footerBar.tintColor = Colors.text
        
        return footerBar
    }()
    
    lazy var deleteButton: UIBarButtonItem = {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                           target: self,
                                           action: #selector(didPressDelete))
        deleteButton.tintColor = Colors.text
        
        return deleteButton
    }()
    
    lazy var containerViewForMediaAndDocument: SegmentedControl = {
        let stackView = SegmentedControl()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.navigationBarBackground
        return stackView
    }()
    
    lazy var mediaLineView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .red
        return stackView
    }()
    
    lazy var documentLineView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .green
        return stackView
    }()
    
    
    private lazy var noDataView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var noDataImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "no_media_image")
        result.set(.width, to: 72)
        result.set(.height, to: 72)
        result.layer.masksToBounds = true
        result.contentMode = .center
        return result
    }()
    
    private lazy var noDataMessageLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.noDataLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "No Media items to show!"
        result.adjustsFontSizeToFitWidth = true
        return result
    }()
    
    // MARK: View Lifecycle Overrides
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        // NavigationBar Title
        self.title = "All Media"
        
        // Remove Back Button Title
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        guard let collectionView = self.collectionView else {
            owsFailDebug("collectionView was unexpectedly nil")
            return
        }
        view.addSubViews(containerViewForMediaAndDocument, mediaLineView, documentLineView)
        
        containerViewForMediaAndDocument.items = ["Media", "Documents"]
        containerViewForMediaAndDocument.font = Fonts.boldOpenSans(ofSize: 16)
        containerViewForMediaAndDocument.selectedIndex = 0
        containerViewForMediaAndDocument.padding = 4
        containerViewForMediaAndDocument.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
        
        mediaLineView.backgroundColor = Colors.bothGreenColor
        documentLineView.backgroundColor = Colors.borderColorNew
        
        
        collectionView.backgroundColor = Colors.navigationBarBackground
        
        collectionView.register(PhotoGridViewCell.self, forCellWithReuseIdentifier: PhotoGridViewCell.reuseIdentifier)
        collectionView.register(DocumentCollectionViewCell.self, forCellWithReuseIdentifier: DocumentCollectionViewCell.reuseidentifier)
        collectionView.register(MediaGallerySectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MediaGallerySectionHeader.reuseIdentifier)
        collectionView.register(MediaGalleryStaticHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MediaGalleryStaticHeader.reuseIdentifier)
        
        collectionView.delegate = self
        
        
        if let collectionView = self.collectionView {
            collectionView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 20, right: 0)
        } else {
            owsFailDebug("collectionView was unexpectedly nil")
        }
        
        self.view.addSubview(self.footerBar)
        footerBar.autoPinWidthToSuperview()
        footerBar.autoSetDimension(.height, toSize: kFooterBarHeight)
        self.footerBarBottomConstraint = footerBar.autoPinEdge(toSuperviewEdge: .bottom, withInset: -kFooterBarHeight)
        
        updateSelectButton()
        self.mediaTileViewLayout.invalidateLayout()
        
        NSLayoutConstraint.activate([
            containerViewForMediaAndDocument.heightAnchor.constraint(equalToConstant: 58),
            containerViewForMediaAndDocument.topAnchor.constraint(equalTo: view.topAnchor),
            containerViewForMediaAndDocument.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerViewForMediaAndDocument.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mediaLineView.heightAnchor.constraint(equalToConstant: 2),
            documentLineView.heightAnchor.constraint(equalToConstant: 2),
            mediaLineView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2),
            documentLineView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2),
            mediaLineView.topAnchor.constraint(equalTo: containerViewForMediaAndDocument.bottomAnchor),
            mediaLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            documentLineView.topAnchor.constraint(equalTo: containerViewForMediaAndDocument.bottomAnchor),
            documentLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        view.addSubview(noDataView)
        noDataView.addSubViews(noDataImageView, noDataMessageLabel)
        self.noDataView.isHidden = true
        
        NSLayoutConstraint.activate([
            noDataView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            noDataImageView.topAnchor.constraint(equalTo: noDataView.topAnchor, constant: 0),
            noDataImageView.centerXAnchor.constraint(equalTo: noDataView.centerXAnchor),
            noDataMessageLabel.topAnchor.constraint(equalTo: noDataImageView.bottomAnchor, constant: 11),
            noDataMessageLabel.centerXAnchor.constraint(equalTo: noDataView.centerXAnchor),
            noDataMessageLabel.bottomAnchor.constraint(equalTo: noDataView.bottomAnchor, constant: 0),
        ])
        
//        getAllDcouments()
//        fetchAllDocuments()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if containerViewForMediaAndDocument.selectedIndex == 0 {
            guard let focusedItem = self.focusedItem else {
                return
            }
            
            guard let indexPath = self.indexPath(galleryItem: focusedItem) else {
                owsFailDebug("unexpectedly unable to find indexPath for focusedItem: \(focusedItem)")
                return
            }
            
            Logger.debug("scrolling to focused item at indexPath: \(indexPath)")
            self.view.layoutIfNeeded()
            self.collectionView?.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            self.autoLoadMoreIfNecessary()
        }
    }
    
    override public func viewWillTransition(to size: CGSize,
                                            with coordinator: UIViewControllerTransitionCoordinator) {
        self.mediaTileViewLayout.invalidateLayout()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateLayout(selectedIndex: containerViewForMediaAndDocument.selectedIndex)
    }
    
    private func indexPath(galleryItem: MediaGalleryItem) -> IndexPath? {
        guard let sectionIdx = galleryDates.firstIndex(of: galleryItem.galleryDate) else {
            return nil
        }
        guard let rowIdx = galleryItems[galleryItem.galleryDate]!.firstIndex(of: galleryItem) else {
            return nil
        }
        
        return IndexPath(row: rowIdx, section: sectionIdx + 1)
    }
    
    // Top SegmentView Changed
    @objc func segmentValueChanged(_ sender: AnyObject?) {
        if containerViewForMediaAndDocument.selectedIndex == 0 {
            mediaLineView.backgroundColor = Colors.bothGreenColor
            documentLineView.backgroundColor = Colors.borderColorNew
            
            self.noDataView.isHidden = true
            self.noDataImageView.image = UIImage(named: "no_media_image")
            self.noDataMessageLabel.text = "No Media items to show!"
        } else {
            documentLineView.backgroundColor = Colors.bothGreenColor
            mediaLineView.backgroundColor = Colors.borderColorNew
            
            self.noDataView.isHidden = false
            self.noDataImageView.image = UIImage(named: "no_document_image")
            self.noDataMessageLabel.text = "No Document items to show!"
        }
        updateLayout(selectedIndex: containerViewForMediaAndDocument.selectedIndex)
        updateSelectButton()
        self.collectionView.reloadData()
    }
    
    func fetchAllDocuments() {
        documents = []
        if let objects = UserDefaults.standard.value(forKey: Constants.attachedDocuments) as? Data {
            let decoder = JSONDecoder()
            if let documentsDecoded = try? decoder.decode([Document].self, from: objects) as [Document] {
                documents = documentsDecoded
            }
            self.collectionView.reloadData()
            documents.forEach { document in
            }
        }
    }
    
    func getAllDcouments() {
        UserDefaults.standard.removeObject(forKey: Constants.attachedDocuments)
        
        var deletedDocuments: [Document] = []
        if let objects = UserDefaults.standard.value(forKey: Constants.deleteAttachedDocuments) as? Data {
            let decoder = JSONDecoder()
            if let documentsDecoded = try? decoder.decode([Document].self, from: objects) as [Document] {
                deletedDocuments = documentsDecoded
            }
            deletedDocuments.forEach { document in
            }
        }
        
        var allAttachments: [TSAttachmentStream] = []
        var documents: [Document] = []
        guard let theViewItems = viewItems else { return }
        theViewItems.forEach { viewItem in
            if let message = viewItem.interaction as? TSMessage {
                Storage.read { transaction in
                    message.attachmentIds.forEach { attachmentID in
                        guard let attachmentID = attachmentID as? String else { return }
                        let attachment = TSAttachment.fetch(uniqueId: attachmentID, transaction: transaction)
                        guard let stream = attachment as? TSAttachmentStream else { return }
                        allAttachments.append(stream) //appending all attachments
                        
                        if stream.contentType == DocumentContentType.mswordDocument.rawValue || stream.contentType == DocumentContentType.pdfDocument.rawValue || stream.contentType == DocumentContentType.textDocument.rawValue {
                            
                            if !deletedDocuments.isEmpty {
                                for document in deletedDocuments {
                                    if document.documentId == attachmentID {
                                        self.deleteLocally(viewItem)
                                    }
                                }
                            }
                            
                            guard let filePath = stream.originalFilePath, let mediaUrl = stream.originalMediaURL else { return }
                            let theDocument = Document(contentType: stream.contentType,
                                                       originalFilePath: filePath,
                                                       originalMediaURL: mediaUrl,
                                                       createdTimeStamp: stream.creationTimestamp,
                                                       documentId: attachmentID)
                            documents.append(theDocument) //appending only documents
                        }
                    }
                }
            }
        }
        if !documents.isEmpty {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(documents) {
                UserDefaults.standard.set(encoded, forKey: Constants.attachedDocuments)
            }
        }
//        fetchAllDocuments()
    }
    
    func deleteLocally(_ viewItem: ConversationViewItem) {
        viewItem.deleteLocallyAction()
//        if let unsendRequest = buildUnsendRequest(viewItem) {
//            SNMessagingKitConfiguration.shared.storage.write { transaction in
//                MessageSender.send(unsendRequest, to: .contact(publicKey: getUserHexEncodedPublicKey()), using: transaction).retainUntilComplete()
//            }
//        }
    }
    
//    private func buildUnsendRequest(_ viewItem: ConversationViewItem) -> UnsendRequest? {
//        if let message = viewItem.interaction as? TSMessage,
//           message.isOpenGroupMessage || message.serverHash == nil { return nil }
//        let unsendRequest = UnsendRequest()
//        switch viewItem.interaction.interactionType() {
//        case .incomingMessage:
//            if let incomingMessage = viewItem.interaction as? TSIncomingMessage {
//                unsendRequest.author = incomingMessage.authorId
//            }
//        case .outgoingMessage: unsendRequest.author = getUserHexEncodedPublicKey()
//        default: return nil // Should never occur
//        }
//        unsendRequest.timestamp = viewItem.interaction.timestamp
//        return unsendRequest
//    }

    
    
    // Date formate for document
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy, h:mm a"
        return dateFormatter.string(from: date)
    }
    
    // MARK: Orientation
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    // MARK: UICollectionViewDelegate
    
    override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.autoLoadMoreIfNecessary()
    }
    
    override public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isUserScrolling = true
    }
    
    override public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isUserScrolling = false
    }
    
    override public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        Logger.debug("")
        if containerViewForMediaAndDocument.selectedIndex == 0 {
            guard galleryDates.count > 0 else {
                return false
            }
            
            switch indexPath.section {
            case kLoadOlderSectionIdx, loadNewerSectionIdx:
                return false
            default:
                return true
            }
        } else {
            return true
        }
    }
    
    override public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        
        Logger.debug("")
        if containerViewForMediaAndDocument.selectedIndex == 0 {
            guard galleryDates.count > 0 else {
                return false
            }
            
            switch indexPath.section {
            case kLoadOlderSectionIdx, loadNewerSectionIdx:
                return false
            default:
                return true
            }
        } else {
            return true
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        
        Logger.debug("")
        if containerViewForMediaAndDocument.selectedIndex == 0 {
            guard galleryDates.count > 0 else {
                return false
            }
            
            switch indexPath.section {
            case kLoadOlderSectionIdx, loadNewerSectionIdx:
                return false
            default:
                return true
            }
        } else {
            return true
        }
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Logger.debug("")
        
        if containerViewForMediaAndDocument.selectedIndex == 0 {
            guard let gridCell = self.collectionView(collectionView, cellForItemAt: indexPath) as? PhotoGridViewCell else {
                owsFailDebug("galleryCell was unexpectedly nil")
                return
            }
            
            guard let galleryItem = (gridCell.item as? GalleryGridCellItem)?.galleryItem else {
                owsFailDebug("galleryItem was unexpectedly nil")
                return
            }
            
            if isInBatchSelectMode {
                updateDeleteButton()
            } else {
                collectionView.deselectItem(at: indexPath, animated: true)
                self.delegate?.mediaTileViewController(self, didTapView: gridCell.imageView, mediaGalleryItem: galleryItem)
            }
        } else {
            
            if isInBatchSelectMode {
                updateDeleteButton()
            } else {
                collectionView.deselectItem(at: indexPath, animated: true)
                let viewItem = documents[indexPath.item]
                if viewItem.contentType == DocumentContentType.pdfDocument.rawValue ||
                    viewItem.contentType == DocumentContentType.mswordDocument.rawValue ||
                    viewItem.contentType == DocumentContentType.textDocument.rawValue {
                    let fileUrl: URL = viewItem.originalMediaURL//URL(fileURLWithPath: viewItem.originalFilePath)
                    let interactionController: UIDocumentInteractionController = UIDocumentInteractionController(url: fileUrl)
                    interactionController.delegate = self
                    interactionController.presentPreview(animated: true)
                }
                else {
                    // Open the document if possible
                    let url = viewItem.originalMediaURL
                    let shareVC = UIActivityViewController(activityItems: [ url ], applicationActivities: nil)
                    if UIDevice.current.isIPad {
                        shareVC.excludedActivityTypes = []
                        shareVC.popoverPresentationController?.permittedArrowDirections = []
                        shareVC.popoverPresentationController?.sourceView = self.view
                        shareVC.popoverPresentationController?.sourceRect = self.view.bounds
                    }
                    navigationController!.present(shareVC, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        Logger.debug("")
        
//        if containerViewForMediaAndDocument.selectedIndex == 0 {
            if isInBatchSelectMode {
                updateDeleteButton()
            }
//        }
    }
    
    private var isUserScrolling: Bool = false {
        didSet {
            autoLoadMoreIfNecessary()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if containerViewForMediaAndDocument.selectedIndex == 0 {
            guard galleryDates.count > 0 else {
                // empty gallery
                return 1
            }
            // One for each galleryDate plus a "loading older" and "loading newer" section
            return galleryItems.keys.count + 2
        } else {
            return 1
        }
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection sectionIdx: Int) -> Int {
        
        if containerViewForMediaAndDocument.selectedIndex == 0 {
            guard galleryDates.count > 0 else {
                // empty gallery
                return 0
            }
            
            if sectionIdx == kLoadOlderSectionIdx {
                // load older
                return 0
            }
            
            if sectionIdx == loadNewerSectionIdx {
                // load more recent
                return 0
            }
            
            guard let sectionDate = self.galleryDates[safe: sectionIdx - 1] else {
                owsFailDebug("unknown section: \(sectionIdx)")
                return 0
            }
            
            guard let section = self.galleryItems[sectionDate] else {
                owsFailDebug("no section for date: \(sectionDate)")
                return 0
            }
            
            return section.count
        } else {
            return documents.count
        }
    }
    
    override public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let defaultView = UICollectionReusableView()
        
        if containerViewForMediaAndDocument.selectedIndex == 0 {
            guard galleryDates.count > 0 else {
                guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MediaGalleryStaticHeader.reuseIdentifier, for: indexPath) as? MediaGalleryStaticHeader else {
                    
                    owsFailDebug("unable to build section header for kLoadOlderSectionIdx")
                    return defaultView
                }
                let title = NSLocalizedString("GALLERY_TILES_EMPTY_GALLERY", comment: "Label indicating media gallery is empty")
                sectionHeader.configure(title: title)
                self.noDataView.isHidden = false
                self.noDataImageView.image = UIImage(named: "no_media_image")
                self.noDataMessageLabel.text = "No Media items to show!"
                return sectionHeader
            }
            
            if (kind == UICollectionView.elementKindSectionHeader) {
                switch indexPath.section {
                case kLoadOlderSectionIdx:
                    guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MediaGalleryStaticHeader.reuseIdentifier, for: indexPath) as? MediaGalleryStaticHeader else {
                        
                        owsFailDebug("unable to build section header for kLoadOlderSectionIdx")
                        return defaultView
                    }
                    let title = NSLocalizedString("GALLERY_TILES_LOADING_OLDER_LABEL", comment: "Label indicating loading is in progress")
                    sectionHeader.configure(title: title)
                    return sectionHeader
                case loadNewerSectionIdx:
                    guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MediaGalleryStaticHeader.reuseIdentifier, for: indexPath) as? MediaGalleryStaticHeader else {
                        
                        owsFailDebug("unable to build section header for kLoadOlderSectionIdx")
                        return defaultView
                    }
                    let title = NSLocalizedString("GALLERY_TILES_LOADING_MORE_RECENT_LABEL", comment: "Label indicating loading is in progress")
                    sectionHeader.configure(title: title)
                    return sectionHeader
                default:
                    guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MediaGallerySectionHeader.reuseIdentifier, for: indexPath) as? MediaGallerySectionHeader else {
                        owsFailDebug("unable to build section header for indexPath: \(indexPath)")
                        return defaultView
                    }
                    guard let date = self.galleryDates[safe: indexPath.section - 1] else {
                        owsFailDebug("unknown section for indexPath: \(indexPath)")
                        return defaultView
                    }
                    
                    sectionHeader.configure(title: date.localizedString)
                    return sectionHeader
                }
            }
        }
        
        return defaultView
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        Logger.debug("indexPath: \(indexPath)")
        
        if containerViewForMediaAndDocument.selectedIndex == 0 {
            let defaultCell = UICollectionViewCell()
            
            guard galleryDates.count > 0 else {
                owsFailDebug("unexpected cell for loadNewerSectionIdx")
                return defaultCell
            }
            
            switch indexPath.section {
            case kLoadOlderSectionIdx:
                owsFailDebug("unexpected cell for kLoadOlderSectionIdx")
                return defaultCell
            case loadNewerSectionIdx:
                owsFailDebug("unexpected cell for loadNewerSectionIdx")
                return defaultCell
            default:
                guard let galleryItem = galleryItem(at: indexPath) else {
                    owsFailDebug("no message for path: \(indexPath)")
                    return defaultCell
                }
                
                guard let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: PhotoGridViewCell.reuseIdentifier, for: indexPath) as? PhotoGridViewCell else {
                    owsFailDebug("unexpected cell for indexPath: \(indexPath)")
                    return defaultCell
                }
                
                let gridCellItem = GalleryGridCellItem(galleryItem: galleryItem)
                cell.configure(item: gridCellItem)
                
                return cell
            }
        } else {
            let cell = self.collectionView!.dequeueReusableCell(withReuseIdentifier: DocumentCollectionViewCell.reuseidentifier, for: indexPath) as! DocumentCollectionViewCell
            
            let documentItem = documents[indexPath.item]
            
            cell.titleLabel.text = documentItem.originalMediaURL.lastPathComponent
            let filePath = documentItem.originalFilePath
            var fileSize : UInt64
            do {
                let attr = try FileManager.default.attributesOfItem(atPath: filePath)
                fileSize = attr[FileAttributeKey.size] as! UInt64
                let dict = attr as NSDictionary
                fileSize = dict.fileSize()
                cell.sizeLabel.text = OWSFormat.formatFileSize(UInt(fileSize))
            } catch {
                print("Error: \(error)")
            }
            cell.dateLabel.text = formatDate(documentItem.createdTimeStamp)
            
            let contentType = documentItem.contentType
            let documentImage = contentType == DocumentContentType.mswordDocument.rawValue ? "ic_documentType_doc" :
                                contentType == DocumentContentType.pdfDocument.rawValue ? "ic_documentType_pdf" :
                                contentType == DocumentContentType.textDocument.rawValue ? "ic_documentType_text" : "ic_documentType_doc"
            
            cell.documentImageView.image = UIImage(named: documentImage)
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if containerViewForMediaAndDocument.selectedIndex == 0 {
            let kMonthHeaderSize: CGSize = CGSize(width: 0, height: 50)
            let kStaticHeaderSize: CGSize = CGSize(width: 0, height: 100)
            
            guard galleryDates.count > 0 else {
                return kStaticHeaderSize
            }
            
            guard let mediaGalleryDataSource = self.mediaGalleryDataSource else {
                owsFailDebug("mediaGalleryDataSource was unexpectedly nil")
                return CGSize.zero
            }
            
            switch section {
            case kLoadOlderSectionIdx:
                // Show "loading older..." iff there is still older data to be fetched
                return mediaGalleryDataSource.hasFetchedOldest ? CGSize.zero : kStaticHeaderSize
            case loadNewerSectionIdx:
                // Show "loading newer..." iff there is still more recent data to be fetched
                return mediaGalleryDataSource.hasFetchedMostRecent ? CGSize.zero : kStaticHeaderSize
            default:
                return kMonthHeaderSize
            }
        } else {
            return CGSize.zero
        }
    }
    
    func galleryItem(at indexPath: IndexPath) -> MediaGalleryItem? {
        guard let sectionDate = self.galleryDates[safe: indexPath.section - 1] else {
            owsFailDebug("unknown section: \(indexPath.section)")
            return nil
        }
        
        guard let sectionItems = self.galleryItems[sectionDate] else {
            owsFailDebug("no section for date: \(sectionDate)")
            return nil
        }
        
        guard let galleryItem = sectionItems[safe: indexPath.row] else {
            owsFailDebug("no message for row: \(indexPath.row)")
            return nil
        }
        
        return galleryItem
    }
    
    
    func galleryItemForDocuments(at indexPath: IndexPath) -> Document? {
        
        guard let galleryItem = documents[safe: indexPath.row] else {
            owsFailDebug("no message for row: \(indexPath.row)")
            return nil
        }
        
        return galleryItem
    }
    
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    static let kInterItemSpacing: CGFloat = 2
    private class func buildLayout() -> MediaTileViewLayout {
        let layout = MediaTileViewLayout()
        
        if #available(iOS 11, *) {
            layout.sectionInsetReference = .fromSafeArea
        }
        layout.minimumInteritemSpacing = kInterItemSpacing
        layout.minimumLineSpacing = kInterItemSpacing
        layout.sectionHeadersPinToVisibleBounds = true
        
        return layout
    }
    
    func updateLayout(selectedIndex: Int) {
        
        self.noDataView.isHidden = false
        if selectedIndex == 0 {
            if galleryDates.count > 0 {
                self.noDataView.isHidden = true
            }
        } else {
            if documents.count > 0 {
                self.noDataView.isHidden = true
            }
        }
        
        var kItemsPerPortraitRow = 4
        if containerViewForMediaAndDocument.selectedIndex == 1 {
            kItemsPerPortraitRow = 1
        }
        
        let containerWidth: CGFloat
        if #available(iOS 11.0, *) {
            containerWidth = self.view.safeAreaLayoutGuide.layoutFrame.size.width
        } else {
            containerWidth = self.view.frame.size.width
        }
        
        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let approxItemWidth = screenWidth / CGFloat(kItemsPerPortraitRow)
        
        let itemCount = round(containerWidth / approxItemWidth)
        let spaceWidth = (itemCount + 1) * type(of: self).kInterItemSpacing
        let availableWidth = containerWidth - spaceWidth
        
        let itemWidth = floor(availableWidth / CGFloat(itemCount))
        let newItemSize = CGSize(width: itemWidth, height: containerViewForMediaAndDocument.selectedIndex == 1 ? 90 : itemWidth)
        
        if (newItemSize != mediaTileViewLayout.itemSize) {
            mediaTileViewLayout.itemSize = newItemSize
            mediaTileViewLayout.invalidateLayout()
        }
    }
    
    // MARK: Batch Selection
    
    var isInBatchSelectMode = false {
        didSet {
            collectionView!.allowsMultipleSelection = isInBatchSelectMode
            updateSelectButton()
            updateDeleteButton()
        }
    }
    
    func updateDeleteButton() {
        guard let collectionView = self.collectionView else {
            owsFailDebug("collectionView was unexpectedly nil")
            return
        }
        
        if let count = collectionView.indexPathsForSelectedItems?.count, count > 0 {
            self.deleteButton.isEnabled = true
        } else {
            self.deleteButton.isEnabled = false
        }
    }
    
    func updateSelectButton() {
        if isInBatchSelectMode {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelSelect))
        } else {
            if containerViewForMediaAndDocument.selectedIndex == 0 {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("BUTTON_SELECT", comment: "Button text to enable batch selection mode"),
                                                                         style: .plain,
                                                                         target: self,
                                                                         action: #selector(didTapSelect))
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    @objc
    func didTapSelect(_ sender: Any) {
        isInBatchSelectMode = true
        
        guard let collectionView = self.collectionView else {
            owsFailDebug("collectionView was unexpectedly nil")
            return
        }
        
        // show toolbar
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            NSLayoutConstraint.deactivate([self.footerBarBottomConstraint])
            self.footerBarBottomConstraint = self.footerBar.autoPinEdge(toSuperviewSafeArea: .bottom)
            
            self.footerBar.superview?.layoutIfNeeded()
            
            // ensure toolbar doesn't cover bottom row.
            collectionView.contentInset.bottom += self.kFooterBarHeight
        }, completion: nil)
        
        // disabled until at least one item is selected
        self.deleteButton.isEnabled = false
        
        // Don't allow the user to leave mid-selection, so they realized they have
        // to cancel (lose) their selection if they leave.
        self.navigationItem.hidesBackButton = true
    }
    
    @objc
    func didCancelSelect(_ sender: Any) {
        endSelectMode()
    }
    
    func endSelectMode() {
        isInBatchSelectMode = false
        
        guard let collectionView = self.collectionView else {
            owsFailDebug("collectionView was unexpectedly nil")
            return
        }

        collectionView.performBatchUpdates({
//            collectionView.indexPathsForSelectedItems?.forEach { indexPath in
//                collectionView.deselectItem(at: indexPath, animated: false)
//            }

            NSLayoutConstraint.deactivate([self.footerBarBottomConstraint])
            self.footerBarBottomConstraint = self.footerBar.autoPinEdge(toSuperviewEdge: .bottom, withInset: -self.kFooterBarHeight)
            self.footerBar.superview?.layoutIfNeeded()
            collectionView.contentInset.bottom -= self.kFooterBarHeight
        }, completion: nil)
        
        self.navigationItem.hidesBackButton = false
    }
    
    @objc
    func didPressDelete(_ sender: Any) {
        Logger.debug("")
        
        guard let collectionView = self.collectionView else {
            owsFailDebug("collectionView was unexpectedly nil")
            return
        }
        
        guard let indexPaths = collectionView.indexPathsForSelectedItems else {
            owsFailDebug("indexPaths was unexpectedly nil")
            return
        }
        
        if containerViewForMediaAndDocument.selectedIndex == 1 {
            let documentsItems: [Document] = indexPaths.compactMap { return self.galleryItemForDocuments(at: $0) }
            print("selected Documents : ",documentsItems)
            
            // Don't delete
            if documentsItems.count > 0 {
                for documentsItem in documentsItems {
                    documents = documents.filter { $0.documentId != documentsItem.documentId }
                    self.collectionView.reloadData()
                }
            }
            
            if !documentsItems.isEmpty {
                UserDefaults.standard.removeObject(forKey: Constants.deleteAttachedDocuments)
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(documentsItems) {
                    UserDefaults.standard.set(encoded, forKey: Constants.deleteAttachedDocuments)
                    self.endSelectMode()
                }
            }
            
           return
        }
        
        let items: [MediaGalleryItem] = indexPaths.compactMap { return self.galleryItem(at: $0) }
        
        guard let mediaGalleryDataSource = self.mediaGalleryDataSource else {
            owsFailDebug("mediaGalleryDataSource was unexpectedly nil")
            return
        }
        
        let confirmationTitle: String = {
            if indexPaths.count == 1 {
                return NSLocalizedString("MEDIA_GALLERY_DELETE_SINGLE_MESSAGE", comment: "Confirmation button text to delete selected media message from the gallery")
            } else {
                let format = NSLocalizedString("MEDIA_GALLERY_DELETE_MULTIPLE_MESSAGES_FORMAT", comment: "Confirmation button text to delete selected media from the gallery, embeds {{number of messages}}")
                return String(format: format, indexPaths.count)
            }
        }()
        
        let deleteAction = UIAlertAction(title: confirmationTitle, style: .destructive) { _ in
            mediaGalleryDataSource.delete(items: items, initiatedBy: self)
            self.endSelectMode()
        }
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(OWSAlerts.cancelAction)
        
        presentAlert(actionSheet)
    }
    
    var footerBarBottomConstraint: NSLayoutConstraint!
    let kFooterBarHeight: CGFloat = 40
    
    // MARK: MediaGalleryDataSourceDelegate
    
    func mediaGalleryDataSource(_ mediaGalleryDataSource: MediaGalleryDataSource, willDelete items: [MediaGalleryItem], initiatedBy: AnyObject) {
        Logger.debug("")
        
        guard let collectionView = self.collectionView else {
            owsFailDebug("collectionView was unexpectedly nil")
            return
        }
        
        // We've got to lay out the collectionView before any changes are made to the date source
        // otherwise we'll fail when we try to remove the deleted sections/rows
        collectionView.layoutIfNeeded()
    }
    
    func mediaGalleryDataSource(_ mediaGalleryDataSource: MediaGalleryDataSource, deletedSections: IndexSet, deletedItems: [IndexPath]) {
        Logger.debug("with deletedSections: \(deletedSections) deletedItems: \(deletedItems)")
        
        guard let collectionView = self.collectionView else {
            owsFailDebug("collectionView was unexpectedly nil")
            return
        }
        
        guard mediaGalleryDataSource.galleryItemCount > 0  else {
            // Show Empty
            self.collectionView?.reloadData()
            return
        }
        
        collectionView.performBatchUpdates({
            collectionView.deleteSections(deletedSections)
            collectionView.deleteItems(at: deletedItems)
        })
    }
    
    // MARK: Lazy Loading
    
    // This should be substantially larger than one screen size so we don't have to call it
    // multiple times in a rapid succession, but not so large that loading get's really chopping
    let kMediaTileViewLoadBatchSize: UInt = 40
    var oldestLoadedItem: MediaGalleryItem? {
        guard let oldestDate = galleryDates.first else {
            return nil
        }
        
        return galleryItems[oldestDate]?.first
    }
    
    var mostRecentLoadedItem: MediaGalleryItem? {
        guard let mostRecentDate = galleryDates.last else {
            return nil
        }
        
        return galleryItems[mostRecentDate]?.last
    }
    
    var isFetchingMoreData: Bool = false
    
    let kLoadOlderSectionIdx = 0
    var loadNewerSectionIdx: Int {
        return galleryDates.count + 1
    }
    
    public func autoLoadMoreIfNecessary() {
        let kEdgeThreshold: CGFloat = 800
        
        if (self.isUserScrolling) {
            return
        }
        
        guard let collectionView = self.collectionView else {
            owsFailDebug("collectionView was unexpectedly nil")
            return
        }
        
        guard let mediaGalleryDataSource = self.mediaGalleryDataSource else {
            owsFailDebug("mediaGalleryDataSource was unexpectedly nil")
            return
        }
        
        let contentOffsetY = collectionView.contentOffset.y
        let oldContentHeight = collectionView.contentSize.height
        
        if contentOffsetY < kEdgeThreshold {
            // Near the top, load older content
            
            guard let oldestLoadedItem = self.oldestLoadedItem else {
                Logger.debug("no oldest item")
                return
            }
            
            guard !mediaGalleryDataSource.hasFetchedOldest else {
                return
            }
            
            guard !isFetchingMoreData else {
                Logger.debug("already fetching more data")
                return
            }
            isFetchingMoreData = true
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            // mediaTileViewLayout will adjust content offset to compensate for the change in content height so that
            // the same content is visible after the update. I considered doing something like setContentOffset in the
            // batchUpdate completion block, but it caused a distinct flicker, which I was able to avoid with the
            // `CollectionViewLayout.prepare` based approach.
            mediaTileViewLayout.isInsertingCellsToTop = true
            mediaTileViewLayout.contentSizeBeforeInsertingToTop = collectionView.contentSize
            collectionView.performBatchUpdates({
                mediaGalleryDataSource.ensureGalleryItemsLoaded(.before, item: oldestLoadedItem, amount: self.kMediaTileViewLoadBatchSize) { addedSections, addedItems in
                    Logger.debug("insertingSections: \(addedSections) items: \(addedItems)")
                    
                    collectionView.insertSections(addedSections)
                    collectionView.insertItems(at: addedItems)
                }
            }, completion: { finished in
                Logger.debug("performBatchUpdates finished: \(finished)")
                self.isFetchingMoreData = false
                CATransaction.commit()
            })
            
        } else if oldContentHeight - contentOffsetY < kEdgeThreshold {
            // Near the bottom, load newer content
            
            guard let mostRecentLoadedItem = self.mostRecentLoadedItem else {
                Logger.debug("no mostRecent item")
                return
            }
            
            guard !mediaGalleryDataSource.hasFetchedMostRecent else {
                return
            }
            
            guard !isFetchingMoreData else {
                Logger.debug("already fetching more data")
                return
            }
            isFetchingMoreData = true
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates({
                    mediaGalleryDataSource.ensureGalleryItemsLoaded(.after, item: mostRecentLoadedItem, amount: self.kMediaTileViewLoadBatchSize) { addedSections, addedItems in
                        Logger.debug("insertingSections: \(addedSections), items: \(addedItems)")
                        collectionView.insertSections(addedSections)
                        collectionView.insertItems(at: addedItems)
                    }
                }, completion: { finished in
                    Logger.debug("performBatchUpdates finished: \(finished)")
                    self.isFetchingMoreData = false
                    CATransaction.commit()
                })
            }
        }
    }
}

extension MediaTileViewController: UIDocumentInteractionControllerDelegate {
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

// MARK: - Private Helper Classes

// Accomodates remaining scrolled to the same "apparent" position when new content is inserted
// into the top of a collectionView. There are multiple ways to solve this problem, but this
// is the only one which avoided a perceptible flicker.
private class MediaTileViewLayout: UICollectionViewFlowLayout {

    fileprivate var isInsertingCellsToTop: Bool = false
    fileprivate var contentSizeBeforeInsertingToTop: CGSize?

    override public func prepare() {
        super.prepare()

        if isInsertingCellsToTop {
            if let collectionView = collectionView, let oldContentSize = contentSizeBeforeInsertingToTop {
                let newContentSize = collectionViewContentSize
                let contentOffsetY = collectionView.contentOffset.y + (newContentSize.height - oldContentSize.height)
                let newOffset = CGPoint(x: collectionView.contentOffset.x, y: contentOffsetY)
                collectionView.setContentOffset(newOffset, animated: false)
            }
            contentSizeBeforeInsertingToTop = nil
            isInsertingCellsToTop = false
        }
    }
}

private class MediaGallerySectionHeader: UICollectionReusableView {

    static let reuseIdentifier = "MediaGallerySectionHeader"

    // HACK: scrollbar incorrectly appears *behind* section headers
    // in collection view on iOS11 =(
    private class AlwaysOnTopLayer: CALayer {
        override var zPosition: CGFloat {
            get { return 0 }
            set {}
        }
    }

    let label: UILabel

    override class var layerClass: AnyClass {
        get {
            // HACK: scrollbar incorrectly appears *behind* section headers
            // in collection view on iOS11 =(
            if #available(iOS 11, *) {
                return AlwaysOnTopLayer.self
            } else {
                return super.layerClass
            }
        }
    }

    override init(frame: CGRect) {
        label = UILabel()
        label.textColor = Colors.text

        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)

        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        super.init(frame: frame)

        self.backgroundColor = isLightMode ? Colors.cellBackground : UIColor.ows_black.withAlphaComponent(OWSNavigationBar.backgroundBlurMutingFactor)

        self.addSubview(blurEffectView)
        self.addSubview(label)

        blurEffectView.autoPinEdgesToSuperviewEdges()
        blurEffectView.isHidden = isLightMode
        label.autoPinEdge(toSuperviewMargin: .trailing)
        label.autoPinEdge(toSuperviewMargin: .leading)
        label.autoVCenterInSuperview()
    }

    @available(*, unavailable, message: "Unimplemented")
    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    public func configure(title: String) {
        self.label.text = title
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        self.label.text = nil
    }
}

private class MediaGalleryStaticHeader: UICollectionViewCell {

    static let reuseIdentifier = "MediaGalleryStaticHeader"

    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label)

        label.textColor = Colors.text
        label.textAlignment = .center
        label.numberOfLines = 0
        label.autoPinEdgesToSuperviewMargins(with: UIEdgeInsets(top: 0, leading: Values.largeSpacing, bottom: 0, trailing: Values.largeSpacing))
    }

    @available(*, unavailable, message: "Unimplemented")
    required public init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    public func configure(title: String) {
        self.label.text = title
    }

    public override func prepareForReuse() {
        self.label.text = nil
    }
}

class GalleryGridCellItem: PhotoGridItem {
    let galleryItem: MediaGalleryItem

    init(galleryItem: MediaGalleryItem) {
        self.galleryItem = galleryItem
    }

    var type: PhotoGridItemType {
        if galleryItem.isVideo {
            return .video
        } else if galleryItem.isAnimated {
            return .animated
        } else {
            return .photo
        }
    }

    func asyncThumbnail(completion: @escaping (UIImage?) -> Void) -> UIImage? {
        return galleryItem.thumbnailImage(async: completion)
    }
}
