//
//  LPCustomInputViewConfig.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/4/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit
import LPInputView

extension LPInputToolBarItemType {
    static let customItem = LPInputToolBarItemType(rawValue: 1 << 10)
}

extension LPCustomInputViewController: LPInputToolBarConfig {
    
//    var textViewOfCustomToolBarItem: LPStretchyTextView? {
//        return textCell?.textView
//    }
    
    var isAtEnabled: Bool {
        return true
    }
    
    var toolBarItems: [LPInputToolBarItemType] {
        return [.customItem]
    }
    
    var barContentInset: UIEdgeInsets {
        return .zero
    }
    
    func configCustomBarItem(for type: LPInputToolBarItemType) -> UIView? {
        let customToolBar = LPCustomInputToolBar.instance()!
        customToolBar.emotionButton.addTarget(self,
                                              action: #selector(emotionButtonClicked),
                                              for: .touchUpInside)
        customToolBar.atButton.addTarget(self,
                                         action: #selector(atButtonClicked),
                                         for: .touchUpInside)
        customToolBar.loationButton.addTarget(self,
                                              action: #selector(locationButtonClicked),
                                              for: .touchUpInside)
        return customToolBar
    }
    
    var separatorOfToolBar: [(loc: LPInputSeparatorLocation, color: UIColor?)]? {
        return [(loc: .top, color: nil), (loc: .bottom, color: nil)]
    }
    
    // MARK: - Button Action
    
    @objc func emotionButtonClicked(_ sender: UIButton) {
        inputBar.showOrHideContainer(for: .emotion)
    }
    
    @objc func atButtonClicked(_ sender: UIButton) {
        pushFriendsVC(nil)
    }
    
    @objc func locationButtonClicked(_ sender: UIButton) {
        
    }
}
