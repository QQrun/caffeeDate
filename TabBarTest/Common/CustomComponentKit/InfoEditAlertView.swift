//
//  StrategyStockInfoEditAlertView.swift
//  StockSelect
//
//  Created by mitake on 2020/10/23.
//  Copyright © 2020 mitake. All rights reserved.
//

import UIKit

class InfoEditAlertView: UIView {
    @IBOutlet weak var viewLine: UIView!
    @IBOutlet weak var lblPageName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    func setColor() {
        viewLine.backgroundColor = .on().withAlphaComponent(0.12)
        lblTitle.textColor = .on().alphaComponent(.default)
        messageLabel.textColor = .on().alphaComponent(.default)
        lblPageName.textColor = .on().alphaComponent(.default)
        inputTextField.textColor = .on().alphaComponent(.default)
    }
}
