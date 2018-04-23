//
//  LPInputProtocol.swift
//  LPInputView
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

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
}

public extension LPInputToolBarConfig {
    func configButton(_ button: UIButton, type: LPInputToolBarItemType) { }
    func configTextView(_ textView: LPStretchyTextView, type: LPInputToolBarItemType) { }
    func configCustomBarItem(for type: LPInputToolBarItemType) -> UIView? { return nil }
    
    var textViewOfCustomToolBarItem: LPStretchyTextView? { return nil }
    
    var barContentInset: UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    }
    var barInteritemSpacing: CGFloat { return 10 }
}


//// MARK: - LPInputViewDelegate
//
//protocol LPInputViewDelegate: class {
//    /// optional
//    func inputView(_ inputView: LPInputView, heightDidChange height: CGFloat)
//    func inputView(_ inputView: LPInputView,
//                   shouldHandleClickedFor item: UIButton,
//                   type: LPInputBarItemType) -> Bool
//
//    func inputView(_ inputView: LPInputView, containerViewFor type: LPInputBarItemType) -> UIView?
//
//    func inputView(_ inputView: LPInputView,
//                   textView: LPStretchyTextView,
//                   didProcessEditing editedRange: NSRange,
//                   changeInLength delta: Int)
//
//    func inputView(_ inputView: LPInputView, inputAtCharacter character: String)
//    func inputView(_ inputView: LPInputView, textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
//
//    func inputView(_ inputView: LPInputView, sendFor textView: UITextView) -> Bool
//
//    func inputView(_ inputView: LPInputView, maximumCharacterLimitExceeded maxLength: Int) -> Bool
//}
//
// MARK: -
// MARK: - Protocol Extensions


//extension LPInputViewDelegate {
//    func inputView(_ inputView: LPInputView, heightDidChange height: CGFloat) { }
//    func inputView(_ inputView: LPInputView,
//                   shouldHandleClickedFor item: UIButton,
//                   type: LPInputBarItemType) -> Bool {
//        return true
//    }
//
//    func inputView(_ inputView: LPInputView,
//                   containerViewFor type: LPInputBarItemType) -> UIView? { return nil }
//
//    func inputView(_ inputView: LPInputView,
//                   textView: LPStretchyTextView,
//                   didProcessEditing editedRange: NSRange,
//                   changeInLength delta: Int) { }
//    func inputView(_ inputView: LPInputView, inputAtCharacter character: String) { }
//
//    func inputView(_ inputView: LPInputView, textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        return true
//    }
//    func inputView(_ inputView: LPInputView, sendFor textView: UITextView) -> Bool {
//        return true
//    }
//
//    func inputView(_ inputView: LPInputView, maximumCharacterLimitExceeded maxLength: Int) -> Bool {
//        return false
//    }
//}
