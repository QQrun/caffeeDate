//
//  ScoreCoffeeViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/01/29.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ScoreCoffeeViewController : UIViewController{
        
    var annotation : CoffeeAnnotation
    var scoreBoard : UIView = UIView()
    var finishBtn : UIButton = UIButton()
    var commentTextView : UITextView = UITextView()
    
    var wifiScore : Int = 0
    var quietScore : Int = 0
    var seatScore : Int = 0
    var tastyScore : Int = 0
    var cheapScore : Int = 0
    var musicScore : Int = 0
    
    let commentTextViewDelegate = WordLimitUITextFieldDelegate()
    var commentPlaceholder = "您可以在這寫下您對這間店的評價、建議或是鼓勵。"
    
    init(annotation:CoffeeAnnotation) {
        self.annotation = annotation
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setBackground()
        setScoreBoard()
        setCommentTextView()
    }
    
    fileprivate func setCommentTextView() {
        let itemNameLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "留言"
            label.textColor = .on().withAlphaComponent(0.9)
            label.font = UIFont(name: "HelveticaNeue-bold", size: 16)
            label.frame = CGRect(x: 16, y: 220, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        view.addSubview(itemNameLabel)
        
        let separator = { () -> UIView in
            let separator = UIView()
            separator.backgroundColor = .on().withAlphaComponent(0.08)
            separator.frame = CGRect(x: 15, y:itemNameLabel.frame.origin.y + itemNameLabel.frame.height + 7, width: view.frame.width - 30, height: 1)
            
            return separator
        }()
        view.addSubview(separator)
        
        commentTextView = { () -> UITextView in
            let textView = UITextView()
            textView.tintColor = .primary()
            textView.frame = CGRect(x:20, y: separator.frame.origin.y + separator.frame.height, width: view.frame.width - 20 * 2, height: 400)
            textView.returnKeyType = .default
            textView.textColor =  .on().withAlphaComponent(0.5)
            textView.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            textView.backgroundColor = .clear
            textView.text = commentPlaceholder
            commentTextViewDelegate.placeholder = commentPlaceholder
            commentTextViewDelegate.placeholderColor = .on().withAlphaComponent(0.5)
            commentTextViewDelegate.wordLimit = 1000
            textView.delegate = commentTextViewDelegate
            textView.tintColor = .on().withAlphaComponent(0.3)
            return textView
        }()
        view.addSubview(commentTextView)
    }
    
    fileprivate func setBackground() {
        view.backgroundColor = .surface()
        
        scoreBoard.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scoreBoard)
        
        let customTopBarKit = CustomTopBarKit()
        customTopBarKit.CreatTopBar(view: view,showSeparator: true)
        customTopBarKit.CreatCenterTitle(text: annotation.name)
        customTopBarKit.getGobackBtn().addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        customTopBarKit.CreatDoSomeThingTextBtn(text: "完成")
        finishBtn = customTopBarKit.getDoSomeThingTextBtn()
        finishBtn.addTarget(self, action: #selector(finishBtnAct), for: .touchUpInside)
        finishBtn.isEnabled = false
        finishBtn.alpha = 0.3
    }
    
    fileprivate func setScoreBoard(){
        
        
        
        let wifiLabel = UILabel()
        wifiLabel.text = "WIFI穩定"
        wifiLabel.textColor = .on()
        wifiLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        wifiLabel.frame = CGRect(x: 10, y: 103, width: wifiLabel.intrinsicContentSize.width, height: wifiLabel.intrinsicContentSize.height)
        scoreBoard.addSubview(wifiLabel)
        drawStarsAfterLabel(scoreBoard,wifiLabel,wifiScore,0)
        let labelHeightWithInterval = wifiLabel.intrinsicContentSize.height + 16
        
        let quietLabel = UILabel()
        quietLabel.text = "安靜程度"
        quietLabel.textColor = .on()
        quietLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        quietLabel.frame = CGRect(x: 10, y: 103 + labelHeightWithInterval, width: quietLabel.intrinsicContentSize.width, height: quietLabel.intrinsicContentSize.height)
        drawStarsAfterLabel(scoreBoard,quietLabel,quietScore,1)
        scoreBoard.addSubview(quietLabel)
        
        let seatLabel = UILabel()
        seatLabel.text = "通常有位"
        seatLabel.textColor = .on()
        seatLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        seatLabel.frame = CGRect(x: 10, y: 103 + labelHeightWithInterval * 2, width: seatLabel.intrinsicContentSize.width, height: seatLabel.intrinsicContentSize.height)
        drawStarsAfterLabel(scoreBoard,seatLabel,seatScore,2)
        scoreBoard.addSubview(seatLabel)
        
        
        let tastyLabel = UILabel()
        tastyLabel.text = "咖啡好喝"
        tastyLabel.textColor = .on()
        tastyLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        tastyLabel.frame = CGRect(x: view.frame.width/2 + 10, y: 103, width: tastyLabel.intrinsicContentSize.width, height: tastyLabel.intrinsicContentSize.height)
        drawStarsAfterLabel(scoreBoard,tastyLabel,tastyScore,3)
        scoreBoard.addSubview(tastyLabel)
        
        let cheapLabel = UILabel()
        cheapLabel.text = "價格便宜"
        cheapLabel.textColor = .on()
        cheapLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        cheapLabel.frame = CGRect(x: view.frame.width/2 + 10, y: 103 + labelHeightWithInterval, width: cheapLabel.intrinsicContentSize.width, height: cheapLabel.intrinsicContentSize.height)
        drawStarsAfterLabel(scoreBoard,cheapLabel,cheapScore,4)
        scoreBoard.addSubview(cheapLabel)
        
        let musicLabel = UILabel()
        musicLabel.text = "裝潢音樂"
        musicLabel.textColor = .on()
        musicLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        musicLabel.frame = CGRect(x: view.frame.width/2 + 10, y: 103 + labelHeightWithInterval * 2, width: musicLabel.intrinsicContentSize.width, height: musicLabel.intrinsicContentSize.height)
        drawStarsAfterLabel(scoreBoard,musicLabel,musicScore,5)
        scoreBoard.addSubview(musicLabel)
        
    }
    
    
    fileprivate func drawStarsAfterLabel(_ board: UIView,_ label: UILabel,_ score:Int,_ scorePosition:Int) {
        
        let interval : CGFloat = 4
        let star_1 = UIButton(frame: CGRect(x: label.frame.origin.x - 100 + view.frame.width/2 - interval * 4, y: label.frame.origin.y - 1, width: 20, height: 20))
        var star_1_image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        if score > 0{
            star_1_image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        star_1.setImage(star_1_image, for: .normal)
        star_1.tintColor = .primary()
        star_1.tag = scorePosition * 10 + 1
        star_1.isEnabled = true
        star_1.addTarget(self, action: #selector(starBtnAct), for: .touchUpInside)
        board.addSubview(star_1)
        let star_2 = UIButton(frame: CGRect(x: label.frame.origin.x - 84 + view.frame.width/2 - interval * 3, y: label.frame.origin.y - 1, width: 20, height: 20))
        var star_2_image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        if score > 1{
            star_2_image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        star_2.setImage(star_2_image, for: .normal)
        star_2.tintColor = .primary()
        star_2.tag = scorePosition * 10 + 2
        star_2.isEnabled = true
        star_2.addTarget(self, action: #selector(starBtnAct), for: .touchUpInside)
        board.addSubview(star_2)
        let star_3 = UIButton(frame: CGRect(x: label.frame.origin.x - 68 + view.frame.width/2 - interval * 2, y: label.frame.origin.y - 1, width: 20, height: 20))
        var star_3_image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        if score > 2{
            star_3_image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        star_3.setImage(star_3_image, for: .normal)
        star_3.tintColor = .primary()
        star_3.tag = scorePosition * 10 + 3
        star_3.isEnabled = true
        star_3.addTarget(self, action: #selector(starBtnAct), for: .touchUpInside)
        board.addSubview(star_3)
        let star_4 = UIButton(frame: CGRect(x: label.frame.origin.x - 52 + view.frame.width/2 - interval, y: label.frame.origin.y - 1, width: 20, height: 20))
        var star_4_image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        if score > 3{
            star_4_image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        star_4.setImage(star_4_image, for: .normal)
        star_4.tintColor = .primary()
        star_4.tag = scorePosition * 10 + 4
        star_4.isEnabled = true
        star_4.addTarget(self, action: #selector(starBtnAct), for: .touchUpInside)
        board.addSubview(star_4)
        let star_5 = UIButton(frame: CGRect(x: label.frame.origin.x - 36 + view.frame.width/2, y: label.frame.origin.y - 1, width: 20, height: 20))
        var star_5_image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        if score > 4{
            star_5_image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        star_5.setImage(star_5_image, for: .normal)
        star_5.tintColor = .primary()
        star_5.tag = scorePosition * 10 + 5
        star_5.isEnabled = true
        star_5.addTarget(self, action: #selector(starBtnAct), for: .touchUpInside)
        board.addSubview(star_5)
    }
    
    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func finishBtnAct(){
        
    
        let ref = Database.database().reference().child("CoffeeScore/" +  annotation.address + "/" + UserSetting.UID)
        
        let coffeeScoreData = CoffeeScoreData(wifiScore: wifiScore, quietScore: quietScore, seatScore: seatScore, tastyScore: tastyScore, cheapScore: cheapScore, musicScore: musicScore)
        
        
        let loadingAnimationView = UIView()
        loadingAnimationView.frame = CGRect(x: view.frame.width/2 - 60/2, y: view.frame.height/2 - 60/2, width: 60, height: 60)
        loadingAnimationView.setupToLoadingView()
        view.addSubview(loadingAnimationView)

        ref.setValue(coffeeScoreData.toAnyObject()){ (error, ref) -> Void in
            if error != nil{
                print(error ?? "上傳coffeeScoreData失敗")
                CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.showToast(message: "上傳評分失敗", font: .systemFont(ofSize: 14.0))
                self.navigationController?.popViewController(animated: true)
            }
            
            CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.refresh_bulletinBoard_CoffeeShop()
            CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.showToast(message: "已完成對" + "\(self.annotation.name)" + "的評分", font: .systemFont(ofSize: 14.0))
            self.navigationController?.popViewController(animated: true)
        }
        
        
        //上傳留言
        let commentContent = commentTextView.text
        if commentContent! == commentPlaceholder{
            return
        }
        if commentContent!.trimmingCharacters(in: [" "]) == ""{
            return
        }
        let commentID = NSUUID().uuidString
        let commentRef = Database.database().reference(withPath: "CoffeeComment/" + annotation.address + "/" + commentID)
        let currentTimeString = Date().getCurrentTimeString()
        let comment = Comment(time: currentTimeString, UID: UserSetting.UID, name: UserSetting.userName,
                              gender: UserSetting.userGender, content: commentContent!, likeUIDs: nil)
        commentRef.setValue(comment.toAnyObject())
        
        
    }
    
    @objc private func starBtnAct(_ btn: UIButton){
       
        let currentScorePosition = btn.tag/10
        let score = btn.tag % 10
        
        if(currentScorePosition == 0){
            wifiScore = score
        }else if(currentScorePosition == 1){
            quietScore = score
        }else if(currentScorePosition == 2){
            seatScore = score
        }else if(currentScorePosition == 3){
            tastyScore = score
        }else if(currentScorePosition == 4){
            cheapScore = score
        }else if(currentScorePosition == 5){
            musicScore = score
        }
        
        scoreBoard.removeAllSubviews()
        setScoreBoard()
        
        
        if(wifiScore > 0 && quietScore > 0 && seatScore > 0 &&
           tastyScore > 0 && cheapScore > 0 && musicScore > 0){
            finishBtn.isEnabled = true
            finishBtn.alpha = 1
        }
    }
    
    
}
