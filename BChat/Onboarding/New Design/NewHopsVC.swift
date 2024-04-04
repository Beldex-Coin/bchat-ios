// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import NVActivityIndicatorView

class NewHopsVC: BaseVC {
    
    
    private lazy var infoLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleNewColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.22
        result.attributedText = NSMutableAttributedString(string: "BChat masks your IP address by routing your messages through several masternodes in the Beldex decentralized network. your connection is currently routed through the following masternodes", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return result
    }()
    
    private lazy var spinner: NVActivityIndicatorView = {
        let result = NVActivityIndicatorView(frame: CGRect.zero, type: .circleStrokeSpin, color: Colors.text, padding: nil)
        result.set(.width, to: 64)
        result.set(.height, to: 64)
        return result
    }()
    
    
    private lazy var youLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "You"
        return result
    }()
    
    lazy var filledDotView1: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = Colors.bothGreenColor
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
        View.layer.borderColor = Colors.bothGreenColor.cgColor
        View.layer.cornerRadius = 6
        return View
    }()
    
    private lazy var entryNodeLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
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
        View.backgroundColor = Colors.bothGreenColor
        View.layer.cornerRadius = 6
        return View
    }()
    
    private lazy var masterNodeLabel1: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
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
        View.layer.borderColor = Colors.bothGreenColor.cgColor
        View.layer.cornerRadius = 6
        return View
    }()
    
    private lazy var masterNodeLabel2: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
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
        View.backgroundColor = Colors.greenColor
        View.layer.cornerRadius = 8
        return View
    }()
    
    private lazy var destinationLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Destination"
        return result
    }()
    
    var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.mainBackGroundColor2
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Hops"
        
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
        update()
        registerObservers()
    }
    
    
    
    private func registerObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleBuildingPathsNotification), name: .buildingPaths, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handlePathsBuiltNotification), name: .pathsBuilt, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleOnionRequestPathCountriesLoadedNotification), name: .onionRequestPathCountriesLoaded, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Updating
    @objc private func handleBuildingPathsNotification() { update() }
    @objc private func handlePathsBuiltNotification() { update() }
    @objc private func handleOnionRequestPathCountriesLoadedNotification() { update() }

    
    private func update() {
//        pathStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if !OnionRequestAPI.paths.isEmpty {
            let pathToDisplay = OnionRequestAPI.paths.first!
            let dotAnimationRepeatInterval = Double(pathToDisplay.count) + 2
            let snodeRows: [UIStackView] = pathToDisplay.enumerated().map { index, snode in
                let isGuardSnode = (snode == pathToDisplay.first!)
                 getPathRow(snode: snode, location: .middle, dotAnimationStartDelay: Double(index) + 2, dotAnimationRepeatInterval: dotAnimationRepeatInterval, isGuardSnode: isGuardSnode)
                return UIStackView()
            }
//            let youRow = getPathRow(title: NSLocalizedString("vc_path_device_row_title", comment: ""), subtitle: nil, location: .top, dotAnimationStartDelay: 1, dotAnimationRepeatInterval: dotAnimationRepeatInterval)
//            let destinationRow = getPathRow(title: NSLocalizedString("vc_path_destination_row_title", comment: ""), subtitle: nil, location: .bottom, dotAnimationStartDelay: Double(pathToDisplay.count) + 2, dotAnimationRepeatInterval: dotAnimationRepeatInterval)
//            let rows = [ youRow ] + snodeRows + [ destinationRow ]
//            rows.forEach { pathStackView.addArrangedSubview($0) }
//            gifimageView.isHidden = true
            //spinner.stopAnimating()
            UIView.animate(withDuration: 0.25) {
                self.spinner.alpha = 0
            }
        } else {
//            gifimageView.isHidden = false
//            spinner.startAnimating()
            UIView.animate(withDuration: 0.25) {
                self.spinner.alpha = 1
            }
        }
    }

    private func getPathRow(snode: Snode, location: LineView2.Location, dotAnimationStartDelay: Double, dotAnimationRepeatInterval: Double, isGuardSnode: Bool) {
        let country = IP2Country.isInitialized ? (IP2Country.shared.countryNamesCache[snode.ip] ?? "Resolving...") : "Resolving..."
        let title = isGuardSnode ? NSLocalizedString("vc_path_guard_node_row_title", comment: "") : NSLocalizedString("Master Node", comment: "")
        
        
        count += 1
        if count == 1 {
            entryNodeLabel.text = title
            entryNodeInfoLabel.text = country
            return
        }
        
        if count == 2 {
            masterNodeLabel1.text = title
            masterNodeInfoLabel1.text = country
            return
        }
        
        if count == 3 {
            masterNodeLabel2.text = title
            masterNodeInfoLabel2.text = country
            return
        }
        
    }
   

}


