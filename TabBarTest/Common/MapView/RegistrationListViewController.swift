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
        registrationListTableView.rowHeight = 104
        registrationListTableView.backgroundColor = .clear
        registrationListTableView.separatorColor = .clear
        registrationListTableView.register(UINib(nibName: "MailListTableViewCell", bundle: nil), forCellReuseIdentifier: "mailListTableViewCell")
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "mailListTableViewCell", for: indexPath) as! MailListTableViewCell
        
        cell.name.textColor = .on().withAlphaComponent(0.9)
        cell.age.textColor = .on().withAlphaComponent(0.9)
        cell.lastMessage.textColor = .on().withAlphaComponent(0.7)
        cell.time.textColor = .on().withAlphaComponent(0.5)
        cell.time.text = "評價：4.3(32人)"
        cell.shopName.textColor = .clear
        cell.arrowIcon.tintColor = .clear
        
        if(UserSetting.userGender == 0){
            var i = 0
            for (UID,InvitationCode) in sharedSeatAnnotation.signUpBoysID! {
                if(i == indexPath.row){
                    let ref = Database.database().reference().child("PersonDetail/" + "\(UID)")
                    ref.observeSingleEvent(of: .value, with: {(snapshot) in
                        let personInfo = PersonDetailInfo(snapshot: snapshot)
                        cell.name.text = personInfo.name
                        let birthdayFormatter = DateFormatter()
                        birthdayFormatter.dateFormat = "yyyy/MM/dd"
                        let currentTime = Date()
                        let birthDayDate = birthdayFormatter.date(from: personInfo.birthday)
                        let age = currentTime.years(sinceDate: birthDayDate!) ?? 0
                        if age != 0 {
                            cell.age.text = "\(age)"
                        }
                        cell.lastMessage.text = personInfo.selfIntroduction
                        
                        AF.request(personInfo.headShot!).response { (response) in
                            guard let data = response.data, let image = UIImage(data: data)
                            else { return }
                            cell.headShot.image = image
                        }
                        
                        self.personDetails.append(personInfo)
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
                        cell.name.text = personInfo.name
                        let birthdayFormatter = DateFormatter()
                        birthdayFormatter.dateFormat = "yyyy/MM/dd"
                        let currentTime = Date()
                        let birthDayDate = birthdayFormatter.date(from: personInfo.birthday)
                        let age = currentTime.years(sinceDate: birthDayDate!) ?? 0
                        if age != 0 {
                            cell.age.text = "\(age)"
                        }
                        cell.lastMessage.text = personInfo.selfIntroduction
                        
                        AF.request(personInfo.headShot!).response { (response) in
                            guard let data = response.data, let image = UIImage(data: data)
                            else { return }
                            cell.headShot.image = image
                        }
                        
                        self.personDetails.append(personInfo)
                    })
                }
                i += 1
            }
        }
        
        return cell
    }

}
