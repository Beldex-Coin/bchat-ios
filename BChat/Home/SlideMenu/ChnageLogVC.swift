// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class ChnageLogVC: BaseVC, UITableViewDelegate, UITableViewDataSource,ExpandableHeaderViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var sections = [
        Section(genre: "1.0.0",
                movies: ["- Initial release", "- Added changelog"],
                expandable: false),
        Section(genre: "1.1.0",
                movies: ["- Message request implementation", "- Link Preview will be turn on by default", "- Add the images for SwipeActionsConfiguration"],
                expandable: false),
        Section(genre: "1.2.0",
                movies: ["- Call Feature Added", "- Blocked Contact list added", "- Minor Bug Fixes"],
                expandable: false),
        Section(genre: "1.2.1",
                movies: ["- Introduced Report issue feature.",
                         "- Added support for inchat payment card.",
                         "- Added font size customization for Chat.",
                         "- BChat Font changed to standard font 'Open Sans' across all platforms.",
                         "- User won't be allowed to call blocked contacts.",
                         "- Fixed the block pop-up in the conversation screen for unblocked user.",
                         "- Updated validation of seed for restore process.",
                         "- Minor Bug Fixes."],
                expandable: false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "Changelog"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].movies.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (sections[indexPath.section].expandable) {
            return 40
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView()
        header.customInit(title: sections[section].genre, section: section, delegate: self)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell")!
        cell.textLabel?.text = sections[indexPath.section].movies[indexPath.row]
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.font = cell.textLabel?.font.withSize(13)
        return cell
    }
    
    func toggleSection(header: UITableViewHeaderFooterView, section: Int) {
        sections[section].expandable = !sections[section].expandable
        tableView.beginUpdates()
        for i in 0 ..< sections[section].movies.count
        {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates()
    }

}
