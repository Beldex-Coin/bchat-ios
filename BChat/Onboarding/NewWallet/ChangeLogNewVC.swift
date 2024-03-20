
// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class ChangeLogNewVC: BaseVC, UITableViewDataSource, UITableViewDelegate{
    
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
    var isExpanded: Bool = false
    var selectedRowIndex: Int?
    var versionArray = ["1.0.0","1.1.0","1.2.0","1.2.1","1.3.0","1.3.1","1.3.2","1.3.3","1.4.0"]
    var descArray = ["\u{2022} Initial release\n\u{2022} Added changelog",
                     "\u{2022} Message request implementation\n\u{2022} Link Preview will be turn on by default\n\u{2022} Add the images for SwipeActionsConfiguration",
                     "\u{2022} Call Feature Added\n\u{2022} Blocked Contact list added\n\u{2022} Minor Bug Fixes",
                     "\u{2022} Introduced Report issue feature\n\u{2022} Added support for inchat payment card\n\u{2022} Added font size customization for Chat\n\u{2022} BChat Font changed to standard font 'Open Sans' across all platforms\n\u{2022} User won't be allowed to call blocked contacts\n\u{2022} Fixed the block pop-up in the conversation screen for unblocked user\n\u{2022} Updated validation of seed for restore process\n\u{2022} Minor Bug Fixes",
                     "\u{2022} Wallet Integration Beta release\n\u{2022} Introduced Address book of contacts in Wallet\n\u{2022} Improved UI and Content\n\u{2022} Minor Bug fixes","\u{2022} Feature Pay as you chat\n\u{2022} Fix Crash issues in wallet\n\u{2022} Minor Bug fixes",
                     "\u{2022} Update for Hardfork 18\n\u{2022} Minor bug fixes","\u{2022} Minor bug fixes",
                     "\u{2022} Integrated BNS in BChat\n\u{2022} Minor Bug fixes"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.viewBackgroundColorNew
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Changelog"
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0),
        ])
        
    }
    
    
    // MARK: - Navigation
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return versionArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure cell for expanded state
        if isExpanded, let selectedRowIndex = selectedRowIndex, indexPath.row == selectedRowIndex {
            let cell = ChangeLogTableCell2(style: .default, reuseIdentifier: "ChangeLogTableCell2")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            let logoImage = isLightMode ? "ic_dropdown_changelog_black" : "ic_dropdown_arrowNew"
            cell.expandArrowImage.image = UIImage(named: logoImage)
            cell.titleLabel.text = versionArray[indexPath.row]
            cell.subTitleLabel.text = descArray[indexPath.row]
            cell.expandArrowImage.tag = indexPath.row
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandArrowTapped(_:)))
            cell.expandArrowImage.addGestureRecognizer(tapGestureRecognizer)
            cell.expandArrowImage.isUserInteractionEnabled = true
            return cell
        } else {
            // Configure cell for normal state
            let cell = ChangeLogTableCell(style: .default, reuseIdentifier: "ChangeLogTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            let logoImage = isLightMode ? "ic_down_black_changelog" : "ic_downArrow_Changelog"
            cell.arrowImage.image = UIImage(named: logoImage)
            cell.titleLabel.text = versionArray[indexPath.row]
            cell.arrowImage.tag = indexPath.row
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(arrowTapped(_:)))
            cell.arrowImage.addGestureRecognizer(tapGestureRecognizer)
            cell.arrowImage.isUserInteractionEnabled = true
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if isExpanded, let selectedRowIndex = selectedRowIndex, indexPath.row == selectedRowIndex {
            return UITableView.automaticDimension
        } else {
            return UITableView.automaticDimension
        }
    }
    
    @objc func expandArrowTapped(_ sender: UITapGestureRecognizer) {
        if let index = sender.view?.tag {
            isExpanded.toggle()
            selectedRowIndex = isExpanded ? index : nil
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    @objc func arrowTapped(_ sender: UITapGestureRecognizer) {
        if let index = sender.view?.tag {
            isExpanded.toggle()
            selectedRowIndex = isExpanded ? index : nil
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
}

class ChangeLogTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cellBackgroundColorForChangeLog
        view.layer.borderColor = Colors.borderColor.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        return view
    }()
    lazy var arrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_down_black_changelog" : "ic_downArrow_Changelog"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var circularView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_fullCircle", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(circularView)
        backGroundView.addSubview(titleLabel)
        backGroundView.addSubview(arrowImage)
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            circularView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 25),
            circularView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -25),
            circularView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 15),
            circularView.widthAnchor.constraint(equalToConstant: 8),
            circularView.heightAnchor.constraint(equalToConstant: 8),
            circularView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: circularView.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            arrowImage.widthAnchor.constraint(equalToConstant: 22),
            arrowImage.heightAnchor.constraint(equalToConstant: 22),
            arrowImage.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -14),
            arrowImage.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
        ])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ChangeLogTableCell2: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cellBackgroundColorForChangeLog
        view.layer.borderColor = Colors.borderColor.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        return view
    }()
    lazy var expandArrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_down_black_changelog" : "ic_downArrow_Changelog"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var circularView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_fullCircle", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    let subTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        // Set up attributed text with space before the text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacingBefore = 10  // Adjust the value for the desired top space
        let attributedText = NSAttributedString(
            string: " ",
            attributes: [
                //                .font: result.font,
                //                .foregroundColor: result.textColor,
                .paragraphStyle: paragraphStyle
            ]
        )
        result.attributedText = attributedText
        return result
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(circularView)
        backGroundView.addSubview(titleLabel)
        backGroundView.addSubview(expandArrowImage)
        backGroundView.addSubview(subTitleLabel)
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            circularView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 25),
            circularView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 15),
            circularView.widthAnchor.constraint(equalToConstant: 8),
            circularView.heightAnchor.constraint(equalToConstant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: circularView.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: circularView.centerYAnchor),
            expandArrowImage.widthAnchor.constraint(equalToConstant: 22),
            expandArrowImage.heightAnchor.constraint(equalToConstant: 22),
            expandArrowImage.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -14),
            expandArrowImage.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 18),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -18),
            subTitleLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -25),
            
        ])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

