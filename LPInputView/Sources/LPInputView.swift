//
//  LPInputView.swift
//  LPInputView <https://github.com/leo-lp/LPInputView>
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

public class LPInputView: UIView, LPInputBarDelegate, LPKeyboardObserver {
    public weak var dataSource: LPInputBarDataSource?
    public weak var delegate: LPInputViewDelegate?
    
    /// 当键盘消失后`inputBar`是否隐藏，默认`false`
    public var isHideWhenResign: Bool = false
    /// 是否将`inputView`填充到安全区域
    public var isFillSafeArea: Bool = true
    /// 最大输入的字符长度
    public var maxTextLength: Int = 1000
    
    public var bar: LPInputBar?
    private var status: LPInputBarItemType = .text
    
    private lazy var containers: [LPInputBarItemType: UIView] = [:]
    private lazy var bottomSafeInset: CGFloat = 0.0
    
    // MARK: - Override Funcs
    
    deinit {
        LPKeyboardManager.shared.removeObserver(self)
        #if DEBUG
        print("LPInputView: -> release memory.")
        #endif
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(at superview: UIView) {
        super.init(frame: CGRect(x: 0, y: 0, width: superview.frame.width, height: 60))
        backgroundColor = UIColor.white
        if #available(iOS 11.0, *) {
            insetsLayoutMarginsFromSafeArea = false
        }
        superview.addSubview(self)
        LPKeyboardManager.shared.addObserver(self)
    }
    
    public override func didMoveToWindow() {
        guard window != nil else { return }
        guard bar == nil
            , let bar = LPInputBar(frame: bounds, dataSource: dataSource) else { return }
        self.bar = bar
        bar.delegate = self
        bar.sizeToFit()
        resetLayout(animated: false)
        addSubview(bar)
    }
    
    public var textView: LPAtTextView? { return bar?.textView }
    
    public var isShowKeyboard: Bool {
        get { return bar?.isShowKeyboard ?? false }
        set { bar?.isShowKeyboard = newValue }
    }
    
    public func endTyping() {
        guard let bar = bar else { return }
        if bar.isShowKeyboard {
            bar.isShowKeyboard = false
        } else if isTyping {
            renewStatus(to: .text, isDelay: true)
            resetLayout(animated: true)
        }
    }
    
    /// 是否正在输入
    public var isTyping: Bool {
        switch status {
        case .text:  return LPKeyboardManager.shared.keyboardVisible
        case .more, .emotion: return true
        default:
            guard let container = containers[status] else { return false }
            return !container.isHidden
        }
    }
    
    public func showOrHideContainer(for type: LPInputBarItemType) {
        if status != type {
            showContainer(for: type)
        } else {
            guard let bar = bar else { return assert(false) }
            renewStatus(to: .text, isDelay: false)
            bar.isShowKeyboard = true
        }
    }
    
    public func showContainer(for type: LPInputBarItemType) {
        guard let bar = bar, type != .text, let container = container(for: type) else { return }
        
        if container.superview == nil { addSubview(container) }
        
        container.frame.origin.y = frame.height
        bringSubviewToFront(container)
        container.isHidden = false
        
        renewStatus(to: type, isDelay: false)
        
        animate({
            container.frame.origin.y = bar.frame.maxY
        }, completion: nil)
        
        if bar.isShowKeyboard {
            bar.isShowKeyboard = false
        } else {
            resetLayout(animated: true)
        }
    }
    
