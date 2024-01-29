// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class WalletNodeListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    private lazy var refreshButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString(NSLocalizedString("REFRESH_BUTTON_NEW", comment: ""), comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 14)
        result.addTarget(self, action: #selector(refreshButtonAction), for: UIControl.Event.touchUpInside)
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.setTitleColor(.white, for: .normal)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var addNodeButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString(NSLocalizedString("ADD_NODE_BUTTON_NEW", comment: ""), comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 14)
        result.addTarget(self, action: #selector(addNodeButtonAction), for: UIControl.Event.touchUpInside)
        result.backgroundColor = Colors.greenColor
        result.setTitleColor(UIColor.white, for: .normal)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var buttonStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ refreshButton, addNodeButton ])
        result.axis = .horizontal
        result.spacing = 15
        result.distribution = .fillEqually
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    //MAINNET
    var nodeArray = ["explorer.beldex.io:19091","mainnet.beldex.io:29095","publicnode1.rpcnode.stream:29095","publicnode2.rpcnode.stream:29095","publicnode3.rpcnode.stream:29095","publicnode4.rpcnode.stream:29095"]//["149.102.156.174:19095"]
    //TESTNET
//    var nodeArray = ["149.102.156.174:19095"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x111119)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Nodes"
        
        view.addSubview(tableView)
        view.addSubview(buttonStackView)
        refreshButton.addRightIcon(image: UIImage(named: "ic_refresh_new")!.withRenderingMode(.alwaysTemplate))
        refreshButton.tintColor = .white
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            buttonStackView.heightAnchor.constraint(equalToConstant: 54),
            buttonStackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshButton.layer.cornerRadius = refreshButton.frame.height/2
        addNodeButton.layer.cornerRadius = addNodeButton.frame.height/2
    }
    
    // MARK: - Navigation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NodeListTableCell(style: .default, reuseIdentifier: "NodeListTableCell")
        cell.backgroundColor = .clear
        cell.nodeNameTitleLabel.text = nodeArray[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NodeListTableCell
        cell.backGroundView.layer.borderWidth = 1.5
        cell.backGroundView.layer.borderColor = Colors.greenColor.cgColor
        cell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NodeListTableCell
        cell.backGroundView.layer.borderWidth = 0
        cell.backGroundView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func refreshButtonAction(_ sender: UIButton){
        
    }
    
    @objc func addNodeButtonAction(_ sender: UIButton){
        
    }
    
}
class NodeListTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        view.layer.cornerRadius = 16
        return view
    }()
    lazy var circularView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_fullCircle", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var nodeNameTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.greenColor
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var nodeIPLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Testing IP : 43.204.199.139.."
        return result
    }()
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(circularView)
        backGroundView.addSubview(nodeNameTitleLabel)
        backGroundView.addSubview(nodeIPLabel)
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            circularView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 28),
            circularView.widthAnchor.constraint(equalToConstant: 10),
            circularView.heightAnchor.constraint(equalToConstant: 10),
            circularView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            nodeNameTitleLabel.leadingAnchor.constraint(equalTo: circularView.trailingAnchor, constant: 20),
            nodeNameTitleLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: -13),
            nodeNameTitleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 18),
            nodeIPLabel.leadingAnchor.constraint(equalTo: circularView.trailingAnchor, constant: 20),
            nodeIPLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: 13),
            nodeIPLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -18),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
