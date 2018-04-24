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
        
        inputBar.delegate = self
        view.addSubview(inputBar)
        
        let right = UIBarButtonItem(barButtonSystemItem: .done,
                                    target: self,
                                    action: #selector(rightButtonClicked))
        navigationItem.rightBarButtonItem = right
    }
    
    @objc func rightButtonClicked(_ sender: UIBarButtonItem) {
        
    }
}

extension LPInputViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LPInputViewCell", for: indexPath)
        switch indexPath.row {
        case 0:  cell.textLabel?.text = "显示键盘"
        case 1:  cell.textLabel?.text = "隐藏键盘"
        case 2:  cell.textLabel?.text = "关闭输入状态"
        default: cell.textLabel?.text = "\(indexPath.row)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.row {
        case 0:
            if !inputBar.isShowKeyboard {
                inputBar.isShowKeyboard = true
            }
        case 1:
            if inputBar.isShowKeyboard {
                inputBar.isShowKeyboard = false
            }
        case 2:
            inputBar.endEditing()
        default:
            break
        }
    }
}

extension LPInputViewController: LPInputViewDelegate, LPEmoticonViewDelegate {
    
    // MARK: -  LPInputViewDelegate
    
    func inputViewDidChangeFrame(_ inputView: LPInputView) {
        
    }
    
    func inputView(_ inputView: LPInputView, shouldHandleClickedFor item: UIButton, type: LPInputToolBarItemType) -> Bool {
        return true
    }
    
    func inputView(_ inputView: LPInputView, containerViewFor type: LPInputToolBarItemType) -> UIView? {
        switch type {
        case .emotion:
            return LPEmoticonView.instance(delegate: self)
        default:
            return nil
        }
    }
    
//    func inputView(_ inputView: LPInputView, textView: LPStretchyTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//
//    }
//
//    func inputView(_ inputView: LPInputView, textView: LPStretchyTextView, didProcessEditing editedRange: NSRange, changeInLength delta: Int) {
//        <#code#>
//    }
//
//    func inputView(_ inputView: LPInputView, inputAtCharacter character: String) {
//        <#code#>
//    }
//
//    func inputView(_ inputView: LPInputView, shouldHandleForMaximumLengthExceedsLimit maxLength: Int) -> Bool {
//        <#code#>
//    }
//
//    func inputView(_ inputView: LPInputView, sendFor textView: LPStretchyTextView) -> Bool {
//        <#code#>
//    }
    
    // MARK: - LPEmoticonViewDelegate
    
    func inputEmoticon(id: String, img: UIImage) {
        
    }
    
    func inputEmoticonDelete() {
        
    }
    
    func inputEmoticonSend() {
        
    }
}
