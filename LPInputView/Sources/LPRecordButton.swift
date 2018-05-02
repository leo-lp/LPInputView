//
//  LPRecordButton.swift
//  LPInputView
//
//  Created by pengli on 2018/5/2.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

public protocol LPRecordButtonDelegate: class {
    
}

public enum LPAudioRecordPhase {
    case start
    case recording
    case cancelling
    case finished
}
public class LPRecordButton: UIButton {
    weak var delegate: LPRecordButtonDelegate?
    lazy var recordPhase: LPAudioRecordPhase = .start
    lazy var maxRecordTime: Float = 20.0 // 最大录制时间（秒）
    
    func setup(with del: LPRecordButtonDelegate?) {
        delegate = del
        
        addTarget(self, action: #selector(onTouchDown), for: .touchDown)
        addTarget(self, action: #selector(onTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(onTouchUpOutsideOrCancel), for: [.touchUpOutside, .touchCancel])
        addTarget(self, action: #selector(onTouchDragInside(_:event:)), for: .touchDragInside)
    }
    
    /// 当按下按钮
    @objc private func onTouchDown() {
        recordPhase = .start
        print("开始录音")
    }
    
    /// 按钮内部松开（注：实际Touch区域比按钮的bounds大70px）
    @objc private func onTouchUpInside() {
//        if touchType == .dragExit {
//            touchType = .upOutsideOrCancel
//            cancelRecord()
//        } else {
//            touchType = .upInside
//            stopRecordAndSend()
//        }
        
        print("结束")
    }
    
    /// 按钮外部松开或取消（注：实际Touch区域比按钮的bounds大70px）
    @objc private func onTouchUpOutsideOrCancel() {
        recordPhase = .cancelling
        print("取消")
    }
    
    /// 按钮内部拖动（注：实际Touch区域比按钮的bounds大70px）
    @objc private func onTouchDragInside(_ sender: UIButton, event: UIEvent) {
        guard let touch = event.allTouches?.first else { return }
        if bounds.contains(touch.location(in: self)) {
//            if touchType == .dragExit && touchType != .dragEnter {
//                touchType = .dragEnter
//                hud?.state = .dragEnter /// 进入按钮范围
//            }
            
            print("手指上滑，取消发送")
        } else {
            recordPhase = .cancelling
            print("松开手指，取消发送")
        }
    }
    //
    //    /// 正常停止录音，开始转换数据
    //    private func stopRecordAndSend() {
    //        mp3.stopRecord(type)
    //        hud?.dismiss()
    //    }
    //
    //    /// 取消录音
    //    private func cancelRecord() {
    //        mp3.cancelRecord()
    //        guard let hud = hud else { return }
    //        hud.dismiss()
    //        hud.state = .recordCancel
    //    }
    
}
