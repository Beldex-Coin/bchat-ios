// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewBlockedContactVC: BaseVC, UITableViewDataSource, UITableViewDelegate {

    
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    private lazy var bottomButtonView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private lazy var unblockButton: UIButton = {
        let button = UIButton()
        button.setTitle("Unblock selected", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x282836)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(UIColor(hex: 0x00BD40), for: .normal)
        button.addTarget(self, action: #selector(unblockButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    var isSelectionEnable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Blocked contacts", style: .plain, target: nil, action: nil)

        self.updateRighBarButton(isSelectionEnable: self.isSelectionEnable)
        
        view.addSubview(tableView)
        view.addSubview(bottomButtonView)
        bottomButtonView.addSubview(unblockButton)
            
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14.0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomButtonView.topAnchor, constant: 0).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.register(NewBlockContactTableViewCell.self, forCellReuseIdentifier: "NewBlockContactTableViewCell")
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        
        NSLayoutConstraint.activate([
        bottomButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        bottomButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
        bottomButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
        bottomButtonView.heightAnchor.constraint(equalToConstant: 88),
        
        unblockButton.centerYAnchor.constraint(equalTo: bottomButtonView.centerYAnchor),
        unblockButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
        unblockButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
        unblockButton.heightAnchor.constraint(equalToConstant: 58),
        ])
    }
    

    func updateRighBarButton(isSelectionEnable : Bool){
        var rightBarButtonItems: [UIBarButtonItem] = []
        if isSelectionEnable {
            let selectionButton = UIBarButtonItem(image: UIImage(named: "ic_check_all_enable")!, style: .plain, target: self, action: #selector(selectionButtonTapped))
            rightBarButtonItems.append(selectionButton)
        } else {
            let selectionButton = UIBarButtonItem(image: UIImage(named: "ic_check_all")!, style: .plain, target: self, action: #selector(selectionButtonTapped))
            rightBarButtonItems.append(selectionButton)
        }
        self.bottomButtonView.isHidden = !isSelectionEnable
        navigationItem.rightBarButtonItems = rightBarButtonItems
        
    }

    
    
    
    
    // MARK: Button Actions :-
    @objc private func unblockButtonTapped() {
        
    }
    
    @objc func selectionButtonTapped() {
        self.isSelectionEnable = !self.isSelectionEnable
        self.updateRighBarButton(isSelectionEnable: self.isSelectionEnable)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 14
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewBlockContactTableViewCell") as! NewBlockContactTableViewCell
        
        if self.isSelectionEnable {
            cell.selectionButton.isHidden = false
            cell.unblockButton.isHidden = true
        } else {
            cell.selectionButton.isSelected = false
            cell.selectionButton.isHidden = true
            cell.unblockButton.isHidden = false
        }
        
        return cell
    }
    
    
    
    

}