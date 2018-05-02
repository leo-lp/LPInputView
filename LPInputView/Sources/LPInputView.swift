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
    public weak var delegate: LPInputViewDelegate?
    
    public var hidesWhenResign: Bool = false
    public var bottomFill: Bool = true
    
    public var maxInputLength: Int = 1000
    
    public var toolBar: LPInputToolBar
    private var status: LPInputToolBarItemType = .text
    
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
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToWindow() {
        guard window != nil else { return }
        let size = toolBar.sizeThatFits(CGSize(width: frame.width,
                                               height: CGFloat.greatestFiniteMagnitude))
        if toolBar.frame.size != size {
            toolBar.frame.size = size
            resetLayout()
        }
        guard toolBar.superview == nil else { return }
        addSubview(toolBar)
    }
}

// MARK: - Public Funcs

public extension LPInputView {
    
    var textView: LPStretchyTextView? {
        return toolBar.textView
    }
    
    var isShowKeyboard: Bool {
        get { return toolBar.isShowKeyboard }
        set { toolBar.isShowKeyboard = newValue }
    }
    
    func endEditing() {
        if toolBar.isShowKeyboard {
            toolBar.isShowKeyboard = false
        } else if isUp {
            renewStatus(to: .text, isDelay: true)
            resetLayout()
        }
    }
    
    var isUp: Bool {
        switch status {
        //case .voice: return false
        case .text:  return LPKeyboard.shared.isVisiable
        case .more, .emotion: return true
        default:
            guard let container = containers[status] else { return false }
            return !container.isHidden
        }
    }
    
    func showOrHideContainer(for type: LPInputToolBarItemType) {
        if status != type {
            showContainer(for: type)
        } else {
            renewStatus(to: .text, isDelay: false)
            toolBar.isShowKeyboard = true
        }
    }
    
    func showContainer(for type: LPInputToolBarItemType) {
        guard type != .text else { return }
        
        var newContainer: UIView? {
            if let container = containers[type] { return container }
            guard let container = delegate?.inputView(self, containerViewFor: type)
                else { return nil }
            
            var size = container.sizeThatFits(CGSize(width: frame.width,
                                                     height: CGFloat.greatestFiniteMagnitude))
            if bottomFill {
                size.height += LPKeyboard.shared.safeAreaInsets.bottom
            }
            container.frame.size = size
            container.autoresizingMask = .flexibleWidth
            containers[type] = container
            return container
        }
        
        guard let container = newContainer else { return }
        
        if container.superview == nil { addSubview(container) }
        
        container.frame.origin.y = frame.height
        bringSubview(toFront: container)
        container.isHidden = false
        
        renewStatus(to: type, isDelay: false)
        
        animate({
            container.frame.origin.y = self.toolBar.frame.maxY
        }, completion: nil)
        
        if toolBar.isShowKeyboard {
            toolBar.isShowKeyboard = false
        } else {
            resetLayout()
        }
    }
}

// MARK: - LPInputToolBarDelegate

extension LPInputView: LPInputToolBarDelegate {
    
    func toolBarDidChangeHeight(_ toolBar: LPInputToolBar) {
        resetLayout()
    }
    
    func toolBar(_ toolBar: LPInputToolBar, barItemClicked item: UIButton, type: LPInputToolBarItemType) {
        if let delegate = delegate
            , !delegate.inputView(self, shouldHandleClickedFor: item, type: type) {
            return
        }

        switch type {
        case .text:
            break
//        case .voice:
//            if status != .voice {
//                refreshStatus(.voice)
//                sizeToFit()
//                if toolBar.isShowKeyboard {
//                    toolBar.isShowKeyboard = false
//                }
//            } else {
//                refreshStatus(.text)
//                toolBar.isShowKeyboard = true
//            }
        default:
            showOrHideContainer(for: type)
        }
    }
    
    func toolBar(_ toolBar: LPInputToolBar, textViewShouldBeginEditing textView: UITextView) -> Bool {
        if status != .text {
            renewStatus(to: .text, isDelay: false)
        }
        return true
    }
    
