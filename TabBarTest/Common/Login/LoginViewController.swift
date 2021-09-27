//
//  LoginViewController.swift
//  TabBarTest
//
//  Created by Howard Sun on 2021/9/27.
//  Copyright © 2021 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    lazy var googleLoginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign in with Google", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(googleLogin), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(googleLoginButton)
        googleLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
    }
    
    @objc func googleLogin() {
        print("googleLogin")
    }

}
