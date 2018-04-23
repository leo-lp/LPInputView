//
//  LPInputView.swift
//  LPInputView
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

public class LPInputView: UIView {
    private(set) var toolBar: LPInputToolBar
    
    //    // MARK: - Property Funcs
    //
    //    weak var inputDelegate: LPInputViewDelegate?
    //
    //    var hidesWhenResign: Bool = false
    //    var bottomFill: Bool = true
    //
    //    var maxInputLength: Int = 20
    //
    //    private(set) var status: LPInputBarItemType = .text
    //
    //    private lazy var containers: [LPInputBarItemType: UIView] = [:]
    //
    //    // MARK: - Override Funcs
    //    required init?(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    deinit {
        print("LPInputView: -> release memory.")
    }
    
    public init(frame: CGRect, config: LPInputToolBarConfig) {
        let rect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        toolBar = LPInputToolBar(frame: rect, config: config)
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        //        toolBar.delegate = self
        
        //        toolBar.frame.size = toolBar.sizeThatFits(CGSize(width: frame.width,
        //                                                         height: CGFloat.greatestFiniteMagnitude))
        toolBar.sizeToFit()
        addSubview(toolBar)
        
        //        refreshStatus(.text)
        
        sizeToFit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LPInputView {
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        let calculateView = superview ?? self
//
//        /// 计算容器高
//        if status != .text, let container = containers[status] {
//            return CGSize(width: calculateView.frame.width,
//                          height: toolBar.frame.height + container.frame.height)
//        }
//
//        /// 计算键盘高
//        var safeBottom: CGFloat = 0.0
//        if #available(iOS 11.0, *) {
//            safeBottom = calculateView.safeAreaInsets.bottom
//        }
//
//        print("1.safeBottom=\(safeBottom)")
//
//        let bottomMargin = (bottomFill && !hidesWhenResign) ? safeBottom : 0
//
//        // 键盘是从最底下弹起的，需要减去安全区域底部的高度
//        var keyboardDelta = LPKeyboard.shared.keyboardHeight - safeBottom
//
//        // 如果键盘还没有安全区域高，容器的初始值为0；否则则为键盘和安全区域的高度差值，这样可以保证 toolBar 始终在键盘上面
//        keyboardDelta = keyboardDelta > 0 ? keyboardDelta : bottomMargin
//        return CGSize(width: calculateView.frame.width, height: toolBar.frame.height + keyboardDelta)
//    }
//
//    override var frame: CGRect {
//        didSet {
//            if frame.height != oldValue.height {
//                callDidChangeHeight()
//            }
//        }
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        guard status != .text
//            , let container = containers[status]
//            , !container.isHidden
//            , container.frame.origin.y != toolBar.frame.maxY else { return }
//
//        let options = UIViewAnimationOptions(rawValue: 7)
//        UIView.animate(withDuration: 0.25, delay: 0, options: options, animations: {
//            container.frame.origin.y = self.toolBar.frame.maxY
//        }, completion: nil)
//    }
//
//    override func endEditing(_ force: Bool) -> Bool {
//        let flag = super.endEditing(force)
//        if !toolBar.isShowsKeyboard {
//            let curve = UIViewAnimationOptions.curveEaseInOut.rawValue
//            let begin = UIViewAnimationOptions.beginFromCurrentState.rawValue
//            let options = UIViewAnimationOptions(rawValue: curve << 16 | begin)
//            UIView.animate(withDuration: 0.25, delay: 0.0, options: options, animations: {
//                self.refreshStatus(.text)
//                self.sizeToFit()
//                self.inputDelegate?.inputView(self, heightDidChange: self.frame.height)
//            }, completion: nil)
//        }
//        return flag
//    }
}
//
//// MARK: - Public Funcs
//
//extension LPInputView {
//
//    func refreshStatus(_ status: LPInputBarItemType) {
//        self.status = status
//        toolBar.updateStatus(status)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
//            guard let `self` = self, self.containers.count > 0  else { return }
//            for container in self.containers {
//                container.value.isHidden = status != container.key
//            }
//        }
//    }
//
//    var isShowKeyboard: Bool {
//        get { return toolBar.isShowsKeyboard }
//        set { toolBar.isShowsKeyboard = newValue }
//    }
//
//    var isUp: Bool {
//        switch status {
//        case .voice: return false
//        case .text:  return LPKeyboard.shared.isVisiable
//        case .more, .emotion: return true
//        default:
//            guard let container = containers[status] else { return false }
//            return !container.isHidden
//        }
//    }
//
//    func showOrHideContainer(for type: LPInputBarItemType) {
//        if status != type {
//            showContainer(for: type)
//        } else {
//            refreshStatus(.text)
//            toolBar.isShowsKeyboard = true
//        }
//    }
//
//    func showContainer(for type: LPInputBarItemType) {
//        guard type != .text else { return }
//
//        var newContainer: UIView? {
//            if let container = containers[type] { return container }
//            guard let container = inputDelegate?.inputView(self, containerViewFor: type)
//                else { return nil }
//
//            adjustSize(for: container)
//            container.autoresizingMask = .flexibleWidth
//            containers[type] = container
//            return container
//        }
//
//        guard let container = newContainer else { return }
//
//        if container.superview == nil { addSubview(container) }
//
//        container.frame.origin.y = frame.height
//        bringSubview(toFront: container)
//
//        for container in containers {
//            container.value.isHidden = container.key != type
//        }
//
//        refreshStatus(type)
//        sizeToFit()
//
//        if toolBar.isShowsKeyboard {
//            toolBar.isShowsKeyboard = false
//        }
//    }
//}
//
//// MARK: - Private Funcs
//
//extension LPInputView {
//
//    private func callDidChangeHeight() {
//        guard let inputDelegate = inputDelegate else { return }
//        if status == .text {
//            inputDelegate.inputView(self, heightDidChange: frame.height)
//        } else {
//            // 这个时候需要一个动画来模拟键盘
//            let options = UIViewAnimationOptions(rawValue: 7)
//            UIView.animate(withDuration: 0.25, delay: 0, options: options, animations: {
//                inputDelegate.inputView(self, heightDidChange: self.frame.height)
//            }, completion: nil)
//        }
//    }
//
//    private func adjustSize(for vc: UIView) {
//        var fitSize = vc.sizeThatFits(CGSize(width: frame.width,
//                                             height: CGFloat.greatestFiniteMagnitude))
//        if #available(iOS 11.0, *), bottomFill {
//            fitSize.height += (superview ?? self).safeAreaInsets.bottom
//        }
//        vc.frame.size = fitSize
//    }
//}
//
//// MARK: - LPInputToolBarDelegate
//
//extension LPInputView: LPInputToolBarDelegate {
//
//    func toolBar(_ toolBar: LPInputToolBar, barItemClicked item: UIButton, type: LPInputBarItemType) {
//        if let delegate = inputDelegate
//            , !delegate.inputView(self, shouldHandleClickedFor: item, type: type) {
//            return
//        }
//
//        switch type {
//        case .voice:
//            if status != .voice {
//                refreshStatus(.voice)
//                sizeToFit()
//                if toolBar.isShowsKeyboard {
//                    toolBar.isShowsKeyboard = false
//                }
//            } else {
//                refreshStatus(.text)
//                toolBar.isShowsKeyboard = true
//            }
//        //case .emotion, .more:
//            //showOrHideContainer(for: type)
//        default:
//            showOrHideContainer(for: type)
//        }
//    }
//
//    func toolBar(_ toolBar: LPInputToolBar, heightDidChange newHeight: CGFloat) {
//        sizeToFit()
//    }
//
//    func toolBar(_ toolBar: LPInputToolBar, inputAtCharacter character: String) {
//        inputDelegate?.inputView(self, inputAtCharacter: character)
//    }
//
//    func toolBar(_ toolBar: LPInputToolBar, textViewShouldBeginEditing textView: UITextView) -> Bool {
//        refreshStatus(.text)
//        return true
//    }
//
//    func toolBar(_ toolBar: LPInputToolBar, textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if let inputDelegate = inputDelegate
//            , !inputDelegate.inputView(self,
//                                       textView: textView,
//                                       shouldChangeTextIn: range,
//                                       replacementText: text) {
//            return false
//        }
//
//        if text == "\n" && textView.returnKeyType == .send {
//            if let inputDelegate = inputDelegate
//                , inputDelegate.inputView(self, sendFor: textView) {
//                if let textView = textView as? LPStretchyTextView {
//                    textView.clearTextStorage()
//                } else {
//                    textView.text = ""
//                }
//                toolBar.layoutIfNeeded()
//            }
//            return false
//        }
//        return true
//    }
//
//    func toolBar(_ toolBar: LPInputToolBar,
//                 textView: LPStretchyTextView,
//                 didProcessEditing editedRange: NSRange,
//                 changeInLength delta: Int) {
//        guard let inputDelegate = inputDelegate else { return }
//        inputDelegate.inputView(self,
//                                textView: textView,
//                                didProcessEditing: editedRange,
//                                changeInLength: delta)
//        guard textView.textStorage.length > maxInputLength
//            , inputDelegate.inputView(self, maximumCharacterLimitExceeded: maxInputLength)
//            else { return }
//
//        let range = NSRange(location: maxInputLength - 1,
//                            length: textView.textStorage.length - maxInputLength)
//        textView.textStorage.deleteCharacters(in: range)
//    }
//}
