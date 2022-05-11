//
//  GiveScoreViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/05/11.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Firebase

class ScorePersonViewController: UIViewController {

    let customTopBarKit = CustomTopBarKit()
    var finishBtn : UIButton = UIButton()
    var scoreBoard : UIView = UIView()
    var commentTextView : UITextView = UITextView()
    var score : Int = 0
    
    let commentTextViewDelegate = WordLimitUITextFieldDelegate()
    var commentPlaceholder = "您可以在這寫下您對這人的鼓勵或是建議。"
    
    let UID : String!
    let name : String!
    
    init(UID: String,name:String) {
        self.UID = UID
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .surface()
        scoreBoard.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scoreBoard)
        configTopBar()
        setScoreBoard()
        setCommentTextView()
    }
    
    private func setScoreBoard(){
        drawStars(score)
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
    
    fileprivate func drawStars(_ score:Int) {
        
        let topbar = customTopBarKit.getTopBar()
        let star_y : CGFloat = 135
        let star_width : CGFloat = 40
        
        let interval : CGFloat = 6
        let star_1 = UIButton(frame: CGRect(x: view.frame.width/2 - 2.5 * star_width - interval * 2, y: star_y, width: star_width, height: star_width))
        var star_1_image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        if score > 0{
            star_1_image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        star_1.setImage(star_1_image, for: .normal)
        star_1.imageView?.contentMode = .scaleAspectFill
        star_1.tintColor = .primary()
        star_1.tag = 1
        star_1.isEnabled = true
        star_1.addTarget(self, action: #selector(starBtnAct), for: .touchUpInside)
        scoreBoard.addSubview(star_1)
        let star_2 = UIButton(frame: CGRect(x: view.frame.width/2 - 1.5 * star_width - interval * 1, y: star_y, width: star_width, height: star_width))
        var star_2_image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        if score > 1{
            star_2_image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        star_2.setImage(star_2_image, for: .normal)
        star_2.imageView?.contentMode = .scaleAspectFill
        star_2.tintColor = .primary()
        star_2.tag = 2
        star_2.isEnabled = true
        star_2.addTarget(self, action: #selector(starBtnAct), for: .touchUpInside)
        scoreBoard.addSubview(star_2)
        let star_3 = UIButton(frame: CGRect(x: view.frame.width/2 - 0.5  * star_width, y: star_y, width: star_width, height: star_width))
        var star_3_image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        if score > 2{
            star_3_image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        star_3.setImage(star_3_image, for: .normal)
        star_3.imageView?.contentMode = .scaleAspectFill
        star_3.tintColor = .primary()
        star_3.tag = 3
        star_3.isEnabled = true
        star_3.addTarget(self, action: #selector(starBtnAct), for: .touchUpInside)
        scoreBoard.addSubview(star_3)
        let star_4 = UIButton(frame: CGRect(x: view.frame.width/2 + 0.5 * star_width + interval, y: star_y, width: star_width, height: star_width))
        var star_4_image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        if score > 3{
            star_4_image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        star_4.setImage(star_4_image, for: .normal)
        star_4.tintColor = .primary()
        star_4.tag = 4
        star_4.isEnabled = true
        star_4.addTarget(self, action: #selector(starBtnAct), for: .touchUpInside)
        scoreBoard.addSubview(star_4)
        let star_5 = UIButton(frame: CGRect(x: view.frame.width/2 + 1.5 * star_width + 2 * interval, y: star_y, width: star_width, height: star_width))
        var star_5_image = UIImage(named: "EmptyStar")?.withRenderingMode(.alwaysTemplate)
        if score > 4{
            star_5_image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
        }
        star_5.setImage(star_5_image, for: .normal)
        star_5.imageView?.contentMode = .scaleAspectFill
        star_5.tintColor = .primary()
        star_5.tag = 5
        star_5.isEnabled = true
        star_5.addTarget(self, action: #selector(starBtnAct), for: .touchUpInside)
        scoreBoard.addSubview(star_5)
    }
    
    fileprivate func configTopBar() {
        customTopBarKit.CreatTopBar(view: view,showSeparator: true)
        customTopBarKit.CreatCenterTitle(text: "給" + name + "評分")
        customTopBarKit.getGobackBtn().addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
        customTopBarKit.CreatDoSomeThingTextBtn(text: "確認")
        
        finishBtn = customTopBarKit.getDoSomeThingTextBtn()
        finishBtn.addTarget(self, action: #selector(finishBtnAct), for: .touchUpInside)
        finishBtn.isEnabled = false
        finishBtn.alpha = 0.3
        
    }
    
    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func finishBtnAct(){
        
        let ref = Database.database().reference().child("PersonDetail/" + UID + "/sharedSeatScore/" + UserSetting.UID)
        
        let loadingAnimationView = UIView()
        loadingAnimationView.frame = CGRect(x: view.frame.width/2 - 60/2, y: view.frame.height/2 - 60/2, width: 60, height: 60)
        loadingAnimationView.setupToLoadingView()
        view.addSubview(loadingAnimationView)

        ref.setValue(score){ (error, ref) -> Void in
            if error != nil{
                print(error ?? "上傳sharedSeatScore失敗")
                CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController.showToast(message: "上傳評分失敗", font: .systemFont(ofSize: 14.0))
                self.navigationController?.popViewController(animated: true)
            }
            CoordinatorAndControllerInstanceHelper.rootCoordinator.rootTabBarController.showToast(message: "已完成對" + self.name + "的評分")
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
        let commentRef = Database.database().reference().child("PersonDetail/" + UID + "/sharedSeatComment/" + UserSetting.UID)
        let currentTimeString = Date().getCurrentTimeString()
        let comment = Comment(time: currentTimeString, UID: UserSetting.UID, name: UserSetting.userName,
                              gender: UserSetting.userGender,smallHeadshotURL: UserSetting.userSmallHeadShotURL, content: commentContent!, likeUIDs: nil)
        commentRef.setValue(comment.toAnyObject())
        
    }
    
    
    @objc private func starBtnAct(_ btn: UIButton){
        score = btn.tag
        scoreBoard.removeAllSubviews()
        setScoreBoard()
        if(score > 0){
            finishBtn.isEnabled = true
            finishBtn.alpha = 1
        }
    }
    
}
