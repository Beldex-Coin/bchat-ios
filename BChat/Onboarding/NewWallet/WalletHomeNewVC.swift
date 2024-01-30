// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class WalletHomeNewVC: UIViewController, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate {
    
    private lazy var topBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 18
        stackView.backgroundColor = Colors.backgroundViewColor2
        return stackView
    }()
    private lazy var isFromProgressStatusLabel: UILabel = {
        let result = UILabel()
        result.text = "123456 Blocks remaining"
        result.textColor = UIColor.lightGray
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var isFromSyncingImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_syncing_New", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    let isCurrencyNameTitleLabel = UILabel()
    private lazy var isCurrencyResultTitleLabel: UILabel = {
        let result = UILabel()
        result.text = "0.5700 USD"
        result.textColor = UIColor.lightGray
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.center = view.center
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.setProgress(0.8, animated: false)
        progressView.trackTintColor = .lightGray
        progressView.tintColor = Colors.greenColor
        return progressView
    }()
    lazy var beldexLogoImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_beldex", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    private lazy var beldexBalanceLabel: UILabel = {
        let result = UILabel()
        result.text = "96.89654086"
        result.textColor = .white
        result.font = Fonts.boldOpenSans(ofSize: 26)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var middleBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 16
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        return stackView
    }()
    private lazy var isFromScanButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: 0xEBEBEB)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 14
        let image = UIImage(named: "ic_Newqr")?.scaled(to: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(isFromScanButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var isFromSendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: 0x2979FB)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 14
        let image = UIImage(named: "ic_send_new")?.scaled(to: CGSize(width: 25, height: 25))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(isFromSendButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var isFromReceiveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.greenColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 14
        let image = UIImage(named: "ic_Receive_New")?.scaled(to: CGSize(width: 25, height: 25))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(isFromReceiveButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var isFromReConnectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: 0x333343)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 14
        let image = UIImage(named: "ic_rotate_new")?.scaled(to: CGSize(width: 25, height: 25))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(isFromReConnectButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var buttonsStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ isFromScanButton, isFromSendButton, isFromReceiveButton, isFromReConnectButton ])
        result.axis = .horizontal
        result.spacing = 28
        result.distribution = .fillEqually
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var transationTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("TRANSACTION_LABEL", comment: "")
        result.textColor = .white
        result.font = Fonts.semiOpenSans(ofSize: 18)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var isFromFilterImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: 0xEBEBEB)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "ic_Filter_New")?.scaled(to: CGSize(width: 20, height: 20))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(isFromFilterImageButtonTapped), for: .touchUpInside)
        return button
    }()
    // MARK: - Here Wallet Syncing Components
    private lazy var walletSyncingBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 28
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stackView
    }()
    lazy var walletSyncingLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_wallet_syncing_new", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        imageView.tintColor = UIColor(hex: 0x65656E)
        return imageView
    }()
    private lazy var walletSyncingTitleLabel: UILabel = {
        let result = UILabel()
        result.text = "Wallet Syncing.."
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.semiOpenSans(ofSize: 18)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var walletSyncingSubTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("PLEASE_WAIT_WHILE_WALLET_SYNCING", comment: "")
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    // MARK: - Here No Transactions Yet Components
    private lazy var noTransactionsYetBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 28
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stackView
    }()
    lazy var noTransactionsYetLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_no_transactions_light", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        imageView.tintColor = UIColor(hex: 0x65656E)
        return imageView
    }()
    private lazy var noTransactionsYetTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("NO_TRANSACTION_MSG", comment: "")
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.semiOpenSans(ofSize: 18)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var noTransactionsYetSubTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("AFTER_YOUR_FIRST_TRANSATION_VIEW", comment: "")
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .center
        result.numberOfLines = 0
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    // MARK: - Here Transactions History Components
    private lazy var isFromFilterTransactionsHistoryBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 28
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stackView
    }()
    private lazy var incomingButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("INCOMING_BUTTON", comment: ""), for: .normal)
        let image = UIImage(named: "ic_Uncheck_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white // Set the tint color to white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(incomingButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var outgoingButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("OUTGOING_BUTTON", comment: ""), for: .normal)
        let image = UIImage(named: "ic_Uncheck_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white // Set the tint color to white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(outgoingButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var byDateButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("BY_DATE_BUTTON", comment: ""), for: .normal)
        let image = UIImage(named: "ic_by_date_New")?.scaled(to: CGSize(width: 20.0, height: 20.0))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white // Set the tint color to white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
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
        stackView.backgroundColor = UIColor(hex: 0x4B4B64)
        return stackView
    }()
    private lazy var lineBackgroundView2: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x4B4B64)
        return stackView
    }()
    private lazy var lineBackgroundView3: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x4B4B64)
        return stackView
    }()
    private lazy var lineBackgroundView4: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x4B4B64)
        return stackView
    }()
    private lazy var lineBackgroundView5: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x4B4B64)
        return stackView
    }()
    private lazy var lineBackgroundView6: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x4B4B64)
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
    let sectionNames = ["Today", "Saturday", "May 12"]
    // MARK: - Here No Transactions Details Components
    private lazy var transactionsDetailsBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 28
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stackView
    }()
    private lazy var detailsTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("DETAILS_MSG", comment: "")
        result.textColor = .white
        result.font = Fonts.semiOpenSans(ofSize: 18)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var backImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "ic_transation_back_new")?.scaled(to: CGSize(width: 35, height: 25))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backImageButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var directionLogoForDetailsPageImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_receive_New 1", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var balanceAmountForDetailsPageLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.boldOpenSans(ofSize: 15)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "0.6 BDX"
        return result
    }()
    lazy var dateForDetailsPageLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "10-Feb-2022"
        return result
    }()
    lazy var transationDetailsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("TRANSACTION_ID", comment: "")
        return result
    }()
    lazy var dateDetailsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("DATE_TITLE", comment: "")
        return result
    }()
    lazy var dateDetailsIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Feb 10, 2022, 2:02:53 PM"
        return result
    }()
    lazy var heightDetailsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("HEIGHT_TITLE", comment: "")
        return result
    }()
    lazy var heightDetailsIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "2121221"
        return result
    }()
    lazy var amountDetailsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("AMOUNT_TITLE", comment: "")
        return result
    }()
    lazy var amountDetailsIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.greenColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "0.12 BDX"
        return result
    }()
    lazy var transationDetailsIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.numberOfLines = 0
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "1da5eb62d1a8b935e05a7ea89515a68ef453a4db27b6d7ee017afe8b7d80b856"
        return result
    }()
    private lazy var transationIDcopyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.setImage(UIImage(named: "copy_white")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(transationIDcopyButtonTapped), for: .touchUpInside)
        button.tintColor = Colors.greenColor
        return button
    }()
    lazy var isFromSendDetailsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0x0085FF)
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("ATTACHMENT_APPROVAL_SEND_BUTTON", comment: "")
        return result
    }()
    lazy var recipientAddressDetailsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("RECIPIENT_ADDRESS", comment: "")
        return result
    }()
    lazy var recipientAddressDetailsIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.numberOfLines = 0
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "1da5eb62d1a8b935e05a7ea89515a68ef453a4db27b6d7ee017afe8b7d80b856"
        return result
    }()
    private lazy var recipientAddresscopyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.setImage(UIImage(named: "copy_white")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(recipientAddresscopyButtonTapped), for: .touchUpInside)
        button.tintColor = Colors.greenColor
        return button
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
        stackView.backgroundColor = UIColor(hex: 0x080812).withAlphaComponent(0.8)
        return stackView
    }()
    private lazy var selectDateRangePopUpbackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x111119)
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        return stackView
    }()
    lazy var selectDateRangeTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("Select Date Range", comment: "")
        return result
    }()
    private lazy var fromDateTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("From Date", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 14)
        result.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        result.layer.borderWidth = 1
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 12
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
        result.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("To Date", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 14)
        result.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        result.layer.borderWidth = 1
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 12
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
        result.addTarget(self, action: #selector(cancelButtonTapped), for: UIControl.Event.touchUpInside)
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var okButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString("OK", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(okButtonTapped), for: UIControl.Event.touchUpInside)
        result.layer.cornerRadius = 16
        result.backgroundColor = Colors.greenColor
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "My Wallet"
        
        let item1 = UIBarButtonItem(image: UIImage(named: "icsettings1_New")!, style: .plain, target: self, action: #selector(settingsOptionTapped))
        let rightBarButtonItems = [item1]
        navigationItem.rightBarButtonItems = rightBarButtonItems
        
        isCurrencyNameTitleLabel.text = "USD"
        isCurrencyNameTitleLabel.textColor = UIColor(hex: 0xACACAC)
        isCurrencyNameTitleLabel.font = Fonts.boldOpenSans(ofSize: 12)
        isCurrencyNameTitleLabel.textAlignment = .center
        isCurrencyNameTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        isCurrencyNameTitleLabel.backgroundColor = UIColor(hex: 0x1c1c26)
        isCurrencyNameTitleLabel.clipsToBounds = true
        isCurrencyNameTitleLabel.layer.cornerRadius = isCurrencyNameTitleLabel.frame.height/2
        
        view.addSubview(topBackgroundView)
        topBackgroundView.addSubview(isFromProgressStatusLabel)
        topBackgroundView.addSubview(isFromSyncingImage)
        topBackgroundView.addSubview(isCurrencyNameTitleLabel)
        topBackgroundView.addSubview(isCurrencyResultTitleLabel)
        topBackgroundView.addSubview(progressView)
        topBackgroundView.addSubview(beldexLogoImg)
        topBackgroundView.addSubview(beldexBalanceLabel)
        topBackgroundView.addSubview(middleBackgroundView)
        middleBackgroundView.addSubview(buttonsStackView)
        view.addSubview(transationTitleLabel)
        view.addSubview(isFromFilterImageButton)
        
        view.addSubview(walletSyncingBackgroundView)
        walletSyncingBackgroundView.addSubview(walletSyncingLogoImage)
        walletSyncingBackgroundView.addSubview(walletSyncingTitleLabel)
        walletSyncingBackgroundView.addSubview(walletSyncingSubTitleLabel)
        
        view.addSubview(noTransactionsYetBackgroundView)
        noTransactionsYetBackgroundView.addSubview(noTransactionsYetLogoImage)
        noTransactionsYetBackgroundView.addSubview(noTransactionsYetTitleLabel)
        noTransactionsYetBackgroundView.addSubview(noTransactionsYetSubTitleLabel)
        
        view.addSubview(isFromFilterTransactionsHistoryBackgroundView)
        isFromFilterTransactionsHistoryBackgroundView.addSubview(filterStackView)
        isFromFilterTransactionsHistoryBackgroundView.addSubview(lineBackgroundView)
        isFromFilterTransactionsHistoryBackgroundView.addSubview(tableView)
        isFromFilterTransactionsHistoryBackgroundView.addSubview(stackView)
        
        view.addSubview(transactionsDetailsBackgroundView)
        transactionsDetailsBackgroundView.addSubview(detailsTitleLabel)
        transactionsDetailsBackgroundView.addSubview(backImageButton)
        transactionsDetailsBackgroundView.addSubview(lineBackgroundView2)
        transactionsDetailsBackgroundView.addSubview(directionLogoForDetailsPageImage)
        transactionsDetailsBackgroundView.addSubview(balanceAmountForDetailsPageLabel)
        transactionsDetailsBackgroundView.addSubview(dateForDetailsPageLabel)
        transactionsDetailsBackgroundView.addSubview(transationDetailsTitleLabel)
        transactionsDetailsBackgroundView.addSubview(isFromSendDetailsTitleLabel)
        transactionsDetailsBackgroundView.addSubview(transationDetailsIDLabel)
        transactionsDetailsBackgroundView.addSubview(transationIDcopyButton)
        transactionsDetailsBackgroundView.addSubview(lineBackgroundView3)
        transactionsDetailsBackgroundView.addSubview(dateDetailsTitleLabel)
        transactionsDetailsBackgroundView.addSubview(dateDetailsIDLabel)
        transactionsDetailsBackgroundView.addSubview(lineBackgroundView4)
        transactionsDetailsBackgroundView.addSubview(heightDetailsTitleLabel)
        transactionsDetailsBackgroundView.addSubview(heightDetailsIDLabel)
        transactionsDetailsBackgroundView.addSubview(lineBackgroundView5)
        transactionsDetailsBackgroundView.addSubview(amountDetailsTitleLabel)
        transactionsDetailsBackgroundView.addSubview(amountDetailsIDLabel)
        transactionsDetailsBackgroundView.addSubview(lineBackgroundView6)
        transactionsDetailsBackgroundView.addSubview(recipientAddressDetailsTitleLabel)
        transactionsDetailsBackgroundView.addSubview(recipientAddressDetailsIDLabel)
        transactionsDetailsBackgroundView.addSubview(recipientAddresscopyButton)
        
        // Date PopUp
        view.addSubview(backgroundBlerView)
        backgroundBlerView.addSubview(selectDateRangePopUpbackgroundView)
        selectDateRangePopUpbackgroundView.addSubview(selectDateRangeTitleLabel)
        selectDateRangePopUpbackgroundView.addSubview(fromDateTextField)
        selectDateRangePopUpbackgroundView.addSubview(toDateTextField)
        selectDateRangePopUpbackgroundView.addSubview(buttonStackView)
        
        // MARK: - Here Conditions based on hidden the view only
        walletSyncingBackgroundView.isHidden = true
        noTransactionsYetBackgroundView.isHidden = true
        isFromFilterTransactionsHistoryBackgroundView.isHidden = false
        transactionsDetailsBackgroundView.isHidden = true
        // Date PopUp
        backgroundBlerView.isHidden = true
        selectDateRangePopUpbackgroundView.isHidden = true
        
        
        filterStackView.isHidden = true
        lineBackgroundView.isHidden = true
        isFromFilterImageButton.backgroundColor = .clear
        isFromFilterImageButton.tintColor = UIColor.white
        
        NSLayoutConstraint.activate([
            topBackgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            isFromProgressStatusLabel.topAnchor.constraint(equalTo: topBackgroundView.topAnchor, constant: 20),
            isFromProgressStatusLabel.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 18),
            isFromSyncingImage.widthAnchor.constraint(equalToConstant: 12),
            isFromSyncingImage.heightAnchor.constraint(equalToConstant: 12),
            isFromSyncingImage.centerYAnchor.constraint(equalTo: isFromProgressStatusLabel.centerYAnchor),
            isFromSyncingImage.leadingAnchor.constraint(equalTo: isFromProgressStatusLabel.trailingAnchor, constant: 5),
            isCurrencyResultTitleLabel.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -18),
            isCurrencyResultTitleLabel.centerYAnchor.constraint(equalTo: isFromProgressStatusLabel.centerYAnchor),
            isCurrencyNameTitleLabel.trailingAnchor.constraint(equalTo: isCurrencyResultTitleLabel.leadingAnchor, constant: -5),
            isCurrencyNameTitleLabel.centerYAnchor.constraint(equalTo: isCurrencyResultTitleLabel.centerYAnchor),
            isCurrencyNameTitleLabel.widthAnchor.constraint(equalToConstant: 53),
            isCurrencyNameTitleLabel.heightAnchor.constraint(equalToConstant: 22),
            progressView.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 0),
            progressView.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -0),
            progressView.topAnchor.constraint(equalTo: isFromProgressStatusLabel.bottomAnchor, constant: 16),
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
            buttonsStackView.widthAnchor.constraint(equalToConstant: 50),
            buttonsStackView.trailingAnchor.constraint(equalTo: middleBackgroundView.trailingAnchor, constant: -32),
            buttonsStackView.leadingAnchor.constraint(equalTo: middleBackgroundView.leadingAnchor, constant: 32),
            buttonsStackView.centerXAnchor.constraint(equalTo: middleBackgroundView.centerXAnchor),
            buttonsStackView.centerYAnchor.constraint(equalTo: middleBackgroundView.centerYAnchor),
            transationTitleLabel.topAnchor.constraint(equalTo: middleBackgroundView.bottomAnchor, constant: 13),
            transationTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            isFromFilterImageButton.heightAnchor.constraint(equalToConstant: 35),
            isFromFilterImageButton.widthAnchor.constraint(equalToConstant: 35),
            isFromFilterImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            isFromFilterImageButton.centerYAnchor.constraint(equalTo: transationTitleLabel.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            walletSyncingBackgroundView.topAnchor.constraint(equalTo: isFromFilterImageButton.bottomAnchor, constant: 12),
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
        
        NSLayoutConstraint.activate([
            noTransactionsYetBackgroundView.topAnchor.constraint(equalTo: isFromFilterImageButton.bottomAnchor, constant: 12),
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
            isFromFilterTransactionsHistoryBackgroundView.topAnchor.constraint(equalTo: isFromFilterImageButton.bottomAnchor, constant: 12),
            isFromFilterTransactionsHistoryBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            isFromFilterTransactionsHistoryBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            isFromFilterTransactionsHistoryBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0),
            filterStackView.topAnchor.constraint(equalTo: isFromFilterTransactionsHistoryBackgroundView.topAnchor, constant: 10),
            filterStackView.trailingAnchor.constraint(equalTo: isFromFilterTransactionsHistoryBackgroundView.trailingAnchor, constant: -25),
            filterStackView.leadingAnchor.constraint(equalTo: isFromFilterTransactionsHistoryBackgroundView.leadingAnchor, constant: 25),
            filterStackView.heightAnchor.constraint(equalToConstant: 50),
            lineBackgroundView.topAnchor.constraint(equalTo: filterStackView.bottomAnchor, constant: 15),
            lineBackgroundView.trailingAnchor.constraint(equalTo: isFromFilterTransactionsHistoryBackgroundView.trailingAnchor, constant: -0),
            lineBackgroundView.leadingAnchor.constraint(equalTo: isFromFilterTransactionsHistoryBackgroundView.leadingAnchor, constant: 0),
            lineBackgroundView.heightAnchor.constraint(equalToConstant: 1),
            tableView.topAnchor.constraint(equalTo: lineBackgroundView.bottomAnchor, constant: -15),
            tableView.leadingAnchor.constraint(equalTo: isFromFilterTransactionsHistoryBackgroundView.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: isFromFilterTransactionsHistoryBackgroundView.trailingAnchor, constant: -0),
            tableView.bottomAnchor.constraint(equalTo: isFromFilterTransactionsHistoryBackgroundView.bottomAnchor, constant: -0),
            stackView.topAnchor.constraint(equalTo: isFromFilterTransactionsHistoryBackgroundView.topAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: isFromFilterTransactionsHistoryBackgroundView.trailingAnchor, constant: -0),
            stackView.leadingAnchor.constraint(equalTo: isFromFilterTransactionsHistoryBackgroundView.leadingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: isFromFilterTransactionsHistoryBackgroundView.bottomAnchor, constant: -0)
        ])
        
        NSLayoutConstraint.activate([
            transactionsDetailsBackgroundView.topAnchor.constraint(equalTo: isFromFilterImageButton.bottomAnchor, constant: 12),
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
            transationDetailsIDLabel.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 25),
            transationDetailsIDLabel.trailingAnchor.constraint(equalTo: transationIDcopyButton.leadingAnchor, constant: -15),
            transationDetailsIDLabel.heightAnchor.constraint(equalToConstant: 50),
            transationDetailsIDLabel.centerYAnchor.constraint(equalTo: transationIDcopyButton.centerYAnchor),
            transationIDcopyButton.topAnchor.constraint(equalTo: transationDetailsTitleLabel.bottomAnchor, constant: 18),
            transationIDcopyButton.trailingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.trailingAnchor, constant: -23),
            transationIDcopyButton.widthAnchor.constraint(equalToConstant: 16),
            transationIDcopyButton.heightAnchor.constraint(equalToConstant: 16),
            lineBackgroundView3.topAnchor.constraint(equalTo: transationDetailsIDLabel.bottomAnchor, constant: 14),
            lineBackgroundView3.trailingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.trailingAnchor, constant: -23),
            lineBackgroundView3.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 23),
            lineBackgroundView3.heightAnchor.constraint(equalToConstant: 1),
            dateDetailsTitleLabel.topAnchor.constraint(equalTo: lineBackgroundView3.bottomAnchor, constant: 14),
            dateDetailsTitleLabel.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 25),
            dateDetailsIDLabel.trailingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.trailingAnchor, constant: -23),
            dateDetailsIDLabel.centerYAnchor.constraint(equalTo: dateDetailsTitleLabel.centerYAnchor),
            lineBackgroundView4.topAnchor.constraint(equalTo: dateDetailsIDLabel.bottomAnchor, constant: 14),
            lineBackgroundView4.trailingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.trailingAnchor, constant: -23),
            lineBackgroundView4.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 23),
            lineBackgroundView4.heightAnchor.constraint(equalToConstant: 1),
            heightDetailsTitleLabel.topAnchor.constraint(equalTo: lineBackgroundView4.bottomAnchor, constant: 14),
            heightDetailsTitleLabel.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 25),
            heightDetailsIDLabel.trailingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.trailingAnchor, constant: -23),
            heightDetailsIDLabel.centerYAnchor.constraint(equalTo: heightDetailsTitleLabel.centerYAnchor),
            lineBackgroundView5.topAnchor.constraint(equalTo: heightDetailsIDLabel.bottomAnchor, constant: 14),
            lineBackgroundView5.trailingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.trailingAnchor, constant: -23),
            lineBackgroundView5.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 23),
            lineBackgroundView5.heightAnchor.constraint(equalToConstant: 1),
            amountDetailsTitleLabel.topAnchor.constraint(equalTo: lineBackgroundView5.bottomAnchor, constant: 14),
            amountDetailsTitleLabel.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 25),
            amountDetailsIDLabel.trailingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.trailingAnchor, constant: -23),
            amountDetailsIDLabel.centerYAnchor.constraint(equalTo: amountDetailsTitleLabel.centerYAnchor),
            lineBackgroundView6.topAnchor.constraint(equalTo: amountDetailsIDLabel.bottomAnchor, constant: 14),
            lineBackgroundView6.trailingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.trailingAnchor, constant: -23),
            lineBackgroundView6.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 23),
            lineBackgroundView6.heightAnchor.constraint(equalToConstant: 1),
            recipientAddressDetailsTitleLabel.topAnchor.constraint(equalTo: lineBackgroundView6.bottomAnchor, constant: 14),
            recipientAddressDetailsTitleLabel.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 25),
            recipientAddressDetailsTitleLabel.trailingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.trailingAnchor, constant: -0),
            recipientAddressDetailsIDLabel.leadingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.leadingAnchor, constant: 25),
            recipientAddressDetailsIDLabel.trailingAnchor.constraint(equalTo: recipientAddresscopyButton.leadingAnchor, constant: -15),
            recipientAddressDetailsIDLabel.heightAnchor.constraint(equalToConstant: 50),
            recipientAddressDetailsIDLabel.centerYAnchor.constraint(equalTo: recipientAddresscopyButton.centerYAnchor),
            recipientAddresscopyButton.topAnchor.constraint(equalTo: recipientAddressDetailsTitleLabel.bottomAnchor, constant: 18),
            recipientAddresscopyButton.trailingAnchor.constraint(equalTo: transactionsDetailsBackgroundView.trailingAnchor, constant: -23),
            recipientAddresscopyButton.widthAnchor.constraint(equalToConstant: 16),
            recipientAddresscopyButton.heightAnchor.constraint(equalToConstant: 16),
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
        self.fromDateTextField.datePicker(target: self,
                                    doneAction: #selector(fromdoneAction),
                                    cancelAction: #selector(fromcancelAction),
                                    datePickerMode: .date)
        self.toDateTextField.datePicker(target: self,
                                  doneAction: #selector(todoneAction),
                                  cancelAction: #selector(tocancelAction),
                                  datePickerMode: .date)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        isCurrencyNameTitleLabel.layer.cornerRadius = isCurrencyNameTitleLabel.frame.height/2
        isFromFilterImageButton.layer.cornerRadius = isFromFilterImageButton.frame.height/2
        cancelButton.layer.cornerRadius = cancelButton.frame.height/2
        okButton.layer.cornerRadius = okButton.frame.height/2
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
    
    // MARK: - Navigation
    @objc func settingsOptionTapped() {
        let vc = WalletSettingsNewVC()
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func isFromFilterImageButtonTapped(_ sender: UIButton){
        isFromFilterImageButton.isSelected = !isFromFilterImageButton.isSelected
        if isFromFilterImageButton.isSelected {
            filterStackView.isHidden = false
            lineBackgroundView.isHidden = false
            isFromFilterImageButton.backgroundColor = UIColor(hex: 0xEBEBEB)
            isFromFilterImageButton.tintColor = UIColor.black
            isFromFilterImageButton.setImage(UIImage(named: "ic_funnel_black"), for: .normal)
        }else{
            filterStackView.isHidden = true
            lineBackgroundView.isHidden = true
            isFromFilterImageButton.backgroundColor = .clear
            isFromFilterImageButton.tintColor = UIColor.white
            isFromFilterImageButton.setImage(UIImage(named: "ic_Filter_New"), for: .normal)
        }
    }
    
    @objc func isFromScanButtonTapped(_ sender: UIButton){
        let vc = ScanNewVC()
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func transationIDcopyButtonTapped(_ sender: UIButton){
        
    }
    
    @objc func isFromSendButtonTapped(_ sender: UIButton){
        let vc = WalletSendNewVC()
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func isFromReceiveButtonTapped(_ sender: UIButton){
        let vc = WalletReceiveNewVC()
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func isFromReConnectButtonTapped(_ sender: UIButton){
        
    }
    
    @objc func recipientAddresscopyButtonTapped(_ sender: UIButton){
        
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton){
        backgroundBlerView.isHidden = true
        selectDateRangePopUpbackgroundView.isHidden = true
    }
    
    @objc func okButtonTapped(_ sender: UIButton){
        backgroundBlerView.isHidden = true
        selectDateRangePopUpbackgroundView.isHidden = true
    }
    
    @objc func backImageButtonTapped(_ sender: UIButton){
        walletSyncingBackgroundView.isHidden = true
        noTransactionsYetBackgroundView.isHidden = true
        isFromFilterTransactionsHistoryBackgroundView.isHidden = false
        transactionsDetailsBackgroundView.isHidden = true
    }
    
    @objc func incomingButtonTapped(_ sender: UIButton){
        incomingButton.isSelected = !incomingButton.isSelected
        if incomingButton.isSelected {
            let image = UIImage(named: "ic_Check_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0))
            incomingButton.setImage(image, for: .normal)
        }else{
            let image = UIImage(named: "ic_Uncheck_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0))
            incomingButton.setImage(image, for: .normal)
        }
    }
    
    @objc func outgoingButtonTapped(_ sender: UIButton){
        outgoingButton.isSelected = !outgoingButton.isSelected
        if outgoingButton.isSelected {
            let image = UIImage(named: "ic_Check_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0))
            outgoingButton.setImage(image, for: .normal)
        }else{
            let image = UIImage(named: "ic_Uncheck_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0))
            outgoingButton.setImage(image, for: .normal)
        }
    }
    
    @objc func byDateButtonTapped(_ sender: UIButton){
        backgroundBlerView.isHidden = false
        selectDateRangePopUpbackgroundView.isHidden = false
    }
    
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }else if section == 1{
            return 8
        }else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = TransationHistoryTableCell(style: .default, reuseIdentifier: "TransationHistoryTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            return cell
        }else if indexPath.section == 1 {
            let cell = TransationHistoryTableCell(style: .default, reuseIdentifier: "TransationHistoryTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            return cell
        }else {
            let cell = TransationHistoryTableCell(style: .default, reuseIdentifier: "TransationHistoryTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        walletSyncingBackgroundView.isHidden = true
        noTransactionsYetBackgroundView.isHidden = true
        isFromFilterTransactionsHistoryBackgroundView.isHidden = true
        transactionsDetailsBackgroundView.isHidden = false
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40)
        let footerView = UIView(frame:rect)
        footerView.backgroundColor = .clear
        let label = UILabel()
        label.text = sectionNames[section]
        label.textColor = .white
        label.frame = CGRect(x: 30, y: 5, width: tableView.frame.width - 30, height: 30)
        label.font = Fonts.semiOpenSans(ofSize: 14)
        footerView.addSubview(label)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // Set the height of the header view as needed
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
        imageView.image = UIImage(named: "ic_receive_New 1", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var balanceAmountLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.boldOpenSans(ofSize: 15)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "0.6 BDX"
        return result
    }()
    lazy var dateLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "10-Feb-2022"
        return result
    }()
    lazy var isFromSendandReceiveLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
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
        imageView.image = UIImage(named: "ic_back_New", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
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
        backGroundView.addSubview(isFromSendandReceiveLabel)
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            directionLogoImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 24),
            directionLogoImage.widthAnchor.constraint(equalToConstant: 24),
            directionLogoImage.heightAnchor.constraint(equalToConstant: 24),
            directionLogoImage.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            directionLogoImage.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 20),
            directionLogoImage.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -20),
            balanceAmountLabel.leadingAnchor.constraint(equalTo: directionLogoImage.trailingAnchor, constant: 13),
            balanceAmountLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: -10),
            dateLabel.leadingAnchor.constraint(equalTo: directionLogoImage.trailingAnchor, constant: 13),
            dateLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: 10),
            arrowImage.heightAnchor.constraint(equalToConstant: 10),
            arrowImage.widthAnchor.constraint(equalToConstant: 10),
            arrowImage.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -25),
            arrowImage.centerYAnchor.constraint(equalTo: directionLogoImage.centerYAnchor),
            isFromSendandReceiveLabel.trailingAnchor.constraint(equalTo: arrowImage.leadingAnchor, constant: -10),
            isFromSendandReceiveLabel.centerYAnchor.constraint(equalTo: arrowImage.centerYAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
