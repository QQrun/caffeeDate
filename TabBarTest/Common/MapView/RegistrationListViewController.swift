//
//  ParticipantsViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/04/09.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Alamofire
import Firebase


protocol RegistrationListViewDelegant: class {
    func gotoDrawCardPage(sharedSeatAnnotation:SharedSeatAnnotation)
}
class RegistrationListViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    let sharedSeatAnnotation:SharedSeatAnnotation
    var registrationListTableView = UITableView()
    var customTopBarKit = CustomTopBarKit()
    
    weak var viewDelegate: RegistrationListViewDelegant?
    
    var personDetails : [PersonDetailInfo] = []
    
    init(sharedSeatAnnotation:SharedSeatAnnotation){
        self.sharedSeatAnnotation = sharedSeatAnnotation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .surface()
        
        customTopBarKit.CreatTopBar(view: view,showSeparator:true)
        customTopBarKit.CreatDoSomeThingTextBtn(text: "抽卡")
        customTopBarKit.CreatCenterTitle(text: "報名列表")
        let gobackBtn = customTopBarKit.getGobackBtn()
        gobackBtn.addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
        let drawCardBtn = customTopBarKit.getDoSomeThingBtn()
        drawCardBtn.addTarget(self, action: #selector(drawCardBtnAct), for: .touchUpInside)
        
        //先將tableView除了frame的部分都設置好
        registrationListTableView.delegate = self
        registrationListTableView.dataSource = self
        registrationListTableView.isScrollEnabled = true
        registrationListTableView.bounces = false
        registrationListTableView.rowHeight = 80
        registrationListTableView.backgroundColor = .clear
        registrationListTableView.separatorColor = .clear
        registrationListTableView.register(RegistrationListViewCell.self, forCellReuseIdentifier: "registrationListViewCell")
        
        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        let topPadding = window?.safeAreaInsets.top ?? 0
        registrationListTableView.frame = CGRect(x: 0, y: topPadding + 45, width: view.frame.width, height: view.frame.height - topPadding - bottomPadding - 1)
        view.addSubview(registrationListTableView)
        
    }
    
    @objc private func drawCardBtnAct(){
        viewDelegate?.gotoDrawCardPage(sharedSeatAnnotation: sharedSeatAnnotation)
    }

    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(UserSetting.userGender == 0){
            return sharedSeatAnnotation.signUpBoysID?.count ?? 0
        }else{
            return sharedSeatAnnotation.signUpGirlsID?.count ?? 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "registrationListViewCell", for: indexPath) as! RegistrationListViewCell
        
        
        if(UserSetting.userGender == 0){
            var i = 0
            for (UID,InvitationCode) in sharedSeatAnnotation.signUpBoysID! {
                if(i == indexPath.row){
                    let ref = Database.database().reference().child("PersonDetail/" + "\(UID)")
                    ref.observeSingleEvent(of: .value, with: {(snapshot) in
                        let personInfo = PersonDetailInfo(snapshot: snapshot)
                        let birthdayFormatter = DateFormatter()
                        birthdayFormatter.dateFormat = "yyyy/MM/dd"
                        let currentTime = Date()
                        let birthDayDate = birthdayFormatter.date(from: personInfo.birthday)
                        let age = currentTime.years(sinceDate: birthDayDate!) ?? 0
                        if age != 0 {
                            cell.setContent(UID: UID, gender: .Boy, name: personInfo.name, age: String(age), selfIntroduction: personInfo.selfIntroduction, evaluation: "3.2 (23人)")
                        }
                    })
                }
                i += 1
            }
        }else{
            var i = 0
            for (UID,InvitationCode) in sharedSeatAnnotation.signUpGirlsID! {
                if(i == indexPath.row){
                    let ref = Database.database().reference().child("PersonDetail/" + "\(UID)")
                    ref.observeSingleEvent(of: .value, with: {(snapshot) in
                        let personInfo = PersonDetailInfo(snapshot: snapshot)
                        let birthdayFormatter = DateFormatter()
                        birthdayFormatter.dateFormat = "yyyy/MM/dd"
                        let currentTime = Date()
                        let birthDayDate = birthdayFormatter.date(from: personInfo.birthday)
                        let age = currentTime.years(sinceDate: birthDayDate!) ?? 0
                        if age != 0 {
                            cell.setContent(UID: UID, gender: .Girl, name: personInfo.name, age: String(age), selfIntroduction: personInfo.selfIntroduction, evaluation: "3.2 (23人)")
                        }
                    })
                }
                i += 1
            }
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath) as? RegistrationListViewCell
        cell?.goProfile()
        
    }

}
