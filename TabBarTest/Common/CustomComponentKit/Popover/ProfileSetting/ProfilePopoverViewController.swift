//
//  SSPopoverViewController.swift
//
//  Created by Tom on 2020/1/10.
//

import UIKit

extension NSNotification.Name {
    static var ProfilePopoverKeyboardWillShow = NSNotification.Name(rawValue: "ProfilePopoverKeyboardWillShow")
    static var ProfilePopoverKeyboardWillHide = NSNotification.Name(rawValue: "ProfilePopoverKeyboardWillHide")
}

class ProfilePopoverViewController: UIViewController {
    var actions = Array<ProfilePopoverAction>()
    var tapToDismiss: Bool = true
    var confirmButton: UIButton?
    var cancelButton: UIButton?
    var backDropAction: (() -> Void)?
    lazy var vStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()

    lazy var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var buttonContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hStackView)
        hStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        hStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        hStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        hStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        hStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return view
    }()
    
    lazy var hStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()

    lazy var presentationManagerDelegate = ProfilePopoverPresentationManager()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = presentationManagerDelegate
        modalPresentationStyle = .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewYPosition = view.frame.origin.y
            let viewHeight = view.frame.size.height
            let keyboardHeight = keyboardSize.height
            let screnHeight = UIScreen.main.bounds.size.height

            // view距離bottom的高度 (螢幕整體高度 - y距離 - 本身畫面高度)
            let bottomMargin = screnHeight - viewYPosition - viewHeight

            // 若鍵盤高度高於底部高度 則需要位移
            if keyboardHeight > bottomMargin {
                let yOffSet = keyboardHeight - bottomMargin
                view.frame.origin.y -= (yOffSet + 37)
            }
        }
        
        NotificationCenter.default.post(name: .ProfilePopoverKeyboardWillShow, object: nil, userInfo: notification.userInfo)
    }
        
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let center = view.superview?.center {
            view.center = center
        }
        NotificationCenter.default.post(name: .ProfilePopoverKeyboardWillHide, object: nil, userInfo: notification.userInfo)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        view.backgroundColor = .init(hexString: "#e1e1e1")
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        let screenWidth = UIScreen.main.bounds.size.width
        let margin = 33
        
        view.addSubview(vStackView)
        vStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        let leadingConstraint = vStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        leadingConstraint.priority = .defaultLow
        leadingConstraint.isActive = true
        
        let trailingConstraint = vStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        trailingConstraint.priority = .defaultLow
        trailingConstraint.isActive = true
        
        vStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        vStackView.widthAnchor.constraint(equalToConstant: screenWidth-CGFloat((margin*2))).isActive = true
        
        vStackView.addArrangedSubview(containerView)
        
        if hStackView.arrangedSubviews.count > 0 {
            vStackView.addArrangedSubview(buttonContainerView)
        }
    }
    
    func addAction(_ action: ProfilePopoverAction) {
        let button = DesignableButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.setTitleColor(.init(hexString: "#ffffff"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitle(action.title, for: .normal)
        button.addTarget(action, action: #selector(SSPopoverAction.performAction), for: .touchUpInside)
        
        switch action.style {
            case .default:
                button.setBackgroundColor(.init(hexString: "#24adf6"), for: .normal)
                button.setBackgroundColor(.init(hexString: "#4e595c", alpha: 0.15), for: .disabled)
                confirmButton = button
            case .cancel:
                button.setBackgroundColor(.init(hexString: "#4e595c"), for: .normal)
                cancelButton = button
        }
        
        hStackView.addArrangedSubview(button)
        
        actions.append(action)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        actions.removeAll()
    }
}

class ProfilePopoverAction {
    var style: ProfilePopoverAction.Style
    var title: String?
    var handler: ((ProfilePopoverAction) -> Void)?
    
    @objc func performAction() {
        handler?(self)
    }
    
    init(title: String?, style: ProfilePopoverAction.Style, handler: ((ProfilePopoverAction) -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

extension ProfilePopoverAction {
    enum Style {
        case `default`
        case cancel
    }
}
