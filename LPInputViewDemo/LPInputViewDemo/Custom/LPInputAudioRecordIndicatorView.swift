//
//  LPInputAudioRecordIndicatorView.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/5/2.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPInputAudioRecordIndicatorView: UIView {

    deinit {
        print("LPInputAudioRecordIndicatorView: -> release memory.")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return UIScreen.main.bounds.size
    }
    
}
