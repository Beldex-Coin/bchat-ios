// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class AllMediaViewController: BaseVC {
    
    
    
    lazy var containerViewForMediaAndDocument: SegmentedControl = {
       let stackView = SegmentedControl()
       stackView.translatesAutoresizingMaskIntoConstraints = false
       stackView.backgroundColor = .clear
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
    
    var collectionview: UICollectionView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "All Media"
        view.backgroundColor = Colors.mainBackGroundColor
        
        view.addSubViews(containerViewForMediaAndDocument, mediaLineView, documentLineView)
                
        containerViewForMediaAndDocument.items = ["Media", "Documents"]
        containerViewForMediaAndDocument.font = Fonts.boldOpenSans(ofSize: 16)
        containerViewForMediaAndDocument.selectedIndex = 0
        containerViewForMediaAndDocument.padding = 4
        containerViewForMediaAndDocument.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
        
        mediaLineView.backgroundColor = Colors.bothGreenColor
        documentLineView.backgroundColor = Colors.borderColorNew
        
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
        
        // Collection View
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.register(AllMediaCollectionViewCell.self, forCellWithReuseIdentifier: "AllMediaCollectionViewCell")
        collectionview.showsVerticalScrollIndicator = false
        collectionview.backgroundColor = .clear
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionview)
        NSLayoutConstraint.activate([
            collectionview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            collectionview.topAnchor.constraint(equalTo: mediaLineView.bottomAnchor, constant: 16),
            collectionview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            collectionview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
        ])
    }
    
    
    @objc func segmentValueChanged(_ sender: AnyObject?){
        self.collectionview.reloadData()
        if containerViewForMediaAndDocument.selectedIndex == 0 {
            print("Media")
            mediaLineView.backgroundColor = Colors.bothGreenColor
            documentLineView.backgroundColor = Colors.borderColorNew
            
//            self.noDataView.isHidden = false
//            self.noDataImageView.image = UIImage(named: "no_media_image")
//            self.noDataMessageLabel.text = "No Media items to show!"
            
        } else {
            print("Documents")
            documentLineView.backgroundColor = Colors.bothGreenColor
            mediaLineView.backgroundColor = Colors.borderColorNew
            
//            self.noDataView.isHidden = false
//            self.noDataImageView.image = UIImage(named: "no_document_image")
//            self.noDataMessageLabel.text = "No Document items to show!"
        }
    }

  

}


extension AllMediaViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if containerViewForMediaAndDocument.selectedIndex == 0 {
            return 11
        } else {
            return 16
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "AllMediaCollectionViewCell", for: indexPath) as! AllMediaCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 3
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: size)
    }
}

