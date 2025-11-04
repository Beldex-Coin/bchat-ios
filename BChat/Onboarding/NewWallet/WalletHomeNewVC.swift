// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import Alamofire
import BChatUIKit

class WalletHomeNewVC: BaseVC, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate {
    
    private lazy var topBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 18
        stackView.backgroundColor = Colors.walletHomeTopViewBackgroundColor
        return stackView
    }()
    
    private lazy var progressStatusLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var isCurrencyResultLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.cancelButtonTitleColor
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.center = view.center
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = Colors.borderColor
        progressView.tintColor = Colors.bothGreenColor
        return progressView
    }()
    
    private lazy var sliderView: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.thumbTintColor = .clear
        slider.setThumbImage(UIImage(named: "wallet_slider_Image"), for: .normal)
        slider.isUserInteractionEnabled = false
        return slider
    }()
    
    lazy var beldexLogoImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_beldex_green" : "ic_beldex_green"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    private lazy var beldexBalanceLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.boldOpenSans(ofSize: 26)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var middleBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 16
        stackView.backgroundColor = Colors.cancelButtonBackgroundColor
        return stackView
    }()
    
    private lazy var scanButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.messageRequestBackgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 14
        let image = UIImage(named: "ic_Newqr")?.scaled(to: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.enableSendButtonColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 14
        let image = UIImage(named: "ic_send_new")
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 1)
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var receiveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.bothGreenColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 14
        let image = UIImage(named: "ic_receive_wallet")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(receiveButtonTapped), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 3, right: 0)
        return button
    }()
    
    private lazy var reConnectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.walletHomeReconnectBackgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 14
        let logoImage = isLightMode ? "ic_rotate_dark" : "ic_rotate_new"
        let image = UIImage(named: logoImage)?.scaled(to: CGSize(width: 25, height: 25))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(reConnectButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ scanButton, sendButton, receiveButton, reConnectButton ])
        result.axis = .horizontal
        result.spacing = 22
        result.distribution = .fillEqually
        result.translatesAutoresizingMaskIntoConstraints = false
        result.alignment = .center
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    private lazy var transationTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("TRANSACTION_LABEL", comment: "")
        result.textColor = Colors.titleColor3
        result.font = Fonts.semiOpenSans(ofSize: 18)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var filterImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_Filter_New" : "ic_Filter_New"
        let image = UIImage(named: logoImage)?.scaled(to: CGSize(width: 20, height: 20))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(filterImageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Here Wallet Syncing Components
    private lazy var walletSyncingBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor2
        stackView.layer.cornerRadius = 28
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stackView
    }()
    
    lazy var walletSyncingLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_wallet_syncing_dark" : "ic_wallet_syncing_new"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    private lazy var walletSyncingTitleLabel: UILabel = {
        let result = UILabel()
        result.text = "Wallet Syncing.."
        result.textColor = Colors.noDataLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 18)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var walletSyncingSubTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("PLEASE_WAIT_WHILE_WALLET_SYNCING", comment: "")
        result.textColor = Colors.noDataLabelColor
        result.font = Fonts.regularOpenSans(ofSize: 12)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    // MARK: - Here No Transactions Yet Components
    private lazy var noTransactionsYetBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor2
        stackView.layer.cornerRadius = 28
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stackView
    }()
    
    lazy var noTransactionsYetLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_no_transactions_white" : "ic_no_transactions"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    private lazy var noTransactionsYetTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("NO_TRANSACTION_MSG", comment: "")
        result.textColor = Colors.noDataLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 18)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var noTransactionsYetSubTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("AFTER_YOUR_FIRST_TRANSATION_VIEW", comment: "")
        result.textColor = Colors.noDataLabelColor
        result.font = Fonts.regularOpenSans(ofSize: 12)
        result.textAlignment = .center
        result.numberOfLines = 0
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    // MARK: - Here Transactions History Components
    private lazy var filterTransactionsHistoryBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor2
        stackView.layer.cornerRadius = 28
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stackView
    }()
    
    private lazy var incomingButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("INCOMING_BUTTON", comment: ""), for: .normal)
        let logoImage = isLightMode ? "ic_uncheck_white_Theme" : "ic_uncheck"
        let image = UIImage(named: logoImage)?.scaled(to: CGSize(width: 20.0, height: 20.0))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white // Set the tint color to white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Colors.walletHomeFilterLabelColor, for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(incomingButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var outgoingButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("OUTGOING_BUTTON", comment: ""), for: .normal)
        let logoImage = isLightMode ? "ic_uncheck_white_Theme" : "ic_uncheck"
        let image = UIImage(named: logoImage)?.scaled(to: CGSize(width: 20.0, height: 20.0))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white // Set the tint color to white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Colors.walletHomeFilterLabelColor, for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(outgoingButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var byDateButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("BY_DATE_BUTTON", comment: ""), for: .normal)
        let logoImage = isLightMode ? "ic_by_date_dark" : "ic_by_date_New"
        let image = UIImage(named: logoImage)?.scaled(to: CGSize(width: 20.0, height: 20.0))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white // Set the tint color to white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Colors.walletHomeFilterLabelColor, for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(byDateButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var filterStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ incomingButton, outgoingButton, byDateButton ])
        result.axis = .horizontal
        result.spacing = 30
        result.distribution = .fillEqually
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var lineBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.borderColor
        return stackView
    }()
    
    private lazy var lineBackgroundView2: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.borderColor
        return stackView
    }()
    
    private lazy var lineBackgroundView3: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.borderColor
        return stackView
    }()
    
    private lazy var lineBackgroundView4: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.borderColor
        return stackView
    }()
    
    private lazy var lineBackgroundView5: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.borderColor
        return stackView
    }()
    
    private lazy var lineBackgroundView6: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.borderColor
        return stackView
    }()
    
    private lazy var lineBackgroundView7: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.borderColor
        return stackView
    }()
    
    private lazy var lineBackgroundView8: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.borderColor
        return stackView
    }()
    
    private lazy var feeLineBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.borderColor
        return stackView
    }()
    
    @objc private lazy var tableView: UITableView = {
        let result = UITableView()
        result.dataSource = self
        result.delegate = self
        result.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        result.separatorStyle = .none
        result.backgroundColor = .clear
        result.translatesAutoresizingMaskIntoConstraints = false
        result.rowHeight = UITableView.automaticDimension
        return result
    }()
    
    // MARK: - Here No Transactions Details Components
    private lazy var transactionsDetailsBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor2
        stackView.layer.cornerRadius = 28
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stackView
    }()
    
    private lazy var detailsTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("DETAILS_MSG", comment: "")
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 18)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var backImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_transation_back_dark" : "ic_transation_back_new"
        let image = UIImage(named: logoImage)?.scaled(to: CGSize(width: 35, height: 25))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backImageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var directionLogoForDetailsPageImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var balanceAmountForDetailsPageLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 15)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var dateForDetailsPageLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.walletHomeFilterLabelColor
        result.font = Fonts.regularOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var transationDetailsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("TRANSACTION_ID", comment: "")
        return result
    }()
    
    //===========================================================================
    lazy var transationDetailsIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.walletHomeFilterLabelColor
        result.font = Fonts.regularOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.numberOfLines = 0
        result.translatesAutoresizingMaskIntoConstraints = false
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(transationDetailsIDLabelTapped))
        result.isUserInteractionEnabled = true
        result.addGestureRecognizer(tapGesture)
        return result
    }()
    
    private lazy var transationIDcopyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "ic_copy_green"), for: .normal)
        button.addTarget(self, action: #selector(transationIDcopyButtonTapped), for: .touchUpInside)
        button.tintColor = Colors.bothGreenColor
        return button
    }()
    
    private lazy var outerBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var subStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fill
        result.spacing = 25
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var transationIDStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .fill
        result.distribution = .fill
        result.spacing = 10
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var subStackView2: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .fill
        result.distribution = .fillEqually
        result.spacing = 25
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var dateIDStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .fill
        result.distribution = .fill
        result.spacing = 10
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var dateDetailsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("DATE_TITLE", comment: "")
        return result
    }()
    
    lazy var dateDetailsIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .right
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var subStackView3: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .fill
        result.distribution = .fillEqually
        result.spacing = 25
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var paymentIDStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .fill
        result.distribution = .fill
        result.spacing = 10
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var paymentTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("Payment ID", comment: "")
        return result
    }()
    
    lazy var paymentIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .right
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "000000000000"
        return result
    }()
    
    lazy var subStackView4: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .fill
        result.distribution = .fillEqually
        result.spacing = 25
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var heightIDStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .fill
        result.distribution = .fill
        result.spacing = 10
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var subStackView5: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .fill
        result.distribution = .fillEqually
        result.spacing = 25
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var amountIDStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .fill
        result.distribution = .fill
        result.spacing = 10
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var subStackView6: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fill
        result.spacing = 25
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var recipientAddressStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .center
        result.distribution = .fill
        result.spacing = 10
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var mainStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .center
        result.distribution = .fill
        result.spacing = 10
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var heightDetailsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("HEIGHT_TITLE", comment: "")
        return result
    }()
    
    lazy var heightDetailsIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .right
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var amountDetailsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("AMOUNT_TITLE", comment: "")
        return result
    }()
    
    lazy var amountDetailsIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .right
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var isFromSendDetailsTitleLabel: UILabel = {
        let result = UILabel()
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("ATTACHMENT_APPROVAL_SEND_BUTTON", comment: "")
        return result
    }()
    
    lazy var recipientAddressDetailsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("RECIPIENT_ADDRESS", comment: "")
        return result
    }()
    
    lazy var recipientAddressDetailsIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.walletHomeFilterLabelColor
        result.font = Fonts.regularOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.numberOfLines = 0
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var recipientAddresscopyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "ic_copy_green"), for: .normal)
        button.addTarget(self, action: #selector(recipientAddresscopyButtonTapped), for: .touchUpInside)
        button.tintColor = Colors.bothGreenColor
        return button
    }()
    
    
    lazy var feeSubStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .fill
        result.distribution = .fillEqually
        result.spacing = 25
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var feeDetailsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("FEE_TITLE", comment: "")
        return result
    }()
    
    lazy var feeDetailsLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .right
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var feeIDStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .fill
        result.distribution = .fill
        result.spacing = 10
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    private lazy var stackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ filterStackView, lineBackgroundView, tableView ])
        result.axis = .vertical
        result.spacing = 1
        result.distribution = .fill
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    //Date PopUp
    private lazy var backgroundBlerView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.walletHomeDateViewBackgroundColor
        return stackView
    }()
    
    private lazy var selectDateRangePopUpbackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.smallBackGroundColor
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.borderColor.cgColor
        return stackView
    }()
    
    lazy var selectDateRangeTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("Select Date Range", comment: "")
        return result
    }()
    
    private lazy var fromDateTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("From Date", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: Colors.noDataLabelColor])
        result.font = Fonts.regularOpenSans(ofSize: 14)
        result.layer.borderColor = Colors.borderColor.cgColor
        result.layer.borderWidth = 1
        result.backgroundColor = Colors.cellGroundColor2
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = Values.buttonRadius
        // Left Image
        let leftImageView = UIImageView(image: UIImage(named: "ic_Calendar_green"))
        leftImageView.frame = CGRect(x: 15, y: 0, width: 20, height: 20)
        leftImageView.contentMode = .scaleAspectFit
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 20))
        leftPaddingView.addSubview(leftImageView)
        result.leftView = leftPaddingView
        result.leftViewMode = .always
        // Right Image
        let rightImageView = UIImageView(image: UIImage(named: "ic_fullCircle"))
        rightImageView.frame = CGRect(x: 0, y: 0, width: 8, height: 8)
        rightImageView.contentMode = .scaleAspectFit
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 8))
        rightPaddingView.addSubview(rightImageView)
        result.rightView = rightPaddingView
        result.rightViewMode = .always
        return result
    }()
    
    private lazy var toDateTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("To Date", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: Colors.noDataLabelColor])
        result.font = Fonts.regularOpenSans(ofSize: 14)
        result.layer.borderColor = Colors.borderColor.cgColor
        result.layer.borderWidth = 1
        result.backgroundColor = Colors.cellGroundColor2
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = Values.buttonRadius
        // Left Image
        let leftImageView = UIImageView(image: UIImage(named: "ic_Calendar_blue"))
        leftImageView.frame = CGRect(x: 15, y: 0, width: 20, height: 20)
        leftImageView.contentMode = .scaleAspectFit
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 20))
        leftPaddingView.addSubview(leftImageView)
        result.leftView = leftPaddingView
        result.leftViewMode = .always
        // Right Image
        let rightImageView = UIImageView(image: UIImage(named: "ic_Ellipse_New"))
        rightImageView.frame = CGRect(x: 0, y: 0, width: 8, height: 8)
        rightImageView.contentMode = .scaleAspectFit
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 8))
        rightPaddingView.addSubview(rightImageView)
        result.rightView = rightPaddingView
        result.rightViewMode = .always
        return result
    }()
    
    private lazy var cancelButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString("Cancel", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        result.backgroundColor = Colors.cancelButtonBackgroundColor2
        result.setTitleColor(Colors.cancelButtonTitleColor, for: .normal)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var okButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString("OK", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        result.layer.cornerRadius = 16
        result.backgroundColor = Colors.bothGreenColor
        result.setTitleColor(UIColor.white, for: .normal)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ cancelButton, okButton ])
        result.axis = .horizontal
        result.spacing = 15
        result.distribution = .fillEqually
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    var fromDate : String = ""
    var toDate : String = ""
    private var wallet: BDXWallet?
    private var isSyncingUI = false {
        didSet {
            guard oldValue != isSyncingUI else { return }
            if isSyncingUI {
                RunLoop.main.add(timer, forMode: .common)
            } else {
                timer.invalidate()
            }
        }
    }
    
    private lazy var timer: Timer = {
        Timer.init(timeInterval: 0.5, repeats: true) { [weak self] (_) in
            guard let `self` = self else { return }
            self.updateSyncingProgress()
        }
    }()
    
    private var needSynchronized = false {
        didSet {
            guard needSynchronized, !oldValue,
                  let wallet = self.wallet else { return }
            wallet.saveOnTerminate()
        }
    }
    
    var syncingIsFromDelegateMethod = true
    var syncedflag = false
    lazy var statusTextState = { return Observable<String>("") }()
    lazy var conncetingState = { return Observable<Bool>(false) }()
    lazy var refreshState = { return Observable<Bool>(false) }()
    public lazy var loadingState = { Postable<Bool>() }()
    private var connecting: Bool { return conncetingState.value}
    private var currentBlockChainHeight: UInt64 = 0
    private var daemonBlockChainHeight: UInt64 = 0
    var backApiRescanVC = false
    private var listening = false
    private lazy var taskQueue = DispatchQueue(label: "beldex.wallet.task")
    lazy var progressState = { return Observable<CGFloat>(0) }()
    
    var nodeArray = HostManager.shared.hostNet
    
    var nodeArrayDynamic : [String]?
    let myGroup = DispatchGroup()
    var randomNodeValue = ""
    var hashArray = [RecipientDomainSchema]()
    var BackAPI = false
    private var SelectedBalance = ""
    private var marketsDataRequest: DataRequest?
    var backAPISelectedCurrency = false
    private var currencyName = ""
    var mainBalance = ""
    private var currencyValue: Double!
    private var refreshDuration: TimeInterval = 60
    private var selectedDecimal = ""
    var isdaemonHeight : Int64 = 0
    var isFromAllTransationFlag = false
    var isFromSendTransationFlag = false
    var isFromReceiveTransationFlag = false
    var filteredAllTransactionarray : [TransactionItem] = []
    var filteredOutgoingTransactionarray : [TransactionItem] = []
    var filteredIncomingTransactionarray : [TransactionItem] = []
    var transactionAllArray = [TransactionItem]()
    var transactionSendArray = [TransactionItem]()
    var transactionReceiveArray = [TransactionItem]()
    var isFilter = false
    var noTransaction = false
    
    var groupedItemsAll: [String: [TransactionItem]] = [:]
    var groupedItemsSend: [String: [TransactionItem]] = [:]
    var groupedItemsReceived: [String: [TransactionItem]] = [:]
    
    var sortedGroupedTransactionAllArray: [(key: String, value: [TransactionItem])] = []
    var sortedGroupedTransactionSendArray: [(key: String, value: [TransactionItem])] = []
    var sortedGroupedTransactionReceiveArray: [(key: String, value: [TransactionItem])] = []
    
    var filteredAllTransactionSortingArray: [(key: String, value: [TransactionItem])] = []
    var filteredOutgoingTransactionSortingArray: [(key: String, value: [TransactionItem])] = []
    var filteredIncomingTransactionSortingArray: [(key: String, value: [TransactionItem])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.cancelButtonBackgroundColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "My Wallet"
        
        let image = UIImage(named: "NavBarBack")?.withRenderingMode(.alwaysTemplate)
        let leftBarItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backToHomeScreen))
        navigationItem.leftBarButtonItem = leftBarItem
        leftBarItem.imageInsets = UIEdgeInsets(top: -1, leading: -6, bottom: 0, trailing: 0)
        
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "icsettings1_New")!, style: .plain, target: self, action: #selector(settingsOptionTapped))
        let rightBarButtonItems = [rightBarItem]
        navigationItem.rightBarButtonItems = rightBarButtonItems
        
        view.addSubview(topBackgroundView)
        topBackgroundView.addSubview(progressStatusLabel)
        topBackgroundView.addSubview(isCurrencyResultLabel)
        topBackgroundView.addSubview(progressView)
        topBackgroundView.addSubview(sliderView)
        topBackgroundView.addSubview(beldexLogoImg)
        topBackgroundView.addSubview(beldexBalanceLabel)
        topBackgroundView.addSubview(middleBackgroundView)
        middleBackgroundView.addSubview(buttonsStackView)
        view.addSubview(transationTitleLabel)
        view.addSubview(filterImageButton)
        
        view.addSubview(walletSyncingBackgroundView)
        walletSyncingBackgroundView.addSubview(walletSyncingLogoImage)
        walletSyncingBackgroundView.addSubview(walletSyncingTitleLabel)
        walletSyncingBackgroundView.addSubview(walletSyncingSubTitleLabel)
        
        view.addSubview(noTransactionsYetBackgroundView)
        noTransactionsYetBackgroundView.addSubview(noTransactionsYetLogoImage)
        noTransactionsYetBackgroundView.addSubview(noTransactionsYetTitleLabel)
        noTransactionsYetBackgroundView.addSubview(noTransactionsYetSubTitleLabel)
        
        view.addSubview(filterTransactionsHistoryBackgroundView)
        filterTransactionsHistoryBackgroundView.addSubview(filterStackView)
        filterTransactionsHistoryBackgroundView.addSubview(lineBackgroundView)
        filterTransactionsHistoryBackgroundView.addSubview(tableView)
        filterTransactionsHistoryBackgroundView.addSubview(stackView)
        
        view.addSubview(transactionsDetailsBackgroundView)
        transactionsDetailsBackgroundView.addSubview(detailsTitleLabel)
        transactionsDetailsBackgroundView.addSubview(backImageButton)
        transactionsDetailsBackgroundView.addSubview(lineBackgroundView2)
        transactionsDetailsBackgroundView.addSubview(directionLogoForDetailsPageImage)
        transactionsDetailsBackgroundView.addSubview(balanceAmountForDetailsPageLabel)
        transactionsDetailsBackgroundView.addSubview(dateForDetailsPageLabel)
        transactionsDetailsBackgroundView.addSubview(transationDetailsTitleLabel)
        transactionsDetailsBackgroundView.addSubview(isFromSendDetailsTitleLabel)
        transactionsDetailsBackgroundView.addSubview(outerBackgroundView)
        
        outerBackgroundView.addSubview(subStackView)
        subStackView.addArrangedSubview(transationDetailsIDLabel)
        subStackView.addArrangedSubview(transationIDcopyButton)
        outerBackgroundView.addSubview(lineBackgroundView3)
        outerBackgroundView.addSubview(transationIDStackView)
        transationIDStackView.addArrangedSubview(subStackView)
        transationIDStackView.addArrangedSubview(lineBackgroundView3)
        
        outerBackgroundView.addSubview(subStackView2)
        subStackView2.addArrangedSubview(dateDetailsTitleLabel)
        subStackView2.addArrangedSubview(dateDetailsIDLabel)
        outerBackgroundView.addSubview(lineBackgroundView4)
        outerBackgroundView.addSubview(dateIDStackView)
        dateIDStackView.addArrangedSubview(subStackView2)
        dateIDStackView.addArrangedSubview(lineBackgroundView4)
        
        outerBackgroundView.addSubview(subStackView3)
        subStackView3.addArrangedSubview(paymentTitleLabel)
        subStackView3.addArrangedSubview(paymentIDLabel)
        outerBackgroundView.addSubview(lineBackgroundView5)
        outerBackgroundView.addSubview(paymentIDStackView)
        paymentIDStackView.addArrangedSubview(subStackView3)
        paymentIDStackView.addArrangedSubview(lineBackgroundView5)
        
        outerBackgroundView.addSubview(subStackView4)
        subStackView4.addArrangedSubview(heightDetailsTitleLabel)
        subStackView4.addArrangedSubview(heightDetailsIDLabel)
        outerBackgroundView.addSubview(lineBackgroundView6)
        outerBackgroundView.addSubview(heightIDStackView)
        heightIDStackView.addArrangedSubview(subStackView4)
        heightIDStackView.addArrangedSubview(lineBackgroundView6)
        
        outerBackgroundView.addSubview(subStackView5)
        subStackView5.addArrangedSubview(amountDetailsTitleLabel)
        subStackView5.addArrangedSubview(amountDetailsIDLabel)
        outerBackgroundView.addSubview(lineBackgroundView7)
        outerBackgroundView.addSubview(amountIDStackView)
        amountIDStackView.addArrangedSubview(subStackView5)
        amountIDStackView.addArrangedSubview(lineBackgroundView7)
        
        
        //  recipient Address
        outerBackgroundView.addSubview(subStackView6)
        subStackView6.addArrangedSubview(recipientAddressDetailsIDLabel)
        subStackView6.addArrangedSubview(recipientAddresscopyButton)
        outerBackgroundView.addSubview(recipientAddressDetailsTitleLabel)
        outerBackgroundView.addSubview(recipientAddressStackView)
        recipientAddressStackView.addArrangedSubview(recipientAddressDetailsTitleLabel)
        recipientAddressStackView.addArrangedSubview(subStackView6)
        
        // Fee
        outerBackgroundView.addSubview(feeSubStackView)
        feeSubStackView.addArrangedSubview(feeDetailsTitleLabel)
        feeSubStackView.addArrangedSubview(feeDetailsLabel)
        outerBackgroundView.addSubview(feeLineBackgroundView)
        outerBackgroundView.addSubview(feeIDStackView)
        feeIDStackView.addArrangedSubview(feeSubStackView)
        feeIDStackView.addArrangedSubview(feeLineBackgroundView)
        
        outerBackgroundView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(transationIDStackView)
        mainStackView.addArrangedSubview(dateIDStackView)
        mainStackView.addArrangedSubview(paymentIDStackView)
        mainStackView.addArrangedSubview(heightIDStackView)
        mainStackView.addArrangedSubview(amountIDStackView)
        mainStackView.addArrangedSubview(recipientAddressStackView)
        mainStackView.addArrangedSubview(feeIDStackView)
        // Date PopUp
        view.addSubview(backgroundBlerView)
        backgroundBlerView.addSubview(selectDateRangePopUpbackgroundView)
        selectDateRangePopUpbackgroundView.addSubview(selectDateRangeTitleLabel)
        selectDateRangePopUpbackgroundView.addSubview(fromDateTextField)
        selectDateRangePopUpbackgroundView.addSubview(toDateTextField)
        selectDateRangePopUpbackgroundView.addSubview(buttonStackView)
        
        // Date PopUp
        backgroundBlerView.isHidden = true
        selectDateRangePopUpbackgroundView.isHidden = true
        
        filterStackView.isHidden = true
        lineBackgroundView.isHidden = true
        
        NSLayoutConstraint.activate([
            topBackgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            progressStatusLabel.topAnchor.constraint(equalTo: topBackgroundView.topAnchor, constant: 20),
            progressStatusLabel.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 18),
            isCurrencyResultLabel.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -18),
            isCurrencyResultLabel.centerYAnchor.constraint(equalTo: progressStatusLabel.centerYAnchor),
            progressView.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 2),
            progressView.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -2),
            progressView.topAnchor.constraint(equalTo: progressStatusLabel.bottomAnchor, constant: 16),
            progressView.heightAnchor.constraint(equalToConstant: 1.5),
            beldexLogoImg.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 23),
            beldexLogoImg.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 18),
            beldexLogoImg.widthAnchor.constraint(equalToConstant: 20),
            beldexLogoImg.heightAnchor.constraint(equalToConstant: 20),
            beldexBalanceLabel.centerYAnchor.constraint(equalTo: beldexLogoImg.centerYAnchor),
            beldexBalanceLabel.leadingAnchor.constraint(equalTo: beldexLogoImg.trailingAnchor, constant: 10),
            middleBackgroundView.heightAnchor.constraint(equalToConstant: 90),
            middleBackgroundView.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 22),
            middleBackgroundView.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -22),
            middleBackgroundView.centerXAnchor.constraint(equalTo: topBackgroundView.centerXAnchor),
            middleBackgroundView.topAnchor.constraint(equalTo: beldexLogoImg.bottomAnchor, constant: 23),
            middleBackgroundView.centerYAnchor.constraint(equalTo: topBackgroundView.lastBaselineAnchor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 50),
            scanButton.heightAnchor.constraint(equalToConstant: 50),
            sendButton.heightAnchor.constraint(equalToConstant: 50),
            receiveButton.heightAnchor.constraint(equalToConstant: 50),
            reConnectButton.heightAnchor.constraint(equalToConstant: 50),
            scanButton.widthAnchor.constraint(equalToConstant: 50),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            receiveButton.widthAnchor.constraint(equalToConstant: 50),
            reConnectButton.widthAnchor.constraint(equalToConstant: 50),
            buttonsStackView.centerXAnchor.constraint(equalTo: middleBackgroundView.centerXAnchor),
            buttonsStackView.centerYAnchor.constraint(equalTo: middleBackgroundView.centerYAnchor),
            transationTitleLabel.topAnchor.constraint(equalTo: middleBackgroundView.bottomAnchor, constant: 13),
            transationTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            filterImageButton.heightAnchor.constraint(equalToConstant: 35),
            filterImageButton.widthAnchor.constraint(equalToConstant: 35),
            filterImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            filterImageButton.centerYAnchor.constraint(equalTo: transationTitleLabel.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            walletSyncingBackgroundView.topAnchor.constraint(equalTo: filterImageButton.bottomAnchor, constant: 12),
            walletSyncingBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            walletSyncingBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            walletSyncingBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0),
            walletSyncingLogoImage.heightAnchor.constraint(equalToConstant: 68),
            walletSyncingLogoImage.widthAnchor.constraint(equalToConstant: 68),
            walletSyncingLogoImage.centerYAnchor.constraint(equalTo: walletSyncingBackgroundView.centerYAnchor, constant: -60),
            walletSyncingLogoImage.centerXAnchor.constraint(equalTo: walletSyncingBackgroundView.centerXAnchor),
            walletSyncingTitleLabel.topAnchor.constraint(equalTo: walletSyncingLogoImage.bottomAnchor, constant: 20),
            walletSyncingTitleLabel.centerXAnchor.constraint(equalTo: walletSyncingLogoImage.centerXAnchor),
            walletSyncingSubTitleLabel.topAnchor.constraint(equalTo: walletSyncingTitleLabel.bottomAnchor, constant: 5),
            walletSyncingSubTitleLabel.centerXAnchor.constraint(equalTo: walletSyncingLogoImage.centerXAnchor),
        ])
        
        self.sliderView.pin(to: progressView)
        
        NSLayoutConstraint.activate([
            noTransactionsYetBackgroundView.topAnchor.constraint(equalTo: filterImageButton.bottomAnchor, constant: 12),
            noTransactionsYetBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            noTransactionsYetBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            noTransactionsYetBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0),
            noTransactionsYetLogoImage.heightAnchor.constraint(equalToConstant: 141),
            noTransactionsYetLogoImage.widthAnchor.constraint(equalToConstant: 141),
            noTransactionsYetLogoImage.centerYAnchor.constraint(equalTo: noTransactionsYetBackgroundView.centerYAnchor, constant: -60),
            noTransactionsYetLogoImage.centerXAnchor.constraint(equalTo: noTransactionsYetBackgroundView.centerXAnchor),
            noTransactionsYetTitleLabel.topAnchor.constraint(equalTo: noTransactionsYetLogoImage.bottomAnchor, constant: 20),
            noTransactionsYetTitleLabel.centerXAnchor.constraint(equalTo: noTransactionsYetLogoImage.centerXAnchor),
            noTransactionsYetSubTitleLabel.topAnchor.constraint(equalTo: noTransactionsYetTitleLabel.bottomAnchor, constant: 5),
            noTransactionsYetSubTitleLabel.centerXAnchor.constraint(equalTo: noTransactionsYetLogoImage.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            filterTransactionsHistoryBackgroundView.topAnchor.constraint(equalTo: filterImageButton.bottomAnchor, constant: 12),
            filterTransactionsHistoryBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            filterTransactionsHistoryBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            filterTransactionsHistoryBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0),
            filterStackView.topAnchor.constraint(equalTo: filterTransactionsHistoryBackgroundView.topAnchor, constant: 10),
            filterStackView.trailingAnchor.constraint(equalTo: filterTransactionsHistoryBackgroundView.trailingAnchor, constant: -25),
            filterStackView.leadingAnchor.constraint(equalTo: filterTransactionsHistoryBackgroundView.leadingAnchor, constant: 25),
            filterStackView.heightAnchor.constraint(equalToConstant: 50),
            lineBackgroundView.topAnchor.constraint(equalTo: filterStackView.bottomAnchor, constant: 15),
            lineBackgroundView.trailingAnchor.constraint(equalTo: filterTransactionsHistoryBackgroundView.trailingAnchor, constant: -0),
            lineBackgroundView.leadingAnchor.constraint(equalTo: filterTransactionsHistoryBackgroundView.leadingAnchor, constant: 0),
            lineBackgroundView.heightAnchor.constraint(equalToConstant: 1),
            tableView.topAnchor.constraint(equalTo: lineBackgroundView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: filterTransactionsHistoryBackgroundView.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: filterTransactionsHistoryBackgroundView.trailingAnchor, constant: -0),
            tableView.bottomAnchor.constraint(equalTo: filterTransactionsHistoryBackgroundView.bottomAnchor, constant: -0),
            stackView.topAnchor.constraint(equalTo: filterTransactionsHistoryBackgroundView.topAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: filterTransactionsHistoryBackgroundView.trailingAnchor, constant: -0),
            stackView.leadingAnchor.constraint(equalTo: filterTransactionsHistoryBackgroundView.leadingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: filterTransactionsHistoryBackgroundView.bottomAnchor, constant: -0)
        ])
        
        NSLayoutConstraint.activate([
            transactionsDetailsBackgroundView.topAnchor.constraint(equalTo: filterImageButton.bottomAnchor, constant: 12),
            transactionsDetailsBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            transactionsDetailsBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            transactionsDetailsBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0),
            detailsTitleLabel.topAnchor.constraint(equalTo: transactionsDetailsBackgroundView.topAnchor, constant: 18),
            detailsTitleLabel.centerXAnchor.constraint(equalTo: transactionsDetailsBackgroundView.centerXAnchor),
            backImageButton.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 25),
            backImageButton.centerYAnchor.constraint(equalTo: detailsTitleLabel.centerYAnchor),
            lineBackgroundView2.topAnchor.constraint(equalTo: detailsTitleLabel.bottomAnchor, constant: 13),
            lineBackgroundView2.trailingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.trailingAnchor, constant: -0),
            lineBackgroundView2.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 0),
            lineBackgroundView2.heightAnchor.constraint(equalToConstant: 1),
            directionLogoForDetailsPageImage.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 25),
            directionLogoForDetailsPageImage.widthAnchor.constraint(equalToConstant: 24),
            directionLogoForDetailsPageImage.heightAnchor.constraint(equalToConstant: 24),
            directionLogoForDetailsPageImage.topAnchor.constraint(equalTo: lineBackgroundView2.bottomAnchor, constant: 30),
            balanceAmountForDetailsPageLabel.leadingAnchor.constraint(equalTo: directionLogoForDetailsPageImage.trailingAnchor, constant: 13),
            balanceAmountForDetailsPageLabel.centerYAnchor.constraint(equalTo: directionLogoForDetailsPageImage.centerYAnchor, constant: -10),
            dateForDetailsPageLabel.leadingAnchor.constraint(equalTo: directionLogoForDetailsPageImage.trailingAnchor, constant: 13),
            dateForDetailsPageLabel.centerYAnchor.constraint(equalTo: directionLogoForDetailsPageImage.centerYAnchor, constant: 10),
            transationDetailsTitleLabel.topAnchor.constraint(equalTo: dateForDetailsPageLabel.bottomAnchor, constant: 17),
            transationDetailsTitleLabel.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 25),
            isFromSendDetailsTitleLabel.trailingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.trailingAnchor, constant: -23),
            isFromSendDetailsTitleLabel.centerYAnchor.constraint(equalTo: directionLogoForDetailsPageImage.centerYAnchor),
            
            outerBackgroundView.topAnchor.constraint(equalTo: transationDetailsTitleLabel.bottomAnchor, constant: 10),
            outerBackgroundView.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 25),
            outerBackgroundView.trailingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.trailingAnchor, constant: -23),
            
            transationIDcopyButton.widthAnchor.constraint(equalToConstant: 16),
            transationIDcopyButton.heightAnchor.constraint(equalToConstant: 16),
            lineBackgroundView3.heightAnchor.constraint(equalToConstant: 1),
            lineBackgroundView3.leadingAnchor.constraint(equalTo: outerBackgroundView.leadingAnchor, constant: 0),
            lineBackgroundView3.trailingAnchor.constraint(equalTo: outerBackgroundView.trailingAnchor, constant: -0),
            lineBackgroundView4.heightAnchor.constraint(equalToConstant: 1),
            lineBackgroundView4.leadingAnchor.constraint(equalTo: outerBackgroundView.leadingAnchor, constant: 0),
            lineBackgroundView4.trailingAnchor.constraint(equalTo: outerBackgroundView.trailingAnchor, constant: -0),
            lineBackgroundView5.heightAnchor.constraint(equalToConstant: 1),
            lineBackgroundView5.leadingAnchor.constraint(equalTo: outerBackgroundView.leadingAnchor, constant: 0),
            lineBackgroundView5.trailingAnchor.constraint(equalTo: outerBackgroundView.trailingAnchor, constant: -0),
            lineBackgroundView6.heightAnchor.constraint(equalToConstant: 1),
            lineBackgroundView6.leadingAnchor.constraint(equalTo: outerBackgroundView.leadingAnchor, constant: 0),
            lineBackgroundView6.trailingAnchor.constraint(equalTo: outerBackgroundView.trailingAnchor, constant: -0),
            lineBackgroundView7.heightAnchor.constraint(equalToConstant: 1),
            lineBackgroundView7.leadingAnchor.constraint(equalTo: outerBackgroundView.leadingAnchor, constant: 0),
            lineBackgroundView7.trailingAnchor.constraint(equalTo: outerBackgroundView.trailingAnchor, constant: -0),
            feeLineBackgroundView.heightAnchor.constraint(equalToConstant: 1),
            feeLineBackgroundView.leadingAnchor.constraint(equalTo: outerBackgroundView.leadingAnchor, constant: 0),
            feeLineBackgroundView.trailingAnchor.constraint(equalTo: outerBackgroundView.trailingAnchor, constant: -0),
            recipientAddresscopyButton.widthAnchor.constraint(equalToConstant: 16),
            recipientAddresscopyButton.heightAnchor.constraint(equalToConstant: 16),
            recipientAddressDetailsTitleLabel.leadingAnchor.constraint(equalTo: outerBackgroundView.leadingAnchor, constant: 0),
            recipientAddressDetailsTitleLabel.trailingAnchor.constraint(equalTo: outerBackgroundView.trailingAnchor, constant: -0),
            mainStackView.leadingAnchor.constraint(equalTo: outerBackgroundView.leadingAnchor, constant: 0),
            mainStackView.trailingAnchor.constraint(equalTo: outerBackgroundView.trailingAnchor, constant: -0),
            mainStackView.topAnchor.constraint(equalTo: outerBackgroundView.topAnchor, constant: 10),
            mainStackView.bottomAnchor.constraint(equalTo: outerBackgroundView.bottomAnchor, constant: -10),
        ])
        
        NSLayoutConstraint.activate([
            backgroundBlerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            backgroundBlerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            backgroundBlerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            backgroundBlerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0),
            selectDateRangePopUpbackgroundView.leadingAnchor.constraint(equalTo: backgroundBlerView.leadingAnchor, constant: 22),
            selectDateRangePopUpbackgroundView.trailingAnchor.constraint(equalTo: backgroundBlerView.trailingAnchor, constant: -22),
            selectDateRangePopUpbackgroundView.centerYAnchor.constraint(equalTo: backgroundBlerView.centerYAnchor),
            selectDateRangePopUpbackgroundView.centerXAnchor.constraint(equalTo: backgroundBlerView.centerXAnchor),
            selectDateRangeTitleLabel.topAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.topAnchor, constant: 20),
            selectDateRangeTitleLabel.centerXAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.centerXAnchor),
            fromDateTextField.topAnchor.constraint(equalTo: selectDateRangeTitleLabel.bottomAnchor, constant: 20),
            fromDateTextField.heightAnchor.constraint(equalToConstant: 54),
            fromDateTextField.leadingAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.leadingAnchor, constant: 21),
            fromDateTextField.trailingAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.trailingAnchor, constant: -21),
            toDateTextField.topAnchor.constraint(equalTo: fromDateTextField.bottomAnchor, constant: 10),
            toDateTextField.heightAnchor.constraint(equalToConstant: 54),
            toDateTextField.leadingAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.leadingAnchor, constant: 21),
            toDateTextField.trailingAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.trailingAnchor, constant: -21),
            buttonStackView.topAnchor.constraint(equalTo: toDateTextField.bottomAnchor, constant: 16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),
            buttonStackView.leadingAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.leadingAnchor, constant: 21),
            buttonStackView.trailingAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.trailingAnchor, constant: -21),
            buttonStackView.bottomAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.bottomAnchor, constant: -25),
        ])
        
        //from date and to date implemenation
        fromDateTextField.delegate = self
        toDateTextField.delegate = self
        isFromAllTransationFlag = true
        isFromSendTransationFlag = false
        isFromReceiveTransationFlag = false
        self.incomingButton.isSelected = true
        self.outgoingButton.isSelected = true
        let logoImage = "ic_checked_green"
        incomingButton.setImage(UIImage(named: logoImage)?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        outgoingButton.setImage(UIImage(named: logoImage)?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        UserDefaults.standard.setValue(nil, forKey: "btnclicked")
        
        scanButton.isUserInteractionEnabled = false
        sendButton.isUserInteractionEnabled = false
        sendButton.backgroundColor = Colors.walletDisableButtonColor
        scanButton.backgroundColor = Colors.walletDisableButtonColor
        let reConnectButtonImage = isLightMode ? "ic_rotate_dark" : "ic_rotate_new"
        let reConnectButtonImageWithTint = UIImage(named: reConnectButtonImage)?.scaled(to: CGSize(width: 25, height: 25)).withTint(Colors.bothGrayColor)
        reConnectButton.setImage(reConnectButtonImageWithTint, for: .normal)
        let scanButtonImage = UIImage(named: "ic_Newqr")?.scaled(to: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysTemplate).withTint(Colors.bothGrayColor)
        scanButton.setImage(scanButtonImage, for: .normal)
        let sendButtonImage = UIImage(named: "ic_send_new")?.withTint(Colors.bothGrayColor)
        sendButton.setImage(sendButtonImage, for: .normal)
        // MARK: - Here Conditions based on hidden the view only
        walletSyncingBackgroundView.isHidden = false
        noTransactionsYetBackgroundView.isHidden = true
        filterTransactionsHistoryBackgroundView.isHidden = true
        transactionsDetailsBackgroundView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(syncWalletData(_:)), name: Notification.Name(rawValue: "syncWallet"), object: nil)
        if BackAPI == true {
            self.SelectedBalance = SaveUserDefaultsData.SelectedBalance
            self.fetchMarketsData(false)
        }
        
        if globalDynamicNodeArray.count == 0 {
            globalDynamicNodeArray = self.nodeArray
        }
        // randomElement node And Selected Node
        if !SaveUserDefaultsData.SelectedNode.isEmpty {
            if globalDynamicNodeArray.contains(SaveUserDefaultsData.SelectedNode) {
                self.randomNodeValue = SaveUserDefaultsData.SelectedNode
            } else {
                self.randomNodeValue = globalDynamicNodeArray.randomElement()!
                SaveUserDefaultsData.SelectedNode = self.randomNodeValue
            }
        } else {
            randomNodeValue = globalDynamicNodeArray.randomElement()!
            SaveUserDefaultsData.SelectedNode = self.randomNodeValue
        }
        SaveUserDefaultsData.FinalWallet_node = randomNodeValue
        
        //Save Receipent Address fun developed
        if UserDefaults.standard.domainSchemas.isEmpty { } else {
            hashArray = UserDefaults.standard.domainSchemas
        }
        
        self.fromDateTextField.datePicker(target: self,
                                          doneAction: #selector(fromdoneAction),
                                          cancelAction: #selector(fromcancelAction),
                                          datePickerMode: .date)
        self.toDateTextField.datePicker(target: self,
                                        doneAction: #selector(todoneAction),
                                        cancelAction: #selector(tocancelAction),
                                        datePickerMode: .date)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reScaneButtonTapped(_:)), name: .reScaneButtonActionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reconnectButtonTapped(_:)), name: .reconnectButtonActionNotification, object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        filterImageButton.layer.cornerRadius = filterImageButton.frame.height/2
        cancelButton.layer.cornerRadius = cancelButton.frame.height/2
        okButton.layer.cornerRadius = okButton.frame.height/2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        WalletSync.isInsideWallet = true
        UIApplication.shared.isIdleTimerDisabled = false
        self.fromcancelAction()
        self.tocancelAction()
        fromDateTextField.placeholder = "From Date"
        toDateTextField.placeholder = "To Date"
        fromDateTextField.text = ""
        toDateTextField.text = ""
        fromDate = ""
        toDate = ""
        self.backApiRescanVC = false
        
        isFromAllTransationFlag = true
        isFromSendTransationFlag = false
        isFromReceiveTransationFlag = false
        self.incomingButton.isSelected = true
        self.outgoingButton.isSelected = true
        let logoImage = "ic_checked_green"
        incomingButton.setImage(UIImage(named: logoImage), for: .normal)
        outgoingButton.setImage(UIImage(named: logoImage), for: .normal)
        UserDefaults.standard.setValue(nil, forKey: "btnclicked")
        
        self.noTransaction = false
        self.isFilter = false
        if let datePickerView = self.toDateTextField.inputView as? UIDatePicker {
            datePickerView.minimumDate = nil
        }
        filteredAllTransactionSortingArray = []
        filteredOutgoingTransactionSortingArray = []
        filteredIncomingTransactionSortingArray = []
        
        walletSyncingBackgroundView.isHidden = false
        noTransactionsYetBackgroundView.isHidden = true
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        UIApplication.shared.isIdleTimerDisabled = true
        let logoImage = "ic_checked_green"
        incomingButton.setImage(UIImage(named: logoImage)?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        outgoingButton.setImage(UIImage(named: logoImage)?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        
        if !WalletSync.isInsideWallet {
            scanButton.isUserInteractionEnabled = false
            sendButton.isUserInteractionEnabled = false
            scanButton.backgroundColor = Colors.walletDisableButtonColor
            sendButton.backgroundColor = Colors.walletDisableButtonColor
            let sendButtonImage = UIImage(named: "ic_send_new")?.withTint(Colors.bothGrayColor)
            sendButton.setImage(sendButtonImage, for: .normal)
            let scanButtonImage = UIImage(named: "ic_Newqr")?.scaled(to: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysTemplate).withTint(Colors.bothGrayColor)
            scanButton.setImage(scanButtonImage, for: .normal)
            let reConnectButtonImage = isLightMode ? "ic_rotate_dark" : "ic_rotate_new"
            let reConnectButtonImageWithTint = UIImage(named: reConnectButtonImage)?.scaled(to: CGSize(width: 25, height: 25)).withTint(Colors.bothGrayColor)
            reConnectButton.setImage(reConnectButtonImageWithTint, for: .normal)
            beldexBalanceLabel.text = "-.---"
            isCurrencyResultLabel.text = "0.00 USD"
            self.syncedflag = false
            conncetingState.value = true
            walletSyncingBackgroundView.isHidden = false
            noTransactionsYetBackgroundView.isHidden = true
            progressStatusLabel.textColor = Colors.aboutContentLabelColor
            progressStatusLabel.text = "Loading Wallet ..."
            if WalletSharedData.sharedInstance.wallet != nil {
                self.wallet = WalletSharedData.sharedInstance.wallet
                isSyncingUI = true
                syncingIsFromDelegateMethod = false
                connect(wallet: WalletSharedData.sharedInstance.wallet!)
            } else {
                init_syncing_wallet()
            }
        }
        
        if BackAPI == true {
            self.closeWallet()
            init_syncing_wallet()
            self.SelectedBalance = SaveUserDefaultsData.SelectedBalance
            self.fetchMarketsData(false)
        }
        if UserDefaults.standard.domainSchemas.isEmpty {} else {
            hashArray = UserDefaults.standard.domainSchemas
        }
        //Dynamic node array
        getDynamicNodesFromAPI()
        
        myGroup.notify(queue: .main) {
            print("Finished all requests.")
            // randomElement node And Selected Node
            if !SaveUserDefaultsData.SelectedNode.isEmpty, let nodeArray = self.nodeArrayDynamic {
                if nodeArray.contains(SaveUserDefaultsData.SelectedNode) {
                    self.randomNodeValue = SaveUserDefaultsData.SelectedNode
                } else {
                    self.randomNodeValue = self.nodeArrayDynamic!.randomElement()!
                    SaveUserDefaultsData.SelectedNode = self.randomNodeValue
                }
            } else {
                if let nodeArray = self.nodeArrayDynamic {
                    self.randomNodeValue = nodeArray.randomElement()!
                }
                SaveUserDefaultsData.SelectedNode = self.randomNodeValue
            }
            SaveUserDefaultsData.FinalWallet_node = self.randomNodeValue
        }
        
        // Selected Currency Code Implement
        if backAPISelectedCurrency == true {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency.uppercased()
            if mainBalance.isEmpty {
                isCurrencyResultLabel.text = "0.00 \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
            } else {
                isCurrencyResultLabel.text = "\(String(format:"%.2f", Double(mainBalance)! * currencyValue)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
            }
        } else {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency.uppercased()
            if mainBalance.isEmpty {
                let fullblnce = "0.00"
                var str = "\(String(format:"%.2f", fullblnce)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                let cs = CharacterSet.init(charactersIn: "-")
                str = str.trimmingCharacters(in: cs)
                isCurrencyResultLabel.text = "\(str)"
            } else {
                if currencyValue != nil {
                    isCurrencyResultLabel.text = "\(String(format:"%.2f", Double(mainBalance)! * currencyValue)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                }
            }
        }
        // Rescan Height Update in userdefaults work
        if backApiRescanVC == true {
            scanButton.isUserInteractionEnabled = false
            sendButton.isUserInteractionEnabled = false
            scanButton.backgroundColor = Colors.walletDisableButtonColor
            sendButton.backgroundColor = Colors.walletDisableButtonColor
            let sendButtonImage = UIImage(named: "ic_send_new")?.withTint(Colors.bothGrayColor)
            sendButton.setImage(sendButtonImage, for: .normal)
            let reConnectButtonImage = isLightMode ? "ic_rotate_dark" : "ic_rotate_new"
            let reConnectButtonImageWithTint = UIImage(named: reConnectButtonImage)?.scaled(to: CGSize(width: 25, height: 25)).withTint(Colors.bothGrayColor)
            reConnectButton.setImage(reConnectButtonImageWithTint, for: .normal)
            let scanButtonImage = UIImage(named: "ic_Newqr")?.scaled(to: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysTemplate).withTint(Colors.bothGrayColor)
            scanButton.setImage(scanButtonImage, for: .normal)
        }
        filteredAllTransactionSortingArray = []
        filteredOutgoingTransactionSortingArray = []
        filteredIncomingTransactionSortingArray = []
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if SaveUserDefaultsData.SwitchNode == true {
            SaveUserDefaultsData.SwitchNode = false
            self.closeWallet()
            init_syncing_wallet()
            DispatchQueue.main.async {
                let vc = SwitchingNodeVC()
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func getDynamicNodesFromAPI() {
        let url = globalDynamicNodeUrl
        // Create a custom URLRequest with cache policy
        var request = URLRequest(url: URL(string: url)!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        myGroup.enter()
        AF.request(request).responseDecodable(of: [NodeResponceModel].self) { response in
            switch response.result {
            case .success(let nodes):
                let uriArray = nodes.map { $0.uri }
                // Use the 'uriArray' here
                print(uriArray)
                self.nodeArrayDynamic = uriArray
                globalDynamicNodeArray = uriArray
                self.myGroup.leave()
            case .failure(let error):
                print("Error fetching data: \(error)")
                self.nodeArrayDynamic = self.nodeArray
                globalDynamicNodeArray = self.nodeArray
                self.myGroup.leave()
            }
        }
    }
    
    // Settings Option
    @objc func settingsOptionTapped() {
        let vc = WalletSettingsNewVC()
        navigationController!.pushViewController(vc, animated: true)
    }
    
    //Save Receipent Address fun developed
    func start(hashid:String,array:[RecipientDomainSchema])->(boolvalue:Bool,address:String) {
        var boolvalue:Bool = false
        var address:String = ""
        for ar in array {
            let hasid = ar.localhash
            if hashid == hasid {
                boolvalue = true
                address = ar.localaddress
                return (boolvalue,address)
            } else {
                boolvalue = false
            }
        }
        return (boolvalue,address)
    }
    
    //syncWalletData
    @objc func syncWalletData(_ notification: Notification) {
        WalletSync.isInsideWallet = true
        self.closeWallet()
        init_syncing_wallet()
    }
    
    // MARK: - Wallet
    //MARK:- Wallet func Connect Deamon
    func init_syncing_wallet() {
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            scanButton.isUserInteractionEnabled = false
            scanButton.backgroundColor = Colors.walletDisableButtonColor
            let scanButtonImage = UIImage(named: "ic_Newqr")?.scaled(to: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysTemplate).withTint(Colors.bothGrayColor)
            scanButton.setImage(scanButtonImage, for: .normal)
            sendButton.isUserInteractionEnabled = false
            sendButton.backgroundColor = Colors.walletDisableButtonColor
            let sendButtonImage = UIImage(named: "ic_send_new")?.withTint(Colors.bothGrayColor)
            sendButton.setImage(sendButtonImage, for: .normal)
            let reConnectButtonImage = isLightMode ? "ic_rotate_dark" : "ic_rotate_new"
            let reConnectButtonImageWithTint = UIImage(named: reConnectButtonImage)?.scaled(to: CGSize(width: 25, height: 25)).withTint(Colors.bothGrayColor)
            reConnectButton.setImage(reConnectButtonImageWithTint, for: .normal)
            beldexBalanceLabel.text = "-.---"
            isCurrencyResultLabel.text = "0.00 USD"
            self.syncedflag = false
            conncetingState.value = true
            walletSyncingBackgroundView.isHidden = false
            noTransactionsYetBackgroundView.isHidden = true
            progressStatusLabel.textColor = Colors.aboutContentLabelColor
            progressStatusLabel.text = "Loading Wallet ..."
            let username = SaveUserDefaultsData.NameForWallet
            let pwd = SaveUserDefaultsData.israndomUUIDPassword
            WalletService.shared.openWallet(username, password: pwd) { [weak self] (result) in
                DispatchQueue.main.async {
                    self?.scanButton.isUserInteractionEnabled = false
                    self?.sendButton.isUserInteractionEnabled = false
                    self?.sendButton.backgroundColor = Colors.walletDisableButtonColor
                    self?.scanButton.backgroundColor = Colors.walletDisableButtonColor
                    let scanButtonImage = UIImage(named: "ic_Newqr")?.scaled(to: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysTemplate).withTint(Colors.bothGrayColor)
                    self?.scanButton.setImage(scanButtonImage, for: .normal)
                    let sendButtonImage = UIImage(named: "ic_send_new")?.withTint(Colors.bothGrayColor)
                    self?.sendButton.setImage(sendButtonImage, for: .normal)
                    let reConnectButtonImage = isLightMode ? "ic_rotate_dark" : "ic_rotate_new"
                    let reConnectButtonImageWithTint = UIImage(named: reConnectButtonImage)?.scaled(to: CGSize(width: 25, height: 25)).withTint(Colors.bothGrayColor)
                    self?.reConnectButton.setImage(reConnectButtonImageWithTint, for: .normal)
                }
                guard let strongSelf = self else { return }
                switch result {
                case .success(let wallet):
                    strongSelf.wallet = wallet
                    WalletSharedData.sharedInstance.wallet = wallet
                    strongSelf.connect(wallet: wallet)
                case .failure(_):
                    WalletSharedData.sharedInstance.wallet = nil
                    DispatchQueue.main.async {
                        strongSelf.refreshState.value = true
                        strongSelf.conncetingState.value = false
                        strongSelf.progressStatusLabel.textColor = .red
                        strongSelf.progressStatusLabel.text = "Failed to Connect"
                        self!.syncedflag = false
                        self!.walletSyncingBackgroundView.isHidden = false
                        self!.noTransactionsYetBackgroundView.isHidden = true
                    }
                }
            }
        } else {
            self.showToast(message: "Please check your internet connection", seconds: 1.0)
        }
    }
    
    func connect(wallet: BDXWallet) {
        SaveUserDefaultsData.FinalWallet_node = Features.isTestNet ? nodeArray.randomElement() ?? "" : SaveUserDefaultsData.FinalWallet_node
        if !connecting {
            self.syncedflag = false
            self.conncetingState.value = true
            DispatchQueue.main.async {
                self.walletSyncingBackgroundView.isHidden = false
                self.noTransactionsYetBackgroundView.isHidden = true
                self.progressStatusLabel.textColor = Colors.aboutContentLabelColor
            }
        }
        wallet.connectToDaemon(address: SaveUserDefaultsData.FinalWallet_node, delegate: self) { [weak self] (isConnected) in
            guard let `self` = self else { return }
            if isConnected {
                if let wallet = self.wallet {
                    if SaveUserDefaultsData.WalletRestoreHeight == "" {
                        let lastElementHeight = DateHeight.getBlockHeight.last
                        let height = lastElementHeight!.components(separatedBy: ":")
                        SaveUserDefaultsData.WalletRestoreHeight = "\(height[1])"
                        wallet.restoreHeight = UInt64(SaveUserDefaultsData.WalletRestoreHeight)!
                    } else {
                        wallet.restoreHeight = UInt64(SaveUserDefaultsData.WalletRestoreHeight)!
                    }
                    if self.backApiRescanVC == true {
                        wallet.rescanBlockchainAsync()
                    }
                    wallet.start()
                }
                self.listening = true
            } else {
                DispatchQueue.main.async {
                    self.refreshState.value = true
                    self.conncetingState.value = false
                    self.listening = false
                    self.walletSyncingBackgroundView.isHidden = false
                    self.noTransactionsYetBackgroundView.isHidden = true
                    self.progressStatusLabel.textColor = .red
                    self.progressStatusLabel.text = "Failed to Connect"
                }
            }
        }
    }
    
    private func updateSyncingProgress() {
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            if syncingIsFromDelegateMethod {
                if self.wallet?.synchronized == false {
                    taskQueue.async {
                        let (current, total) = (self.currentBlockChainHeight, self.daemonBlockChainHeight)
                        guard total != current else { return }
                        let difference = total.subtractingReportingOverflow(current)
                        var progress = CGFloat(current) / CGFloat(total)
                        let leftBlocks: String
                        if difference.overflow || difference.partialValue <= 1 {
                            leftBlocks = "1"
                            progress = 1
                        } else {
                            leftBlocks = String(difference.partialValue)
                        }
                        let largeNumber = Int(leftBlocks)
                        let numberFormatter = NumberFormatter()
                        numberFormatter.numberStyle = .decimal
                        numberFormatter.groupingSize = 3
                        numberFormatter.secondaryGroupingSize = 2
                        let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber ?? 1))
                        let statusText = "\(formattedNumber!)" + " Blocks Remaining"
                        DispatchQueue.main.async {
                            if self.conncetingState.value {
                                self.conncetingState.value = false
                            }
                            self.walletSyncingBackgroundView.isHidden = false
                            self.noTransactionsYetBackgroundView.isHidden = true
                            self.syncedflag = false
                            self.progressView.progress = Float(progress)
                            self.sliderView.value = Float(progress)
                            self.progressStatusLabel.textColor = Colors.aboutContentLabelColor
                            self.progressStatusLabel.text = statusText
                        }
                    }
                }
            } else {
                taskQueue.async {
                    let (current, total) = (WalletSharedData.sharedInstance.wallet?.blockChainHeight, WalletSharedData.sharedInstance.wallet?.daemonBlockChainHeight)
                    guard total != current else { return }
                    let difference = total!.subtractingReportingOverflow(current!)
                    var progress = CGFloat(current!) / CGFloat(total!)
                    let leftBlocks: String
                    if difference.overflow || difference.partialValue <= 1 {
                        leftBlocks = "1"
                        progress = 1
                    } else {
                        leftBlocks = String(difference.partialValue)
                    }
                    
                    if difference.overflow || difference.partialValue <= 1500 {
                        self.timer.invalidate()
                    }
                    
                    let largeNumber = Int(leftBlocks)
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    numberFormatter.groupingSize = 3
                    numberFormatter.secondaryGroupingSize = 2
                    let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber ?? 1))
                    let statusText = "\(formattedNumber!)" + " Blocks Remaining"
                    DispatchQueue.main.async {
                        if self.conncetingState.value {
                            self.conncetingState.value = false
                        }
                        self.walletSyncingBackgroundView.isHidden = false
                        self.noTransactionsYetBackgroundView.isHidden = true
                        self.syncedflag = false
                        self.progressView.progress = Float(progress)
                        self.sliderView.value = Float(progress)
                        self.progressStatusLabel.textColor = Colors.aboutContentLabelColor
                        self.progressStatusLabel.text = statusText
                    }
                }
            }
        } else {
            self.progressStatusLabel.textColor = .red
            self.progressStatusLabel.text = "Check your internet"
        }
    }
    
    // MARK: - Close Wallet Func
    private func closeWallet() {
        guard let wallet = self.wallet else {
            return
        }
        self.wallet = nil
        if listening {
            listening = false
            wallet.pasue()
        }
        wallet.close()
    }
    deinit {
        isSyncingUI = false
    }
    
    private func synchronizedUI() {
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            progressView.progress = 1
            self.sliderView.value = 1
            syncedflag = true
            scanButton.isUserInteractionEnabled = true
            sendButton.isUserInteractionEnabled = true
            sendButton.backgroundColor = Colors.enableSendButtonColor
            scanButton.backgroundColor = Colors.messageRequestBackgroundColor
            let sendButtonImage = UIImage(named: "ic_send_new")
            sendButton.setImage(sendButtonImage, for: .normal)
            let scanButtonImage = UIImage(named: "ic_Newqr")?.scaled(to: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysTemplate)
            scanButton.setImage(scanButtonImage, for: .normal)
            let reConnectButtonImage = isLightMode ? "ic_rotate_dark" : "ic_rotate_new"
            let reConnectButtonImageWithTint = UIImage(named: reConnectButtonImage)?.scaled(to: CGSize(width: 25, height: 25))
            reConnectButton.setImage(reConnectButtonImageWithTint, for: .normal)
            self.progressStatusLabel.textColor = Colors.aboutContentLabelColor
            if self.backApiRescanVC == true {
                self.progressStatusLabel.text = "Connecting..."
                walletSyncingBackgroundView.isHidden = false
                noTransactionsYetBackgroundView.isHidden = true
            } else {
                self.progressStatusLabel.text = "Synchronized"
                progressStatusLabel.textColor = Colors.bothGreenColor
                beldexLogoImg.image = UIImage(named: "ic_beldex_green")
                walletSyncingBackgroundView.isHidden = true
                if self.transactionAllArray.count == 0 {
                    noTransactionsYetBackgroundView.isHidden = false
                    filterTransactionsHistoryBackgroundView.isHidden = true
                } else {
                    noTransactionsYetBackgroundView.isHidden = true
                    filterTransactionsHistoryBackgroundView.isHidden = false
                }
            }
            self.tableView.reloadData()
        } else {
            self.progressStatusLabel.textColor = .red
            self.progressStatusLabel.text = "Check your internet"
        }
    }
    
    //MARK:- Balance currency conversion
    private func reloadData(_ json: [String: [String: Any]]) {
        let xmrAmount = json["beldex"]?[currencyName] as? Double
        if xmrAmount != nil {
            currencyValue = xmrAmount
            //MARK:- Balance currency conversion
            if mainBalance.isEmpty {
                self.beldexBalanceLabel.text = "0.00"
            } else {
                if !SaveUserDefaultsData.SelectedDecimal.isEmpty {
                    selectedDecimal = SaveUserDefaultsData.SelectedDecimal
                    if selectedDecimal == "4 - Four (0.0000)" {
                        self.beldexBalanceLabel.text = String(format:"%.4f", Double(mainBalance)!)
                    } else if selectedDecimal == "3 - Three (0.000)" {
                        self.beldexBalanceLabel.text = String(format:"%.3f", Double(mainBalance)!)
                    } else if selectedDecimal == "2 - Two (0.00)" {
                        self.beldexBalanceLabel.text = String(format:"%.2f", Double(mainBalance)!)
                    } else if selectedDecimal == "0 - Zero (0)" {
                        self.beldexBalanceLabel.text = String(format:"%.0f", Double(mainBalance)!)
                    }
                    self.currencyName = SaveUserDefaultsData.SelectedCurrency
                    self.fetchMarketsData(false)
                    self.reloadData([:])
                    if mainBalance.isEmpty {
                        isCurrencyResultLabel.text = "\(String(format:"%.2f", "0.00")) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                    } else {
                        if currencyValue != nil {
                            isCurrencyResultLabel.text = "\(String(format:"%.2f", Double(mainBalance)! * currencyValue)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                        }
                    }
                } else {
                    isCurrencyResultLabel.text = "\(String(format:"%.2f", Double(mainBalance)! * currencyValue)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                }
            }
        }
    }
    
    private func fetchMarketsData(_ showHUD: Bool = false) {
        if let req = marketsDataRequest {
            req.cancel()
        }
        if showHUD { loadingState.newState(true) }
        let startTime = CFAbsoluteTimeGetCurrent()
        let Url = "https://api.coingecko.com/api/v3/simple/price?ids=beldex&vs_currencies=\(currencyName)"
        let request = Session.default.request("\(Url)")
        request.responseJSON(queue: .main, options: .mutableLeaves) { [weak self] (resp) in
            guard let SELF = self else { return }
            SELF.marketsDataRequest = nil
            if showHUD { SELF.loadingState.newState(false) }
            switch resp.result {
            case .failure(_): break
                //   HUD.showError(error.localizedDescription)
            case .success(let value):
                SELF.reloadData(value as? [String: [String: Any]] ?? [:])
            }
            let endTime = CFAbsoluteTimeGetCurrent()
            let requestDuration = endTime - startTime
            if requestDuration >= SELF.refreshDuration {
                SELF.fetchMarketsData()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + SELF.refreshDuration - requestDuration) {
                    guard let SELF = self else { return }
                    SELF.fetchMarketsData()
                }
            }
        }
        marketsDataRequest = request
    }
    
    // from date implemenation
    @objc
    func fromcancelAction() {
        self.fromDateTextField.resignFirstResponder()
    }
    
    @objc
    func fromdoneAction() {
        if let datePickerView = self.fromDateTextField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d/MM/yyyy"
            let dateString = dateFormatter.string(from: datePickerView.date)
            self.fromDateTextField.text = dateString
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "dd-MM-yyyy"
            let dateString2 = formatter2.string(from: datePickerView.date)
            fromDate = dateString2
            
            if let datePickerView = self.toDateTextField.inputView as? UIDatePicker {
                let dateFormatter3 = DateFormatter()
                dateFormatter3.dateFormat = "dd-MM-yyyy"
                let date = dateFormatter3.date(from:fromDate)!
                datePickerView.minimumDate = date
            }
            self.fromDateTextField.resignFirstResponder()
        }
    }
    
    // To date implemenation
    @objc
    func tocancelAction() {
        self.toDateTextField.resignFirstResponder()
    }
    
    @objc
    func todoneAction() {
        if let datePickerView = self.toDateTextField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d/MM/yyyy"
            let dateString = dateFormatter.string(from: datePickerView.date)
            self.toDateTextField.text = dateString
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "dd-MM-yyyy"
            let dateString2 = formatter2.string(from: datePickerView.date)
            toDate = dateString2
            self.toDateTextField.resignFirstResponder()
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.isUserInteractionEnabled = false
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isUserInteractionEnabled = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.view.hitTest(firstTouch.location(in: self.view), with: event)
            if hitView === self.backgroundBlerView {
                self.backgroundBlerView.isHidden = true
            }
        }
    }
    
    @objc func filterImageButtonTapped(_ sender: UIButton) {
        if self.transactionAllArray.count == 0 {
            filterImageButton.isUserInteractionEnabled = true
        } else {
            self.noTransaction = false
            self.isFilter = false
            filteredAllTransactionSortingArray = []
            filteredOutgoingTransactionSortingArray = []
            filteredIncomingTransactionSortingArray = []
            fromDate = ""
            toDate = ""
            if let datePickerView = self.toDateTextField.inputView as? UIDatePicker {
                datePickerView.minimumDate = nil
            }
            filterImageButton.isSelected = !filterImageButton.isSelected
            if filterImageButton.isSelected {
                filterStackView.isHidden = false
                lineBackgroundView.isHidden = false
                filterImageButton.backgroundColor = Colors.titleColor
                let logoImage2 = isLightMode ? "ic_filter_white" : "ic_filter_black"
                filterImageButton.setImage(UIImage(named: logoImage2), for: .normal)
            } else {
                filterStackView.isHidden = true
                lineBackgroundView.isHidden = true
                filterImageButton.backgroundColor = .clear
                filterImageButton.setImage(UIImage(named: "ic_Filter_New"), for: .normal)
            }
        }
    }
    
    @objc func scanButtonTapped(_ sender: UIButton) {
        let vc = ScanNewVC()
        vc.isFromWallet = true
        vc.wallet = self.wallet
        vc.mainBalanceForScan = beldexBalanceLabel.text!
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func transationIDcopyButtonTapped(_ sender: UIButton) {
        UIPasteboard.general.string = "\(transationDetailsIDLabel.text!)"
        self.showToast(message: "Copied to Transaction ID", seconds: 1.0)
    }
    
    @objc func sendButtonTapped(_ sender: UIButton) {
        let vc = WalletSendNewVC()
        vc.mainBalance = beldexBalanceLabel.text!
        vc.wallet = self.wallet
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func receiveButtonTapped(_ sender: UIButton) {
        let vc = WalletReceiveNewVC()
        navigationController!.pushViewController(vc, animated: true)
    }
    // Rescan and Reconnect popup
    @objc func reConnectButtonTapped(_ sender: UIButton) {
        let vc = SyncingOptionPopUpVC()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.isPresented = true // Set the flag to true
        self.present(vc, animated: true, completion: nil)
    }
    //Rescan
    @objc func reScaneButtonTapped(_ notification: Notification) {
        self.dismiss(animated: true)
        if syncedflag == true {
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            let vc = RescanNewVC()
            vc.daemonBlockChainHeight = UInt64(isdaemonHeight)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showToast(message: "Can't rescan while wallet is syncing", seconds: 1.0)
        }
    }
    //Reconnect
    @objc func reconnectButtonTapped(_ notification: Notification) {
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.closeWallet()
        init_syncing_wallet()
    }
    
    @objc func recipientAddresscopyButtonTapped(_ sender: UIButton) {
        UIPasteboard.general.string = "\(recipientAddressDetailsIDLabel.text!)"
        self.showToast(message: "Copied to Recipient Address", seconds: 1.0)
    }
    
    //Explorer after clicking the transaction ID
    @objc func transationDetailsIDLabelTapped() {
        let trID = transationDetailsIDLabel.text
        if let url = URL(string: "https://explorer.beldex.io/tx/\(trID!)") {
            UIApplication.shared.open(url)
        }
    }
    
    //By Date Filter Cancel action
    @objc func cancelButtonTapped(_ sender: UIButton) {
        backgroundBlerView.isHidden = true
        selectDateRangePopUpbackgroundView.isHidden = true
        
        self.fromcancelAction()
        self.tocancelAction()
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        fromDateTextField.placeholder = "From Date"
        toDateTextField.placeholder = "To Date"
        fromDateTextField.text = ""
        toDateTextField.text = ""
        filteredAllTransactionSortingArray = []
        filteredOutgoingTransactionSortingArray = []
        filteredIncomingTransactionSortingArray = []
        self.isFilter = false
        fromDate = ""
        toDate = ""
        if let datePickerView = self.toDateTextField.inputView as? UIDatePicker {
            datePickerView.minimumDate = nil
        }
        tableView.reloadData()
    }
    //By Date Filter Ok action
    @objc func okButtonTapped(_ sender: UIButton) {
        backgroundBlerView.isHidden = true
        selectDateRangePopUpbackgroundView.isHidden = true
        
        self.fromcancelAction()
        self.tocancelAction()
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        filteredAllTransactionSortingArray = []
        filteredOutgoingTransactionSortingArray = []
        filteredIncomingTransactionSortingArray = []
        if fromDate == "" || toDate == "" {
            self.isFilter = false
            let alert = UIAlertController(title: "", message: "Please select both From and To dates", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: { action in
                self.fromcancelAction()
                self.tocancelAction()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.isFilter = true
            if UserDefaults.standard.value(forKey: "btnclicked") != nil {
                if UserDefaults.standard.value(forKey: "btnclicked")as! String == "outgoing" { // outgoing filter
                    for element in transactionSendArray {
                        let timeInterval = element.timestamp
                        let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy"
                        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                        let listDate = dateFormatter.string(from: date as Date)
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd-MM-yyyy"
                        let fromDateArray = fromDate.components(separatedBy: "-")
                        let FromDate = fromDateArray[0]
                        let FromMonth = fromDateArray[1]
                        let FromYear = fromDateArray[2]
                        let ToDateArray = toDate.components(separatedBy: "-")
                        let ToDate = ToDateArray[0]
                        let ToMonth = ToDateArray[1]
                        let ToYear = ToDateArray[2]
                        let ListArray = listDate.components(separatedBy: "-")
                        let ListDate = ListArray[0]
                        let ListMonth = ListArray[1]
                        let ListYear = ListArray[2]
                        
                        let currentDateString = listDate
                        let startDateString = fromDate
                        let endDateString = toDate
                        let dateFormatter222 = DateFormatter()
                        dateFormatter222.dateFormat = "dd-MM-yyyy"
                        dateFormatter222.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                        let currentDate = dateFormatter222.date(from: currentDateString)!
                        let startDate = dateFormatter222.date(from: startDateString)!
                        let endDate = dateFormatter222.date(from: endDateString)!
                        let isCointain = currentDate.isBetween(date: startDate as NSDate, andDate: endDate as NSDate)
                        if isCointain {
                            filteredOutgoingTransactionarray.append(element)
                        }
                        
                        if ListYear >= FromYear && ListYear <= ToYear {
                            if ListMonth >= FromMonth && ListMonth <= ToMonth {
                                if ListDate >= FromDate && ListDate <= ToDate {
                                    
                                }
                            }
                        }
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    groupedItemsSend.removeAll()
                    for item in filteredOutgoingTransactionarray {
                        guard let date = dateFormatter.date(from: item.newtimestamp) else {
                            continue
                        }
                        let key = dateFormatter.string(from: date)
                        if groupedItemsSend[key] == nil {
                            groupedItemsSend[key] = [item]
                        } else {
                            groupedItemsSend[key]?.append(item)
                        }
                    }
                    // Sort grouped items by keys (dates) in descending order
                    filteredOutgoingTransactionSortingArray = groupedItemsSend.sorted(by: { dateFormatter.date(from: $0.key)! > dateFormatter.date(from: $1.key)! })
                    
                    self.tableView.reloadData()
                    let fromDateArray = fromDate.components(separatedBy: "-")
                    let FromDate = fromDateArray[0]
                    let FromMonth = fromDateArray[1]
                    let FromYear = fromDateArray[2]
                    let ToDateArray = toDate.components(separatedBy: "-")
                    let ToDate = ToDateArray[0]
                    let ToMonth = ToDateArray[1]
                    let ToYear = ToDateArray[2]
                    if ToYear <= FromYear {
                        if ToMonth <= FromMonth {
                            if ToDate < FromDate {
                                let alert = UIAlertController(title: "", message: "Invalid Date Range", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } else  if UserDefaults.standard.value(forKey: "btnclicked")as! String == "incoming" { // income filetr
                    for element in transactionReceiveArray {
                        let timeInterval = element.timestamp
                        let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy"
                        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                        let listDate = dateFormatter.string(from: date as Date)
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd-MM-yyyy"
                        let fromDateArray = fromDate.components(separatedBy: "-")
                        let FromDate = fromDateArray[0]
                        let FromMonth = fromDateArray[1]
                        let FromYear = fromDateArray[2]
                        let ToDateArray = toDate.components(separatedBy: "-")
                        let ToDate = ToDateArray[0]
                        let ToMonth = ToDateArray[1]
                        let ToYear = ToDateArray[2]
                        let ListArray = listDate.components(separatedBy: "-")
                        let ListDate = ListArray[0]
                        let ListMonth = ListArray[1]
                        let ListYear = ListArray[2]
                        
                        let currentDateString = listDate
                        let startDateString = fromDate
                        let endDateString = toDate
                        let dateFormatter222 = DateFormatter()
                        dateFormatter222.dateFormat = "dd-MM-yyyy"
                        dateFormatter222.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                        let currentDate = dateFormatter222.date(from: currentDateString)!
                        let startDate = dateFormatter222.date(from: startDateString)!
                        let endDate = dateFormatter222.date(from: endDateString)!
                        let isCointain = currentDate.isBetween(date: startDate as NSDate, andDate: endDate as NSDate)
                        if isCointain {
                            filteredIncomingTransactionarray.append(element)
                        }
                        
                        if ListYear >= FromYear && ListYear <= ToYear {
                            if ListMonth >= FromMonth && ListMonth <= ToMonth {
                                if ListDate >= FromDate && ListDate <= ToDate {
                                    
                                }
                            }
                        }
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    groupedItemsReceived.removeAll()
                    for item in filteredIncomingTransactionarray {
                        guard let date = dateFormatter.date(from: item.newtimestamp) else {
                            continue
                        }
                        let key = dateFormatter.string(from: date)
                        if groupedItemsReceived[key] == nil {
                            groupedItemsReceived[key] = [item]
                        } else {
                            groupedItemsReceived[key]?.append(item)
                        }
                    }
                    // Sort grouped items by keys (dates) in descending order
                    filteredIncomingTransactionSortingArray = groupedItemsReceived.sorted(by: { dateFormatter.date(from: $0.key)! > dateFormatter.date(from: $1.key)! })
                    
                    self.tableView.reloadData()
                    let fromDateArray = fromDate.components(separatedBy: "-")
                    let FromDate = fromDateArray[0]
                    let FromMonth = fromDateArray[1]
                    let FromYear = fromDateArray[2]
                    let ToDateArray = toDate.components(separatedBy: "-")
                    let ToDate = ToDateArray[0]
                    let ToMonth = ToDateArray[1]
                    let ToYear = ToDateArray[2]
                    if ToYear <= FromYear {
                        if ToMonth <= FromMonth {
                            if ToDate < FromDate {
                                let alert = UIAlertController(title: "", message: "Invalid Date Range", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    
                }
            } else { // all filter
                for element in transactionAllArray {
                    let timeInterval = element.timestamp
                    let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                    let listDate = dateFormatter.string(from: date as Date)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy"
                    let fromDateArray = fromDate.components(separatedBy: "-")
                    let FromDate = fromDateArray[0]
                    let FromMonth = fromDateArray[1]
                    let FromYear = fromDateArray[2]
                    let ToDateArray = toDate.components(separatedBy: "-")
                    let ToDate = ToDateArray[0]
                    let ToMonth = ToDateArray[1]
                    let ToYear = ToDateArray[2]
                    let ListArray = listDate.components(separatedBy: "-")
                    let ListDate = ListArray[0]
                    let ListMonth = ListArray[1]
                    let ListYear = ListArray[2]
                    
                    let currentDateString = listDate
                    let startDateString = fromDate
                    let endDateString = toDate
                    let dateFormatter222 = DateFormatter()
                    dateFormatter222.dateFormat = "dd-MM-yyyy"
                    dateFormatter222.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                    let currentDate = dateFormatter222.date(from: currentDateString)!
                    let startDate = dateFormatter222.date(from: startDateString)!
                    let endDate = dateFormatter222.date(from: endDateString)!
                    let isCointain = currentDate.isBetween(date: startDate as NSDate, andDate: endDate as NSDate)
                    if isCointain {
                        filteredAllTransactionarray.append(element)
                    }
                    
                    if ListYear >= FromYear && ListYear <= ToYear {
                        if ListMonth >= FromMonth && ListMonth <= ToMonth {
                            if ListDate >= FromDate && ListDate <= ToDate {
                                
                            }
                        }
                    }
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                groupedItemsAll.removeAll()
                for item in filteredAllTransactionarray {
                    guard let date = dateFormatter.date(from: item.newtimestamp) else {
                        continue
                    }
                    let key = dateFormatter.string(from: date)
                    if groupedItemsAll[key] == nil {
                        groupedItemsAll[key] = [item]
                    } else {
                        groupedItemsAll[key]?.append(item)
                    }
                }
                // Sort grouped items by keys (dates) in descending order
                filteredAllTransactionSortingArray = groupedItemsAll.sorted(by: { dateFormatter.date(from: $0.key)! > dateFormatter.date(from: $1.key)! })
                
                self.tableView.reloadData()
                let fromDateArray = fromDate.components(separatedBy: "-")
                let FromDate = fromDateArray[0]
                let FromMonth = fromDateArray[1]
                let FromYear = fromDateArray[2]
                let ToDateArray = toDate.components(separatedBy: "-")
                let ToDate = ToDateArray[0]
                let ToMonth = ToDateArray[1]
                let ToYear = ToDateArray[2]
                if ToYear <= FromYear {
                    if ToMonth <= FromMonth {
                        if ToDate < FromDate {
                            let alert = UIAlertController(title: "", message: "Invalid Date Range", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            fromDateTextField.placeholder = "From Date"
            toDateTextField.placeholder = "To Date"
            fromDateTextField.text = ""
            toDateTextField.text = ""
            showToast(message: "Filter applied", seconds: 1.0)
        }
        fromDate = ""
        toDate = ""
        if let datePickerView = self.toDateTextField.inputView as? UIDatePicker {
            datePickerView.minimumDate = nil
        }
        fromDateTextField.placeholder = "From Date"
        toDateTextField.placeholder = "To Date"
        fromDateTextField.text = ""
        toDateTextField.text = ""
        
    }
    
    @objc func backImageButtonTapped(_ sender: UIButton) {
        walletSyncingBackgroundView.isHidden = true
        noTransactionsYetBackgroundView.isHidden = true
        filterTransactionsHistoryBackgroundView.isHidden = false
        transactionsDetailsBackgroundView.isHidden = true
    }
    
    @objc func incomingButtonTapped(_ sender: UIButton) {
        incomingButton.isSelected = !incomingButton.isSelected
        self.filterTransaction()
    }
    
    @objc func outgoingButtonTapped(_ sender: UIButton) {
        outgoingButton.isSelected = !outgoingButton.isSelected
        self.filterTransaction()
    }
    
    func filterTransaction() {
        let logoImage = "ic_checked_green"
        let logoImageWhite = isLightMode ? "ic_uncheck_white_Theme" : "ic_uncheck"
        if self.incomingButton.isSelected {
            incomingButton.setImage(UIImage(named: logoImage)?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        } else {
            incomingButton.setImage(UIImage(named: logoImageWhite)?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        }
        
        if self.outgoingButton.isSelected {
            outgoingButton.setImage(UIImage(named: logoImage)?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        } else {
            outgoingButton.setImage(UIImage(named: logoImageWhite)?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        }
        
        self.noTransaction = false
        self.isFilter = false
        fromDate = ""
        toDate = ""
        if let datePickerView = self.toDateTextField.inputView as? UIDatePicker {
            datePickerView.minimumDate = nil
        }
        filteredAllTransactionSortingArray = []
        filteredOutgoingTransactionSortingArray = []
        filteredIncomingTransactionSortingArray = []
        
        //All
        if self.incomingButton.isSelected && self.outgoingButton.isSelected {
            isFromAllTransationFlag = true
            isFromSendTransationFlag = false
            isFromReceiveTransationFlag = false
            noTransactionsYetBackgroundView.isHidden = true
            UserDefaults.standard.setValue(nil, forKey: "btnclicked")
        }
        
        //outgoing
        if !self.incomingButton.isSelected && self.outgoingButton.isSelected {
            isFromAllTransationFlag = false
            isFromSendTransationFlag = true
            isFromReceiveTransationFlag = false
            noTransactionsYetBackgroundView.isHidden = true
            UserDefaults.standard.setValue("outgoing", forKey: "btnclicked")
        }
        
        //incoming
        if self.incomingButton.isSelected && !self.outgoingButton.isSelected {
            isFromAllTransationFlag = false
            isFromSendTransationFlag = false
            isFromReceiveTransationFlag = true
            noTransactionsYetBackgroundView.isHidden = true
            UserDefaults.standard.setValue("incoming", forKey: "btnclicked")
        }
        showToast(message: "Filter applied", seconds: 1.0)
        //no
        if !self.incomingButton.isSelected && !self.outgoingButton.isSelected {
            self.noTransaction = true
            noTransactionsYetBackgroundView.isHidden = false
        }
        self.tableView.reloadData()
    }
    
    @objc func byDateButtonTapped(_ sender: UIButton) {
        backgroundBlerView.isHidden = false
        selectDateRangePopUpbackgroundView.isHidden = false
        fromDate = ""
        toDate = ""
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.noTransaction {
            return 0
        } else {
            if isFromAllTransationFlag == true {
                if self.isFilter {
                    return filteredAllTransactionSortingArray.count
                }
                return sortedGroupedTransactionAllArray.count
            } else if isFromSendTransationFlag == true {
                if self.isFilter {
                    return filteredOutgoingTransactionSortingArray.count
                }
                return sortedGroupedTransactionSendArray.count
            } else {
                if self.isFilter {
                    return filteredIncomingTransactionSortingArray.count
                }
                return sortedGroupedTransactionReceiveArray.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.noTransaction {
            return 0
        }
        if isFromAllTransationFlag == true {
            if self.isFilter {
                if filteredAllTransactionSortingArray[section].value.count == 0 {
                    noTransactionsYetBackgroundView.isHidden = false
                    filterTransactionsHistoryBackgroundView.isHidden = true
                }
                return filteredAllTransactionSortingArray[section].value.count
            } else {
                if sortedGroupedTransactionAllArray[section].value.count == 0 {
                    noTransactionsYetBackgroundView.isHidden = false
                    filterTransactionsHistoryBackgroundView.isHidden = true
                }
                return sortedGroupedTransactionAllArray[section].value.count
            }
        } else if isFromSendTransationFlag == true {
            if self.isFilter {
                if filteredOutgoingTransactionSortingArray[section].value.count == 0 {
                    noTransactionsYetBackgroundView.isHidden = false
                    filterTransactionsHistoryBackgroundView.isHidden = true
                }
                return filteredOutgoingTransactionSortingArray[section].value.count
            } else {
                if sortedGroupedTransactionSendArray[section].value.count == 0 {
                    noTransactionsYetBackgroundView.isHidden = false
                    filterTransactionsHistoryBackgroundView.isHidden = true
                }
                return sortedGroupedTransactionSendArray[section].value.count
            }
        } else {
            if self.isFilter {
                if filteredIncomingTransactionSortingArray[section].value.count == 0 {
                    noTransactionsYetBackgroundView.isHidden = false
                    filterTransactionsHistoryBackgroundView.isHidden = true
                }
                return filteredIncomingTransactionSortingArray[section].value.count
            } else {
                if sortedGroupedTransactionReceiveArray[section].value.count == 0 {
                    noTransactionsYetBackgroundView.isHidden = false
                    filterTransactionsHistoryBackgroundView.isHidden = true
                }
                return sortedGroupedTransactionReceiveArray[section].value.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TransationHistoryTableCell(style: .default, reuseIdentifier: "TransationHistoryTableCell")
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        //Date formate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        dateFormatter.timeZone = NSTimeZone(name: "Asia/Kolkata") as TimeZone?
        
        if isFromAllTransationFlag == true {
            if filteredAllTransactionSortingArray.count > 0 {
                let responceData = filteredAllTransactionSortingArray[indexPath.section].value
                let valueResponce = responceData[indexPath.row]
                let timeInterval  = valueResponce.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                cell.dateLabel.text = dateString
                cell.balanceAmountLabel.text = Double(valueResponce.amount)!.removeZerosFromEnd()
                if valueResponce.direction != BChat_Messenger.TransactionDirection.received {
                    cell.sendandReceiveLabel.text = "Send"
                    let logoImage = isLightMode ? "ic_send_whitethem" : "ic_send_icon"
                    cell.directionLogoImage.image = UIImage(named: logoImage)
                    cell.balanceAmountLabel.textColor = Colors.bothRedColor
                } else {
                    cell.sendandReceiveLabel.text = "Received"
                    let logoImage = isLightMode ? "ic_receiver_whitethem" : "ic_receive"
                    cell.directionLogoImage.image = UIImage(named: logoImage)
                    cell.balanceAmountLabel.textColor = Colors.bothGreenColor
                }
            } else {
                let responceData = sortedGroupedTransactionAllArray[indexPath.section].value
                let valueResponce = responceData[indexPath.row]
                let timeInterval  = valueResponce.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MMM-yyyy"
                dateFormatter.timeZone = NSTimeZone(name: "Asia/Kolkata") as TimeZone?
                let dateString = dateFormatter.string(from: date as Date)
                cell.dateLabel.text = dateString
                cell.balanceAmountLabel.text = Double(valueResponce.amount)!.removeZerosFromEnd()
                if valueResponce.direction != BChat_Messenger.TransactionDirection.received {
                    cell.sendandReceiveLabel.text = "Send"
                    let logoImage = isLightMode ? "ic_send_whitethem" : "ic_send_icon"
                    cell.directionLogoImage.image = UIImage(named: logoImage)
                    cell.balanceAmountLabel.textColor = Colors.bothRedColor
                } else {
                    cell.sendandReceiveLabel.text = "Received"
                    let logoImage = isLightMode ? "ic_receiver_whitethem" : "ic_receive"
                    cell.directionLogoImage.image = UIImage(named: logoImage)
                    cell.balanceAmountLabel.textColor = Colors.bothGreenColor
                }
            }
        } else if isFromSendTransationFlag == true {
            if filteredOutgoingTransactionSortingArray.count > 0 {
                let responceData = filteredOutgoingTransactionSortingArray[indexPath.section].value
                let valueResponce = responceData[indexPath.row]
                let timeInterval  = valueResponce.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                cell.dateLabel.text = dateString
                cell.balanceAmountLabel.text = Double(valueResponce.amount)!.removeZerosFromEnd()
                let logoImage = isLightMode ? "ic_send_whitethem" : "ic_send_icon"
                if valueResponce.direction != BChat_Messenger.TransactionDirection.sent {
                    cell.sendandReceiveLabel.text = "Send"
                    cell.directionLogoImage.image = UIImage(named: logoImage)
                } else {
                    cell.sendandReceiveLabel.text = "Send"
                    cell.directionLogoImage.image = UIImage(named: logoImage)
                }
            } else {
                let responceData = sortedGroupedTransactionSendArray[indexPath.section].value
                let transaction = responceData[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                cell.dateLabel.text = dateString
                cell.balanceAmountLabel.text = Double(transaction.amount)!.removeZerosFromEnd()
                let logoImage = isLightMode ? "ic_send_whitethem" : "ic_send_icon"
                if transaction.direction != BChat_Messenger.TransactionDirection.sent {
                    cell.sendandReceiveLabel.text = "Send"
                    cell.directionLogoImage.image = UIImage(named: logoImage)
                } else {
                    cell.sendandReceiveLabel.text = "Send"
                    cell.directionLogoImage.image = UIImage(named: logoImage)
                }
            }
            cell.balanceAmountLabel.textColor = Colors.bothRedColor
        } else {
            if filteredIncomingTransactionSortingArray.count > 0 {
                let responceData = filteredIncomingTransactionSortingArray[indexPath.section].value
                let valueResponce = responceData[indexPath.row]
                let timeInterval  = valueResponce.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                cell.dateLabel.text = dateString
                cell.balanceAmountLabel.text = Double(valueResponce.amount)!.removeZerosFromEnd()
                let logoImage = isLightMode ? "ic_receiver_whitethem" : "ic_receive"
                if valueResponce.direction != BChat_Messenger.TransactionDirection.received {
                    cell.sendandReceiveLabel.text = "Received"
                    cell.directionLogoImage.image = UIImage(named: logoImage)
                } else {
                    cell.sendandReceiveLabel.text = "Received"
                    cell.directionLogoImage.image = UIImage(named: logoImage)
                }
            } else {
                let responceData = sortedGroupedTransactionReceiveArray[indexPath.section].value
                let transaction = responceData[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                cell.dateLabel.text = dateString
                cell.balanceAmountLabel.text = Double(transaction.amount)!.removeZerosFromEnd()
                let logoImage = isLightMode ? "ic_receiver_whitethem" : "ic_receive"
                if transaction.direction != BChat_Messenger.TransactionDirection.received {
                    cell.sendandReceiveLabel.text = "Received"
                    cell.directionLogoImage.image = UIImage(named: logoImage)
                } else {
                    cell.sendandReceiveLabel.text = "Received"
                    cell.directionLogoImage.image = UIImage(named: logoImage)
                }
            }
            cell.balanceAmountLabel.textColor = Colors.bothGreenColor
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TransationHistoryTableCell
        cell.selectionStyle = .none
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        dateFormatter.timeZone = NSTimeZone(name: "Asia/Kolkata") as TimeZone?
        let LongdateFormatter = DateFormatter()
        LongdateFormatter.dateFormat = "MMM d, yyyy, h:mm:ss a"
        LongdateFormatter.timeZone = NSTimeZone(name: "Asia/Kolkata") as TimeZone?
        
        if isFromAllTransationFlag == true {
            if filteredAllTransactionSortingArray.count > 0 {
                let responceData = filteredAllTransactionSortingArray[indexPath.section].value
                let transaction = responceData[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                balanceAmountForDetailsPageLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                dateForDetailsPageLabel.text = dateString
                transationDetailsIDLabel.text = transaction.hash
                if transaction.paymentId == "0000000000000000" {
                    paymentIDStackView.isHidden = true
                } else {
                    recipientAddressDetailsIDLabel.text = transaction.paymentId
                    paymentIDStackView.isHidden = false
                }
                amountDetailsIDLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                heightDetailsIDLabel.text = "\(transaction.blockHeight)"
                let dateString2 = LongdateFormatter.string(from: date as Date)
                dateDetailsIDLabel.text = dateString2
                //Save Receipent Address fun developed
                let serverhash = transaction.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true {
                    recipientAddressStackView.isHidden = false
                    recipientAddressDetailsIDLabel.text = "\(address)"
                } else {
                    recipientAddressStackView.isHidden = true
                }
                //Transation Details from Send and Received
                if transaction.direction != BChat_Messenger.TransactionDirection.received {
                    isFromSendDetailsTitleLabel.text = "Send"
                    isFromSendDetailsTitleLabel.textColor = .red
                    let logoImage = isLightMode ? "ic_send_whitethem" : "ic_send_icon"
                    directionLogoForDetailsPageImage.image = UIImage(named: logoImage)
                    balanceAmountForDetailsPageLabel.textColor = Colors.bothRedColor
                    feeIDStackView.isHidden = false
                    feeDetailsLabel.text = transaction.networkFee + " BDX"
                    amountDetailsIDLabel.textColor = Colors.bothRedColor
                } else {
                    isFromSendDetailsTitleLabel.text = "Received"
                    isFromSendDetailsTitleLabel.textColor = Colors.bothGreenColor
                    let logoImage = isLightMode ? "ic_receiver_whitethem" : "ic_receive"
                    directionLogoForDetailsPageImage.image = UIImage(named: logoImage)
                    balanceAmountForDetailsPageLabel.textColor = Colors.bothGreenColor
                    amountDetailsIDLabel.textColor = Colors.bothGreenColor
                    feeIDStackView.isHidden = true
                }
            } else {
                let responceData = sortedGroupedTransactionAllArray[indexPath.section].value
                let transaction = responceData[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                balanceAmountForDetailsPageLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                dateForDetailsPageLabel.text = dateString
                transationDetailsIDLabel.text = transaction.hash
                if transaction.paymentId == "0000000000000000" {
                    paymentIDStackView.isHidden = true
                } else {
                    recipientAddressDetailsIDLabel.text = transaction.paymentId
                    paymentIDStackView.isHidden = false
                }
                amountDetailsIDLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                heightDetailsIDLabel.text = "\(transaction.blockHeight)"
                let dateString2 = LongdateFormatter.string(from: date as Date)
                dateDetailsIDLabel.text = dateString2
                //Save Receipent Address fun developed
                let serverhash = transaction.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true {
                    recipientAddressStackView.isHidden = false
                    recipientAddressDetailsIDLabel.text = "\(address)"
                } else {
                    recipientAddressStackView.isHidden = true
                }
                //Transation Details from Send and Received
                if transaction.direction != BChat_Messenger.TransactionDirection.received {
                    isFromSendDetailsTitleLabel.text = "Send"
                    isFromSendDetailsTitleLabel.textColor = .red
                    let logoImage = isLightMode ? "ic_send_whitethem" : "ic_send_icon"
                    directionLogoForDetailsPageImage.image = UIImage(named: logoImage)
                    balanceAmountForDetailsPageLabel.textColor = Colors.bothRedColor
                    feeIDStackView.isHidden = false
                    feeDetailsLabel.text = transaction.networkFee + " BDX"
                    amountDetailsIDLabel.textColor = Colors.bothRedColor
                } else {
                    isFromSendDetailsTitleLabel.text = "Received"
                    isFromSendDetailsTitleLabel.textColor = Colors.bothGreenColor
                    let logoImage = isLightMode ? "ic_receiver_whitethem" : "ic_receive"
                    directionLogoForDetailsPageImage.image = UIImage(named: logoImage)
                    balanceAmountForDetailsPageLabel.textColor = Colors.bothGreenColor
                    amountDetailsIDLabel.textColor = Colors.bothGreenColor
                    feeIDStackView.isHidden = true
                }
            }
        } else if isFromSendTransationFlag == true {
            if filteredOutgoingTransactionSortingArray.count > 0 {
                let responceData = filteredOutgoingTransactionSortingArray[indexPath.section].value
                let transaction = responceData[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                balanceAmountForDetailsPageLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                dateForDetailsPageLabel.text = dateString
                transationDetailsIDLabel.text = transaction.hash
                if transaction.paymentId == "0000000000000000" {
                    paymentIDStackView.isHidden = true
                } else {
                    recipientAddressDetailsIDLabel.text = transaction.paymentId
                    paymentIDStackView.isHidden = false
                }
                amountDetailsIDLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                heightDetailsIDLabel.text = "\(transaction.blockHeight)"
                let dateString2 = LongdateFormatter.string(from: date as Date)
                dateDetailsIDLabel.text = dateString2
                //Save Receipent Address fun developed
                let serverhash = transaction.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true {
                    recipientAddressStackView.isHidden = false
                    recipientAddressDetailsIDLabel.text = "\(address)"
                } else {
                    recipientAddressStackView.isHidden = true
                }
                //Transation Details from Send and Received
                let logoImage = isLightMode ? "ic_send_whitethem" : "ic_send_icon"
                if transaction.direction != BChat_Messenger.TransactionDirection.sent {
                    isFromSendDetailsTitleLabel.text = "Send"
                    isFromSendDetailsTitleLabel.textColor = .red
                    directionLogoForDetailsPageImage.image = UIImage(named: logoImage)
                } else {
                    isFromSendDetailsTitleLabel.text = "Send"
                    isFromSendDetailsTitleLabel.textColor = .red
                    directionLogoForDetailsPageImage.image = UIImage(named: logoImage)
                }
            } else {
                let responceData = sortedGroupedTransactionSendArray[indexPath.section].value
                let transaction = responceData[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                balanceAmountForDetailsPageLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                dateForDetailsPageLabel.text = dateString
                transationDetailsIDLabel.text = transaction.hash
                if transaction.paymentId == "0000000000000000" {
                    paymentIDStackView.isHidden = true
                } else {
                    recipientAddressDetailsIDLabel.text = transaction.paymentId
                    paymentIDStackView.isHidden = false
                }
                amountDetailsIDLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                heightDetailsIDLabel.text = "\(transaction.blockHeight)"
                let dateString2 = LongdateFormatter.string(from: date as Date)
                dateDetailsIDLabel.text = dateString2
                //Save Receipent Address fun developed
                let serverhash = transaction.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true {
                    recipientAddressStackView.isHidden = false
                    recipientAddressDetailsIDLabel.text = "\(address)"
                } else {
                    recipientAddressStackView.isHidden = true
                }
                //Transation Details from Send and Received
                let logoImage = isLightMode ? "ic_send_whitethem" : "ic_send_icon"
                if transaction.direction != BChat_Messenger.TransactionDirection.sent {
                    isFromSendDetailsTitleLabel.text = "Send"
                    isFromSendDetailsTitleLabel.textColor = .red
                    directionLogoForDetailsPageImage.image = UIImage(named: logoImage)
                } else {
                    isFromSendDetailsTitleLabel.text = "Send"
                    isFromSendDetailsTitleLabel.textColor = .red
                    directionLogoForDetailsPageImage.image = UIImage(named: logoImage)
                }
            }
            amountDetailsIDLabel.textColor = Colors.bothRedColor
            balanceAmountForDetailsPageLabel.textColor = Colors.bothRedColor
        } else {
            if filteredIncomingTransactionSortingArray.count > 0 {
                let responceData = filteredIncomingTransactionSortingArray[indexPath.section].value
                let transaction = responceData[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                balanceAmountForDetailsPageLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                dateForDetailsPageLabel.text = dateString
                transationDetailsIDLabel.text = transaction.hash
                if transaction.paymentId == "0000000000000000" {
                    paymentIDStackView.isHidden = true
                } else {
                    recipientAddressDetailsIDLabel.text = transaction.paymentId
                    paymentIDStackView.isHidden = false
                }
                amountDetailsIDLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                heightDetailsIDLabel.text = "\(transaction.blockHeight)"
                let dateString2 = LongdateFormatter.string(from: date as Date)
                dateDetailsIDLabel.text = dateString2
                //Save Receipent Address fun developed
                let serverhash = transaction.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true {
                    recipientAddressStackView.isHidden = false
                    recipientAddressDetailsIDLabel.text = "\(address)"
                } else {
                    recipientAddressStackView.isHidden = true
                }
                //Transation Details from Send and Received
                let logoImage = isLightMode ? "ic_receiver_whitethem" : "ic_receive"
                if transaction.direction != BChat_Messenger.TransactionDirection.received {
                    isFromSendDetailsTitleLabel.text = "Received"
                    isFromSendDetailsTitleLabel.textColor = Colors.bothGreenColor
                    directionLogoForDetailsPageImage.image = UIImage(named: logoImage)
                } else {
                    isFromSendDetailsTitleLabel.text = "Received"
                    isFromSendDetailsTitleLabel.textColor = Colors.bothGreenColor
                    directionLogoForDetailsPageImage.image = UIImage(named: logoImage)
                }
            } else {
                let responceData = sortedGroupedTransactionReceiveArray[indexPath.section].value
                let transaction = responceData[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                balanceAmountForDetailsPageLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                dateForDetailsPageLabel.text = dateString
                transationDetailsIDLabel.text = transaction.hash
                if transaction.paymentId == "0000000000000000" {
                    paymentIDStackView.isHidden = true
                } else {
                    recipientAddressDetailsIDLabel.text = transaction.paymentId
                    paymentIDStackView.isHidden = false
                }
                amountDetailsIDLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                heightDetailsIDLabel.text = "\(transaction.blockHeight)"
                let dateString2 = LongdateFormatter.string(from: date as Date)
                dateDetailsIDLabel.text = dateString2
                //Save Receipent Address fun developed
                let serverhash = transaction.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true {
                    recipientAddressStackView.isHidden = false
                    recipientAddressDetailsIDLabel.text = "\(address)"
                } else {
                    recipientAddressStackView.isHidden = true
                }
                //Transation Details from Send and Received
                let logoImage = isLightMode ? "ic_receiver_whitethem" : "ic_receive"
                if transaction.direction != BChat_Messenger.TransactionDirection.received {
                    isFromSendDetailsTitleLabel.text = "Received"
                    isFromSendDetailsTitleLabel.textColor = Colors.bothGreenColor
                    directionLogoForDetailsPageImage.image = UIImage(named: logoImage)
                } else {
                    isFromSendDetailsTitleLabel.text = "Received"
                    isFromSendDetailsTitleLabel.textColor = Colors.bothGreenColor
                    directionLogoForDetailsPageImage.image = UIImage(named: logoImage)
                }
            }
            amountDetailsIDLabel.textColor = Colors.bothGreenColor
            balanceAmountForDetailsPageLabel.textColor = Colors.bothGreenColor
        }
        //Hide the Views
        walletSyncingBackgroundView.isHidden = true
        noTransactionsYetBackgroundView.isHidden = true
        transactionsDetailsBackgroundView.isHidden = false
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25)
        let footerView = UIView(frame:rect)
        footerView.backgroundColor = Colors.mainBackGroundColor2
        footerView.layer.cornerRadius = 28
        footerView.layer.masksToBounds = true
        footerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let label = UILabel()
        if isFromAllTransationFlag == true {
            if self.isFilter {
                label.text = formatDateString(filteredAllTransactionSortingArray[section].key)
            } else {
                label.text = formatDateString(sortedGroupedTransactionAllArray[section].key)
            }
        } else if isFromSendTransationFlag == true {
            if self.isFilter {
                label.text = formatDateString(filteredOutgoingTransactionSortingArray[section].key)
            } else {
                label.text = formatDateString(sortedGroupedTransactionSendArray[section].key)
            }
        } else {
            if self.isFilter {
                label.text = formatDateString(filteredIncomingTransactionSortingArray[section].key)
            } else {
                label.text = formatDateString(sortedGroupedTransactionReceiveArray[section].key)
            }
        }
        label.textColor = Colors.aboutContentLabelColor
        label.frame = CGRect(x: 30, y: -5, width: tableView.frame.width - 30, height: 25)
        label.font = Fonts.semiOpenSans(ofSize: 14)
        footerView.addSubview(label)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25 // Set the height of the header view as needed
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func sortAndGroupTransactions() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        //All
        groupedItemsAll.removeAll()
        for item in transactionAllArray {
            guard let date = dateFormatter.date(from: item.newtimestamp) else {
                continue
            }
            let key = dateFormatter.string(from: date)
            if groupedItemsAll[key] == nil {
                groupedItemsAll[key] = [item]
            } else {
                groupedItemsAll[key]?.append(item)
            }
        }
        // Sort grouped items by keys (dates) in descending order
        sortedGroupedTransactionAllArray = groupedItemsAll.sorted(by: { dateFormatter.date(from: $0.key)! > dateFormatter.date(from: $1.key)! })
        // Print and display the sorted grouped items
        for (key, items) in sortedGroupedTransactionAllArray {
            for item in items {
                //print("Date list-------->:", item.newtimestamp)
            }
        }
        
        //Received
        groupedItemsReceived.removeAll()
        for item in transactionReceiveArray {
            guard let date = dateFormatter.date(from: item.newtimestamp) else {
                continue
            }
            let key = dateFormatter.string(from: date)
            if groupedItemsReceived[key] == nil {
                groupedItemsReceived[key] = [item]
            } else {
                groupedItemsReceived[key]?.append(item)
            }
        }
        sortedGroupedTransactionReceiveArray = groupedItemsReceived.sorted(by: { dateFormatter.date(from: $0.key)! > dateFormatter.date(from: $1.key)! })
        
        //Sending
        groupedItemsSend.removeAll()
        for item in transactionSendArray {
            guard let date = dateFormatter.date(from: item.newtimestamp) else {
                continue
            }
            let key = dateFormatter.string(from: date)
            if groupedItemsSend[key] == nil {
                groupedItemsSend[key] = [item]
            } else {
                groupedItemsSend[key]?.append(item)
            }
        }
        sortedGroupedTransactionSendArray = groupedItemsSend.sorted(by: { dateFormatter.date(from: $0.key)! > dateFormatter.date(from: $1.key)! })
        tableView.reloadData()
    }
    
    func formatDateString(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"  // Adjust the format based on your date string
        guard let date = dateFormatter.date(from: dateString) else {
            return "Invalid Date"
        }
        let calendar = Calendar.current
        let currentDate = Date()
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let components = calendar.dateComponents([.year, .month, .day], from: date, to: currentDate)
            if let year = components.year, year == 0, let month = components.month, abs(month) < 1 {
                // Dates within the past week, display day name (EEEE) if within last 7 days
                if let day = components.day, day <= 7 {
                    let dayNameFormatter = DateFormatter()
                    dayNameFormatter.dateFormat = "EEEE"
                    let dayName = dayNameFormatter.string(from: date)
                    return dayName
                }
            }
            // Display the full date and month for dates older than 7 days
            let monthYearFormatter = DateFormatter()
            monthYearFormatter.dateFormat = "dd MMM"
            return monthYearFormatter.string(from: date)
        }
    }
    
}


class TransationHistoryTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var directionLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var balanceAmountLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 15)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var dateLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.walletHomeFilterLabelColor
        result.font = Fonts.regularOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var sendandReceiveLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.walletHomeFilterLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("RECEIVED_TITLE", comment: "")
        return result
    }()
    
    lazy var arrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_expand_arrow_dark" : "ic_back_New"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(directionLogoImage)
        backGroundView.addSubview(balanceAmountLabel)
        backGroundView.addSubview(dateLabel)
        backGroundView.addSubview(arrowImage)
        backGroundView.addSubview(sendandReceiveLabel)
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            directionLogoImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 24),
            directionLogoImage.widthAnchor.constraint(equalToConstant: 24),
            directionLogoImage.heightAnchor.constraint(equalToConstant: 24),
            directionLogoImage.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            directionLogoImage.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 18),
            directionLogoImage.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -18),
            balanceAmountLabel.leadingAnchor.constraint(equalTo: directionLogoImage.trailingAnchor, constant: 13),
            balanceAmountLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: -10),
            dateLabel.leadingAnchor.constraint(equalTo: directionLogoImage.trailingAnchor, constant: 13),
            dateLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: 10),
            arrowImage.heightAnchor.constraint(equalToConstant: 10),
            arrowImage.widthAnchor.constraint(equalToConstant: 10),
            arrowImage.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -25),
            arrowImage.centerYAnchor.constraint(equalTo: directionLogoImage.centerYAnchor),
            sendandReceiveLabel.trailingAnchor.constraint(equalTo: arrowImage.leadingAnchor, constant: -10),
            sendandReceiveLabel.centerYAnchor.constraint(equalTo: arrowImage.centerYAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WalletHomeNewVC: BeldexWalletDelegate {
    
    func beldexWalletRefreshed(_ wallet: BChatWalletWrapper) {
        print("Refreshed---------->blockChainHeight-->\(wallet.blockChainHeight) ---------->daemonBlockChainHeight-->, \(wallet.daemonBlockChainHeight)")
        self.daemonBlockChainHeight = wallet.daemonBlockChainHeight
        isdaemonHeight = Int64(wallet.blockChainHeight)
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            if wallet.isSynchronized == true {
                self.isSyncingUI = false
            }
        }
        if self.needSynchronized {
            self.needSynchronized = !wallet.save()
        }
        taskQueue.async {
            guard let wallet = self.wallet else { return }
            let (balance, history) = (wallet.balance, wallet.history)
            self.postData(balance: balance, history: history)
        }
        if daemonBlockChainHeight != 0 {
            let difference = wallet.daemonBlockChainHeight.subtractingReportingOverflow(daemonBlockChainHeight)
            guard !difference.overflow else { return }
        }
        DispatchQueue.main.async {
            if self.conncetingState.value {
                self.conncetingState.value = false
            }
            if wallet.isSynchronized {
                self.synchronizedUI()
            }
        }
    }
    
    func beldexWalletNewBlock(_ wallet: BChatWalletWrapper, currentHeight: UInt64) {
        print("NewBlock------------------------------------------currentHeight ----> \(currentHeight)---DaemonBlockHeight---->\(wallet.daemonBlockChainHeight)")
        self.currentBlockChainHeight = currentHeight
        self.daemonBlockChainHeight = wallet.daemonBlockChainHeight
        isdaemonHeight = Int64(wallet.daemonBlockChainHeight)
        self.isFromWalletRescan(isCurrentHeight: currentHeight, isdaemonBlockHeight: wallet.daemonBlockChainHeight)
        self.needSynchronized = true
        self.isSyncingUI = true
        DispatchQueue.main.async {
            self.beldexBalanceLabel.text = "-.---"
        }
    }
    
    func isFromWalletRescan(isCurrentHeight:UInt64,isdaemonBlockHeight:UInt64) {
        taskQueue.async {
            let (current, total) = (isCurrentHeight, isdaemonBlockHeight)
            guard total != current else { return }
            let difference = total.subtractingReportingOverflow(current)
            var progress = CGFloat(current) / CGFloat(total)
            let leftBlocks: String
            if difference.overflow || difference.partialValue <= 1 {
                leftBlocks = "1"
                progress = 1
            } else {
                leftBlocks = String(difference.partialValue)
            }
            
            let largeNumber = Int(leftBlocks)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.groupingSize = 3
            numberFormatter.secondaryGroupingSize = 2
            let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber ?? 1))
            let statusText = "\(formattedNumber!)" + " Blocks Remaining"
            if difference.overflow || difference.partialValue <= 1500 {
                self.backApiRescanVC = false
            }
            DispatchQueue.main.async {
                if self.conncetingState.value {
                    self.conncetingState.value = false
                }
                self.walletSyncingBackgroundView.isHidden = false
                self.noTransactionsYetBackgroundView.isHidden = true
                self.syncedflag = false
                self.progressView.progress = Float(progress)
                self.sliderView.value = Float(progress)
                self.progressStatusLabel.textColor = Colors.aboutContentLabelColor
                self.progressStatusLabel.text = statusText
            }
        }
    }
    
    private func postData(balance: String, history: TransactionHistory) {
        let balance_modify = Helper.displayDigitsAmount(balance)
        transactionAllArray = history.all
        transactionSendArray = history.send
        transactionReceiveArray = history.receive
        self.mainBalance = balance_modify
        DispatchQueue.main.async { [self] in
            self.transactionAllArray = history.all
            self.transactionSendArray = history.send
            self.transactionReceiveArray = history.receive
            if SaveUserDefaultsData.WalletRestoreHeight == "" {
                let lastElementHeight = DateHeight.getBlockHeight.last
                let height = lastElementHeight!.components(separatedBy: ":")
                let restoreHeightempty = UInt64("\(height[1])")!
                self.transactionAllArray = self.transactionAllArray.filter{$0.blockHeight >= restoreHeightempty}
                self.transactionSendArray = self.transactionSendArray.filter{$0.blockHeight >= restoreHeightempty}
                self.transactionReceiveArray = self.transactionReceiveArray.filter{$0.blockHeight >= restoreHeightempty}
            } else {
                self.transactionAllArray = self.transactionAllArray.filter{$0.blockHeight >= UInt64(SaveUserDefaultsData.WalletRestoreHeight)!}
                self.transactionSendArray = self.transactionSendArray.filter{$0.blockHeight >= UInt64(SaveUserDefaultsData.WalletRestoreHeight)!}
                self.transactionReceiveArray = self.transactionReceiveArray.filter{$0.blockHeight >= UInt64(SaveUserDefaultsData.WalletRestoreHeight)!}
            }
            if !SaveUserDefaultsData.SelectedDecimal.isEmpty {
                selectedDecimal = SaveUserDefaultsData.SelectedDecimal
                if selectedDecimal == "4 - Four (0.0000)" {
                    self.beldexBalanceLabel.text = String(format:"%.4f", Double(mainBalance)!)
                } else if selectedDecimal == "3 - Three (0.000)" {
                    self.beldexBalanceLabel.text = String(format:"%.3f", Double(mainBalance)!)
                } else if selectedDecimal == "2 - Two (0.00)" {
                    self.beldexBalanceLabel.text = String(format:"%.2f", Double(mainBalance)!)
                } else if selectedDecimal == "0 - Zero (0)" {
                    self.beldexBalanceLabel.text = String(format:"%.0f", Double(mainBalance)!)
                }
            } else {
                self.beldexBalanceLabel.text = String(format:"%.4f", Double(balance_modify)!)
            }
            if SaveUserDefaultsData.SelectedBalance == "Beldex Full Balance" || SaveUserDefaultsData.SelectedBalance == "Beldex Available Balance"{
                if !SaveUserDefaultsData.SelectedDecimal.isEmpty {
                    selectedDecimal = SaveUserDefaultsData.SelectedDecimal
                    if selectedDecimal == "4 - Four (0.0000)" {
                        self.beldexBalanceLabel.text = String(format:"%.4f", Double(mainBalance)!)
                    } else if selectedDecimal == "3 - Three (0.000)" {
                        self.beldexBalanceLabel.text = String(format:"%.3f", Double(mainBalance)!)
                    } else if selectedDecimal == "2 - Two (0.00)" {
                        self.beldexBalanceLabel.text = String(format:"%.2f", Double(mainBalance)!)
                    } else if selectedDecimal == "0 - Zero (0)" {
                        self.beldexBalanceLabel.text = String(format:"%.0f", Double(mainBalance)!)
                    }
                } else {
                    self.beldexBalanceLabel.text = String(format:"%.4f", Double(balance_modify)!)
                }
            }
            if SaveUserDefaultsData.SelectedBalance == "Beldex Hidden" {
                self.beldexBalanceLabel.text = "---"
                self.isCurrencyResultLabel.text = "---"
            }
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            self.fetchMarketsData(false)
            self.reloadData([:])
            
            sortAndGroupTransactions()
            if self.transactionAllArray.count == 0 {
                noTransactionsYetBackgroundView.isHidden = false
                filterTransactionsHistoryBackgroundView.isHidden = true
            } else {
                noTransactionsYetBackgroundView.isHidden = true
                filterTransactionsHistoryBackgroundView.isHidden = false
            }
        }
    }
}