    public func animate(_ animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: UIView.AnimationOptions(rawValue: 7),
                       animations: animations,
                       completion: completion)
    }
    
    // MARK: - LPInputBarDelegate
    func inputBar(_ inputBar: LPInputBar, didChange height: CGFloat) {
        resetLayout(animated: true)
    }
    
    func inputBar(_ inputBar: LPInputBar, clickedAt item: UIButton, for type: LPInputBarItemType) {
        if let delegate = delegate, !delegate.inputView(self, shouldHandleClickedFor: item, type: type), type == .text {
            return
        }
        showOrHideContainer(for: type)
    }
    
    func inputBar(_ inputBar: LPInputBar, textViewShouldBeginEditing textView: UITextView) -> Bool {
        if status != .text {
            renewStatus(to: .text, isDelay: false)
        }
        return true
    }
    
    func inputBar(_ inputBar: LPInputBar, textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let delegate = delegate
            , let textView = textView as? LPAtTextView
            , !delegate.inputView(self, textView: textView, shouldChangeTextIn: range, replacementText: text) { return false }
        
        if text == "\n" && textView.returnKeyType == .send {
            if let delegate = delegate, let textView = textView as? LPAtTextView, delegate.inputView(self, sendFor: textView) {
                textView.clearTextStorage()
            }
            return false
        }
        return true
    }
    
    func inputBar(_ inputBar: LPInputBar, textView: UITextView, didProcessEditing editedRange: NSRange, changeInLength delta: Int) {
        guard let delegate = delegate else { return }
        delegate.inputView(self, textView: textView, didProcessEditing: editedRange, changeInLength: delta)

        guard textView.textStorage.length > maxTextLength
            , delegate.inputView(self, shouldHandleForMaximumLengthExceedsLimit: maxTextLength) else { return }

        DispatchQueue.main.async {
            let length = textView.textStorage.length - self.maxTextLength
            guard length > 0 else { return }

            let range = NSRange(location: self.maxTextLength - 1, length: length)
            textView.textStorage.deleteCharacters(in: range)
            textView.selectedRange = NSRange(location: range.location, length: 0)
        }
    }
    
    func inputBar(_ inputBar: LPInputBar, inputAtCharacter character: String) {
        delegate?.inputView(self, inputAtCharacter: character)
    }
    
    // MARK: - LPKeyboardObserver
    
    public func keyboardManager(_ keyboard: LPKeyboardManager, willTransition trans: LPKeyboardTransition) {
        /// 如果当前视图不是顶部视图，则不需要监听
        guard window != nil else { return }
        resetLayout(animated: false)
    }
}

// MARK: - Private Funcs

extension LPInputView {
    private func container(for type: LPInputBarItemType) -> UIView? {
        if let container = containers[type] { return container }
        
        guard let container = delegate?.inputView(self, containerViewFor: type) else { return nil }
        
        container.sizeToFit()
        if isFillSafeArea {
            container.frame.size.height += lp_safeAreaInsets.bottom
        }
        container.autoresizingMask = .flexibleWidth
        containers[type] = container
        return container
    }
    
    private func renewStatus(to status: LPInputBarItemType, isDelay: Bool) {
        let oldStatus = self.status
        if self.status != .text {
            if isDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    guard let `self` = self, let container = self.containers[oldStatus] else { return }
                    container.isHidden = true
                }
            } else {
                containers[oldStatus]?.isHidden = true
            }
        }
        
        self.status = status
        delegate?.inputView(self, statusChanged: status, oldStatus: oldStatus)
    }
    
    private func resetLayout(animated: Bool) {
        guard let superview = superview, let bar = bar else { return }
        
        let superSize = superview.frame.size
        var rect = frame
        rect.size.height = heightThatFits
        
        if isHideWhenResign {
            rect.origin.y = superSize.height - (isTyping ? rect.height : 0.0)
        } else {
            if isFillSafeArea {
                rect.origin.y = superSize.height - rect.height
            } else {
                rect.origin.y = superSize.height - rect.height - lp_safeAreaInsets.bottom
            }
        }
        
        guard frame != rect else { return }
        
        let animateBlock: () -> Void = {
            self.frame = rect
            if self.status != .text, let container = self.containers[self.status] {
                container.frame.origin.y = bar.frame.maxY
            }
            self.delegate?.inputViewDidChangeFrame(self)
        }
        
        if animated {
            animate(animateBlock, completion: nil)
        } else {
            animateBlock()
        }
    }
    
    private var heightThatFits: CGFloat {
        guard let bar = bar else { return 0 }
        if status != .text, let container = containers[status] {
            return bar.frame.height + container.frame.height
        }
        
        let kbHeight = LPKeyboardManager.shared.keyboardVisible ? LPKeyboardManager.shared.keyboardFrame.height : 0.0
        let bottomSafeArea = lp_safeAreaInsets.bottom
        if isHideWhenResign {
            return bar.frame.height + kbHeight
        } else {
            if isFillSafeArea {
                return bar.frame.height + kbHeight + (isTyping ? 0.0 : bottomSafeArea)
            } else {
                return bar.frame.height + (isTyping ? kbHeight - bottomSafeArea : 0.0)
            }
        }
    }
    
    private var lp_safeAreaInsets: UIEdgeInsets {
        guard #available(iOS 11.0, *)
            , let window = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first else { return .zero }
        return window.safeAreaInsets
    }
}
