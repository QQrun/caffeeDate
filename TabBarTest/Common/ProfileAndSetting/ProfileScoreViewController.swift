//
//  ProfileScoreViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/05/12.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class ProfileScoreViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let customTopBarKit = CustomTopBarKit()
    let personDetail : PersonDetailInfo!
    
    var commentTableView = UITableView()
    
    var comments : [Comment] = []
    
    //防止重複下載
    var commenterHeadShotDict = [String:UIImage]()
    
    init(personDetail: PersonDetailInfo) {
        self.personDetail = personDetail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .surface()
        preprocessing()
        configTopBar()
        configContent()
    }
    
    fileprivate func preprocessing() {
        for (key,value) in personDetail.sharedSeatComment {
            comments.append(value)
        }
    }
    
    fileprivate func configTopBar() {
        customTopBarKit.CreatTopBar(view: view,showSeparator: true)
        customTopBarKit.CreatCenterTitle(text: personDetail.name)
        customTopBarKit.getGobackBtn().addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
    }
    fileprivate func configContent() {
        let topbar = customTopBarKit.getTopBar()
        
        var scoreCount = 0
        var scoreTotalAmount = 0
        for (key,value) in personDetail.sharedSeatScore{
            let score = value
            if(score != 0){
                scoreTotalAmount += score
                scoreCount += 1
            }
        }
        var averageScore : Float = 0
        if(scoreCount != 0){
            averageScore = Float(scoreTotalAmount)/Float(scoreCount)
        }
        
        let scoreLabel = UILabel()
        scoreLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        scoreLabel.textColor = .on().withAlphaComponent(0.7)
        scoreLabel.text = String(format: "%.1f", averageScore) + " (" + "\(scoreCount)" + "人)"
        scoreLabel.frame = CGRect(x: view.frame.width - 16 - scoreLabel.intrinsicContentSize.width, y: topbar.frame.origin.y + topbar.frame.height + 6, width: scoreLabel.intrinsicContentSize.width, height: scoreLabel.intrinsicContentSize.height)
        view.addSubview(scoreLabel)
        
        
        let starImageView : UIImageView = {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: view.frame.width - 20 - 16 - scoreLabel.intrinsicContentSize.width - 4, y: topbar.frame.height + topbar.frame.height + 7.5, width: 20, height: 20)
            imageView.contentMode = .scaleAspectFill
            imageView.backgroundColor = .clear
            imageView.tintColor = UIColor.hexStringToUIColor(hex: "#FBBC05")
            imageView.clipsToBounds = true
            imageView.image = UIImage(named: "FullStar")?.withRenderingMode(.alwaysTemplate)
            return imageView
        }()
        view.addSubview(starImageView)
        
        let commentTableView_y = topbar.frame.origin.y + topbar.frame.height  + scoreLabel.intrinsicContentSize.height + 12
        let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        commentTableView.frame = CGRect(x: 0, y: commentTableView_y, width: view.frame.width, height: view.frame.height - commentTableView_y - bottomPadding)
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "commentTableViewCell")
        commentTableView.backgroundColor = .clear
        commentTableView.separatorColor = .clear
        commentTableView.allowsSelection = false
        commentTableView.bounces = false
        commentTableView.isScrollEnabled = false
        commentTableView.rowHeight = UITableView.automaticDimension
        commentTableView.estimatedRowHeight = 54.0
        
        view.addSubview(commentTableView)
        
    }
    
    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personDetail.sharedSeatComment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentTableViewCell", for: indexPath) as! CommentTableViewCell
        
        cell.UID = comments[indexPath.row].UID
        cell.genderIcon.frame = cell.photo.frame
        cell.genderIcon.contentMode = .scaleAspectFit
        cell.genderIcon.tag = 1
        if comments[indexPath.row].gender == 0{
            cell.genderIcon.image = UIImage(named: "girlIcon")?.withRenderingMode(.alwaysTemplate)
        }else if comments[indexPath.row].gender == 1{
            cell.genderIcon.image = UIImage(named: "boyIcon")?.withRenderingMode(.alwaysTemplate)
        }
        cell.genderIcon.tintColor = .lightGray
        cell.addSubview(cell.genderIcon)
        cell.sendSubviewToBack(cell.genderIcon)
        
        if commenterHeadShotDict[comments[indexPath.row].UID] != nil && commenterHeadShotDict[comments[indexPath.row].UID] != UIImage(named: "Thumbnail"){
            //girlIcon和boyIcon需要Fit,照片需要Fill
            cell.photo.image =  comments[indexPath.row].smallHeadshot
            cell.photo.contentMode = .scaleAspectFill
            cell.photo.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                cell.photo.alpha = 1
                cell.genderIcon.alpha = 0
            })
        }
        
        //去storage那邊找到URL
        if commenterHeadShotDict[self.comments[indexPath.row].UID] == nil{
            commenterHeadShotDict[self.comments[indexPath.row].UID] = UIImage(named: "Thumbnail")
            let smallHeadshotRef = Storage.storage().reference().child("userSmallHeadShot/" + self.comments[indexPath.row].UID + ".png")
            smallHeadshotRef.downloadURL(completion: { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                //下載URL的圖
                AF.request(downloadURL).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else {return }
                    //裝進commenterHeadShotDict
                    self.commenterHeadShotDict[self.comments[indexPath.row].UID] = image
                    
                    if(indexPath.row > self.comments.count - 1) { return }
                    
                    //替換掉所有有相同ID的Comment的headShot
                    for i in 0 ... self.comments.count - 1 {
                        if self.comments[i].UID == self.comments[indexPath.row].UID{
                            let indexPathForSameIDComment = IndexPath(row: i, section: 0)
                            self.comments[i].smallHeadshot = image
                            self.commentTableView.reloadRows(at: [indexPathForSameIDComment], with: .none)
                            let cell = self.commentTableView.cellForRow(at: indexPathForSameIDComment) as! CommentTableViewCell
                            cell.photo.alpha = 0
                            UIView.animate(withDuration: 0.3, animations: {
                                cell.photo.alpha = 1
                                cell.genderIcon.alpha = 0
                            })
                            
                        }
                    }
                }
            })
        }
        
        cell.heartImage.isHidden = true
        cell.heartNumberLabel.isHidden = true
        
        let currentTime = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        var currentTimeString = dateFormatter.string(from: currentTime)
        
        let commmentTime = dateFormatter.date(from: comments[indexPath.row].time)!
        
        let elapsedYear = currentTime.years(sinceDate: commmentTime) ?? 0
        var elapsedMonth = currentTime.months(sinceDate: commmentTime) ?? 0
        elapsedMonth %= 12
        var elapsedDay = currentTime.days(sinceDate: commmentTime) ?? 0
        elapsedDay %= 30
        var elapsedHour = currentTime.hours(sinceDate: commmentTime) ?? 0
        elapsedHour %= 24
        var elapsedMinute = currentTime.minutes(sinceDate: commmentTime) ?? 0
        elapsedMinute %= 60
        var elapsedSecond = currentTime.seconds(sinceDate: commmentTime) ?? 0
        elapsedSecond %= 60
        
        var finalTimeString : String = ""
        if elapsedYear > 0 {
            finalTimeString = "\(elapsedYear)" + "年前"
        }else if elapsedMonth > 0{
            finalTimeString = "\(elapsedMonth)" + "個月前"
        }else if elapsedDay > 0{
            finalTimeString = "\(elapsedDay)" + "天前"
        }else if elapsedHour > 0{
            finalTimeString = "\(elapsedHour)" + "小時前"
        }else if elapsedMinute > 0{
            finalTimeString = "\(elapsedMinute)" + "分前"
        }else {
            finalTimeString = "剛剛"
        }
        
        cell.nameLabel.text = comments[indexPath.row].name + " - " + finalTimeString
        cell.commentLabel.text = comments[indexPath.row].content
        cell.commentID = comments[indexPath.row].commentID!
        
        let bg = UIView()
        bg.backgroundColor = .clear
        cell.backgroundView = bg
        
        return cell
        
    }
    

}
