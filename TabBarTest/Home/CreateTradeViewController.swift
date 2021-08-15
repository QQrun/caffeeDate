//
//  CreateTradeViewController.swift
//  TabBarTest
//
//  Created by Howard Sun on 2021/7/25.
//  Copyright © 2021 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import FloatingPanel
import PromiseKit
import MapKit
import Firebase

class CreateTradeViewController: UIViewController {
    
    enum TradeType: CaseIterable {
        case supply
        case demand
        
        var title: String {
            switch self {
            case .supply:
                return "我想要賣東西"
            case .demand:
                return "我想要買東西"
            }
        }
    }
    
    enum Section {
        case photos
        case name
        case price
        case info
    }
    
    let type: TradeType
    let coordinate: CLLocationCoordinate2D
    let sections: [Section] = [.photos, .name, .price, .info]
    
    init(type: TradeType, coordinate: CLLocationCoordinate2D) {
        self.type = type
        self.coordinate = coordinate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .white
        tableView.estimatedRowHeight = 100
        tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: "TextViewTableViewCell")
        tableView.register(AddPhotosTableViewCell.self, forCellReuseIdentifier: "AddPhotosTableViewCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        return tableView
    }()
    
    lazy var loadingView: UIView = {
        let loadingView = UIView()
        loadingView.setupToLoadingView()
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        return loadingView
    }()
    
    deinit {
        print("CreateTradeViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = type.title
        view.backgroundColor = .white
        navigationController?.additionalSafeAreaInsets = UIEdgeInsets(top: 20, left: 8, bottom: 0, right: 8)
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        navigationController?.navigationBar.tintColor = UIColor(red: 1, green: 162, blue: 153)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close-2")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "刊登", style: .plain, target: self, action: #selector(publishButtonTapped))
        let tapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        tableView.isHidden = false
        loadingView.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChangeFrame(notification: NSNotification){
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        guard let curve = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else { return }
        let keyboardHeight = UIScreen.main.bounds.height - keyboardRect.minY
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: { () -> Void in
            let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight - self.view.safeAreaInsets.bottom, right: 0)
            self.tableView.contentInset = edgeInsets
            self.tableView.scrollIndicatorInsets = edgeInsets
            self.view.layoutIfNeeded()
        })
    }
    
    
    @objc func closeButtonTapped() {
        (navigationController?.parent as? FloatingPanelController)?.dismiss(animated: true)
    }
    
    @objc func publishButtonTapped() {
    
        guard let images = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddPhotosTableViewCell)?.images,
              let name = (tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TextViewTableViewCell)?.textView.text,
              let price = (tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? TextViewTableViewCell)?.textView.text,
              let info = (tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? TextViewTableViewCell)?.textView.text else { return }
        let tasks = images.map { FirebaseHelper.uploadItemImage($0) }
        when(fulfilled: tasks).then { urls -> Promise<[Bool]> in
            let item = Item(itemID: NSUUID().uuidString, thumbnailUrl: urls.first?.absoluteString, photosUrl: urls.map({ $0.absoluteString }), name: name, price: price, descript: info, order: 0, done: false, likeUIDs: [], subscribedIDs: [], commentIDs: [], itemType: self.type == .supply ? .Sell : .Buy
            )
            let tradeAnnotation = TradeAnnotationData(openTime: Date().getCurrentTimeString(), title: name, gender: UserSetting.userGender, isOpenStore: self.type == .supply, isRequest: self.type == .demand, latitude: "\(self.coordinate.latitude)", longitude: "\(self.coordinate.longitude)")
            return when(fulfilled: [self.uploadItem(item), FirebaseHelper.uploadTradeAnnotation(tradeAnnotation)])
        }.done { _ in
            self.closeButtonTapped()
        }.catch { error in
            print(error)
        }
    }
    
    func uploadItem(_ item: Item) -> Promise<Bool> {
        return Promise<Bool> { seal in
            var ref = Database.database().reference()
            switch type {
            case .supply:
                ref = ref.child("PersonDetail/" +  UserSetting.UID + "/SellItems/" + (item.itemID ?? ""))
            case .demand:
                ref = ref.child("PersonDetail/" +  UserSetting.UID + "/BuyItems/" + (item.itemID ?? ""))
            }
            ref.setValue(item.toAnyObject()) { error, ref in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(true)
                }
            }
        }
    }
}

extension CreateTradeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.row]
        switch section {
        case .photos:
            return 112
        case .name:
            return 100
        case .price:
            return 100
        case .info:
            return 200
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

extension CreateTradeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.row]
        switch section {
        case .photos:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPhotosTableViewCell", for: indexPath) as! AddPhotosTableViewCell
            cell.viewController = self
            return cell
        case .name, .price, .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewTableViewCell", for: indexPath) as! TextViewTableViewCell
            cell.section = section
            return cell
        }
       
    }
}
