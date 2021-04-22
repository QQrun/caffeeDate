//
//  AppCoordinator.swift
//  StockSelect
//
//  Created by Tom on 2019/4/29.
//  Copyright © 2019 mitake. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    let window: UIWindow?
    var rootTabBarViewController: RootTabBarController?
    
    // MARK: - Coordinator
    init(window: UIWindow?) {
        self.window = window
    }
    
    override func start() {
        rootTabBarViewController = window?.rootViewController as? RootTabBarController
        let rootCoordinator = RootCoordinator(rootTabBarController: rootTabBarViewController!)
        addChildCoordinator(rootCoordinator)
        rootCoordinator.start()
    }
}
