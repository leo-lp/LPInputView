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
        let rect = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        return LPInputView(frame: rect, config: LPInputViewConfig())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.borderColor = UIColor.red.cgColor
        tableView.layer.borderWidth = 1
        
        inputBar.layer.borderColor = UIColor.blue.cgColor
        inputBar.layer.borderWidth = 5
        
        view.addSubview(inputBar)
        
        let right = UIBarButtonItem(barButtonSystemItem: .done,
                                    target: self,
                                    action: #selector(rightButtonClicked))
        navigationItem.rightBarButtonItem = right
    }
    
    @objc func rightButtonClicked(_ sender: UIBarButtonItem) {
        inputBar.endEditing()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
