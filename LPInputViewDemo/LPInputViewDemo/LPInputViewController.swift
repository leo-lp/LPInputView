//
//  LPInputViewController.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit
import LPInputView

class LPInputViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    lazy var inputBar: LPInputView = {
        let config = LPInputViewConfig()
        let rect = CGRect(x: 0, y: 0, width: view.frame.width, height: 0)
        return LPInputView(frame: rect, config: config)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.borderColor = UIColor.red.cgColor
        tableView.layer.borderWidth = 1
        
        inputBar.layer.borderColor = UIColor.blue.cgColor
        inputBar.layer.borderWidth = 1
        
        view.addSubview(inputBar)
    }

}

extension LPInputViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LPInputViewCell", for: indexPath)
        cell.textLabel?.text = "cell row = \(indexPath.row)"
        return cell
    }
}
