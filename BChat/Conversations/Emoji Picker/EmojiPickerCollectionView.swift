// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import BChatUIKit
import BChatUtilitiesKit
import SignalCoreKit
import GRDB

protocol EmojiPickerCollectionViewDelegate: AnyObject {
    func emojiPicker(_ emojiPicker: EmojiPickerCollectionView?, didSelectEmoji emoji: EmojiWithSkinTones)
    func emojiPickerWillBeginDragging(_ emojiPicker: EmojiPickerCollectionView)
}

class EmojiPickerCollectionView: UICollectionView {
    let layout: UICollectionViewFlowLayout

    weak var pickerDelegate: EmojiPickerCollectionViewDelegate?

    private var recentEmoji: [EmojiWithSkinTones] = []
    var hasRecentEmoji: Bool { !recentEmoji.isEmpty }

    private var allSendableEmojiByCategory: [Emoji.Category: [EmojiWithSkinTones]] = [:]
    private lazy var allSendableEmoji: [EmojiWithSkinTones] = {
        return Array(allSendableEmojiByCategory.values).flatMap({$0})
    }()

    static let emojiWidth: CGFloat = 38
    static let margins: CGFloat = 16
    static let minimumSpacing: CGFloat = 10

    public var searchText: String? {
        didSet {
            searchWithText(searchText)
        }
    }

    private var emojiSearchResults: [EmojiWithSkinTones] = []

    public var isSearching: Bool {
        if let searchText = searchText, searchText.count != 0 {
            return true
        }

        return false
    }

    lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissSkinTonePicker))
    
    // MARK: - Initialization

    init() {
        layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: Self.emojiWidth, height: Self.emojiWidth)
        layout.minimumInteritemSpacing = EmojiPickerCollectionView.minimumSpacing
        layout.sectionInset = UIEdgeInsets(top: 0, leading: EmojiPickerCollectionView.margins, bottom: 0, trailing: EmojiPickerCollectionView.margins)

        super.init(frame: .zero, collectionViewLayout: layout)

        delegate = self
        dataSource = self

        register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        register(
            EmojiSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EmojiSectionHeader.reuseIdentifier
        )

        backgroundColor = isLightMode ? .white : .black
        backgroundColor = isLightMode ? .white : .black

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        panGestureRecognizer.require(toFail: longPressGesture)
        addGestureRecognizer(longPressGesture)

        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
        
        /*
        let defaultEmoji = ["😂", "🥰", "😢", "😡", "😮", "😈"]
        let recentEmoji: [EmojiWithSkinTones] = defaultEmoji
            .compactMap { EmojiWithSkinTones(rawValue: $0) }
            .reduce(into: [EmojiWithSkinTones]()) { result, emoji in
                guard !emoji.isNormalized else {
                    result.append(emoji)
                    return
                }
                guard !result.contains(emoji.normalized) else { return }

                result.append(emoji.normalized)
            }
        self.recentEmoji = recentEmoji
        self.allSendableEmojiByCategory = [:]
         */
        
        
        
