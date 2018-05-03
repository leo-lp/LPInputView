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
    case finished
    case cancelling
    case cancelled
}
public class LPRecordButton: UIButton {
    private var trackingY: CGFloat = 0.0
    
    public weak var delegate: LPRecordButtonDelegate?
    
    public var recordPhase: LPAudioRecordPhase? {
        didSet {
            guard let phase = recordPhase else { return }
            switch phase {
            case .start:      print("开始录制...")
            case .recording:
                isHighlighted = true
                print("录制中... “手指上滑，取消发送”")
                return
            case .finished:   print("录制完成准备发送...")
            case .cancelling: print("正在取消录制中... “松开手指，取消发送”")
            case .cancelled:  print("已经取消录制...")
            }
            isHighlighted = false
        }
    }
    
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
        recordPhase = .recording
    }
    
    /// 按钮内部松开（注：实际Touch区域比按钮的bounds大35pt）
    @objc private func onTouchUpInside() {
        if recordPhase == .cancelling {
            recordPhase = .cancelled
        } else {
            recordPhase = .finished
        }
    }
    
    /// 按钮外部松开或取消（注：实际Touch区域比按钮的bounds大35pt）
    @objc private func onTouchUpOutsideOrCancel() {
        recordPhase = .cancelled
    }
    
    /// 按钮内部拖动（注：实际Touch区域比按钮的bounds大35pt）
    @objc private func onTouchDragInside(_ sender: UIButton, event: UIEvent) {
        guard let touch = event.allTouches?.first else { return }
        let loc = touch.location(in: self)
        if bounds.contains(loc) {
            recordPhase = .recording
        } else {
            if loc.y <= bounds.height / 2 {
                recordPhase = .cancelling
            } else {
                recordPhase = .recording
            }
        }
    }
}
