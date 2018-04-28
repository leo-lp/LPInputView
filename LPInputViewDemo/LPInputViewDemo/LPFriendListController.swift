//
//  LPFriendListController.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/4/17.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

struct LPFriend {
    let id: Int
    let name: String
}

class LPFriendListController: UITableViewController {
    lazy var friends: [LPFriend] = [LPFriend(id: 100000, name: "鸣人"),
                                    LPFriend(id: 100001, name: "天罚"),
                                    LPFriend(id: 100002, name: "阿罪"),
                                    LPFriend(id: 100003, name: "佐助"),
                                    LPFriend(id: 100004, name: "青龙")]
    
    var selectedBlock: ((LPFriend) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let backButton = UIBarButtonItem(title: "取消",
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonClicked))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = friends[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        selectedBlock?(friends[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
}
