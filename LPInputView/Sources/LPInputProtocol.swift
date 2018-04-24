//
//  LPInputProtocol.swift
//  LPInputView
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

// MARK: -
// MARK: - Protocol

public protocol LPInputToolBarConfig: class {
    /// required
    var toolBarItems: [LPInputToolBarItemType] { get }
    
    /// optional
    func configButton(_ button: UIButton, type: LPInputToolBarItemType)
    func configTextView(_ textView: LPStretchyTextView, type: LPInputToolBarItemType)
    func configCustomBarItem(for type: LPInputToolBarItemType) -> UIView?
    
    var textViewOfCustomToolBarItem: LPStretchyTextView? { get }
    
    var barContentInset: UIEdgeInsets { get }
    var barInteritemSpacing: CGFloat { get }
    
    var separatorOfToolBar: [(loc: LPInputSeparatorLocation, color: UIColor?)]? { get }
}

public protocol LPInputViewDelegate: class {
    /// optional
    func inputViewDidChangeFrame(_ inputView: LPInputView)
    func inputView(_ inputView: LPInputView, shouldHandleClickedFor item: UIButton, type: LPInputToolBarItemType) -> Bool
    func inputView(_ inputView: LPInputView, containerViewFor type: LPInputToolBarItemType) -> UIView?
    
    func inputView(_ inputView: LPInputView, textView: LPStretchyTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    func inputView(_ inputView: LPInputView, textView: LPStretchyTextView, didProcessEditing editedRange: NSRange, changeInLength delta: Int)
    func inputView(_ inputView: LPInputView, inputAtCharacter character: String)
    func inputView(_ inputView: LPInputView, maximumCharacterLimitExceeded maxLength: Int) -> Bool

    func inputView(_ inputView: LPInputView, sendFor textView: LPStretchyTextView) -> Bool
}


// MARK: -
// MARK: - Protocol Extensions

public extension LPInputViewDelegate {
    func inputViewDidChangeFrame(_ inputView: LPInputView)
    { }
    
    func inputView(_ inputView: LPInputView, shouldHandleClickedFor item: UIButton, type: LPInputToolBarItemType) -> Bool
    { return true }
    
    func inputView(_ inputView: LPInputView, containerViewFor type: LPInputToolBarItemType) -> UIView?
    {  return nil }
    
    func inputView(_ inputView: LPInputView, textView: LPStretchyTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    { return true }
    
    func inputView(_ inputView: LPInputView, textView: LPStretchyTextView, didProcessEditing editedRange: NSRange, changeInLength delta: Int)
    { }
    
    func inputView(_ inputView: LPInputView, inputAtCharacter character: String)
    { }
    
    func inputView(_ inputView: LPInputView, maximumCharacterLimitExceeded maxLength: Int) -> Bool
    { return false }
    
    func inputView(_ inputView: LPInputView, sendFor textView: LPStretchyTextView) -> Bool
    { return true }
}

public extension LPInputToolBarConfig {
    func configButton(_ button: UIButton, type: LPInputToolBarItemType)
    { }
    
    func configTextView(_ textView: LPStretchyTextView, type: LPInputToolBarItemType)
    { }
    
    func configCustomBarItem(for type: LPInputToolBarItemType) -> UIView?
    { return nil }
    
    var textViewOfCustomToolBarItem: LPStretchyTextView?
    { return nil }
    
    var barContentInset: UIEdgeInsets
    { return UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15) }
    
    var barInteritemSpacing: CGFloat
    { return 10 }
    
    var separatorOfToolBar: [(loc: LPInputSeparatorLocation, color: UIColor?)]?
    { return nil }
}
