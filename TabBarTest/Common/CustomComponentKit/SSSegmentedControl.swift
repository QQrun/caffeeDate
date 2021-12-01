//
//  SSSegmentedControl.swift
//  StockSelect
//
//  Created by 金融產規部-梁雅軒 on 2021/11/2.
//  Copyright © 2021 mitake. All rights reserved.
//

import Foundation
class SSSegmentedControl: UISegmentedControl {
    enum SegmentedType {
        case filledDefauly
        case outling
        case pure
    }
    var type: SegmentedType = .filledDefauly
    init(items: [Any]?,type: SegmentedType = .filledDefauly) {
        super.init(frame: .zero)
        self.type = type
        if let items = items {
            for (index,item) in items.enumerated() {
                if let title = item as? String {
                    self.insertSegment(withTitle: title, at: index, animated: false)
                }
            }
        }
        fetchData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fetchData()
    }
    
    func fetchData() {
        if #available(iOS 13.0, *) {
            self.selectedSegmentTintColor = UIColor.primary() * 0.2 + UIColor.surface() * 0.8
        } else {
            
        }
        self.layer.borderColor = UIColor.on().withAlphaComponent(0.12).cgColor
        self.layer.borderWidth = self.type == .pure ? 0 : 1
        self.backgroundColor = .clear
        self.tintColor = .clear
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.on().alphaComponent(.default)]
        self.setTitleTextAttributes(titleTextAttributes, for: .normal)
        let selectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.primary().alphaComponent(.default)]
        self.setTitleTextAttributes(selectedTitleTextAttributes, for: .selected)
    }
}
