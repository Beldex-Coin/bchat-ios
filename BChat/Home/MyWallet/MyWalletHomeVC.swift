// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class MyWalletHomeVC: BaseVC, ExpandedCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(WalletHomeXibCell.nib, forCellWithReuseIdentifier: WalletHomeXibCell.identifier)
        }
    }
    var rightBarButtonItems: [UIBarButtonItem] = []
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet var progressLabel: UILabel!
    
    @IBOutlet weak var NotransationImg: UIImageView!
    @IBOutlet var NotransationLabel: UILabel!
    
    @IBOutlet weak var leftview: UIView!
    @IBOutlet weak var rightview: UIView!
    @IBOutlet weak var view11: UIView!
    @IBOutlet weak var view22: UIView!
    @IBOutlet weak var view33: UIView!
    @IBOutlet weak var view44: UIView!
    @IBOutlet weak var view55: UIView!
    
    var array = ["12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022","12-Feb-2022"]
    var isExpanded = [Bool]()
    weak var delegate:ExpandedCellDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "My Wallet"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //depending upon direction of collection view
        self.collectionView?.setCollectionViewLayout(layout, animated: true)
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "menu")!, style: .plain, target: self, action: #selector(settingsoptn))
        rightBarButtonItems.append(settingsButton)
        let refreButton = UIBarButtonItem(image: UIImage(named: "Phone"), style: .plain, target: self, action: #selector(refreshoptn))
        refreButton.accessibilityLabel = "Settings button"
        refreButton.isAccessibilityElement = true
        rightBarButtonItems.append(refreButton)
        navigationItem.rightBarButtonItems = rightBarButtonItems
        
        leftview.layer.cornerRadius = 6
        rightview.layer.cornerRadius = 6
        view11.layer.cornerRadius = 6
        view22.layer.cornerRadius = 6
        view33.layer.cornerRadius = 6
        view44.layer.cornerRadius = view44.layer.frame.height/2
        view55.layer.cornerRadius = view55.layer.frame.height/2
        
        NotransationImg.isHidden = true
        NotransationLabel.isHidden = true
        collectionView.isHidden = false
        
        isExpanded = Array(repeating: false, count: array.count)
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func topButtonTouched(indexPath: IndexPath) {
        isExpanded[indexPath.row] = !isExpanded[indexPath.row]
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.collectionView.reloadItems(at: [indexPath])
        }, completion: { success in
            print("success")
        })
    }
    
    // MARK: Settings
    @objc func settingsoptn(_ sender: Any?) {
        
    }
    // MARK: Refresh
    @objc func refreshoptn(_ sender: Any?) {
        
    }
    
    
    
    
    
    
}
extension MyWalletHomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WalletHomeXibCell.identifier, for: indexPath) as! WalletHomeXibCell
        
        cell.indexPath = indexPath
        cell.delegate = self
        
        cell.lblname.text = array[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isExpanded[indexPath.row] == true{
            return CGSize(width: collectionView.frame.size.width, height: 275)
        }else{
            return CGSize(width: collectionView.frame.size.width, height: 75)
        }
    }
    

    
}
