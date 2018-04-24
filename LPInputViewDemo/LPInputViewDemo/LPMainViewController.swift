//
//  LPMainViewController.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/4/24.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPMainViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
