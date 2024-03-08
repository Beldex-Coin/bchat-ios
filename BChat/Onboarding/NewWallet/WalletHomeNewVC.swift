// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import Alamofire
import BChatUIKit

class WalletHomeNewVC: BaseVC, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate {
    private lazy var topBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 18
        stackView.backgroundColor = Colors.backgroundViewColor2
        return stackView
    }()
    private lazy var isFromProgressStatusLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor.lightGray
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var isCurrencyResultLabel: UILabel = {
        let result = UILabel()
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
        imageView.image = UIImage(named: "ic_no_transactions", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
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
        return result
    }()
    lazy var dateForDetailsPageLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
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
        return result
    }()
    lazy var transationDetailsIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.numberOfLines = 0
        result.translatesAutoresizingMaskIntoConstraints = false
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
    // MAINNET
    var nodeArray = ["explorer.beldex.io:19091","mainnet.beldex.io:29095","publicnode1.rpcnode.stream:29095","publicnode2.rpcnode.stream:29095","publicnode3.rpcnode.stream:29095","publicnode4.rpcnode.stream:29095"] //["149.102.156.174:19095"]
    // TESTNET
//    var nodeArray = ["149.102.156.174:19095"]
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
    var transactionAllarray = [TransactionItem]()
    var transactionSendarray = [TransactionItem]()
    var transactionReceivearray = [TransactionItem]()
    var isFilter = false
    var noTransaction = false
    
    var groupedTransactions : [TransactionItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "My Wallet"
        
        let leftBarItem = UIBarButtonItem(image: UIImage(named: "NavBarBack")!, style: .plain, target: self, action: #selector(isGoingToBChatHomeScreen))
        let rightBarButtonItems2 = [leftBarItem]
        navigationItem.leftBarButtonItem = leftBarItem
        
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "icsettings1_New")!, style: .plain, target: self, action: #selector(settingsOptionTapped))
        let rightBarButtonItems = [rightBarItem]
        navigationItem.rightBarButtonItems = rightBarButtonItems
        
        view.addSubview(topBackgroundView)
        topBackgroundView.addSubview(isFromProgressStatusLabel)
        topBackgroundView.addSubview(isCurrencyResultLabel)
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
            isCurrencyResultLabel.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -18),
            isCurrencyResultLabel.centerYAnchor.constraint(equalTo: isFromProgressStatusLabel.centerYAnchor),
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
            isFromScanButton.heightAnchor.constraint(equalToConstant: 50),
            isFromSendButton.heightAnchor.constraint(equalToConstant: 50),
            isFromReceiveButton.heightAnchor.constraint(equalToConstant: 50),
            isFromReConnectButton.heightAnchor.constraint(equalToConstant: 50),
            isFromScanButton.widthAnchor.constraint(equalToConstant: 50),
            isFromSendButton.widthAnchor.constraint(equalToConstant: 50),
            isFromReceiveButton.widthAnchor.constraint(equalToConstant: 50),
            isFromReConnectButton.widthAnchor.constraint(equalToConstant: 50),
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
            tableView.topAnchor.constraint(equalTo: lineBackgroundView.bottomAnchor, constant: 10),
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
        isFromAllTransationFlag = true
        isFromSendTransationFlag = false
        isFromReceiveTransationFlag = false
        self.incomingButton.isSelected = true
        self.outgoingButton.isSelected = true
        incomingButton.setImage(UIImage(named: "ic_Check_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        outgoingButton.setImage(UIImage(named: "ic_Check_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        UserDefaults.standard.setValue(nil, forKey: "btnclicked")
        
        isFromScanButton.isUserInteractionEnabled = false
        isFromSendButton.isUserInteractionEnabled = false
        // MARK: - Here Conditions based on hidden the view only
        walletSyncingBackgroundView.isHidden = false
        noTransactionsYetBackgroundView.isHidden = true
        isFromFilterTransactionsHistoryBackgroundView.isHidden = true
        transactionsDetailsBackgroundView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(syncWalletData(_:)), name: Notification.Name(rawValue: "syncWallet"), object: nil)
        if BackAPI == true{
            self.SelectedBalance = SaveUserDefaultsData.SelectedBalance
            self.fetchMarketsData(false)
        }
        
        //MARK:- Wallet Syncing func
        if WalletSharedData.sharedInstance.wallet != nil {
            if self.wallet == nil {
                isSyncingUI = true
                syncingIsFromDelegateMethod = false
                self.closeWallet()
                init_syncing_wallet()
            }
        }else {
            init_syncing_wallet()
        }
        
        // randomElement node And Selected Node
        if !SaveUserDefaultsData.SelectedNode.isEmpty {
            randomNodeValue = SaveUserDefaultsData.SelectedNode
        }else{
            randomNodeValue = nodeArray.randomElement()!
        }
        SaveUserDefaultsData.FinalWallet_node = randomNodeValue
        
        //Save Receipent Address fun developed
        if UserDefaults.standard.domainSchemas.isEmpty { }else {
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(reScaneButtonTapped(_:)), name: Notification.Name(rawValue: "reScaneButtonAction"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reconnectButtonTapped(_:)), name: Notification.Name(rawValue: "reconnectButtonAction"), object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        isFromFilterImageButton.layer.cornerRadius = isFromFilterImageButton.frame.height/2
        cancelButton.layer.cornerRadius = cancelButton.frame.height/2
        okButton.layer.cornerRadius = okButton.frame.height/2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        incomingButton.setImage(UIImage(named: "ic_Check_box_white"), for: .normal)
        outgoingButton.setImage(UIImage(named: "ic_Check_box_white"), for: .normal)
        UserDefaults.standard.setValue(nil, forKey: "btnclicked")
        
        self.noTransaction = false
        self.isFilter = false
        if let datePickerView = self.toDateTextField.inputView as? UIDatePicker {
            datePickerView.minimumDate = nil
        }
        filteredAllTransactionarray = []
        filteredOutgoingTransactionarray = []
        filteredIncomingTransactionarray = []
        
        walletSyncingBackgroundView.isHidden = false
        noTransactionsYetBackgroundView.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isIdleTimerDisabled = true
        incomingButton.setImage(UIImage(named: "ic_Check_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        outgoingButton.setImage(UIImage(named: "ic_Check_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        if BackAPI == true{
            self.closeWallet()
            init_syncing_wallet()
            self.SelectedBalance = SaveUserDefaultsData.SelectedBalance
            self.fetchMarketsData(false)
        }
        if UserDefaults.standard.domainSchemas.isEmpty {}else {
            hashArray = UserDefaults.standard.domainSchemas
        }
        // randomElement node And Selected Node
        if !SaveUserDefaultsData.SelectedNode.isEmpty {
            randomNodeValue = SaveUserDefaultsData.SelectedNode
        }else{
            randomNodeValue = nodeArray.randomElement()!
        }
        SaveUserDefaultsData.FinalWallet_node = randomNodeValue
        
        // Selected Currency Code Implement
        if backAPISelectedCurrency == true {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency.uppercased()
            if mainBalance.isEmpty {
                isCurrencyResultLabel.text = "0.00 \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
            }else{
                isCurrencyResultLabel.text = "\(String(format:"%.2f", Double(mainBalance)! * currencyValue)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
            }
        }else {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency.uppercased()
            if mainBalance.isEmpty {
                let fullblnce = "0.00"
                var str = "\(String(format:"%.2f", fullblnce)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                let cs = CharacterSet.init(charactersIn: "-")
                str = str.trimmingCharacters(in: cs)
                isCurrencyResultLabel.text = "\(str)"
            }else{
                if currencyValue != nil {
                    isCurrencyResultLabel.text = "\(String(format:"%.2f", Double(mainBalance)! * currencyValue)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                }
            }
        }
        // Rescan Height Update in userdefaults work
        if backApiRescanVC == true {
            isFromScanButton.isUserInteractionEnabled = false
            isFromSendButton.isUserInteractionEnabled = false
            self.closeWallet()
            init_syncing_wallet()
        }
        filteredAllTransactionarray = []
        filteredOutgoingTransactionarray = []
        filteredIncomingTransactionarray = []
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if SaveUserDefaultsData.SwitchNode == true {
            SaveUserDefaultsData.SwitchNode = false
            self.closeWallet()
            init_syncing_wallet()
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "", message: "Switching Node", preferredStyle: .alert)
                let progressBar = UIProgressView(progressViewStyle: .default)
                progressBar.setProgress(0.0, animated: true)
                progressBar.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
                alert.view.addSubview(progressBar)
                self.present(alert, animated: true, completion: nil)
                var progress: Float = 0.0
                // Do the time critical stuff asynchronously
                DispatchQueue.global(qos: .background).async {
                    repeat {
                        progress += 0.1
                        Thread.sleep(forTimeInterval: 0.25)
                        print (progress)
                        DispatchQueue.main.async(flags: .barrier) {
                            progressBar.setProgress(progress, animated: true)
                        }
                    } while progress < 1.0
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true, completion: nil);
                    }
                }
            }
        }
    }
    
    // MARK: - going To BChat Home
    @objc func isGoingToBChatHomeScreen() {
        let homeVC = HomeVC()
        self.navigationController!.setViewControllers([ homeVC ], animated: true)
    }
    
    // MARK: - Settings Option
    @objc func settingsOptionTapped() {
        let vc = WalletSettingsNewVC()
        navigationController!.pushViewController(vc, animated: true)
    }
    
    //Save Receipent Address fun developed
    func start(hashid:String,array:[RecipientDomainSchema])->(boolvalue:Bool,address:String){
        var boolvalue:Bool = false
        var address:String = ""
        for ar in array{
            let hasid = ar.localhash
            if hashid == hasid{
                boolvalue = true
                address = ar.localaddress
                return (boolvalue,address)
            }else{
                boolvalue = false
            }
        }
        return (boolvalue,address)
    }
    
    //syncWalletData
    @objc func syncWalletData(_ notification: Notification) {
        self.closeWallet()
        init_syncing_wallet()
    }
    
    // MARK: - Wallet
    //MARK:- Wallet func Connect Deamon
    func init_syncing_wallet() {
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            isFromScanButton.isUserInteractionEnabled = false
            isFromSendButton.isUserInteractionEnabled = false
            beldexBalanceLabel.text = "-.---"
            isCurrencyResultLabel.text = "0.00 USD"
            self.syncedflag = false
            conncetingState.value = true
            walletSyncingBackgroundView.isHidden = false
            noTransactionsYetBackgroundView.isHidden = true
            isFromProgressStatusLabel.textColor = Colors.bchatButtonColor
            isFromProgressStatusLabel.text = "Loading Wallet ..."
            let username = SaveUserDefaultsData.NameForWallet
            let pwd = SaveUserDefaultsData.israndomUUIDPassword
            WalletService.shared.openWallet(username, password: pwd) { [weak self] (result) in
                WalletSharedData.sharedInstance.wallet = nil
                DispatchQueue.main.async {
                    self?.isFromScanButton.isUserInteractionEnabled = false
                    self?.isFromSendButton.isUserInteractionEnabled = false
                }
                guard let strongSelf = self else { return }
                switch result {
                case .success(let wallet):
                    strongSelf.wallet = wallet
                    WalletSharedData.sharedInstance.wallet = wallet
                    strongSelf.connect(wallet: wallet)
                case .failure(_):
                    DispatchQueue.main.async {
                        strongSelf.refreshState.value = true
                        strongSelf.conncetingState.value = false
                        strongSelf.isFromProgressStatusLabel.textColor = .red
                        strongSelf.isFromProgressStatusLabel.text = "Failed to Connect"
                        self!.syncedflag = false
                        self!.walletSyncingBackgroundView.isHidden = false
                        self!.noTransactionsYetBackgroundView.isHidden = true
                    }
                }
            }
        } else {
            self.showToastMsg(message: "Please check your internet connection", seconds: 1.0)
        }
    }

    func connect(wallet: BDXWallet) {
        if !connecting {
            self.syncedflag = false
            self.conncetingState.value = true
            DispatchQueue.main.async {
                self.walletSyncingBackgroundView.isHidden = false
                self.noTransactionsYetBackgroundView.isHidden = true
                self.isFromProgressStatusLabel.textColor = Colors.bchatButtonColor
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
                    }else {
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
                    self.isFromProgressStatusLabel.textColor = .red
                    self.isFromProgressStatusLabel.text = "Failed to Connect"
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
                            self.isFromProgressStatusLabel.textColor = Colors.bchatButtonColor
                            self.isFromProgressStatusLabel.text = statusText
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
                        self.isFromProgressStatusLabel.textColor = Colors.bchatButtonColor
                        self.isFromProgressStatusLabel.text = statusText
                    }
                }
            }
        } else {
            self.isFromProgressStatusLabel.textColor = .red
            self.isFromProgressStatusLabel.text = "Check your internet"
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
        progressView.progress = 1
        syncedflag = true
        isFromScanButton.isUserInteractionEnabled = true
        isFromSendButton.isUserInteractionEnabled = true
        self.isFromProgressStatusLabel.textColor = Colors.bchatButtonColor
        if self.backApiRescanVC == true{
            self.isFromProgressStatusLabel.text = "Connecting..."
            walletSyncingBackgroundView.isHidden = false
            noTransactionsYetBackgroundView.isHidden = true
        }else {
            self.isFromProgressStatusLabel.text = "Synchronized 100%"
            beldexLogoImg.image = UIImage(named: "ic_beldex_green")
            walletSyncingBackgroundView.isHidden = true
            if self.transactionAllarray.count == 0 {
                noTransactionsYetBackgroundView.isHidden = false
                isFromFilterTransactionsHistoryBackgroundView.isHidden = true
            }else {
                noTransactionsYetBackgroundView.isHidden = true
                isFromFilterTransactionsHistoryBackgroundView.isHidden = false
            }
        }
        self.tableView.reloadData()
        WalletSharedData.sharedInstance.wallet = nil
    }
    
    //MARK:- Balance currency conversion
    private func reloadData(_ json: [String: [String: Any]]) {
        let xmrAmount = json["beldex"]?[currencyName] as? Double
        if xmrAmount != nil {
            currencyValue = xmrAmount
            //MARK:- Balance currency conversion
            if mainBalance.isEmpty {
                self.beldexBalanceLabel.text = "0.00"
            }else {
                if !SaveUserDefaultsData.SelectedDecimal.isEmpty {
                    selectedDecimal = SaveUserDefaultsData.SelectedDecimal
                    if selectedDecimal == "4 - Four (0.0000)"{
                        self.beldexBalanceLabel.text = String(format:"%.4f", Double(mainBalance)!)
                    }else if selectedDecimal == "3 - Three (0.000)"{
                        self.beldexBalanceLabel.text = String(format:"%.3f", Double(mainBalance)!)
                    }else if selectedDecimal == "2 - Two (0.00)"{
                        self.beldexBalanceLabel.text = String(format:"%.2f", Double(mainBalance)!)
                    }else if selectedDecimal == "0 - Zero (0)"{
                        self.beldexBalanceLabel.text = String(format:"%.0f", Double(mainBalance)!)
                    }
                    self.currencyName = SaveUserDefaultsData.SelectedCurrency
                    self.fetchMarketsData(false)
                    self.reloadData([:])
                    if mainBalance.isEmpty{
                        isCurrencyResultLabel.text = "\(String(format:"%.2f", "0.00")) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                    }else {
                        if currencyValue != nil{
                            isCurrencyResultLabel.text = "\(String(format:"%.2f", Double(mainBalance)! * currencyValue)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                        }
                    }
                }else{
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
    
    @objc func isFromFilterImageButtonTapped(_ sender: UIButton){
        self.noTransaction = false
        self.isFilter = false
        filteredAllTransactionarray = []
        filteredOutgoingTransactionarray = []
        filteredIncomingTransactionarray = []
        fromDate = ""
        toDate = ""
        if let datePickerView = self.toDateTextField.inputView as? UIDatePicker {
            datePickerView.minimumDate = nil
        }
        
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
        vc.isFromWallet = true
        vc.wallet = self.wallet
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func transationIDcopyButtonTapped(_ sender: UIButton){
        UIPasteboard.general.string = "\(transationDetailsIDLabel.text!)"
        self.showToastMsg(message: "Copied to Transaction ID", seconds: 1.0)
    }
    
    @objc func isFromSendButtonTapped(_ sender: UIButton){
        let vc = WalletSendNewVC()
        vc.mainBalance = beldexBalanceLabel.text!
        vc.wallet = self.wallet
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func isFromReceiveButtonTapped(_ sender: UIButton){
        let vc = WalletReceiveNewVC()
        navigationController!.pushViewController(vc, animated: true)
    }
    // Rescan and Reconnect popup
    @objc func isFromReConnectButtonTapped(_ sender: UIButton){
        let vc = SyncingOptionPopUpVC()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    //Rescan
    @objc func reScaneButtonTapped(_ notification: Notification){
        self.dismiss(animated: true)
        if syncedflag == true {
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            let vc = RescanNewVC()
            vc.daemonBlockChainHeight = UInt64(isdaemonHeight)
            navigationController!.pushViewController(vc, animated: true)
        }else {
            self.showToastMsg(message: "Can't rescan while wallet is syncing", seconds: 1.0)
        }
    }
    //Reconnect
    @objc func reconnectButtonTapped(_ notification: Notification){
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.closeWallet()
        init_syncing_wallet()
    }
    
    @objc func recipientAddresscopyButtonTapped(_ sender: UIButton){
        UIPasteboard.general.string = "\(recipientAddressDetailsIDLabel.text!)"
        self.showToastMsg(message: "Copied to Recipient Address", seconds: 1.0)
    }

    //By Date Filter Cancel action
    @objc func cancelButtonTapped(_ sender: UIButton){
        backgroundBlerView.isHidden = true
        selectDateRangePopUpbackgroundView.isHidden = true
        
        self.fromcancelAction()
        self.tocancelAction()
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        fromDateTextField.placeholder = "From Date"
        toDateTextField.placeholder = "To Date"
        fromDateTextField.text = ""
        toDateTextField.text = ""
        filteredAllTransactionarray = []
        filteredOutgoingTransactionarray = []
        filteredIncomingTransactionarray = []
        self.isFilter = false
        fromDate = ""
        toDate = ""
        if let datePickerView = self.toDateTextField.inputView as? UIDatePicker {
            datePickerView.minimumDate = nil
        }
        tableView.reloadData()
    }
    //By Date Filter Ok action
    @objc func okButtonTapped(_ sender: UIButton){
        backgroundBlerView.isHidden = true
        selectDateRangePopUpbackgroundView.isHidden = true
        
        self.fromcancelAction()
        self.tocancelAction()
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        filteredAllTransactionarray = []
        filteredOutgoingTransactionarray = []
        filteredIncomingTransactionarray = []
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
                    for element in transactionSendarray {
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
                                if ListDate >= FromDate && ListDate <= ToDate{ //
//                                    filteredOutgoingTransactionarray.append(element)
                                }
                            }
                        }
                    }
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
                    for element in transactionReceivearray {
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
                                if ListDate >= FromDate && ListDate <= ToDate{ //
//                                    filteredIncomingTransactionarray.append(element)
                                }
                            }
                        }
                    }
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
                for element in transactionAllarray {
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
                            if ListDate >= FromDate && ListDate <= ToDate{ //
//                                filteredAllTransactionarray.append(element)
                            }
                        }
                    }
                }
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
    
    @objc func backImageButtonTapped(_ sender: UIButton){
        walletSyncingBackgroundView.isHidden = true
        noTransactionsYetBackgroundView.isHidden = true
        isFromFilterTransactionsHistoryBackgroundView.isHidden = false
        transactionsDetailsBackgroundView.isHidden = true
    }
    
    @objc func incomingButtonTapped(_ sender: UIButton){
        incomingButton.isSelected = !incomingButton.isSelected
        self.filterTransaction()
    }
    
    @objc func outgoingButtonTapped(_ sender: UIButton){
        outgoingButton.isSelected = !outgoingButton.isSelected
        self.filterTransaction()
    }
    
    func filterTransaction() {
        if self.incomingButton.isSelected {
            incomingButton.setImage(UIImage(named: "ic_Check_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        } else {
            incomingButton.setImage(UIImage(named: "ic_Uncheck_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        }
        
        if self.outgoingButton.isSelected {
            outgoingButton.setImage(UIImage(named: "ic_Check_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        } else {
            outgoingButton.setImage(UIImage(named: "ic_Uncheck_box_white")?.scaled(to: CGSize(width: 20.0, height: 20.0)), for: .normal)
        }
        
        self.noTransaction = false
        self.isFilter = false
        fromDate = ""
        toDate = ""
        if let datePickerView = self.toDateTextField.inputView as? UIDatePicker {
            datePickerView.minimumDate = nil
        }
        filteredAllTransactionarray = []
        filteredOutgoingTransactionarray = []
        filteredIncomingTransactionarray = []
        
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
        
        //no
        if !self.incomingButton.isSelected && !self.outgoingButton.isSelected {
            self.noTransaction = true
            noTransactionsYetBackgroundView.isHidden = false
//            isFromFilterTransactionsHistoryBackgroundView.isHidden = true
        }
        self.tableView.reloadData()
    }
    
    @objc func byDateButtonTapped(_ sender: UIButton){
        backgroundBlerView.isHidden = false
        selectDateRangePopUpbackgroundView.isHidden = false
        fromDate = ""
        toDate = ""
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionAllarray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.noTransaction {
            return 0
        }
        if isFromAllTransationFlag == true {
            if self.isFilter {
                if filteredAllTransactionarray.count == 0 {
                    noTransactionsYetBackgroundView.isHidden = false
                    isFromFilterTransactionsHistoryBackgroundView.isHidden = true
                }
                return filteredAllTransactionarray.count
            } else {
                if transactionAllarray.count == 0 {
                    noTransactionsYetBackgroundView.isHidden = false
                    isFromFilterTransactionsHistoryBackgroundView.isHidden = true
                }
                return transactionAllarray.count
            }
        }else if isFromSendTransationFlag == true {
            if self.isFilter {
                if filteredOutgoingTransactionarray.count == 0 {
                    noTransactionsYetBackgroundView.isHidden = false
                    isFromFilterTransactionsHistoryBackgroundView.isHidden = true
                }
                return filteredOutgoingTransactionarray.count
            } else {
                if transactionSendarray.count == 0 {
                    noTransactionsYetBackgroundView.isHidden = false
                    isFromFilterTransactionsHistoryBackgroundView.isHidden = true
                }
                return transactionSendarray.count
            }
        }else {
            if self.isFilter {
                if filteredIncomingTransactionarray.count == 0 {
                    noTransactionsYetBackgroundView.isHidden = false
                    isFromFilterTransactionsHistoryBackgroundView.isHidden = true
                }
                return filteredIncomingTransactionarray.count
            } else {
                if transactionReceivearray.count == 0 {}
                return transactionReceivearray.count
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
            if filteredAllTransactionarray.count > 0{
                let responceData = filteredAllTransactionarray[indexPath.row]
                let timeInterval  = responceData.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                cell.dateLabel.text = dateString
                cell.balanceAmountLabel.text = Double(responceData.amount)!.removeZerosFromEnd()
                if responceData.direction != BChat_Messenger.TransactionDirection.received{
                    cell.isFromSendandReceiveLabel.text = "Send"
                    cell.directionLogoImage.image = UIImage(named: "ic_send_icon")
                }else{
                    cell.isFromSendandReceiveLabel.text = "Received"
                    cell.directionLogoImage.image = UIImage(named: "ic_receive")
                }
            }else{
                let responceData = transactionAllarray[indexPath.row]
                let timeInterval  = responceData.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                cell.dateLabel.text = dateString
                cell.balanceAmountLabel.text = Double(responceData.amount)!.removeZerosFromEnd()
                if responceData.direction != BChat_Messenger.TransactionDirection.received{
                    cell.isFromSendandReceiveLabel.text = "Send"
                    cell.directionLogoImage.image = UIImage(named: "ic_send_icon")
                }else{
                    cell.isFromSendandReceiveLabel.text = "Received"
                    cell.directionLogoImage.image = UIImage(named: "ic_receive")
                }
            }
        }else if isFromSendTransationFlag == true {
            if filteredOutgoingTransactionarray.count > 0{
                let responceData = filteredOutgoingTransactionarray[indexPath.row]
                let timeInterval  = responceData.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                cell.dateLabel.text = dateString
                cell.balanceAmountLabel.text = Double(responceData.amount)!.removeZerosFromEnd()
                if responceData.direction != BChat_Messenger.TransactionDirection.sent{
                    cell.isFromSendandReceiveLabel.text = "Send"
                    cell.directionLogoImage.image = UIImage(named: "ic_send_icon")
                }else{
                    cell.isFromSendandReceiveLabel.text = "Send"
                    cell.directionLogoImage.image = UIImage(named: "ic_send_icon")
                }
            } else {
                let responceData = transactionSendarray[indexPath.row]
                let timeInterval  = responceData.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                cell.dateLabel.text = dateString
                cell.balanceAmountLabel.text = Double(responceData.amount)!.removeZerosFromEnd()
                if responceData.direction != BChat_Messenger.TransactionDirection.sent{
                    cell.isFromSendandReceiveLabel.text = "Send"
                    cell.directionLogoImage.image = UIImage(named: "ic_send_icon")
                }else{
                    cell.isFromSendandReceiveLabel.text = "Send"
                    cell.directionLogoImage.image = UIImage(named: "ic_send_icon")
                }
            }
        }else {
            if filteredIncomingTransactionarray.count > 0{
                let responceData = filteredIncomingTransactionarray[indexPath.row]
                let timeInterval  = responceData.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                cell.dateLabel.text = dateString
                cell.balanceAmountLabel.text = Double(responceData.amount)!.removeZerosFromEnd()
                if responceData.direction != BChat_Messenger.TransactionDirection.received{
                    cell.isFromSendandReceiveLabel.text = "Received"
                    cell.directionLogoImage.image = UIImage(named: "ic_receive")
                }else{
                    cell.isFromSendandReceiveLabel.text = "Received"
                    cell.directionLogoImage.image = UIImage(named: "ic_receive")
                }
            } else {
                let responceData = transactionReceivearray[indexPath.row]
                let timeInterval  = responceData.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                cell.dateLabel.text = dateString
                cell.balanceAmountLabel.text = Double(responceData.amount)!.removeZerosFromEnd()
                if responceData.direction != BChat_Messenger.TransactionDirection.received{
                    cell.isFromSendandReceiveLabel.text = "Received"
                    cell.directionLogoImage.image = UIImage(named: "ic_receive")
                }else{
                    cell.isFromSendandReceiveLabel.text = "Received"
                    cell.directionLogoImage.image = UIImage(named: "ic_receive")
                }
            }
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
        
        if isFromAllTransationFlag == true{
            if filteredAllTransactionarray.count > 0{
                let transaction = filteredAllTransactionarray[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                balanceAmountForDetailsPageLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                dateForDetailsPageLabel.text = dateString
                transationDetailsIDLabel.text = transaction.hash
                amountDetailsIDLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                heightDetailsIDLabel.text = "\(transaction.blockHeight)"
                let dateString2 = LongdateFormatter.string(from: date as Date)
                dateDetailsIDLabel.text = dateString2
                //Save Receipent Address fun developed
                let serverhash = transaction.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true{
                    recipientAddressDetailsIDLabel.text = "\(address)"
                }else{
                    recipientAddressDetailsIDLabel.text = "---"
                }
                //Transation Details from Send and Received
                if transaction.direction != BChat_Messenger.TransactionDirection.received{
                    isFromSendDetailsTitleLabel.text = "Send"
                    isFromSendDetailsTitleLabel.textColor = .red
                    directionLogoForDetailsPageImage.image = UIImage(named: "ic_send_icon")
                }else{
                    isFromSendDetailsTitleLabel.text = "Received"
                    isFromSendDetailsTitleLabel.textColor = Colors.greenColor
                    directionLogoForDetailsPageImage.image = UIImage(named: "ic_receive")
                }
            }else{
                let transaction = transactionAllarray[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                balanceAmountForDetailsPageLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                dateForDetailsPageLabel.text = dateString
                transationDetailsIDLabel.text = transaction.hash
                amountDetailsIDLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                heightDetailsIDLabel.text = "\(transaction.blockHeight)"
                let dateString2 = LongdateFormatter.string(from: date as Date)
                dateDetailsIDLabel.text = dateString2
                //Save Receipent Address fun developed
                let serverhash = transaction.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true{
                    recipientAddressDetailsIDLabel.text = "\(address)"
                }else{
                    recipientAddressDetailsIDLabel.text = "---"
                }
                //Transation Details from Send and Received
                if transaction.direction != BChat_Messenger.TransactionDirection.received{
                    isFromSendDetailsTitleLabel.text = "Send"
                    isFromSendDetailsTitleLabel.textColor = .red
                    directionLogoForDetailsPageImage.image = UIImage(named: "ic_send_icon")
                }else{
                    isFromSendDetailsTitleLabel.text = "Received"
                    isFromSendDetailsTitleLabel.textColor = Colors.greenColor
                    directionLogoForDetailsPageImage.image = UIImage(named: "ic_receive")
                }
            }
        }else if isFromSendTransationFlag == true{
            if filteredOutgoingTransactionarray.count > 0{
                let transaction = filteredOutgoingTransactionarray[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                balanceAmountForDetailsPageLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                dateForDetailsPageLabel.text = dateString
                transationDetailsIDLabel.text = transaction.hash
                amountDetailsIDLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                heightDetailsIDLabel.text = "\(transaction.blockHeight)"
                let dateString2 = LongdateFormatter.string(from: date as Date)
                dateDetailsIDLabel.text = dateString2
                //Save Receipent Address fun developed
                let serverhash = transaction.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true{
                    recipientAddressDetailsIDLabel.text = "\(address)"
                }else{
                    recipientAddressDetailsIDLabel.text = "---"
                }
                //Transation Details from Send and Received
                if transaction.direction != BChat_Messenger.TransactionDirection.sent{
                    isFromSendDetailsTitleLabel.text = "Send"
                    isFromSendDetailsTitleLabel.textColor = .red
                    directionLogoForDetailsPageImage.image = UIImage(named: "ic_send_icon")
                }else{
                    isFromSendDetailsTitleLabel.text = "Send"
                    isFromSendDetailsTitleLabel.textColor = .red
                    directionLogoForDetailsPageImage.image = UIImage(named: "ic_send_icon")
                }
            }else{
                let transaction = transactionSendarray[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                balanceAmountForDetailsPageLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                dateForDetailsPageLabel.text = dateString
                transationDetailsIDLabel.text = transaction.hash
                amountDetailsIDLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                heightDetailsIDLabel.text = "\(transaction.blockHeight)"
                let dateString2 = LongdateFormatter.string(from: date as Date)
                dateDetailsIDLabel.text = dateString2
                //Save Receipent Address fun developed
                let serverhash = transaction.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true{
                    recipientAddressDetailsIDLabel.text = "\(address)"
                }else{
                    recipientAddressDetailsIDLabel.text = "---"
                }
                //Transation Details from Send and Received
                if transaction.direction != BChat_Messenger.TransactionDirection.sent{
                    isFromSendDetailsTitleLabel.text = "Send"
                    isFromSendDetailsTitleLabel.textColor = .red
                    directionLogoForDetailsPageImage.image = UIImage(named: "ic_send_icon")
                }else{
                    isFromSendDetailsTitleLabel.text = "Send"
                    isFromSendDetailsTitleLabel.textColor = .red
                    directionLogoForDetailsPageImage.image = UIImage(named: "ic_send_icon")
                }
            }
        }else{
            if filteredIncomingTransactionarray.count > 0{
                let transaction = filteredIncomingTransactionarray[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                balanceAmountForDetailsPageLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                dateForDetailsPageLabel.text = dateString
                transationDetailsIDLabel.text = transaction.hash
                amountDetailsIDLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                heightDetailsIDLabel.text = "\(transaction.blockHeight)"
                let dateString2 = LongdateFormatter.string(from: date as Date)
                dateDetailsIDLabel.text = dateString2
                //Save Receipent Address fun developed
                let serverhash = transaction.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true{
                    recipientAddressDetailsIDLabel.text = "\(address)"
                }else{
                    recipientAddressDetailsIDLabel.text = "---"
                }
                //Transation Details from Send and Received
                if transaction.direction != BChat_Messenger.TransactionDirection.received{
                    isFromSendDetailsTitleLabel.text = "Received"
                    isFromSendDetailsTitleLabel.textColor = Colors.greenColor
                    directionLogoForDetailsPageImage.image = UIImage(named: "ic_receive")
                }else{
                    isFromSendDetailsTitleLabel.text = "Received"
                    isFromSendDetailsTitleLabel.textColor = Colors.greenColor
                    directionLogoForDetailsPageImage.image = UIImage(named: "ic_receive")
                }
            }else{
                let transaction = transactionReceivearray[indexPath.row]
                let timeInterval  = transaction.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateString = dateFormatter.string(from: date as Date)
                balanceAmountForDetailsPageLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                dateForDetailsPageLabel.text = dateString
                transationDetailsIDLabel.text = transaction.hash
                amountDetailsIDLabel.text = "\(Double(transaction.amount)!.removeZerosFromEnd()) BDX"
                heightDetailsIDLabel.text = "\(transaction.blockHeight)"
                let dateString2 = LongdateFormatter.string(from: date as Date)
                dateDetailsIDLabel.text = dateString2
                //Save Receipent Address fun developed
                let serverhash = transaction.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true{
                    recipientAddressDetailsIDLabel.text = "\(address)"
                }else{
                    recipientAddressDetailsIDLabel.text = "---"
                }
                //Transation Details from Send and Received
                if transaction.direction != BChat_Messenger.TransactionDirection.received{
                    isFromSendDetailsTitleLabel.text = "Received"
                    isFromSendDetailsTitleLabel.textColor = Colors.greenColor
                    directionLogoForDetailsPageImage.image = UIImage(named: "ic_receive")
                }else{
                    isFromSendDetailsTitleLabel.text = "Received"
                    isFromSendDetailsTitleLabel.textColor = Colors.greenColor
                    directionLogoForDetailsPageImage.image = UIImage(named: "ic_receive")
                }
            }
        }
        //Hide the Views
        walletSyncingBackgroundView.isHidden = true
        noTransactionsYetBackgroundView.isHidden = true
//        isFromFilterTransactionsHistoryBackgroundView.isHidden = true
        transactionsDetailsBackgroundView.isHidden = false
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40)
        let footerView = UIView(frame:rect)
        footerView.backgroundColor = UIColor(hex: 0x11111A)
        footerView.layer.cornerRadius = 28
        footerView.layer.masksToBounds = true
        footerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        dateFormatter.timeZone = NSTimeZone(name: "Asia/Kolkata") as TimeZone?
        let timeInterval  = transactionAllarray[section].timestamp
        let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
        let dateString = dateFormatter.string(from: date as Date)
        
        let label = UILabel()
        label.text = formatDateString(dateString)
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
    
    func sortAndGroupTransactions() {
//        groupedTransactions = Dictionary(grouping: transactionAllarray, by: { timestampToDate(Int($0.timestamp)) }).values.map { $0 }
        // Reload your table view data
        
        groupedTransactions = transactionAllarray.sorted { $0.timestamp > $1.timestamp }
        for timestmp in groupedTransactions {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            dateFormatter.timeZone = NSTimeZone(name: "Asia/Kolkata") as TimeZone?
            let date = NSDate(timeIntervalSince1970: TimeInterval(timestmp.timestamp))
            let dateString = dateFormatter.string(from: date as Date)
//            print("--Date-->",dateString)
        }
        tableView.reloadData()
    }

    // Helper function to convert timestamp to date (customize based on your needs)
    func timestampToDate(_ timestamp: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy" // Customize the date format
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return dateFormatter.string(from: date)
    }
    
    func formatDateString(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"  // Adjust the format based on your date string
        guard let date = dateFormatter.date(from: dateString) else {
            return "Invalid Date"
        }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "MMM, yyyy"
            return dateFormatter.string(from: date)
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
        imageView.image = UIImage(named: "ic_receive_New 1", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var balanceAmountLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.boldOpenSans(ofSize: 15)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var dateLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
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
                self.isFromProgressStatusLabel.textColor = Colors.bchatButtonColor
                self.isFromProgressStatusLabel.text = statusText
            }
        }
    }
    
    private func postData(balance: String, history: TransactionHistory) {
        let balance_modify = Helper.displayDigitsAmount(balance)
        transactionAllarray = history.all
        transactionSendarray = history.send
        transactionReceivearray = history.receive
        self.mainBalance = balance_modify
        DispatchQueue.main.async { [self] in
            self.transactionAllarray = history.all
            self.transactionSendarray = history.send
            self.transactionReceivearray = history.receive
            if SaveUserDefaultsData.WalletRestoreHeight == "" {
                let lastElementHeight = DateHeight.getBlockHeight.last
                let height = lastElementHeight!.components(separatedBy: ":")
                let restoreHeightempty = UInt64("\(height[1])")!
                self.transactionAllarray = self.transactionAllarray.filter{$0.blockHeight >= restoreHeightempty}
                self.transactionSendarray = self.transactionSendarray.filter{$0.blockHeight >= restoreHeightempty}
                self.transactionReceivearray = self.transactionReceivearray.filter{$0.blockHeight >= restoreHeightempty}
            } else {
                self.transactionAllarray = self.transactionAllarray.filter{$0.blockHeight >= UInt64(SaveUserDefaultsData.WalletRestoreHeight)!}
                self.transactionSendarray = self.transactionSendarray.filter{$0.blockHeight >= UInt64(SaveUserDefaultsData.WalletRestoreHeight)!}
                self.transactionReceivearray = self.transactionReceivearray.filter{$0.blockHeight >= UInt64(SaveUserDefaultsData.WalletRestoreHeight)!}
            }
            if !SaveUserDefaultsData.SelectedDecimal.isEmpty {
                selectedDecimal = SaveUserDefaultsData.SelectedDecimal
                if selectedDecimal == "4 - Four (0.0000)" {
                    self.beldexBalanceLabel.text = String(format:"%.4f", Double(mainBalance)!)
                }else if selectedDecimal == "3 - Three (0.000)" {
                    self.beldexBalanceLabel.text = String(format:"%.3f", Double(mainBalance)!)
                }else if selectedDecimal == "2 - Two (0.00)" {
                    self.beldexBalanceLabel.text = String(format:"%.2f", Double(mainBalance)!)
                }else if selectedDecimal == "0 - Zero (0)" {
                    self.beldexBalanceLabel.text = String(format:"%.0f", Double(mainBalance)!)
                }
            }else {
                self.beldexBalanceLabel.text = String(format:"%.4f", Double(balance_modify)!)
            }
            if SaveUserDefaultsData.SelectedBalance == "Beldex Full Balance" || SaveUserDefaultsData.SelectedBalance == "Beldex Available Balance"{
                if !SaveUserDefaultsData.SelectedDecimal.isEmpty {
                    selectedDecimal = SaveUserDefaultsData.SelectedDecimal
                    if selectedDecimal == "4 - Four (0.0000)" {
                        self.beldexBalanceLabel.text = String(format:"%.4f", Double(mainBalance)!)
                    }else if selectedDecimal == "3 - Three (0.000)" {
                        self.beldexBalanceLabel.text = String(format:"%.3f", Double(mainBalance)!)
                    }else if selectedDecimal == "2 - Two (0.00)" {
                        self.beldexBalanceLabel.text = String(format:"%.2f", Double(mainBalance)!)
                    }else if selectedDecimal == "0 - Zero (0)" {
                        self.beldexBalanceLabel.text = String(format:"%.0f", Double(mainBalance)!)
                    }
                }else {
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
            
//            self.tableView.reloadData()
            sortAndGroupTransactions()
            if self.transactionAllarray.count == 0 {
                noTransactionsYetBackgroundView.isHidden = false
                isFromFilterTransactionsHistoryBackgroundView.isHidden = true
            }else {
                noTransactionsYetBackgroundView.isHidden = true
                isFromFilterTransactionsHistoryBackgroundView.isHidden = false
            }
        }
    }
}

