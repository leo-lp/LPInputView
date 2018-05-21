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

public protocol LPInputToolBarConfig: class {
    /// required
    var toolBarItems: [LPInputToolBarItemType] { get }
    
    /// optional
    func configItem(_ button: UIButton, type: LPInputToolBarItemType)
    func configTextView(_ textView: LPStretchyTextView, type: LPInputToolBarItemType)
    func configRecordButton(_ button: LPRecordButton)
    func configCustomBarItem(for type: LPInputToolBarItemType) -> UIView?
    
    var textViewOfCustomToolBarItem: LPStretchyTextView? { get }
    
    var barContentInset: UIEdgeInsets { get }
    var barInteritemSpacing: CGFloat { get }
    
    var separatorOfToolBar: [(loc: LPInputSeparatorLocation, color: UIColor?)]? { get }
    
    var isAtEnabled: Bool { get }
    
    var toolBarHeightWhenAudioRecording: CGFloat { get }
}

public protocol LPInputViewDelegate: class {
    /// optional
    func inputViewDidChangeFrame(_ inputView: LPInputView)
    func inputView(_ inputView: LPInputView, shouldHandleClickedFor item: UIButton, type: LPInputToolBarItemType) -> Bool
    func inputView(_ inputView: LPInputView, containerViewFor type: LPInputToolBarItemType) -> UIView?
    func inputViewAudioRecordIndicator(in inputView: LPInputView) -> (UIView & LPRecordButtonDelegate)?
    
    func inputView(_ inputView: LPInputView, statusChanged newStatus: LPInputToolBarItemType, oldStatus: LPInputToolBarItemType)
    
    func inputView(_ inputView: LPInputView, textView: LPStretchyTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    func inputView(_ inputView: LPInputView, textView: LPStretchyTextView, didProcessEditing editedRange: NSRange, changeInLength delta: Int)
    func inputView(_ inputView: LPInputView, inputAtCharacter character: String)
    func inputView(_ inputView: LPInputView, shouldHandleForMaximumLengthExceedsLimit maxLength: Int) -> Bool

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
    
    func inputViewAudioRecordIndicator(in inputView: LPInputView) -> (UIView & LPRecordButtonDelegate)?
    {  return nil }
    
    func inputView(_ inputView: LPInputView, statusChanged newStatus: LPInputToolBarItemType, oldStatus: LPInputToolBarItemType)
    { }
    
    func inputView(_ inputView: LPInputView, textView: LPStretchyTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    { return true }

    func inputView(_ inputView: LPInputView, textView: LPStretchyTextView, didProcessEditing editedRange: NSRange, changeInLength delta: Int)
    { }
    
    func inputView(_ inputView: LPInputView, inputAtCharacter character: String)
    { }
    
    func inputView(_ inputView: LPInputView, shouldHandleForMaximumLengthExceedsLimit maxLength: Int) -> Bool
    { return true }
    
    func inputView(_ inputView: LPInputView, sendFor textView: LPStretchyTextView) -> Bool
    { return true }
}

public extension LPInputToolBarConfig {
    func configItem(_ button: UIButton, type: LPInputToolBarItemType)
    { }
    
    func configTextView(_ textView: LPStretchyTextView, type: LPInputToolBarItemType)
    { }
    
    func configRecordButton(_ button: LPRecordButton)
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
    
    var isAtEnabled: Bool
    { return false }
    
    var toolBarHeightWhenAudioRecording: CGFloat
    { return 54.0 }
}
