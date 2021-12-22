//
//  ProfileEditViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/05/20.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire

class ProfileEditViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    weak var mapViewController: MapViewController?
    
    var scrollView : UIScrollView!
    var publishBtn : UIButton!
    var selfIntroductionTextView = UITextView()
    
    let photoLimitAmount = 10 //照片最多十張
    var photos : [UIImage] = []
    var photoUrls : [String] = []
    var photoUrlsNeedToDelete : [String] = []
    let noURLString = "noURL"
    let picker = UIImagePickerController()
    
    var currentSelectPhotoNumber = 0
    
    var photoTableView = UITableView()
    
    let selfIntroductionWordLimit = 500
    let selfIntroductionTextViewDelegate = WordLimitUITextFieldDelegate()
    var selfIntroductionTextFieldCountLabel = UILabel()
    let selfIntroductionPlaceholder = "\n   在這寫下自己的嗜好、平常假日都在做什麼、工作的內容等等⋯⋯"
    
    var profileChanged = false
    
    var photoNumberNeedToPut = 0 //需要上傳的照片數量
    var successedPutPhotoNumber = 0 //已經照片上傳的數量
    
    var originalFirstPhotoUrl : String?
    
    
    let customTopBarKit = CustomTopBarKit()
    
    var isPhotosAlreadyDownload : [Bool] = [] //這個為了處理WantAddPhotoTableViewCell的deleteIcon隨著loadingView浮現的問題
    
    private let actionSheetKit_deletePhoto = ActionSheetKit()
    private let actionSheetKit_addPhoto = ActionSheetKit()
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        self.hidesBottomBarWhenPushed = true
        
        setBackground()
        configTopBar()
        configContent()
        addDeleteAndCancealBtn()
        addTakePhotoOrUsePhotoBtn()
        setDefaultProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    
    fileprivate func setBackground() {
        
        view.backgroundColor = .surface()
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        let topbarHeight : CGFloat = 45 //加陰影部分
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0 + topPadding + topbarHeight, width: view.frame.width, height: view.frame.height - topPadding - topbarHeight))
        scrollView.contentSize = CGSize(width: view.frame.width,height: view.frame.height)
        view.addSubview(scrollView)
        
        let endEditTouchRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditTouch))
        endEditTouchRecognizer.cancelsTouchesInView = false
        endEditTouchRecognizer.numberOfTapsRequired = 1
        endEditTouchRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(endEditTouchRecognizer)
    }
    
    
    fileprivate func addDeleteAndCancealBtn() {
        let actionSheetText = ["取消","刪除"]
        actionSheetKit_deletePhoto.creatActionSheet(containerView: view, actionSheetText: actionSheetText)
        actionSheetKit_deletePhoto.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(deleteBtnAct), for: .touchUpInside)
    }
    
    
    
    fileprivate func configTopBar() {
        customTopBarKit.CreatTopBar(view: view)
        customTopBarKit.CreatCenterTitle(text: "編輯個人資料")
        customTopBarKit.CreatDoSomeThingTextBtn(text: "完成")
        customTopBarKit.hiddenGobackBtn()
        publishBtn = customTopBarKit.getDoSomeThingBtn()
        publishBtn.addTarget(self, action: #selector(publishBtnAct), for: .touchUpInside)
        
    }
    
    fileprivate func configContent(){
        
        
        let photoTitleLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "照片(第一張將設為大頭貼)"
            label.textColor = .on().withAlphaComponent(0.7)
            label.font = UIFont(name: "HelveticaNeue", size: 16)
            label.frame = CGRect(x: 14, y: 20, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(photoTitleLabel)
        
        let separator1_1 = { () -> UIView in
            let seperator = UIView()
            seperator.frame = CGRect(x: 15, y:photoTitleLabel.frame.origin.y + photoTitleLabel.frame.height + 7, width: view.frame.width - 30, height: 1)
            seperator.backgroundColor = .on().withAlphaComponent(0.08)
            return seperator
        }()
        scrollView.addSubview(separator1_1)
        
        
        
        let tableViewContainer = UIView(frame: CGRect(x: 0, y: separator1_1.frame.origin.y + 16, width: view.frame.width, height: 135))
        tableViewContainer.backgroundColor = .clear
        scrollView.addSubview(tableViewContainer)
        
        photoTableView.frame = CGRect(x: 0, y: 0, width: 150, height: view.frame.width)
        photoTableView.center = CGPoint(x: view.frame.width/2.0, y: 96/2.0)
        photoTableView.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi)/2)
        photoTableView.delegate = self
        photoTableView.dataSource = self
        photoTableView.showsVerticalScrollIndicator = false
        photoTableView.register(WantAddPhotoTableViewCell.self, forCellReuseIdentifier: "wantAddPhotoTableViewCell")
        photoTableView.rowHeight = 122
        photoTableView.estimatedRowHeight = 0
        photoTableView.backgroundColor = .clear
        photoTableView.separatorColor = .clear
        photoTableView.setEditing(true, animated: false)
        photoTableView.allowsSelectionDuringEditing = true
        photoTableView.allowsSelection = true
        
        tableViewContainer.addSubview(photoTableView)
        
        let separator2_1 = { () -> UIView in
            let seperator = UIView()
            seperator.frame = CGRect(x: 15, y:tableViewContainer.frame.maxY + 20, width: view.frame.width - 30, height: 1)
            seperator.backgroundColor = .on().withAlphaComponent(0.08)
            return seperator
        }()
        scrollView.addSubview(separator2_1)
        
        let selfIntroductionLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "自我介紹"
            label.textColor = .on().withAlphaComponent(0.7)
            label.font = UIFont(name: "HelveticaNeue", size: 16)
            label.frame = CGRect(x: 14, y: separator2_1.frame.origin.y - label.intrinsicContentSize.height - 7, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(selfIntroductionLabel)
        
        selfIntroductionTextFieldCountLabel  = { () -> UILabel in
            let label = UILabel()
            label.text = "\(selfIntroductionWordLimit)"
            label.textColor = .on().withAlphaComponent(0.5)
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.textAlignment = .right
            label.frame = CGRect(x:view.frame.width - 14 - 26, y: separator2_1.frame.origin.y - label.intrinsicContentSize.height - 7, width: 26, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(selfIntroductionTextFieldCountLabel)
        
        
        
        selfIntroductionTextView = { () -> UITextView in
            let textView = UITextView()
            textView.tintColor = .white
            textView.frame = CGRect(x:20, y: separator2_1.frame.origin.y + separator2_1.frame.height, width: view.frame.width - 20 * 2, height: 250)
            textView.returnKeyType = .default
            textView.textColor =  .on().withAlphaComponent(0.5)
            textView.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            textView.backgroundColor = .clear
            textView.text = selfIntroductionPlaceholder
            selfIntroductionTextViewDelegate.placeholder = selfIntroductionPlaceholder
            selfIntroductionTextViewDelegate.placeholderColor = UIColor.on().withAlphaComponent(0.5)
            
            selfIntroductionTextViewDelegate.wordLimit = selfIntroductionWordLimit
            selfIntroductionTextViewDelegate.wordLimitLabel = selfIntroductionTextFieldCountLabel
            textView.delegate = selfIntroductionTextViewDelegate
            return textView
        }()
        scrollView.addSubview(selfIntroductionTextView)
        
        let separator3_1 = { () -> UIView in
            let seperator = UIView()
            seperator.frame = CGRect(x: 15, y:selfIntroductionTextView.frame.maxY, width: view.frame.width - 30, height: 1)
            seperator.backgroundColor = .on().withAlphaComponent(0.08)
            return seperator
        }()
        scrollView.addSubview(separator3_1)
        
        let space = { () -> UIView in
            let space = UIView()
            space.frame = CGRect(x: 0, y:separator3_1.frame.maxY, width: view.frame.width, height: view.frame.height/2)
            return space
        }()
        scrollView.addSubview(space)
        

    }
    
    
    func setDefaultProfile(){
        
        if UserSetting.userSelfIntroduction != ""{
            selfIntroductionTextView.text = UserSetting.userSelfIntroduction
        }
        selfIntroductionTextFieldCountLabel.text = "\(selfIntroductionWordLimit - UserSetting.userSelfIntroduction.count)"
        
        
        if UserSetting.userPhotosUrl.count > 0 {
            originalFirstPhotoUrl = UserSetting.userPhotosUrl[0]
            for i in 0 ... UserSetting.userPhotosUrl.count - 1{
                photos.append(UIImage())
                photoUrls.append(UserSetting.userPhotosUrl[i])
            }
            self.photoTableView.reloadData()
            for i in 0...UserSetting.userPhotosUrl.count - 1{
                isPhotosAlreadyDownload.append(false)
                AF.request(UserSetting.userPhotosUrl[i]).response { (response) in
                    guard let data = response.data, let image = UIImage(data: data)
                    else { return }
                    self.photos[i] = image
                    let indexPath: IndexPath = IndexPath.init(row: i, section: 0)
                    self.photoTableView.reloadRows(at: [indexPath], with: .none)
                    if self.isPhotosAlreadyDownload.count - 1 >= i{
                        self.isPhotosAlreadyDownload[i] = true
                    }
                    if let cell = self.photoTableView.cellForRow(at: indexPath) as? WantAddPhotoTableViewCell{
                        cell.photo.alpha = 0
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.photo.alpha = 1
                            cell.deleteIcon.alpha = 1
                        })}
                }
            }
        }        
    }
    
    
    // MARK: - BtnAct
    @objc fileprivate func showDeletePhotoBtn() {
        //跳出是否要刪除照片鈕
        self.view.endEditing(true)
        actionSheetKit_deletePhoto.allBtnSlideIn()

    }
    
    @objc fileprivate func showSelectPhotoBtn() {
        //跳出是否要新增照片鈕 從相簿、從相機
        self.view.endEditing(true)
        actionSheetKit_addPhoto.allBtnSlideIn()
    }
    
    
    
    @objc fileprivate func endEditTouch() {
        self.view.endEditing(true)
    }
    
    
    
    @objc private func publishBtnAct(){
        
        var loadingView = UIView()
        loadingView = UIView(frame: CGRect(x: view.frame.width/2 - 40, y: view.frame.height/2 - 40, width: 80, height: 80))
        view.addSubview(loadingView)
        loadingView.setupToLoadingView()
        
        publishBtn.isEnabled = false
        publishBtn.alpha = 0.5
        
        //這行是為了只刪除但不上傳存在，因為只有上傳後才會更新photoUrls然後再更新UserSetting
        UserSetting.userPhotosUrl = photoUrls
        
        
        //如果userSelfIntroduction變動過，就存在本地端，接下來要上傳
        let oldSelfIntroduction = UserSetting.userSelfIntroduction
        if selfIntroductionTextView.text == selfIntroductionPlaceholder || selfIntroductionTextView.text == ""{
            UserSetting.userSelfIntroduction = ""
        }else{
            UserSetting.userSelfIntroduction = selfIntroductionTextView.text
        }
        if UserSetting.userSelfIntroduction != oldSelfIntroduction {
            profileChanged = true
        }
        
        
        //沒變動過就直接回去
        if !profileChanged {
            gobackAct()
            return
        }
        
        
        
        
        //更新Firebase上的自我介紹
        let ref = Database.database().reference().child("PersonDetail/" + UserSetting.UID + "/selfIntroduction")
        ref.setValue(UserSetting.userSelfIntroduction)
        
        //先刪除需要刪除的photo，就是過去已經上傳過，但是在編輯時把它刪除的照片
        for photoUrl in photoUrlsNeedToDelete {
            let photoStorageRef = Storage.storage().reference(forURL: photoUrl)
            photoStorageRef.delete(completion: { (error) in
                if let error = error {
                    print(error)
                } else {
                    // success
                    print("deleted \(photoUrl)")
                    if let index =  UserSetting.userPhotosUrl.firstIndex(of: photoUrl){
                        UserSetting.userPhotosUrl.remove(at: index)
                    }
                }
            })
        }
        
        //如果照片數為0但是有userSmallHeadShotURL，代表原本有縮圖，但是後來刪除了
        if photos.count == 0{
            //刪除Storage
            if let userSmallHeadShotURL = UserSetting.userSmallHeadShotURL{
                let photoStorageRef = Storage.storage().reference(forURL: userSmallHeadShotURL)
                photoStorageRef.delete(completion: { (error) in
                    if let error = error {
                        print(error)
                    } else {
                        // success
                        print("deleted \(userSmallHeadShotURL)")
                        //刪除本地端資料
                        UserSetting.userSmallHeadShotURL = nil
                        //刪除FireBase
                        let ref = Database.database().reference().child("PersonDetail/" + UserSetting.UID + "/headShot")
                        ref.removeValue()
                    }
                })
            }
            self.putPhotoURLToFireBase()
            return
        }
        
        
        ////計算需要上傳的photo數量
        for url in photoUrls{
            if url == noURLString{
                photoNumberNeedToPut += 1
            }
        }
        
        //處理縮圖
        if originalFirstPhotoUrl != nil{
            if photoUrls[0] != originalFirstPhotoUrl!{
                photoNumberNeedToPut += 1
                
                //Storage確認是否有原有縮圖
                if let userSmallUrl = UserSetting.userSmallHeadShotURL{
                    let smallPhotoStorageRef = Storage.storage().reference(forURL: userSmallUrl)
                    //Storage刪除原有縮圖
                    smallPhotoStorageRef.delete(completion: { (error) in
                        if let error = error {
                            print(error)
                        }
                    })
                }
                
                //Storage上傳新縮圖
                FirebaseHelper.putUserSmallHeadShot(image: self.photos[0], completion: {url -> () in
                                                        UserSetting.userSmallHeadShotURL = url
                                                        self.successedPutPhotoNumber += 1
                                                        if self.successedPutPhotoNumber == self.photoNumberNeedToPut{
                                                            self.putPhotoURLToFireBase()
                                                        }}
                )
            }
        }else{
            //如果originalFirstPhotoUrl是nil，但現在photo.count>0 需上傳新縮圖
            photoNumberNeedToPut += 1
            FirebaseHelper.putUserSmallHeadShot(image: self.photos[0], completion: {url -> () in
                                                    UserSetting.userSmallHeadShotURL = url
                                                    self.successedPutPhotoNumber += 1
                                                    if self.successedPutPhotoNumber == self.photoNumberNeedToPut{
                                                        self.putPhotoURLToFireBase()
                                                    }})
        }
        if photoNumberNeedToPut == 0{
            putPhotoURLToFireBase()
        }
        
        ////如果有照片就先存起來拿到url，都湊齊就都update personDetail
        for i in 0...photos.count - 1{
            
            if photoUrls[i] == noURLString{
                FirebaseHelper.putUserPhoto(image: photos[i], completion:  {url -> () in
                                                self.photoUrls[i] = url
                                                self.successedPutPhotoNumber += 1
                                                
                                                if self.successedPutPhotoNumber == self.photoNumberNeedToPut{
                                                    self.putPhotoURLToFireBase()
                                                }})
            }
            
        }
        
        
        
    }
    
    func gobackAct(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func putPhotoURLToFireBase(){
        //photoUrls
        let ref = Database.database().reference().child("PersonDetail/" + UserSetting.UID + "/photos/" )
        UserSetting.userPhotosUrl = photoUrls
        ref.setValue(UserSetting.userPhotosUrl)
        
        
        gobackAct()
        refreshMapViewController()
    }
    
    func refreshMapViewController(){
        if photos.count > 0{
            mapViewController?.presonAnnotationGetter.reFreshUserAnnotation(smallHeadShot: photos[0],refreshLocation: false)
        }else{
            mapViewController?.presonAnnotationGetter.reFreshUserAnnotation(smallHeadShot: nil, refreshLocation: false)
        }
        
    }
    
    
    @objc fileprivate func takePhotoBtnAct(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = true // 可對照片作編輯
            picker.delegate = self
            picker.modalPresentationStyle = .overCurrentContext
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func addPhotoBtnAct(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true // 可對照片作編輯
            picker.modalPresentationStyle = .overCurrentContext
            self.present(picker, animated: true, completion: nil)
        }
    }

    fileprivate func addTakePhotoOrUsePhotoBtn(){
        let actionSheetText = ["取消","從相簿找圖","拍照"]
        actionSheetKit_addPhoto.creatActionSheet(containerView: view, actionSheetText: actionSheetText)
        actionSheetKit_addPhoto.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(addPhotoBtnAct), for: .touchUpInside)
        actionSheetKit_addPhoto.getActionSheetBtn(i: 2)?.addTarget(self, action: #selector(takePhotoBtnAct), for: .touchUpInside)
    }
    
    @objc fileprivate func deleteBtnAct(){
        
        photos.remove(at: currentSelectPhotoNumber)
        photoTableView.reloadData()
        
        profileChanged = true
        
        //如果是已經上傳過的，需要記錄起來，之後如果按刊登，就一起刪除
        if photoUrls[currentSelectPhotoNumber] != noURLString{
            photoUrlsNeedToDelete.append(photoUrls[currentSelectPhotoNumber])
        }
        //刪除photoUrl
        photoUrls.remove(at: currentSelectPhotoNumber)
        
    }
    
    
    
    
    // MARK: - UIImagePickerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            photos.append(image)
            photoUrls.append(noURLString)
            photoTableView.reloadData()
            picker.dismiss(animated: true, completion: nil)
            profileChanged = true
        }
        
    }
    
    
    
    // MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if photos.count != photoLimitAmount{
            return photos.count + 1
        }else{
            return photos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wantAddPhotoTableViewCell", for: indexPath) as! WantAddPhotoTableViewCell
        
        
        if indexPath.row <= photos.count - 1{
            cell.deleteIcon.image = UIImage(named: "icons24DeleteFilledShade24")!
            cell.photo.image = photos[indexPath.row]
            
            if UserSetting.userGender == 0{
                cell.loadingView.image = UIImage(named: "girlPhotoIcon")?.withRenderingMode(.alwaysTemplate)
            }else{
                cell.loadingView.image = UIImage(named: "boyPhotoIcon")?.withRenderingMode(.alwaysTemplate)
            }
        }else{
            cell.loadingView.alpha = 0
            cell.deleteIcon.image = UIImage()
            cell.photo.image = UIImage(named: "AddPhotoIcon")?.withRenderingMode(.alwaysTemplate)
            cell.photo.tintColor = .primary()
            
        }
        
        if isPhotosAlreadyDownload.count - 1 >= indexPath.row{
            if isPhotosAlreadyDownload[indexPath.row]{
                cell.deleteIcon.alpha = 1
            }else{
                cell.deleteIcon.alpha = 0
            }
        }else{
            cell.deleteIcon.alpha = 1
        }
        
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        cell.selectedBackgroundView = selectedBackgroundView
        cell.backgroundColor = .clear
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //如果不是最後一張
        if indexPath.row != photos.count{
            showDeletePhotoBtn()
            currentSelectPhotoNumber = indexPath.row
        }else{
            if photos.count == photoLimitAmount{
                showDeletePhotoBtn()
                currentSelectPhotoNumber = indexPath.row
            }else{
                showSelectPhotoBtn()
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let tempImg = photos[sourceIndexPath.row]
        photos.remove(at: sourceIndexPath.row)
        photos.insert(tempImg, at: destinationIndexPath.row)
        
        let tempURL = photoUrls[sourceIndexPath.row]
        photoUrls.remove(at: sourceIndexPath.row)
        photoUrls.insert(tempURL, at: destinationIndexPath.row)
        
        profileChanged = true
        
    }
    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        if proposedDestinationIndexPath.row != photos.count{
            return proposedDestinationIndexPath
        }else{
            if photos.count == photoLimitAmount{
                return proposedDestinationIndexPath
            }else{
                return sourceIndexPath            }
        }
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.row != photos.count{
            return true
        }else{
            if photos.count == photoLimitAmount{
                return true
            }else{
                return false
            }
        }
    }
    
    
    
    
    
}
