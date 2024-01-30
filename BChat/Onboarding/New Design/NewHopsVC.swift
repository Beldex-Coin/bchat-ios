// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewHopsVC: BaseVC {
    
    
    private lazy var infoLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.22
        result.attributedText = NSMutableAttributedString(string: "BChat masks your IP address by routing your messages through several masternodes in the Beldex decentralized network. your connection is currently routed through the following masternodes", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return result
    }()
    
    
    private lazy var youLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "You"
        return result
    }()
    
    lazy var filledDotView1: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = UIColor(hex: 0x00BD40)
        View.layer.cornerRadius = 8
        return View
    }()
    
    private lazy var lineView1: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_lineDotted")
        result.set(.width, to: 1.5)
        result.set(.height, to: 39.5)
        result.layer.masksToBounds = true
        result.contentMode = .scaleToFill
        return result
    }()
    
    lazy var borderDotView1: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = .clear
        View.layer.borderWidth = 2
        View.layer.borderColor = UIColor(hex: 0x00BD40).cgColor
        View.layer.cornerRadius = 6
        return View
    }()
    
    private lazy var entryNodeLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Entry Node"
        return result
    }()
    
    private lazy var entryNodeInfoLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "United States [3.111.164.59]"
        return result
    }()
    
    
    private lazy var lineView2: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_lineDotted")
        result.set(.width, to: 1.5)
        result.set(.height, to: 39.5)
        result.layer.masksToBounds = true
        result.contentMode = .scaleToFill
        return result
    }()
    
    lazy var filledDotView2: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = UIColor(hex: 0x00BD40)
        View.layer.cornerRadius = 6
        return View
    }()
    
    private lazy var masterNodeLabel1: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Masternode"
        return result
    }()
    
    private lazy var masterNodeInfoLabel1: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "United States [3.111.164.59]"
        return result
    }()
    
    
    private lazy var lineView3: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_lineDotted")
        result.set(.width, to: 1.5)
        result.set(.height, to: 39.5)
        result.layer.masksToBounds = true
        result.contentMode = .scaleToFill
        return result
    }()
    
    lazy var borderDotView2: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = .clear
        View.layer.borderWidth = 2
        View.layer.borderColor = UIColor(hex: 0x00BD40).cgColor
        View.layer.cornerRadius = 6
        return View
    }()
    
    private lazy var masterNodeLabel2: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Masternode"
        return result
    }()
    
    private lazy var masterNodeInfoLabel2: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "United States [3.111.164.59]"
        return result
    }()
    
    private lazy var lineView4: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_lineDotted")
        result.set(.width, to: 1.5)
        result.set(.height, to: 39.5)
        result.layer.masksToBounds = true
        result.contentMode = .scaleToFill
        return result
    }()
    
    lazy var filledDotView3: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = UIColor(hex: 0x00BD40)
        View.layer.cornerRadius = 8
        return View
    }()
    
    private lazy var destinationLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Destination"
        return result
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Hops", style: .plain, target: nil, action: nil)
        
        view.addSubViews(infoLabel, youLabel, filledDotView1, lineView1, borderDotView1, entryNodeLabel, entryNodeInfoLabel, lineView2, filledDotView2, masterNodeLabel1, masterNodeInfoLabel1, lineView3, borderDotView2, masterNodeLabel2, masterNodeInfoLabel2, lineView4, filledDotView3, destinationLabel)
        
        
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 46),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -43),
            
            youLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 31),
            youLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 80),
            
            filledDotView1.topAnchor.constraint(equalTo: youLabel.bottomAnchor, constant: 4),
            filledDotView1.leadingAnchor.constraint(equalTo: youLabel.leadingAnchor, constant: 1),
            filledDotView1.heightAnchor.constraint(equalToConstant: 16),
            filledDotView1.widthAnchor.constraint(equalToConstant: 16),
            
            lineView1.topAnchor.constraint(equalTo: filledDotView1.bottomAnchor, constant: 10),
            lineView1.centerXAnchor.constraint(equalTo: filledDotView1.centerXAnchor),
            
            borderDotView1.topAnchor.constraint(equalTo: lineView1.bottomAnchor, constant: 9.5),
            borderDotView1.centerXAnchor.constraint(equalTo: filledDotView1.centerXAnchor),
            borderDotView1.heightAnchor.constraint(equalToConstant: 12),
            borderDotView1.widthAnchor.constraint(equalToConstant: 12),
            
            entryNodeLabel.topAnchor.constraint(equalTo: borderDotView1.bottomAnchor, constant: 5),
            entryNodeLabel.leadingAnchor.constraint(equalTo: borderDotView1.leadingAnchor, constant: 0),
            
            entryNodeInfoLabel.topAnchor.constraint(equalTo: entryNodeLabel.bottomAnchor, constant: 0),
            entryNodeInfoLabel.leadingAnchor.constraint(equalTo: borderDotView1.leadingAnchor, constant: 0),
            
            
            lineView2.topAnchor.constraint(equalTo: entryNodeInfoLabel.bottomAnchor, constant: 9),
            lineView2.centerXAnchor.constraint(equalTo: filledDotView1.centerXAnchor),
            
            filledDotView2.topAnchor.constraint(equalTo: lineView2.bottomAnchor, constant: 10.5),
            filledDotView2.centerXAnchor.constraint(equalTo: filledDotView1.centerXAnchor),
            filledDotView2.heightAnchor.constraint(equalToConstant: 12),
            filledDotView2.widthAnchor.constraint(equalToConstant: 12),
            
            masterNodeLabel1.topAnchor.constraint(equalTo: filledDotView2.bottomAnchor, constant: 5),
            masterNodeLabel1.leadingAnchor.constraint(equalTo: filledDotView2.leadingAnchor, constant: 0),
            
            masterNodeInfoLabel1.topAnchor.constraint(equalTo: masterNodeLabel1.bottomAnchor, constant: 0),
            masterNodeInfoLabel1.leadingAnchor.constraint(equalTo: borderDotView1.leadingAnchor, constant: 0),
            
            
            lineView3.topAnchor.constraint(equalTo: masterNodeInfoLabel1.bottomAnchor, constant: 9),
            lineView3.centerXAnchor.constraint(equalTo: filledDotView1.centerXAnchor),
            
            borderDotView2.topAnchor.constraint(equalTo: lineView3.bottomAnchor, constant: 9.5),
            borderDotView2.centerXAnchor.constraint(equalTo: filledDotView1.centerXAnchor),
            borderDotView2.heightAnchor.constraint(equalToConstant: 12),
            borderDotView2.widthAnchor.constraint(equalToConstant: 12),
            
            masterNodeLabel2.topAnchor.constraint(equalTo: borderDotView2.bottomAnchor, constant: 2),
            masterNodeLabel2.leadingAnchor.constraint(equalTo: borderDotView2.leadingAnchor, constant: 0),
            
            masterNodeInfoLabel2.topAnchor.constraint(equalTo: masterNodeLabel2.bottomAnchor, constant: 0),
            masterNodeInfoLabel2.leadingAnchor.constraint(equalTo: borderDotView1.leadingAnchor, constant: 0),
            
            lineView4.topAnchor.constraint(equalTo: masterNodeInfoLabel2.bottomAnchor, constant: 8),
            lineView4.centerXAnchor.constraint(equalTo: filledDotView1.centerXAnchor),
            
            filledDotView3.topAnchor.constraint(equalTo: lineView4.bottomAnchor, constant: 10.5),
            filledDotView3.centerXAnchor.constraint(equalTo: filledDotView1.centerXAnchor),
            filledDotView3.heightAnchor.constraint(equalToConstant: 16),
            filledDotView3.widthAnchor.constraint(equalToConstant: 16),
            
            destinationLabel.topAnchor.constraint(equalTo: filledDotView3.bottomAnchor, constant: 3),
            destinationLabel.leadingAnchor.constraint(equalTo: youLabel.leadingAnchor, constant: 0),
            
        ])
        
        
    }
    

   

}
