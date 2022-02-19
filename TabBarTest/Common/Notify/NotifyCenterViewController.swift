//
//  NotifyCenterViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/09.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Alamofire
import Firebase


protocol NotifyCenterViewControllerDelegate: class {
    func gotoItemViewController_NotifyCenterView(item : Item,itemOwnerID:String)
}


class NotifyCenterViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    var notifyListTableView = UITableView()
    weak var viewDelegate: NotifyCenterViewControllerDelegate?
    var vm = NotifyCenterViewControllerModel()
    var customTopBarKit = CustomTopBarKit()
    
    //一起動App需要先監聽
    override func awakeFromNib() {
        super.awakeFromNib()
        configTableView()
        vm.delegate = self
        vm.startListenPostNotifcations()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        CoordinatorAndControllerInstanceHelper.rootCoordinator.hiddenTabBar()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("NotifyCenterViewController viewDidLoad")
        
        view.backgroundColor = .surface()
        configTopBar()
        configNotifyListTableViewFrame()
    }
    
    
    fileprivate func configTopBar() {
        customTopBarKit.CreatTopBar(view: view,showSeparator:true)
        customTopBarKit.showGobackBtn()
        customTopBarKit.getGobackBtn().addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        customTopBarKit.CreatCenterTitle(text: "通知")
    }
    
    
    fileprivate func configTableView() {
        //先將tableView除了frame的部分都設置好
        notifyListTableView.delegate = self
        notifyListTableView.dataSource = self
        notifyListTableView.isScrollEnabled = true
        notifyListTableView.bounces = false
        notifyListTableView.backgroundColor = .clear
        notifyListTableView.separatorColor = .clear
        notifyListTableView.register(UINib(nibName: "NotifyTableViewCell", bundle: nil), forCellReuseIdentifier: "notifyTableViewCell")
    }
    
    fileprivate func configNotifyListTableViewFrame() {
        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        let topPadding = window?.safeAreaInsets.top ?? 0
        notifyListTableView.frame = CGRect(x: 0, y: topPadding + 45, width: view.frame.width, height: view.frame.height - topPadding - bottomPadding - 1)
        view.addSubview(notifyListTableView)
    }
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        for subView in tableView.subviews{
            if subView.tag == 999{
                subView.removeFromSuperview()
            }
        }
        
        if vm.postNotifcations.count == 0{
            let noDataLabel = { () -> UILabel in
                let label = UILabel()
                let str = "目前還沒有任何通知喔！"
                let paraph = NSMutableParagraphStyle()
                paraph.lineSpacing = 8
                let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15),
                                  NSAttributedString.Key.paragraphStyle: paraph]
                label.attributedText = NSAttributedString(string: str, attributes: attributes)
                label.numberOfLines = 0
                label.textColor = .gray
                label.textAlignment = .center
                label.font = UIFont(name: "HelveticaNeue", size: 16)
                label.frame = CGRect(x: tableView.frame.width/2 - label.intrinsicContentSize.width/2, y: 45, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
                label.tag = 999
                return label
            }()
            tableView.addSubview(noDataLabel)
        }
        
        return vm.postNotifcations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notifyTableViewCell", for: indexPath) as! NotifyTableViewCell
        
        vm.configure(cell: cell, at: indexPath)
        
        return cell
        
    }
    
    
    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: false)
        
        let cell = tableView.cellForRow(at: indexPath) as! NotifyTableViewCell
        vm.didSelectRowAt(cell: cell, indexPath: indexPath)
        
    }
    
    
    @objc func gobackBtnAct(){
        CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.selectedViewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.mapTab
    }
    
}


extension NotifyCenterViewController: NotifyCenterViewControllerModelDelegate{
    func reloadData() {
        notifyListTableView.reloadData()
    }
    
    func gotoItemView(item:Item,itemOwnerID:String) {
        viewDelegate?.gotoItemViewController_NotifyCenterView(item: item, itemOwnerID: itemOwnerID)
    }
    
    func showToast(message: String) {
        self.showToast(message: message, font: .systemFont(ofSize: 14.0))
    }
    
}
