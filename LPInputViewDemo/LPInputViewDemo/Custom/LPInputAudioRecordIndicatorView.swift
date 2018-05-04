//
//  LPInputAudioRecordIndicatorView.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/5/2.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit
import LPInputView

class LPInputAudioRecordIndicatorView: UIView {

    deinit {
        print("LPInputAudioRecordIndicatorView: -> release memory.")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    func setup() {
        backgroundColor = UIColor(white: 0, alpha: 0.65)
        
    }
}

extension LPInputAudioRecordIndicatorView: LPRecordButtonDelegate {
    
    func recordButton(_ recordButton: LPRecordButton, recordPhase: LPAudioRecordPhase) {
        switch recordPhase {
        case .start:
            print("开始录制...")
        case .recording:
            print("录制中... “手指上滑，取消发送”")
        case .finished:
            print("录制完成...")
        case .cancelling:
            print("正在取消录制中... “松开手指，取消发送”")
        case .cancelled:
            print("已经取消录制...")
        }
    }
}
