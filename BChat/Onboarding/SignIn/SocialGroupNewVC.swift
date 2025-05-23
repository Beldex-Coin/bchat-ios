// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import NVActivityIndicatorView
import PromiseKit
import BChatUIKit

class SocialGroupNewVC: BaseVC,UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.textFieldPlaceHolderColor
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var topView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.layer.cornerRadius = 14
        stackView.layer.borderColor = Colors.borderColor.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    private lazy var groupUrlTextField: UITextField = {
        let result = UITextField()
        result.textColor = Colors.titleColor3
        result.font = Fonts.OpenSans(ofSize: 14)
        result.setLeftPaddingPoints(8)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString(NSLocalizedString("Enter_Group_Url_New", comment: ""), comment: ""), attributes:[NSAttributedString.Key.foregroundColor: Colors.textFieldPlaceHolderColor])
        result.backgroundColor = .clear
        result.layer.cornerRadius = Values.buttonRadius
        return result
    }()
    
    private lazy var urlBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = Values.buttonRadius
        stackView.backgroundColor = Colors.backgroundViewColor
        return stackView
    }()
    
    private lazy var scannerImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        let logoImage = isLightMode ? "ic_scanner_dark" : "ic_Newqr"
        imageView.image = UIImage(named: logoImage) // Set the image if you have one
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scannerimageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        return imageView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Next_Button_New", comment: ""), for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.backgroundViewColor
        button.setTitleColor(Colors.buttonTextColor, for: .normal)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor5
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    var collectionview: UICollectionView!
    var cellId = "SocialGroupCell"
    private var allRooms: [OpenGroupAPIV2.Info] = [] { didSet { update() } }
    private var isJoining = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.viewBackgroundColorSocialGroup
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Social group"
        self.titleLabel.text = "Join Social Group"
        self.subTitleLabel.text = "Or Join"
        groupUrlTextField.delegate = self
        
        view.addSubViews(topView)
        view.addSubViews(subTitleLabel)
        topView.addSubview(titleLabel)
        topView.addSubview(urlBackgroundView)
        topView.addSubview(nextButton)
        
        let stackView = UIStackView(arrangedSubviews: [groupUrlTextField, scannerImg])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        urlBackgroundView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: urlBackgroundView.topAnchor, constant: 5),
            stackView.leadingAnchor.constraint(equalTo: urlBackgroundView.leadingAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: urlBackgroundView.bottomAnchor, constant: -5),
            scannerImg.widthAnchor.constraint(equalToConstant: 28),
            scannerImg.heightAnchor.constraint(equalToConstant: 28),
            scannerImg.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16),
            groupUrlTextField.trailingAnchor.constraint(equalTo: urlBackgroundView.trailingAnchor, constant: -56),
        ])
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            
            titleLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 13),
            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -15),
            
            urlBackgroundView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            urlBackgroundView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 11),
            urlBackgroundView.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -10),
            nextButton.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 11),
            nextButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -10),
            nextButton.topAnchor.constraint(equalTo: urlBackgroundView.bottomAnchor, constant: 7),
            urlBackgroundView.heightAnchor.constraint(equalToConstant: 60),
            nextButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -12),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 21),
            subTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            subTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
        ])
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.register(SocialGroupCell.self, forCellWithReuseIdentifier: cellId)
        collectionview.showsVerticalScrollIndicator = false
        collectionview.backgroundColor = .clear
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionview)
        // Add constraints for collectionView
        NSLayoutConstraint.activate([
            collectionview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21.0),
            collectionview.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 14.0),
            collectionview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21.0),
            collectionview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -21.0)
        ])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.collectionview.addGestureRecognizer(tap)
        
        OpenGroupAPIV2.getDefaultRoomsIfNeeded()
            .done { [weak self] rooms in
                self?.allRooms = rooms
                self?.update()
            }
            .catch { [weak self] _ in
                self?.update()
            }
        nextButton.isUserInteractionEnabled = false
        nextButton.backgroundColor = Colors.backgroundViewColor
        nextButton.setTitleColor(Colors.buttonTextColor, for: .normal)
        
    }
    
    private func update() {
        collectionview.reloadData()
    }
    
    @objc private func dismissKeyboard() {
        groupUrlTextField.resignFirstResponder()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let str = textField.text!
        if str == "\n" {
            textField.resignFirstResponder()
            return
        }
        if str.count == 0 {
            nextButton.isUserInteractionEnabled = false
            nextButton.backgroundColor = Colors.backgroundViewColor
            nextButton.setTitleColor(Colors.buttonTextColor, for: .normal)
        } else {
            nextButton.isUserInteractionEnabled = true
            nextButton.backgroundColor = Colors.bothGreenColor
            nextButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
        }
    }
    
    // MARK: Button Actions :-
    @objc private func nextButtonTapped() {
        let url = groupUrlTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        joinOpenGroup(with: url)
    }
    
    @objc func scannerimageViewTapped() {
        let vc = ScanNewVC()
        vc.newChatScanflag = true
        vc.isFromSocialGroup = true
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let indexPath = self.collectionview?.indexPathForItem(at: sender.location(in: self.collectionview)) {
            let room = allRooms[indexPath.item]
            joinV2OpenGroup(room: room.id, server: OpenGroupAPIV2.defaultServer, publicKey: OpenGroupAPIV2.defaultServerPublicKey)
        }
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
                    self?.isJoining = false
                    self?.showError(title: "BChat", message: "Couldn't join social group.")
                }
        }
    }
    
    // MARK: Convenience
    private func showError(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
        presentAlert(alert)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allRooms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SocialGroupCell
        cell.allroom = allRooms[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 4   //number of column you want
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: 112)
    }
    
}
