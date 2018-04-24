//
//  LPInputView.swift
//  LPInputView
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

public class LPInputView: UIView {
    // MARK: - Property
    weak var delegate: LPInputViewDelegate?
    
    var hidesWhenResign: Bool = false
    var bottomFill: Bool = true
    
    var maxInputLength: Int = 20
    
    private(set) var toolBar: LPInputToolBar
    private(set) var status: LPInputToolBarItemType = .text
    
    private lazy var containers: [LPInputToolBarItemType: UIView] = [:]
    private lazy var bottomSafeInset: CGFloat = 0.0
    
    // MARK: - Override Funcs
  
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("LPInputView: -> release memory.")
    }
    
    public init(frame: CGRect, config: LPInputToolBarConfig) {
        let rect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        toolBar = LPInputToolBar(frame: rect, config: config)
        super.init(frame: frame)
        backgroundColor = UIColor.white
        if #available(iOS 11.0, *) {
            insetsLayoutMarginsFromSafeArea = false
        }
        
        toolBar.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame),
                                               name: .LPKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToWindow() {
        guard window != nil else { return }
        toolBar.sizeToFit()
        guard toolBar.superview == nil else { return }
        addSubview(toolBar)
    }
}

public extension LPInputView {
    
    func endEditing() {
        if toolBar.isShowsKeyboard {
            toolBar.isShowsKeyboard = false
        } else {
            
        }
    }
    
    var isUp: Bool {
        switch status {
        //case .voice: return false
        case .text:  return LPKeyboard.shared.isVisiable
        //case .more, .emotion: return true
        default:
            guard let container = containers[status] else { return false }
            return !container.isHidden
        }
    }
}

// MARK: - LPInputToolBarDelegate

extension LPInputView: LPInputToolBarDelegate {
    
    func toolBarDidChange(in toolBar: LPInputToolBar) {
        print("LPInputView:->toolBarDidChange")
        resetLayout()
    }
    
    // MARK: - Notification Funcs
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        /// 如果当前视图不是顶部视图，则不需要监听
        guard window != nil else { return }
        print("LPInputView:->keyboardWillChangeFrame")
        resetLayout()
    }
}

// MARK: - Private Funcs

extension LPInputView {
    
    private func resetLayout() {
        print("LPInputView:->resetLayout")
        guard let superSize = superview?.frame.size else { return }
        let toolBarHeight = toolBar.frame.height
        let keyboard = LPKeyboard.shared
        
        var rect = frame
        if self.hidesWhenResign {
        } else {
            if bottomFill {
                let keyboardDelta = keyboard.height + (isUp ? 0.0 : keyboard.safeAreaInsets.bottom)
                rect.size.height = toolBarHeight + keyboardDelta
                rect.origin.y = superSize.height - rect.size.height
            } else {
                
            }
        }
        
        guard frame != rect else { return }
        
        let options = UIViewAnimationOptions(rawValue: 7)
        UIView.animate(withDuration: 0.25, delay: 0, options: options, animations: {
            self.frame = rect
            print("重置布局:->frame=\(rect, rect.maxY)")
        }, completion: nil)
    }
}

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

extension LPInputView {
    
    @available(iOS 11.0, *)
    public override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        print("safeAreaInsetsDidChange=\(safeAreaInsets)")
    }
}
