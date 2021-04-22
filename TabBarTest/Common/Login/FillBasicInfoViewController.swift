//
//  FillBasicInfoViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/25.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class FillBasicInfoViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    weak var logInPageViewController : LogInPageViewController!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoBtn: UIButton!
    let picker = UIImagePickerController()
    
    @IBOutlet weak var boyIcon: UIImageView!
    @IBOutlet weak var boyBtn: UIButton!
    
    @IBOutlet weak var girlIcon: UIImageView!
    @IBOutlet weak var girlBtn: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    var nameWordLimit = 8
    
    @IBOutlet weak var birthdayBtn: UIButton!
    @IBOutlet weak var birthdayLabel: UILabel!
    let birthDayPicker = UIDatePicker()
    
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var descriptStatusLabel: UILabel!
    let truePhotoImageView = UIImageView()
    
    var userGender = 1
    
    //這兩個資訊是從fb登入拿到的
    var defaultUserName : String!
    var defaultUserPhoto : String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CustomBGKit().CreatDarkStyleBG(view: view)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configBirthDayPicker()
        configIconAndBtnStyle()
        setTruePhotoImageView()
        
        setDefaultData()
    }
    
    
    fileprivate func setDefaultData() {
        if UserSetting.userName != ""{
            nameTextField.text = UserSetting.userName
            descriptStatusLabel.text = "請輸入姓名/綽號"
        }
        
        if UserSetting.userPhotosUrl.count > 0{
            let url = UserSetting.userPhotosUrl[0]
            setUserImage(url)
            descriptStatusLabel.text = " "
        }
    }
    
    fileprivate func configBirthDayPicker() {
        birthDayPicker.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 150)
        birthDayPicker.datePickerMode = .date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let fromDateTime = formatter.date(from: "1920/01/01")
        birthDayPicker.minimumDate = fromDateTime
        let endDateTime = formatter.date(from: "2020/01/01")
        birthDayPicker.maximumDate = endDateTime
        birthDayPicker.date = formatter.date(from: "2000/01/01")!
        birthDayPicker.locale = NSLocale(localeIdentifier: "zh_TW") as Locale
        birthDayPicker.addTarget(self,action:#selector(datePickerChanged),for: .valueChanged)
        view.addSubview(birthDayPicker)
        birthDayPicker.tintColor = .white
    }
    
    
    
    fileprivate func configIconAndBtnStyle() {
        boyIcon.image = UIImage(named: "boyIcon")?.withRenderingMode(.alwaysTemplate)
        boyIcon.tintColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
        girlIcon.image = UIImage(named: "girlIcon")?.withRenderingMode(.alwaysTemplate)
        girlIcon.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        continueBtn.layer.cornerRadius = 7
        nameTextField.backgroundColor = .clear
        nameTextField.borderStyle = .none
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
        nameTextField.tintColor = .white
        if nameTextField.text == ""{
            continueBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
            continueBtn.isEnabled = false
        }else{
            continueBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "AEA9A0")
            continueBtn.isEnabled = true
        }
    }
    
    //這個是因為直接換photoImageView的image 不知道為啥會跑版 懶得研究
    fileprivate func setTruePhotoImageView() {
        truePhotoImageView.layer.cornerRadius = 75
        truePhotoImageView.frame = CGRect(x:view.frame.width/2 - 150/2, y: 85, width: 150, height: 150)
        truePhotoImageView.contentMode = .scaleAspectFill
        truePhotoImageView.clipsToBounds = true
        view.addSubview(truePhotoImageView)
    }
    
    private func setUserImage(_ url: String) {
        
        AF.request(url).response { (response) in
            guard let data = response.data, let image = UIImage(data: data)
                else { return }
            self.photoImageView.alpha = 0
            self.truePhotoImageView.image = image
            
        }
    }
    
    @IBAction func photoBtnAct(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true // 可對照片作編輯
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            photoImageView.alpha = 0
            truePhotoImageView.image = image
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    
    @IBAction func boyBtnAct(_ sender: Any) {
        userGender = 1
        boyIcon.tintColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
        girlIcon.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
    }
    
    @IBAction func girlBtnAct(_ sender: Any) {
        userGender = 0
        boyIcon.tintColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        girlIcon.tintColor = UIColor.hexStringToUIColor(hex: "D8D8D8")
    }
    
    @IBAction func birthdayBtnAct(_ sender: Any) {
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.birthDayPicker.frame = CGRect(x: 0, y: self.view.frame.height - 150 - 25, width: self.view.frame.width, height: 150)
        })
    }
    
    @IBAction func continueBtnAct(_ sender: Any) {
        
        let loadingView = UIView(frame: CGRect(x: view.frame.width/2 - 40, y: view.frame.height/2 - 40, width: 80, height: 80))
        view.addSubview(loadingView)
        loadingView.setupToLoadingView()
        
        continueBtn.isEnabled = false
        continueBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
        
        if Auth.auth().currentUser == nil{
            logInPageViewController.dismiss(animated: true, completion: nil)
            return
        }
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        UserSetting.userName = nameTextField.text!
        UserSetting.userGender = userGender
        UserSetting.userBirthDay = formatter.string(from: self.birthDayPicker.date)
        
        let currentTimeString = Date().getCurrentTimeString()
        
        // photoImageView.alpha == 0 代表有設定照片
        if photoImageView.alpha == 0{
            //壓縮圖檔
            
            var compressImg = truePhotoImageView.image!.imageWithNewSize(size: CGSize(width: 50, height: 50))
            compressImg = compressImg!.compressQuality(maxLength:10000)
            
            let uid = Auth.auth().currentUser!.uid
            let storageRef = Storage.storage().reference().child("userSmallHeadShot/"+"\(uid).png")
            let storageRefForUserPhoto = Storage.storage().reference().child("userPhoto/"+uid+"/"+"0.png")
            
            //上傳壓縮後用在map上的小圖
            if let uploadData = compressImg!.jpegData(compressionQuality: 1){
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata,error) in
                    if error != nil {
                        print(error ?? "上傳壓縮後用在map上的小圖失敗")
                    }
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        UserSetting.userSmallHeadShotURL = downloadURL.absoluteString
                                                
                        //上傳第一張照片
                        let compressedFirstPhoto = self.truePhotoImageView.image!.compressQuality(maxLength: 1024 * 1024)
                        
                        if let uploadDataForPhoto = compressedFirstPhoto.jpegData(compressionQuality: 1){
                            
                            storageRefForUserPhoto.putData(uploadDataForPhoto, metadata: nil, completion: { (metadata,error) in
                                if error != nil {
                                    print(error ?? "上傳第一張照片失敗")
                                }
                                storageRefForUserPhoto.downloadURL { (url, error) in
                                    guard let downloadURL = url else {
                                        // Uh-oh, an error occurred!
                                        return
                                    }
                                    let photoURL = downloadURL.absoluteString
                                    UserSetting.userPhotosUrl = [photoURL]
                                    //上傳PersonDetailInfo
                                    let personInfo = PersonDetailInfo(UID:UserSetting.UID,name: UserSetting.userName, gender: UserSetting.userGender, birthday: UserSetting.userBirthDay, lastSignInTime: currentTimeString, selfIntroduction: "", photos: [photoURL], headShot: UserSetting.userSmallHeadShotURL,perferIconStyleToShowInMap: UserSetting.perferIconStyleToShowInMap)
                                    self.uploadPersonDetailToFireBase(personInfo)
                                }

                            })
                        }
                        
                    }
                    
                })
            }
            
        }else{
            let personInfo = PersonDetailInfo(UID:UserSetting.UID,name: UserSetting.userName, gender: UserSetting.userGender, birthday: UserSetting.userBirthDay, lastSignInTime: currentTimeString, selfIntroduction: "", photos: [], headShot: UserSetting.userSmallHeadShotURL,perferIconStyleToShowInMap: UserSetting.perferIconStyleToShowInMap)
            uploadPersonDetailToFireBase(personInfo)
        }
    }
    
    
    func uploadPersonDetailToFireBase(_ personInfo:PersonDetailInfo) {
        let ref = Database.database().reference()
        let locationWithIDRef = ref.child("PersonDetail/" +  Auth.auth().currentUser!.uid)
        
        locationWithIDRef.setValue(personInfo.toAnyObject()){ (error, ref) -> Void in
            if error != nil{
                print(error ?? "上傳PersonDetail失敗")
            }
            UserSetting.alreadyUpdatePersonDetail = true
            self.logInPageViewController.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.birthDayPicker.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 150)
        })
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let countOfWords = string.count + textField.text!.count -  range.length
        
        if countOfWords == 0{
            continueBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
            continueBtn.isEnabled = false
            descriptStatusLabel.text = "請輸入姓名/綽號"
        }else{
            continueBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "AEA9A0")
            continueBtn.isEnabled = true
            descriptStatusLabel.text = " "
        }
        
        if countOfWords > nameWordLimit{
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc fileprivate func datePickerChanged(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        let currentTime = Date()
        
        birthdayLabel.text = formatter.string(from: birthDayPicker.date)
        
        let elapsedYear = currentTime.years(sinceDate: birthDayPicker.date) ?? 0
        
        if elapsedYear < 18 {
            continueBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "4A4A4A")
            continueBtn.isEnabled = false
            descriptStatusLabel.text = "您需年滿十八歲才能使用此服務"
        }else{
            continueBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "AEA9A0")
            continueBtn.isEnabled = true
            descriptStatusLabel.text = " "
        }
        
    }
    
}
