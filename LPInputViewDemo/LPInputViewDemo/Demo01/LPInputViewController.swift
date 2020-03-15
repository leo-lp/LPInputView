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
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    private lazy var inputBar = LPInputView(at: view!)
    private lazy var config = LPInputViewConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.borderColor = UIColor.red.cgColor
        tableView.layer.borderWidth = 1
        
        inputBar.dataSource = config
        inputBar.delegate = self
        
        let right = UIBarButtonItem(barButtonSystemItem: .done,
                                    target: self,
                                    action: #selector(rightButtonClicked))
        navigationItem.rightBarButtonItem = right
        right.isEnabled = false
    }
    
    @objc func rightButtonClicked(_ sender: UIBarButtonItem) {
        inputBar.endTyping()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        inputBar.endTyping()
    }
}

extension LPInputViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
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
            inputBar.endTyping()
        default:
            break
        }
    }
}

extension LPInputViewController: LPInputViewDelegate, LPEmoticonViewDelegate {
    
    // MARK: -  LPInputViewDelegate
    
    func inputView(_ inputView: LPInputView, didChange frame: CGRect) {
        let isEditing = inputView.isTyping
        tableView.isUserInteractionEnabled = !isEditing
        tableViewBottomConstraint.constant = view.frame.height - inputView.frame.origin.y
        tableView.lp_scrollToBottom(true)
        inputView.animate({
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func inputView(_ inputView: LPInputView, statusChanged new: LPInputBarItemType, old: LPInputBarItemType) {
//        if newStatus == .voice {
//            if let atBtn = inputView.toolBar.item(with: .at) {
//                if atBtn.isHidden != true {
//                    atBtn.isHidden = true
//                    inputView.toolBar.sizeToFit()
//                }
//            }
//        } else if oldStatus == .voice {
//            if let atBtn = inputView.toolBar.item(with: .at) {
//                if atBtn.isHidden == true {
//                    atBtn.isHidden = false
//                    inputView.toolBar.sizeToFit()
//                }
//            }
//        }
    }
    
    func inputView(_ inputView: LPInputView, shouldHandleClickedAt item: UIButton, for type: LPInputBarItemType) -> Bool {
        if type == .at {
            pushFriendsVC(nil)
            return false
        }
        return true
    }
    
    func inputView(_ inputView: LPInputView, containerViewFor type: LPInputBarItemType) -> UIView? {
        switch type {
        case .emotion:
            return LPEmoticonView.instance(delegate: self)
        case .more:
            return LPMoreView(target: self, action: #selector(moreItemClicked))
//        case .voice:
//            return LPInputAudioRecordIndicatorView()
        default:
            return nil
        }
    }
    
    func inputViewAudioRecordIndicator(in inputView: LPInputView) -> (UIView & LPRecordButtonDelegate)? {
        return LPInputAudioRecordIndicatorView()
    }
    
    func inputView(_ inputView: LPInputView, textView: LPAtTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }

    func inputView(_ inputView: LPInputView, textView: UITextView, didProcessEditing editedRange: NSRange, changeInLength delta: Int) {
        navigationItem.rightBarButtonItem?.isEnabled = textView.textStorage.length > 0
    }

    func inputView(_ inputView: LPInputView, inputAtCharacter character: String) {
        pushFriendsVC(character)
    }

    func inputView(_ inputView: LPInputView, sendFor textView: LPAtTextView) -> Bool {
        sendMSG()
        return true
    }
    
    // MARK: - LPEmoticonViewDelegate
    
    func inputEmoticon(id: String, img: UIImage) {
        guard let textView = inputBar.textView else { return }
        textView.insertEmotion(LPTextAttachment(image: img, scale: 1.0, tag: id))
    }
    
    func inputEmoticonDelete() {
        inputBar.textView?.deleteCharacters()
    }
    
    func inputEmoticonSend() {
        sendMSG()
    }
    
    // MARK: -
    // MARK: - Action
    
    private func pushFriendsVC(_ character: String?) {
        let vc = LPFriendListController(style: .plain)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
        vc.selectedBlock = { friend in
            self.inputBar.textView?.insertUser(withID: friend.id,
                                               name: friend.name,
                                               checkAt: character)
        }
    }
    
    private func sendMSG() {
        guard let textView = inputBar.textView else { return }

        let atUserPlaceholderByBlock: (Int, LPAtUser) -> String = { (index, _) -> String in
            return "@{\(index)}"
        }
        let result = textView.textStorage.lp_parse(atUserPlaceholderByBlock)
        print(result.description)

        textView.clearTextStorage()
    }
    
    @objc private func moreItemClicked(_ sender: UIButton) {
        let title = "提示"
        let msg = "您点击了“\(sender.titleLabel?.text ?? "")”"
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "👌", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
