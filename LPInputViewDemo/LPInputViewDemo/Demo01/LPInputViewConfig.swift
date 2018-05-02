//
//  LPInputViewConfig.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit
import LPInputView

class LPInputViewConfig: LPInputToolBarConfig {
    
    deinit {
        print("LPInputViewConfig: -> release memory.")
    }
    
    var isAtEnabled: Bool {
        return true
    }
    
    var toolBarItems: [LPInputToolBarItemType] {
        return [.voice, .text, .emotion, .at, .more]
    }
    
    func configItem(_ button: UIButton, type: LPInputToolBarItemType) {
        switch type {
        case .voice:   button.setImage(#imageLiteral(resourceName: "icon_toolview_voice_normal"), for: .normal)
        case .emotion: button.setImage(#imageLiteral(resourceName: "icon_toolview_emotion_normal"), for: .normal)
        case .more:    button.setImage(#imageLiteral(resourceName: "icon_toolview_add_normal"), for: .normal)
        case .at:      button.setImage(#imageLiteral(resourceName: "btn_at"), for: .normal)
        default: break
        }
    }
    
    func configTextView(_ textView: LPStretchyTextView, type: LPInputToolBarItemType) {
        let placeholder = "说点什么..."
        let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.brown]
        textView.placeholder = NSAttributedString(string: placeholder,
                                                  attributes: attributes)
        textView.maxNumberOfLines = 4
        textView.minNumberOfLines = 1
        textView.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1).cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 4
    }
    
    func configRecordButton(_ button: LPRecordButton) {
        button.setImage(#imageLiteral(resourceName: "btn_voice_record"), for: .normal)
    }
    
//    func configCustomBarItem(for type: LPInputToolBarItemType) -> UIView? {
//        let button = UIButton(type: .custom)
//        button.setImage(#imageLiteral(resourceName: "icon_team_creator"), for: .normal)
//        button.sizeToFit()
//        return button
//        //let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
//        //view.backgroundColor = UIColor.red
//        //view.addSubview(button)
//        //return view
//    }
    
    var separatorOfToolBar: [(loc: LPInputSeparatorLocation, color: UIColor?)]? {
        return [(loc: .top, color: nil), (loc: .bottom, color: nil)]
    }
}
