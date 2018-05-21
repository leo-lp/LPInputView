//
//  LPRecordButton.swift
//  LPInputView <https://github.com/leo-lp/LPInputView>
//
//  Created by pengli on 2018/5/2.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

public protocol LPRecordButtonDelegate: class {
    func recordButton(_ recordButton: LPRecordButton, recordPhase: LPAudioRecordPhase)
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
    
    public var recordPhase: LPAudioRecordPhase = .start {
        didSet {
            isHighlighted = recordPhase == .recording
            delegate?.recordButton(self, recordPhase: recordPhase)
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