//         Fetch the emoji data from the database
//        let maybeEmojiData: (recent: [EmojiWithSkinTones], allGrouped: [Emoji.Category: [EmojiWithSkinTones]])? = Storage.shared.read { db in
//            // Some emoji have two different code points but identical appearances. Let's remove them!
//            // If we normalize to a different emoji than the one currently in our array, we want to drop
//            // the non-normalized variant if the normalized variant already exists. Otherwise, map to the
//            // normalized variant.
//            let recentEmoji: [EmojiWithSkinTones] = try Emoji.getRecent(db, withDefaultEmoji: false)
//                .compactMap { EmojiWithSkinTones(rawValue: $0) }
//                .reduce(into: [EmojiWithSkinTones]()) { result, emoji in
//                    guard !emoji.isNormalized else {
//                        result.append(emoji)
//                        return
//                    }
//                    guard !result.contains(emoji.normalized) else { return }
//                    
//                    result.append(emoji.normalized)
//                }
//            let allSendableEmojiByCategory: [Emoji.Category: [EmojiWithSkinTones]] = Emoji.allSendableEmojiByCategoryWithPreferredSkinTones(db)
//            
//            return (recentEmoji, allSendableEmojiByCategory)
//        }
//         
//        
//        if let emojiData: (recent: [EmojiWithSkinTones], allGrouped: [Emoji.Category: [EmojiWithSkinTones]]) = maybeEmojiData {
//            self.recentEmoji = emojiData.recent
//            self.allSendableEmojiByCategory = emojiData.allGrouped
//        }
         
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // This is not an exact calculation, but is simple and works for our purposes.
    var numberOfColumns: Int {
        Int((self.width()) / (EmojiPickerCollectionView.emojiWidth + EmojiPickerCollectionView.minimumSpacing))
    }

    // At max, we show 3 rows of recent emoji
    private var maxRecentEmoji: Int { numberOfColumns * 3 }
    private var categoryIndexOffset: Int { hasRecentEmoji ? 1 : 0}

    func emojiForSection(_ section: Int) -> [EmojiWithSkinTones] {
        guard section > 0 || !hasRecentEmoji else { return Array(recentEmoji[0..<min(maxRecentEmoji, recentEmoji.count)]) }
        
        guard let category = Emoji.Category.allCases[safe: section - categoryIndexOffset] else {
            owsFailDebug("Unexpectedly missing category for section \(section)")
            return []
        }

        guard let categoryEmoji = allSendableEmojiByCategory[category] else {
            //owsFailDebug("Unexpectedly missing emoji for category \(category)")
            return []
        }

        return categoryEmoji
    }

    func emojiForIndexPath(_ indexPath: IndexPath) -> EmojiWithSkinTones? {
        return isSearching ? emojiSearchResults[safe: indexPath.row] : emojiForSection(indexPath.section)[safe: indexPath.row]
    }

    func nameForSection(_ section: Int) -> String? {
        guard section > 0 || !hasRecentEmoji else {
            return "Recently Used"
        }

        guard let category = Emoji.Category.allCases[safe: section - categoryIndexOffset] else {
            owsFailDebug("Unexpectedly missing category for section \(section)")
            return nil
        }

        return category.localizedName
    }

    // MARK: - Search

    func searchWithText(_ searchText: String?) {
        if let searchText = searchText {
            emojiSearchResults = allSendableEmoji.filter { emoji in
                return emoji.baseEmoji?.name.range(of: searchText, options: [.caseInsensitive]) != nil
            }
        } else {
            emojiSearchResults = []
        }

        reloadData()
    }

    var scrollingToSection: Int?
    func scrollToSectionHeader(_ section: Int, animated: Bool) {
        guard let attributes = layoutAttributesForSupplementaryElement(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: section)
        ) else { return }
        scrollingToSection = section
        setContentOffset(CGPoint(x: 0, y: (attributes.frame.minY - contentInset.top)), animated: animated)
    }

    private weak var currentSkinTonePicker: EmojiSkinTonePicker?

    @objc
    func handleLongPress(sender: UILongPressGestureRecognizer) {

        switch sender.state {
        case .began:
            let point = sender.location(in: self)
            guard let indexPath = indexPathForItem(at: point) else { return }
            guard let emoji = emojiForIndexPath(indexPath) else { return }
            guard let cell = cellForItem(at: indexPath) else { return }

            currentSkinTonePicker?.dismiss()
            currentSkinTonePicker = EmojiSkinTonePicker.present(referenceView: cell, emoji: emoji) { [weak self] emoji in
                if let emoji: EmojiWithSkinTones = emoji {
                    Storage.shared.writeSync { db in
                        emoji.baseEmoji?.setPreferredSkinTones(
                            db as! Database,
                            preferredSkinTonePermutation: emoji.skinTones
                        )
                    }

                    self?.pickerDelegate?.emojiPicker(self, didSelectEmoji: emoji)
                }

                self?.currentSkinTonePicker?.dismiss()
                self?.currentSkinTonePicker = nil
            }
        case .changed:
            currentSkinTonePicker?.didChangeLongPress(sender)
        case .ended:
            currentSkinTonePicker?.didEndLongPress(sender)
        default:
            break
        }
    }

    @objc
    func dismissSkinTonePicker() {
        currentSkinTonePicker?.dismiss()
        currentSkinTonePicker = nil
    }
}

extension EmojiPickerCollectionView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGestureRecognizer {
            return currentSkinTonePicker != nil
        }

        return true
    }
}

extension EmojiPickerCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let emoji = emojiForIndexPath(indexPath) else {
            return owsFailDebug("Missing emoji for indexPath \(indexPath)")
        }
        
        pickerDelegate?.emojiPicker(self, didSelectEmoji: emoji)
    }
}

extension EmojiPickerCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? emojiSearchResults.count : emojiForSection(section).count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isSearching ? 1 : Emoji.Category.allCases.count + categoryIndexOffset
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath)

        guard let emojiCell = cell as? EmojiCell else {
            owsFailDebug("unexpected cell type")
            return cell
        }

        guard let emoji = emojiForIndexPath(indexPath) else {
            owsFailDebug("unexpected indexPath")
            return cell
        }

        emojiCell.configure(emoji: emoji)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let supplementaryView = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: EmojiSectionHeader.reuseIdentifier,
            for: indexPath
        )

        guard let sectionHeader = supplementaryView as? EmojiSectionHeader else {
            owsFailDebug("unexpected supplementary view type")
            return supplementaryView
        }

        sectionHeader.label.text = nameForSection(indexPath.section)

        return sectionHeader
    }
}

extension EmojiPickerCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard !isSearching else {
            return CGSize.zero
        }

        let measureCell = EmojiSectionHeader()
        measureCell.label.text = nameForSection(section)
        return measureCell.sizeThatFits(CGSize(width: self.width(), height: .greatestFiniteMagnitude))
    }
}
