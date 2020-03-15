//
//  LPInputProtocol.swift
//  LPInputView <https://github.com/leo-lp/LPInputView>
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

// MARK: -
// MARK: - Protocol

public protocol LPInputBarDataSource: class {
    /// required
    var inputBarItemTypes: [LPInputBarItemType] { get }
    
    /// optional
    func customTextView(in inputBar: LPInputBar) -> LPAtTextView?
    func edgeInsets(in inputBar: LPInputBar) -> UIEdgeInsets?
    func interitemSpacing(in inputBar: LPInputBar) -> CGFloat?
    func isAtEnabled(in inputBar: LPInputBar, textView: LPAtTextView) -> Bool
    
    func inputBar(_ inputBar: LPInputBar, configure textView: LPAtTextView, for type: LPInputBarItemType)
    func inputBar(_ inputBar: LPInputBar, configure button: UIButton, for type: LPInputBarItemType)
    func inputBar(_ inputBar: LPInputBar, customItemFor type: LPInputBarItemType) -> UIView?
    func inputBar(_ inputBar: LPInputBar, separatorColorFor type: LPInputSeparatorLocation) -> UIColor?
}

internal protocol LPInputBarDelegate: class {
    func inputBar(_ inputBar: LPInputBar, didChange height: CGFloat)
    func inputBar(_ inputBar: LPInputBar, clickedAt item: UIButton, for type: LPInputBarItemType)
    func inputBar(_ inputBar: LPInputBar, textViewShouldBeginEditing textView: UITextView) -> Bool
    func inputBar(_ inputBar: LPInputBar, textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    func inputBar(_ inputBar: LPInputBar, textView: UITextView, didProcessEditing editedRange: NSRange, changeInLength delta: Int)
    func inputBar(_ inputBar: LPInputBar, inputAtCharacter character: String)
}

public protocol LPInputViewDelegate: class {
    /// optional
    func inputView(_ inputView: LPInputView, didChange frame: CGRect)
    func inputView(_ inputView: LPInputView, shouldHandleClickedAt item: UIButton, for type: LPInputBarItemType) -> Bool
    func inputView(_ inputView: LPInputView, containerViewFor type: LPInputBarItemType) -> UIView?
    
    func inputView(_ inputView: LPInputView, statusChanged new: LPInputBarItemType, old: LPInputBarItemType)
    
    func inputView(_ inputView: LPInputView, textView: LPAtTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    func inputView(_ inputView: LPInputView, textView: UITextView, didProcessEditing editedRange: NSRange, changeInLength delta: Int)
    func inputView(_ inputView: LPInputView, inputAtCharacter character: String)
    
    func inputView(_ inputView: LPInputView, sendFor textView: LPAtTextView) -> Bool
}

// MARK: -
// MARK: - Protocol Extensions

public extension LPInputViewDelegate {
    func inputView(_ inputView: LPInputView, didChange frame: CGRect) { }
    
    func inputView(_ inputView: LPInputView, shouldHandleClickedAt item: UIButton, for type: LPInputBarItemType) -> Bool { return true }
    
    func inputView(_ inputView: LPInputView, containerViewFor type: LPInputBarItemType) -> UIView? {  return nil }
        
    func inputView(_ inputView: LPInputView, statusChanged new: LPInputBarItemType, old: LPInputBarItemType) { }
    
    func inputView(_ inputView: LPInputView, textView: LPAtTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool { return true }

    func inputView(_ inputView: LPInputView, textView: UITextView, didProcessEditing editedRange: NSRange, changeInLength delta: Int) { }
    
    func inputView(_ inputView: LPInputView, inputAtCharacter character: String) { }
        
    func inputView(_ inputView: LPInputView, sendFor textView: LPAtTextView) -> Bool { return true }
}

public extension LPInputBarDataSource {
    func inputBar(_ inputBar: LPInputBar, configure textView: LPAtTextView, for type: LPInputBarItemType) { }
    
    func inputBar(_ inputBar: LPInputBar, configure button: UIButton, for type: LPInputBarItemType) { }
    
    func inputBar(_ inputBar: LPInputBar, customItemFor type: LPInputBarItemType) -> UIView? { return nil }
    
    func customTextView(in inputBar: LPInputBar) -> LPAtTextView? { return nil }
    
    func edgeInsets(in inputBar: LPInputBar) -> UIEdgeInsets? { return nil }
    
    func interitemSpacing(in inputBar: LPInputBar) -> CGFloat? { return nil }
    
    func isAtEnabled(in inputBar: LPInputBar, textView: LPAtTextView) -> Bool { return false }
    
    func inputBar(_ inputBar: LPInputBar, separatorColorFor type: LPInputSeparatorLocation) -> UIColor? { return #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1) }
}
