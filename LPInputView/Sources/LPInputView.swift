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
        toolBar.recordButton?.setup(with: self)
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
        
        let fitSize = CGSize(width: frame.width,
                             height: CGFloat.greatestFiniteMagnitude)
        let size = toolBar.sizeThatFits(fitSize)
        if toolBar.frame.size != size {
            toolBar.frame.size = size
            resetLayout(false)
        }
        
        if toolBar.superview == nil {
            addSubview(toolBar)
        }
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTestView = super.hitTest(point, with: event)
        if hitTestView == nil
            , let recordButton = toolBar.recordButton
            , !recordButton.isHidden {
            let convertPoint = recordButton.convert(point, from: toolBar)
            if recordButton.bounds.contains(convertPoint) {
                return recordButton
            }
        }
        return hitTestView
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
        } else if isEditing || status == .voice {
            renewStatus(to: .text, isDelay: true)
            resetLayout(true)
        }
    }
    
    var isEditing: Bool {
        switch status {
        case .voice: return false
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
        guard type != .text
            , let container = container(for: type) else { return }
        
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
            resetLayout(true)
        }
    }
    
    public func animate(_ animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        let options = UIViewAnimationOptions(rawValue: 7)
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: options,
                       animations: animations,
                       completion: completion)
    }
}

// MARK: - LPInputToolBarDelegate & LPRecordButtonDelegate

extension LPInputView: LPInputToolBarDelegate, LPRecordButtonDelegate {
    
    func toolBarDidChangeHeight(_ toolBar: LPInputToolBar) {
        resetLayout(true)
    }
    
    func toolBar(_ toolBar: LPInputToolBar, barItemClicked item: UIButton, type: LPInputToolBarItemType) {
        if let delegate = delegate
            , !delegate.inputView(self, shouldHandleClickedFor: item, type: type) {
            return
        }

        switch type {
        case .text:
            break
        case .voice:
            if status != .voice {
                renewStatus(to: .voice, isDelay: true)
                if toolBar.isShowKeyboard {
                    toolBar.isShowKeyboard = false
                } else {
                    resetLayout(true)
                }
            } else {
                renewStatus(to: .text, isDelay: false)
                toolBar.isShowKeyboard = true
            }
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
    
    // MARK: - LPRecordButtonDelegate
    
    public func recordButton(_ recordButton: LPRecordButton, recordPhase: LPAudioRecordPhase) {
        guard let container = container(for: .voice) as? (UIView & LPRecordButtonDelegate)
            else { return }
        switch recordPhase {
        case .start:
            container.alpha = 0.0
            if container.superview == nil {
                UIApplication.shared.keyWindow?.addSubview(container)
            }
            animate({
                container.alpha = 1.0
            }, completion: nil)
        case .finished, .cancelled:
            animate({
                container.alpha = 0.0
            }) { (_) in
                container.removeFromSuperview()
            }
        default:
            break
        }
        container.recordButton(recordButton, recordPhase: recordPhase)
    }
    
    // MARK: - Notification Funcs
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        /// 如果当前视图不是顶部视图，则不需要监听
        guard window != nil else { return }
        resetLayout(false)
    }
}

// MARK: - Private Funcs

extension LPInputView {
    
    private func container(for type: LPInputToolBarItemType) -> UIView? {
        if let container = containers[type] { return container }
        
        let containerOptional: UIView?
        if type == .voice {
            containerOptional = delegate?.inputViewAudioRecordIndicator(in: self)
        } else {
            containerOptional = delegate?.inputView(self, containerViewFor: type)
        }
        
        guard let container = containerOptional else { return nil }
        
        var size = container.sizeThatFits(CGSize(width: frame.width,
                                                 height: CGFloat.greatestFiniteMagnitude))
        if type != .voice && bottomFill {
            size.height += LPKeyboard.shared.safeAreaInsets.bottom
        }
        container.frame.size = size
        container.autoresizingMask = .flexibleWidth
        containers[type] = container
        return container
    }
    
    private func renewStatus(to status: LPInputToolBarItemType, isDelay: Bool) {
        let oldStatus = self.status
        if self.status != .text && self.status != .voice {
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
        
        toolBar.status = status
        self.status = status
        delegate?.inputView(self, statusChanged: status, oldStatus: oldStatus)
    }
    
    private func resetLayout(_ animated: Bool) {
        guard let superview = superview else { return }
        
        let superSize = superview.frame.size
        var rect = frame
        rect.size.height = heightThatFits
        
        if hidesWhenResign {
            rect.origin.y = superSize.height - (isEditing ? rect.size.height : 0.0)
        } else {
            if bottomFill {
                rect.origin.y = superSize.height - rect.size.height
            } else {
                let delta = LPKeyboard.shared.safeAreaInsets.bottom
                rect.origin.y = superSize.height - rect.size.height - delta
            }
        }
        
        guard frame != rect else { return }
        
        let animateBlock: () -> Void = {
            self.frame = rect
            if (self.status != .text && self.status != .voice)
                , let container = self.containers[self.status] {
                container.frame.origin.y = self.toolBar.frame.maxY
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
        if (status != .text && status != .voice)
            , let container = containers[status] {
            return toolBar.frame.height + container.frame.height
        }
        
        let kb = LPKeyboard.shared
        if hidesWhenResign {
            return toolBar.frame.height + kb.height
        } else {
            if bottomFill {
                let delta = isEditing ? 0.0 : kb.safeAreaInsets.bottom
                return toolBar.frame.height + kb.height + delta
            } else {
                let delta = isEditing ? kb.height - kb.safeAreaInsets.bottom : 0.0
                return toolBar.frame.height + delta
            }
        }
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
