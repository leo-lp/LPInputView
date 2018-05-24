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
    let stateLbl: UILabel = UILabel(frame: UIScreen.main.bounds)
    
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
        
        stateLbl.textColor = UIColor.white
        stateLbl.textAlignment = .center
        stateLbl.font = UIFont.boldSystemFont(ofSize: 17)
        addSubview(stateLbl)
    }
}

extension LPInputAudioRecordIndicatorView: LPRecordButtonDelegate {
    
    func recordButton(_ recordButton: LPRecordButton, recordPhase: LPAudioRecordPhase) {
        let msg: String
        switch recordPhase {
        case .start:
            msg = "开始录制..."
        case .recording:
            msg = "录制中... “手指上滑，取消发送”"
        case .finished:
            msg = "录制完成..."
        case .cancelling:
            msg = "正在取消录制中... “松开手指，取消发送”"
        case .cancelled:
            msg = "已经取消录制..."
        }
        stateLbl.text = msg
    }
}