    func toolBar(_ toolBar: LPInputToolBar, textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let delegate = delegate
            , let textView = textView as? LPStretchyTextView
            , !delegate.inputView(self, textView: textView, shouldChangeTextIn: range, replacementText: text)
        { return false }
        
        if text == "\n" && textView.returnKeyType == .send {
            if let delegate = delegate
                , let textView = textView as? LPStretchyTextView
                , delegate.inputView(self, sendFor: textView) {
                textView.clearTextStorage()
            }
            return false
        }
        return true
    }
    
    func toolBar(_ toolBar: LPInputToolBar, textView: LPStretchyTextView, didProcessEditing editedRange: NSRange, changeInLength delta: Int) {
        guard let delegate = delegate else { return }
        delegate.inputView(self, textView: textView, didProcessEditing: editedRange, changeInLength: delta)

        guard textView.textStorage.length > maxInputLength
            , delegate.inputView(self, shouldHandleForMaximumLengthExceedsLimit: maxInputLength)
            else { return }

        DispatchQueue.main.async {
            let length = textView.textStorage.length - self.maxInputLength
            guard length > 0 else { return }

            let range = NSRange(location: self.maxInputLength - 1, length: length)
            textView.textStorage.deleteCharacters(in: range)
            textView.selectedRange = NSRange(location: range.location, length: 0)
        }
    }
    
    func toolBar(_ toolBar: LPInputToolBar, inputAtCharacter character: String) {
        delegate?.inputView(self, inputAtCharacter: character)
    }
    
    // MARK: - Notification Funcs
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        /// 如果当前视图不是顶部视图，则不需要监听
        guard window != nil else { return }
        resetLayout()
    }
}

// MARK: - Private Funcs

extension LPInputView {
    
    private func renewStatus(to status: LPInputToolBarItemType, isDelay: Bool) {
        if self.status != .text {
            let oldStatus = self.status
            if isDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    guard let `self` = self
                        , let container = self.containers[oldStatus] else { return }
                    container.isHidden = true
                }
            } else {
                containers[oldStatus]?.isHidden = true
            }
        }
        self.status = status
    }
    
    private func resetLayout() {
        guard let superview = superview else { return }
        let superSize = superview.frame.size
        var rect = frame
        rect.size.height = heightThatFits
        
        if hidesWhenResign {
            rect.origin.y = superSize.height - (isUp ? rect.size.height : 0.0)
        } else {
            if bottomFill {
                rect.origin.y = superSize.height - rect.size.height
            } else {
                let delta = LPKeyboard.shared.safeAreaInsets.bottom
                rect.origin.y = superSize.height - rect.size.height - delta
            }
        }
        
        guard frame != rect else { return }
        
        superview.layoutIfNeeded()
        animate({
            self.frame = rect
            if self.status != .text, let container = self.containers[self.status] {
                container.frame.origin.y = self.toolBar.frame.maxY
            }
            print("重置布局:->frame=\(rect, rect.maxY)")
        }, completion: nil)
    }
    
    private var heightThatFits: CGFloat {
        if status != .text, let container = containers[status] {
            return toolBar.frame.height + container.frame.height
        }
        
        let kb = LPKeyboard.shared
        if hidesWhenResign {
            return toolBar.frame.height + kb.height
        } else {
            
            if bottomFill {
                let delta = isUp ? 0.0 : kb.safeAreaInsets.bottom
                return toolBar.frame.height + kb.height + delta
            } else {
                let delta = isUp ? kb.height - kb.safeAreaInsets.bottom : 0.0
                return toolBar.frame.height + delta
            }
        }
    }
    
    private func animate(_ animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        let options = UIViewAnimationOptions(rawValue: 7)
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: options,
                       animations: animations,
                       completion: completion)
    }
}

//extension LPInputView {
//
//    @available(iOS 11.0, *)
//    public override func safeAreaInsetsDidChange() {
//        super.safeAreaInsetsDidChange()
//        print("safeAreaInsetsDidChange=\(safeAreaInsets)")
//    }
//}
