//
//  DrawCardViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/04/10.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import MapKit

class DrawCardViewController: UIViewController {
    
    var customTopBarKit = CustomTopBarKit()
    
    let sharedSeatAnnotation:SharedSeatAnnotation
    
    var selectedName = UILabel()
    var drawBackBtn = UIButton()
    var drawCardBtn = UIButton()
    var loveCardBtn = UIButton()
    var drawForwardBtn = UIButton()
    
    var select1 = "" //選到的第一人ID
    var select2 = "" //選到的第二人ID
    
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
        
        customTopBarKit.CreatTopBar(view: view,showSeparator:true,considerSafeAreaInsets: false)
        customTopBarKit.CreatCenterTitle(text: "隨機抽卡")
        
        let gobackBtn = customTopBarKit.getGobackBtn()
        gobackBtn.addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
        selectedName = UILabel()
        selectedName.text = "😄😄😄"
        selectedName.font = selectedName.font.withSize(24)
        selectedName.textColor = .sksPurple()
        selectedName.textAlignment = .center
        selectedName.frame = CGRect(x: 0, y: view.frame.height/2 - selectedName.intrinsicContentSize.height/2, width: view.frame.width, height: selectedName.intrinsicContentSize.height)
        view.addSubview(selectedName)
        
        
        
        drawBackBtn = UIButton()
        drawBackBtn.frame = CGRect(x: view.frame.width/8 - 25, y: view.frame.height - 125 - 50, width: 50, height: 50)
        drawBackBtn.setImage(UIImage(named: "arrow_left_black_36dp"), for: .normal)
        drawBackBtn.alpha = 0.3
        view.addSubview(drawBackBtn)
        
        drawCardBtn = UIButton()
        drawCardBtn.frame = CGRect(x: (view.frame.width/8) * 3 - 30, y: view.frame.height - 125 - 55, width: 60, height: 60)
        drawCardBtn.setImage(UIImage(named: "random_card_36dp"), for: .normal)
        drawCardBtn.addTarget(self, action: #selector(drawCardBtnAct), for: .touchUpInside)
        view.addSubview(drawCardBtn)
        
        loveCardBtn = UIButton()
        loveCardBtn.frame = CGRect(x: (view.frame.width/8) * 5 - 30, y: view.frame.height - 125 - 55, width: 60, height: 60)
        loveCardBtn.setImage(UIImage(named: "love_card_36dp"), for: .normal)
        loveCardBtn.addTarget(self, action: #selector(confirmBtnAct), for: .touchUpInside)
        loveCardBtn.alpha = 0.3
        view.addSubview(loveCardBtn)
        
        drawForwardBtn = UIButton()
        drawForwardBtn.frame = CGRect(x: (view.frame.width/8) * 7 - 25, y: view.frame.height - 125 - 50, width: 50, height: 50)
        drawForwardBtn.setImage(UIImage(named: "arrow_right_black_36dp"), for: .normal)
        view.addSubview(drawForwardBtn)
      
    }
    
    private func drawCard(){
        
        if(sharedSeatAnnotation.mode == 1){ //1v1模式抽卡
            var signUpID : [String : String] = [:]
            if(UserSetting.userGender == 0){
                signUpID = sharedSeatAnnotation.signUpBoysID!
            }else{
                signUpID = sharedSeatAnnotation.signUpGirlsID!
            }
            let selectNumber = Int.random(in: 0...signUpID.count - 1)
            var i = 0
            for (UID,InvitationCode) in signUpID {
                if(i == selectNumber){
                    select1 = UID
                }
                i += 1
            }
            
            let ref = Database.database().reference().child("PersonDetail/" + "\(select1)")
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                let personInfo = PersonDetailInfo(snapshot: snapshot)
                self.selectedName.text = personInfo.name
            })
            
        }else{ //2v2模式抽卡
            
            var signUpID : [String : String] = [:]
            if(UserSetting.userGender == 0){
                signUpID = sharedSeatAnnotation.signUpBoysID!
            }else{
                signUpID = sharedSeatAnnotation.signUpGirlsID!
            }
            var pairSignUpID: [String:[String]] = [:]
            
            for (UID,InvitationCode) in signUpID {
                if pairSignUpID.index(forKey: InvitationCode) != nil {
                    pairSignUpID[InvitationCode] = [pairSignUpID[InvitationCode]![0],UID]
                }else{
                    pairSignUpID[InvitationCode] = [UID]
                }
            }
            
            let selectNumber = Int.random(in: 0...pairSignUpID.count - 1)
            var i = 0
            for (InvitationCode,IDs) in pairSignUpID {
                if(i == selectNumber){
                    select1 = IDs[0]
                    select2 = IDs[1]
                }
                i += 1
            }
            
            let ref = Database.database().reference().child("PersonDetail/" + "\(select1)")
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                let personInfo = PersonDetailInfo(snapshot: snapshot)
                print(personInfo.name)
                self.selectedName.text = self.selectedName.text! + "  " +  personInfo.name
                
            })
            
            let ref2 = Database.database().reference().child("PersonDetail/" + "\(select2)")
            ref2.observeSingleEvent(of: .value, with: {(snapshot) in
                let personInfo = PersonDetailInfo(snapshot: snapshot)
                print(personInfo.name)
                self.selectedName.text = self.selectedName.text! + "  " +  personInfo.name
            })
            
            
            
        }
        
        drawBackBtn.alpha = 1
        loveCardBtn.alpha = 1
        
    }
    
    @objc private func confirmBtnAct(){
        print("確認！")
        
        if(sharedSeatAnnotation.mode == 1){
            if select1 != ""{
                //上傳
                var updateGender = ""
                if(UserSetting.userGender == 0){
                    updateGender = "boysID"
                }else{
                    updateGender = "girlsID"
                }
                let ref = Database.database().reference().child("SharedSeatAnnotation/" + sharedSeatAnnotation.holderUID + "/" + updateGender + "/" + select1)
                ref.setValue("-"){ (error, ref) -> Void in
                    if error != nil{
                        print(error ?? "上傳參加者失敗")
                    }
                    //本地端修改
                    if(UserSetting.userGender == 0){
                        self.sharedSeatAnnotation.boysID = [:]
                        self.sharedSeatAnnotation.boysID![self.select1] = "-"
                    }else{
                        self.sharedSeatAnnotation.girlsID = [:]
                        self.sharedSeatAnnotation.girlsID![self.select1] = "-"
                    }
                    //開啟聊天室
                    
                    //退出然後刷新selectAnnotation
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popViewController(animated: true)
                    CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.mapView.deselectAnnotation(nil, animated: false)
                    let currentSharedSeatAnnotation = CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.currentSharedSeatAnnotation
                    CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.mapView.selectAnnotation(currentSharedSeatAnnotation as! MKAnnotation, animated: false)
                }
            }
        }else{
            if select1 != "" && select2 != ""{
                
            }
        }
        
        
    }
    
    @objc private func gobackBtnAct(){
//        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func drawCardBtnAct(){
        
        selectedName.text = ""
        drawCard()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
