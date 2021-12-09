//
//  SSAlertController.swift
//
//  Created by Tom on 2019/8/19.
//

import UIKit

class SSAlertController: ProfilePopoverViewController {
    var alertTitle: String
    var alertMessage: String?
    var alertAttributedMessage: NSAttributedString?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .init(hexString: "#111416")
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.textAlignment = .center
        label.text = alertTitle
        return label
    }()
    
    lazy var detailLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .init(hexString: "#1a2125")
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()
    
    init(title: String, message: String? = nil) {
        self.alertTitle = title
        self.alertMessage = message
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(titleLabel)

        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let constraint = titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        constraint.priority = .defaultLow
        constraint.isActive = true
        
        if let detailText = alertMessage {
            detailLabel.text = detailText
            containerView.addSubview(detailLabel)
            let separatorView = UIView(frame: .zero)
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.backgroundColor = .init(hexString: "A3AEB2")
            containerView.addSubview(separatorView)
            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
            detailLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 18).isActive = true
            
            detailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18).isActive = true
            detailLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18).isActive = true
            detailLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -18).isActive = true
        }
        else {
            if let alertAttributedMessage = alertAttributedMessage {
                detailLabel.attributedText = alertAttributedMessage
                
                let separatorView = UIView(frame: .zero)
                separatorView.translatesAutoresizingMaskIntoConstraints = false
                separatorView.backgroundColor = .init(hexString: "A3AEB2")
                containerView.addSubview(separatorView)
                separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
                separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
                separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
                separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
                
                containerView.addSubview(detailLabel)
                detailLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 18).isActive = true
                detailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18).isActive = true
                detailLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18).isActive = true
                detailLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -18).isActive = true
            }
        }
    }
}
