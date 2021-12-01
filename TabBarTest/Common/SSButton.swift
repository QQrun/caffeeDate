//
//  SSButton.swift
//  PushDemo
//
//  Created by 金融產規部-梁雅軒 on 2021/9/15.
//

import UIKit
@IBDesignable
class SSButton: UIButton {
    var openDefaultOnClickEvent = false
    enum SSButtonType: Int {
        case text = 0
        case `default` = 1
        case filled = 2
        case filledTab = 3
    }
    
    @IBInspectable var ssType: Int {
        get {
            return self.type.rawValue
        }
        set {
            self.type = SSButtonType(rawValue: newValue) ?? .text
        }
    }
    
    var type: SSButtonType = .text {
        didSet {
            fetchData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fetchData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fetchData()
    }
    
    func fetchData() {
        titleLabel?.font = .boldSystemFont(ofSize: 14)
        imageView?.tintColor = .primary()
        contentEdgeInsets = .init(top: 4, left: 8, bottom: 4, right: 8)
        layer.borderColor = UIColor.primary().cgColor
        layer.cornerRadius = 8
        if openDefaultOnClickEvent {
            addTarget(self, action: #selector(onClick), for: .touchUpInside)
        }
        tintColor = .clear
        changeStatus()
    }
    
    func changeStatus() {
        layer.borderWidth = isSelected ? 1 : 0
        backgroundColor = isSelected ? .primary().withAlphaComponent(0.12) : .clear
        setTitleColor(.on().alphaComponent(.default), for: .normal)
        setTitleColor(.primary().alphaComponent(.default), for: .selected)
        switch type {
        case .filled:
            backgroundColor = .primary()
            setTitleColor(.white, for: .normal)
        case .`default`:
            backgroundColor = isSelected ? .primary().withAlphaComponent(0.12) : .on().withAlphaComponent(0.08)
            setTitleColor(.primary().alphaComponent(.default), for: .normal)
        case .filledTab:
            backgroundColor = isSelected ? .primary() * 0.2 + .surface() * 0.8  : .clear
            layer.borderWidth = 0
        default:
            break
        }
    }
    
    @objc func onClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        changeStatus()
    }
}
