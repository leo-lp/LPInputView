//
//  LPCustomInputViewConfig.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/4/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit
import LPInputView

extension LPCustomInputViewController: LPInputBarDataSource {
    
    var inputBarItemTypes: [LPInputBarItemType] {
        [.custom(tag: 1)]
    }
    
    func customTextView(in inputBar: LPInputBar) -> LPAtTextView? {
        textCell?.textView
    }
    
    func isAtEnabled(in inputBar: LPInputBar, textView: LPAtTextView) -> Bool {
        true
    }
    
    func edgeInsets(in inputBar: LPInputBar) -> UIEdgeInsets? {
        .zero
    }
    
    func inputBar(_ inputBar: LPInputBar, customItemFor type: LPInputBarItemType) -> UIView? {
        guard case .custom(let tag) = type, tag == 1 else { assert(false); return nil }
        
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
    
    func inputBar(_ inputBar: LPInputBar, separatorColorFor type: LPInputSeparatorLocation) -> UIColor? {
        nil
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
