//
//  ListLocationViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/03/29.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class ListLocationViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    let sharedSeatAnnotations : [SharedSeatAnnotation]
    
    init(sharedSeatAnnotations:[SharedSeatAnnotation]){
        self.sharedSeatAnnotations = sharedSeatAnnotations
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var annotationTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .surface()
        
        let title = UILabel()
        title.textColor = .on().withAlphaComponent(0.7)
        title.font = UIFont(name: "HelveticaNeue-bold", size: 18)
        title.text = "聚會"
        title.frame = CGRect(x:view.frame.width/2 - title.intrinsicContentSize.width/2, y: 25 - title.intrinsicContentSize.height/2, width: title.intrinsicContentSize.width, height: title.intrinsicContentSize.height)
        view.addSubview(title)
        
        let seperator = UIView()
        seperator.frame = CGRect(x: 0, y: 49, width: view.frame.width, height: 1)
        seperator.backgroundColor = .on().withAlphaComponent(0.16)
        view.addSubview(seperator)
        
        
        
        //先將tableView除了frame的部分都設置好
        annotationTableView.delegate = self
        annotationTableView.dataSource = self
        annotationTableView.isScrollEnabled = true
        annotationTableView.bounces = false
        annotationTableView.backgroundColor = .clear
        annotationTableView.separatorColor = .clear
        annotationTableView.register(UINib(nibName: "NotifyTableViewCell", bundle: nil), forCellReuseIdentifier: "notifyTableViewCell")

        annotationTableView.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height - 50)
        view.addSubview(annotationTableView)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("sharedSeatAnnotations.count:" + "\(sharedSeatAnnotations.count)")
        return sharedSeatAnnotations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notifyTableViewCell", for: indexPath) as! NotifyTableViewCell
        
        cell.body.font = UIFont(name: "HelveticaNeue", size: 16)
        cell.body.text = sharedSeatAnnotations[indexPath.row].title
        
        let firebaseDateFormatter = DateFormatter()
        firebaseDateFormatter.dateFormat = "YYYYMMddHHmmss"
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd EEEE HH:mm"
        
        var dateTimeStr = formatter.string(from: firebaseDateFormatter.date(from: sharedSeatAnnotations[indexPath.row].dateTime)!)
        dateTimeStr = dateTimeStr.replace(target: "Monday", withString: "週一")
            .replace(target: "Tuesday", withString: "週二")
            .replace(target: "Wednesday", withString: "週三")
            .replace(target: "Thursday", withString: "週四")
            .replace(target: "Friday", withString: "週五")
            .replace(target: "Saturday", withString: "週六")
            .replace(target: "Sunday", withString: "週日")
        cell.time.textColor = .on().withAlphaComponent(0.9)
        cell.time.font = UIFont(name: "HelveticaNeue", size: 16)
        cell.time.text = dateTimeStr
        
        

        //        vm.configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.mapView.selectAnnotation(sharedSeatAnnotations[indexPath.row], animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}