private final class LineView2 : UIView {
    private let location: Location
    private let dotAnimationStartDelay: Double
    private let dotAnimationRepeatInterval: Double
    private var dotViewWidthConstraint: NSLayoutConstraint!
    private var dotViewHeightConstraint: NSLayoutConstraint!
    private var dotViewAnimationTimer: Timer!

    enum Location {
        case top, middle, bottom
    }

    private lazy var dotView: UIView = {
        let result = UIView()
        result.layer.cornerRadius = PathVC.dotSize / 2
        let glowRadius: CGFloat = isLightMode ? 1 : 2
        let glowColor = isLightMode ? UIColor.black.withAlphaComponent(0.4) : UIColor.black
        let glowConfiguration = UIView.CircularGlowConfiguration(size: PathVC.dotSize, color: glowColor, isAnimated: true, animationDuration: 0.5, radius: glowRadius)
        result.setCircularGlow(with: glowConfiguration)
        result.backgroundColor = Colors.accent
        return result
    }()
    
    init(location: Location, dotAnimationStartDelay: Double, dotAnimationRepeatInterval: Double) {
        self.location = location
        self.dotAnimationStartDelay = dotAnimationStartDelay
        self.dotAnimationRepeatInterval = dotAnimationRepeatInterval
        super.init(frame: CGRect.zero)
        setUpViewHierarchy()
    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(location:dotAnimationStartDelay:dotAnimationRepeatInterval:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(location:dotAnimationStartDelay:dotAnimationRepeatInterval:) instead.")
    }
    
    private func setUpViewHierarchy() {
        let lineView = UIView()
        lineView.set(.width, to: Values.separatorThickness)
        lineView.backgroundColor = Colors.text
        addSubview(lineView)
        lineView.center(.horizontal, in: self)
        switch location {
        case .top: lineView.topAnchor.constraint(equalTo: centerYAnchor).isActive = true
        case .middle, .bottom: lineView.pin(.top, to: .top, of: self)
        }
        switch location {
        case .top, .middle: lineView.pin(.bottom, to: .bottom, of: self)
        case .bottom: lineView.bottomAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
        let dotSize = PathVC.dotSize
        dotViewWidthConstraint = dotView.set(.width, to: dotSize)
        dotViewHeightConstraint = dotView.set(.height, to: dotSize)
        addSubview(dotView)
        dotView.center(in: self)
        Timer.scheduledTimer(withTimeInterval: dotAnimationStartDelay, repeats: false) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.animate()
            strongSelf.dotViewAnimationTimer = Timer.scheduledTimer(withTimeInterval: strongSelf.dotAnimationRepeatInterval, repeats: true) { _ in
                guard let strongSelf = self else { return }
                strongSelf.animate()
            }
        }
    }

    deinit {
        dotViewAnimationTimer?.invalidate()
    }

    private func animate() {
        expandDot()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.collapseDot()
        }
    }

    private func expandDot() {
        let newSize = PathVC.expandedDotSize
        let newGlowRadius: CGFloat = isLightMode ? 4 : 6
        let newGlowColor = Colors.accent.withAlphaComponent(0.6)
        updateDotView(size: newSize, glowRadius: newGlowRadius, glowColor: newGlowColor)
    }

    private func collapseDot() {
        let newSize = PathVC.dotSize
        let newGlowRadius: CGFloat = isLightMode ? 1 : 2
        let newGlowColor = isLightMode ? UIColor.black.withAlphaComponent(0.4) : UIColor.black
        updateDotView(size: newSize, glowRadius: newGlowRadius, glowColor: newGlowColor)
    }

    private func updateDotView(size: CGFloat, glowRadius: CGFloat, glowColor: UIColor) {
        let frame = CGRect(center: dotView.center, size: CGSize(width: size, height: size))
        dotViewWidthConstraint.constant = size
        dotViewHeightConstraint.constant = size
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
            self.dotView.frame = frame
            self.dotView.layer.cornerRadius = size / 2
            let glowConfiguration = UIView.CircularGlowConfiguration(size: size, color: glowColor, isAnimated: true, animationDuration: 0.5, radius: glowRadius)
            self.dotView.setCircularGlow(with: glowConfiguration)
            self.dotView.backgroundColor = Colors.accent
        }
    }
}
