// Copyright © 2022 Beldex. All rights reserved.

import UIKit
import NVActivityIndicatorView
import PromiseKit
import BChatUIKit

class SocialGroupVC: BaseVC,UITextFieldDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UITextViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(Groupcell.nib, forCellWithReuseIdentifier: Groupcell.identifier)
        }
    }
    private var allRooms: [OpenGroupAPIV2.Info] = [] { didSet { update() } }
    private var heightConstraint: NSLayoutConstraint!
    private static let cellHeight: CGFloat = 40
    private lazy var spinner: NVActivityIndicatorView = {
        let result = NVActivityIndicatorView(frame: CGRect.zero, type: .circleStrokeSpin, color: Colors.text, padding: nil)
        result.set(.width, to: SocialGroupVC.cellHeight)
        result.set(.height, to: SocialGroupVC.cellHeight)
        return result
    }()
    @IBOutlet weak var backgroundView:UIView!
    @IBOutlet weak var nextRef:UIButton!
    @IBOutlet weak var txtview:UITextView!
    @IBOutlet weak var scanRef:UIButton!
    var placeholderLabel : UILabel!
    weak var joinOpenGroupVC: SocialGroupVC!
    private var isJoining = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGradientBackground()
        setUpNavBarStyle()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //depending upon direction of collection view
        self.collectionView?.setCollectionViewLayout(layout, animated: true)
        
        self.title = "Join Social Group"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backgroundView.layer.cornerRadius = 10
        nextRef.layer.cornerRadius = 6
        let origImage = UIImage(named: isLightMode ? "scan_QR" : "scan_QR_dark")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        scanRef.setImage(tintedImage, for: .normal)
        scanRef.tintColor = isLightMode ? UIColor.black : UIColor.white
        txtview.delegate = self
        txtview.returnKeyType = .done
        txtview.setPlaceholder2()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.collectionView.addGestureRecognizer(tap)
        
        OpenGroupAPIV2.getDefaultRoomsIfNeeded()
            .done { [weak self] rooms in
                self?.allRooms = rooms
                self?.update()
            }
            .catch { [weak self] _ in
                self?.update()
            }
        nextRef.isUserInteractionEnabled = false
        nextRef.backgroundColor = Colors.bchatViewBackgroundColor
        
    }
    
    
    // MARK: Updating
    private func update() {
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.update()
        // On small screens we hide the legal label when the keyboard is up, but it's important that the user sees it so
        // in those instances we don't make the keyboard come up automatically
        if !isIPhone5OrSmaller {
            // txtview.becomeFirstResponder()
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func dismissKeyboard() {
        txtview.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let str = textView.text!
        if str == "\n" {
            textView.resignFirstResponder()
            return
        }
        if str.count == 0 {
            nextRef.isUserInteractionEnabled = false
            nextRef.backgroundColor = Colors.bchatViewBackgroundColor
            nextRef.setTitleColor(UIColor.lightGray, for: .normal)
            txtview.checkPlaceholder()
        }else {
            nextRef.isUserInteractionEnabled = true
            nextRef.backgroundColor = Colors.bchatButtonColor
            nextRef.setTitleColor(UIColor.white, for: .normal)
            txtview.checkPlaceholder()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView.text.count >= 0 {
                textView.resignFirstResponder()
                let url = txtview.text?.trimmingCharacters(in: .whitespaces) ?? ""
                joinOpenGroup(with: url)
                return false
            }
        }
        return true
    }
    
    @IBAction func scanAction(sender:UIButton){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScannerQRVC") as! ScannerQRVC
        vc.newChatScanflag = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func nextAction(sender:UIButton){
        let url = txtview.text?.trimmingCharacters(in: .whitespaces) ?? ""
        joinOpenGroup(with: url)
    }
    
    fileprivate func joinOpenGroup(with string: String) {
        // A V2 open group URL will look like: <optional scheme> + <host> + <optional port> + <room> + <public key>
        // The host doesn't parse if no explicit scheme is provided
        if let (room, server, publicKey) = OpenGroupManagerV2.parseV2OpenGroup(from: string) {
            joinV2OpenGroup(room: room, server: server, publicKey: publicKey)
        } else {
            let title = NSLocalizedString("invalid_url", comment: "")
            let message = "Please check the URL you entered and try again."
            showError(title: title, message: message)
        }
    }
    
    fileprivate func joinV2OpenGroup(room: String, server: String, publicKey: String) {
        guard !isJoining else { return }
        isJoining = true
        Storage.shared.write { transaction in
            OpenGroupManagerV2.shared.add(room: room, server: server, publicKey: publicKey, using: transaction)
                .done(on: DispatchQueue.main) { [weak self] _ in
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                    
                    MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete() // FIXME: It's probably cleaner to do this inside addOpenGroup(...)
                    
                    let registerVC = HomeVC()
                    self?.navigationController!.pushViewController(registerVC, animated: true)
                }
                .catch(on: DispatchQueue.main) { [weak self] error in
                    self?.dismiss(animated: true, completion: nil) // Dismiss the loader
                    let title = "Couldn't Join"
                    let message = error.localizedDescription
                    self?.isJoining = false
                    self?.showError(title: title, message: message)
                }
        }
    }
    
    // MARK: Convenience
    private func showError(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
        presentAlert(alert)
    }
    
    // MARK: Layout
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allRooms.count    //min(allRooms.count, 8) // Cap to a maximum of 8 (4 rows of 2)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Groupcell.identifier, for: indexPath) as! Groupcell
        cell.allroom = allRooms[indexPath.item]
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 2   //number of column you want
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let room = allRooms[indexPath.item]
        joinV2OpenGroup(room: room.id, server: OpenGroupAPIV2.defaultServer, publicKey: OpenGroupAPIV2.defaultServerPublicKey)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            let room = allRooms[indexPath.item]
            joinV2OpenGroup(room: room.id, server: OpenGroupAPIV2.defaultServer, publicKey: OpenGroupAPIV2.defaultServerPublicKey)
        }
    }
}

extension UITextView{
    func setPlaceholder2() {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Enter a social group URL"
        placeholderLabel.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 222
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! / 0.7)
        placeholderLabel.textColor = Colors.text.withAlphaComponent(Values.mediumOpacity)
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
    }
}
