//
//  UITableView+LPInputView.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/5/4.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

extension UITableView {
    
    func lp_scrollToBottom(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let `self` = self else { return }
            let row = self.numberOfRows(inSection: 0) - 1
            if row > 0 {
                let indexPath = IndexPath(row: row, section: 0)
                self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
    
}
