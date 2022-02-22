//
//  HoldShareSeatViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/02/21.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class HoldShareSeatViewController : UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WordLimitForTypeDelegate{
    
    var scrollView : UIScrollView!
    var customTopBarKit = CustomTopBarKit()
    var publishBtn : UIButton!
    
    let picker = UIImagePickerController()
    
    var photos : [UIImage] = []
    var photoUrls : [String] = []
    var photoTableView = UITableView()
    let noURLString = "noURL"
    
    var loadingView = UIView()
    var tableViewContainer = UIView()
    
    var currentSelectPhotoNumber = 0
    
    let restaurantNameWordLimit = 20
    var restaurantNameTextField : UITextField!
    var restaurantNameTextFieldCountLabel = UILabel()
    let restaurantNameTextFieldDelegate = WordLimitUITextFieldDelegate()
    
    var isPhotosAlreadyDownload : [Bool] = [] //這個為了處理WantAddPhotoTableViewCell的deleteIcon隨著loadingView浮現的問題
    
    var addressHint = UITextField()
    var addressSelectBtn = UIButton()
    
    private let actionSheetKit_deletePhoto = ActionSheetKit()
    private let actionSheetKit_addPhoto = ActionSheetKit()
    
    let photoLimitAmount = 5 //照片最多五張
    
    //隐藏狀態欄
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
        configTopBar()
        configPhotoTableView()
        configItemInfoInputField()
        addDeleteAndCancealBtn()
        addTakePhotoOrUsePhotoBtn()
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
    
    fileprivate func configItemInfoInputField(){
        
        let restaurantNameLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "餐廳名稱"
            label.textColor = .on().withAlphaComponent(0.9)
            label.font = UIFont(name: "HelveticaNeue-bold", size: 16)
            label.frame = CGRect(x: 16, y: tableViewContainer.frame.maxY + 3, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(restaurantNameLabel)
        
        
        let separator1 = { () -> UIView in
            let separator = UIView()
            separator.backgroundColor = .on().withAlphaComponent(0.08)
            separator.frame = CGRect(x: 15, y:restaurantNameLabel.frame.origin.y + restaurantNameLabel.frame.height + 7, width: view.frame.width - 30, height: 1)
            
            return separator
        }()
        scrollView.addSubview(separator1)
        
        restaurantNameTextFieldCountLabel  = { () -> UILabel in
            let label = UILabel()
            label.text = "\(restaurantNameWordLimit)"
            label.textColor = .on().withAlphaComponent(0.5)
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.textAlignment = .right
            label.frame = CGRect(x:view.frame.width - 15 - 26, y: separator1.frame.origin.y - label.intrinsicContentSize.height - 7, width: 26, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(restaurantNameTextFieldCountLabel)
        
        restaurantNameTextField = { () -> UITextField in
            let textField = UITextField()
            textField.tintColor = .primary()
            textField.frame = CGRect(x:20, y: separator1.frame.origin.y + separator1.frame.height, width: view.frame.width - 20 * 2, height: 60)
            
            textField.attributedPlaceholder = NSAttributedString(string:
                                                                    " 在這寫下餐廳名稱 ", attributes:
                                                                        [NSAttributedString.Key.foregroundColor:UIColor.on().withAlphaComponent(0.5)])

            textField.clearButtonMode = .whileEditing
            textField.returnKeyType = .done
            textField.textColor = .on()
            textField.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            textField.backgroundColor = .clear
            restaurantNameTextFieldDelegate.wordLimit = restaurantNameWordLimit
            restaurantNameTextFieldDelegate.wordLimitLabel = restaurantNameTextFieldCountLabel
            restaurantNameTextFieldDelegate.wordLimitForTypeDelegate = self
            textField.delegate = restaurantNameTextFieldDelegate
            return textField
        }()
        scrollView.addSubview(restaurantNameTextField)

        let separator2 = { () -> UIView in
            let separator = UIView()
            separator.backgroundColor = .on().withAlphaComponent(0.08)
            separator.frame = CGRect(x: 15, y:separator1.frame.origin.y + 120, width: view.frame.width - 30, height: 1)
            
            return separator
        }()
        scrollView.addSubview(separator2)
        
        let addressLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "餐廳地點"
            label.textColor = .on().withAlphaComponent(0.9)
            label.font = UIFont(name: "HelveticaNeue-bold", size: 16)
            label.frame = CGRect(x: 16, y: separator2.frame.origin.y - label.intrinsicContentSize.height - 7, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(addressLabel)
        
        
        addressHint = { () -> UITextField in
            let textField = UITextField()
            textField.tintColor = .primary()
            textField.frame = CGRect(x:20, y: separator2.frame.origin.y + separator2.frame.height, width: view.frame.width - 20 * 2, height: 60)
            
            textField.attributedPlaceholder = NSAttributedString(string:
                                                                    " 點擊選擇地點 ", attributes:
                                                                        [NSAttributedString.Key.foregroundColor:UIColor.on().withAlphaComponent(0.5)])

            textField.textColor = .on()
            textField.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            textField.backgroundColor = .clear
            textField.isEnabled = false
            return textField
        }()
        scrollView.addSubview(addressHint)
        
        addressSelectBtn = { () -> UIButton in
            let btn = UIButton()
            btn.frame = CGRect(x:20, y: separator2.frame.origin.y + separator2.frame.height, width: view.frame.width - 20 * 2, height: 60)
            btn.addTarget(self, action: #selector(addressSelectBtnAct), for: .touchUpInside)
            return btn
        }()
        scrollView.addSubview(addressSelectBtn)
        
        
        let dateTimeLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "聚會時間"
            label.textColor = .on().withAlphaComponent(0.9)
            label.font = UIFont(name: "HelveticaNeue-bold", size: 16)
            label.frame = CGRect(x: 16, y: separator2.frame.origin.y + 120 - label.intrinsicContentSize.height - 7, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(dateTimeLabel)
        
        let inputLine1 = { () -> UIView in
            let separator = UIView()
            separator.backgroundColor = .on().withAlphaComponent(0.08)
            separator.frame = CGRect(x: view.frame.width/2, y:separator2.frame.origin.y + 120, width: (view.frame.width - 30)/2, height: 1)
            return separator
        }()
        scrollView.addSubview(inputLine1)
        
        
        let dateTimeBtn = { () -> UIButton in
            let btn = UIButton()
            btn.setTitle("-", for: .normal) //週三,2月23-11:20
            btn.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
            btn.backgroundColor = .clear
            btn.setTitleColor(.on().withAlphaComponent(0.9), for: .normal)
            btn.addTarget(self, action: #selector(dateTimeBtnAct), for: .touchUpInside)
            btn.frame = CGRect(x: view.frame.width/2, y: inputLine1.frame.origin.y - 40, width: (view.frame.width - 30)/2, height: 40)
            return btn
        }()
        scrollView.addSubview(dateTimeBtn)
        
        let reviewTimeLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "最晚審核時間"
            label.textColor = .on().withAlphaComponent(0.9)
            label.font = UIFont(name: "HelveticaNeue-bold", size: 16)
            label.frame = CGRect(x: 16, y: dateTimeLabel.frame.origin.y + 60, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(reviewTimeLabel)
        
        let inputLine2 = { () -> UIView in
            let separator = UIView()
            separator.backgroundColor = .on().withAlphaComponent(0.08)
            separator.frame = CGRect(x: view.frame.width/2, y:inputLine1.frame.origin.y + 60, width: (view.frame.width - 30)/2, height: 1)
            return separator
        }()
        scrollView.addSubview(inputLine2)

        let reviewTimeBtn = { () -> UIButton in
            let btn = UIButton()
            btn.setTitle("-", for: .normal)
            btn.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
            btn.backgroundColor = .clear
            btn.setTitleColor(.on().withAlphaComponent(0.9), for: .normal)
            btn.addTarget(self, action: #selector(reviewTimeBtnAct), for: .touchUpInside)
            btn.frame = CGRect(x: view.frame.width/2, y: inputLine2.frame.origin.y - 40, width: (view.frame.width - 30)/2, height: 40)
            return btn
        }()
        scrollView.addSubview(reviewTimeBtn)
        
        let headCountLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "參加人數"
            label.textColor = .on().withAlphaComponent(0.9)
            label.font = UIFont(name: "HelveticaNeue-bold", size: 16)
            label.frame = CGRect(x: 16, y: reviewTimeLabel.frame.origin.y + 60, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(headCountLabel)
        
        let headCountSlashLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "/"
            label.textColor = .on().withAlphaComponent(0.16)
            label.textAlignment = .center
            label.font = UIFont(name: "HelveticaNeue-bold", size: 16)
            label.frame = CGRect(x: view.frame.width/2, y: reviewTimeLabel.frame.origin.y + 60, width: (view.frame.width - 30)/2, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(headCountSlashLabel)
        
        let oneToOneBtn = { () -> UIButton in
            let btn = UIButton()
            btn.setTitle("1男1女", for: .normal)
            btn.titleLabel?.font = UIFont(name: "HelveticaNeue-bold", size: 16)
            btn.backgroundColor = .clear
            btn.setTitleColor(.primary(), for: .normal)
            btn.addTarget(self, action: #selector(oneToOneBtnAct), for: .touchUpInside)
            btn.frame = CGRect(x: view.frame.width/2, y: inputLine2.frame.origin.y + 24, width: (view.frame.width - 30)/4, height: 36)
            return btn
        }()
        scrollView.addSubview(oneToOneBtn)
        
        let twoToTwoBtn = { () -> UIButton in
            let btn = UIButton()
            btn.setTitle("2男2女", for: .normal)
            btn.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
            btn.backgroundColor = .clear
            btn.setTitleColor(.on().withAlphaComponent(0.5), for: .normal)
            btn.addTarget(self, action: #selector(twoToTwoBtnAct), for: .touchUpInside)
            btn.frame = CGRect(x: view.frame.width - (view.frame.width - 30)/4 - 15, y: inputLine2.frame.origin.y + 24, width: (view.frame.width - 30)/4, height: 36)
            return btn
        }()
        scrollView.addSubview(twoToTwoBtn)
        
        let paymentMethodLabel = { () -> UILabel in
            let label = UILabel()
            label.text = "付款方式"
            label.textColor = .on().withAlphaComponent(0.9)
            label.font = UIFont(name: "HelveticaNeue-bold", size: 16)
            label.frame = CGRect(x: 16, y: headCountLabel.frame.origin.y + 60, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(paymentMethodLabel)
        
        let paymentMethodBtn = { () -> UIButton in
            let btn = UIButton()
            btn.setTitle("男方付款", for: .normal)
            btn.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
            btn.backgroundColor = .clear
            btn.setTitleColor(.on().withAlphaComponent(0.9), for: .normal)
            btn.frame = CGRect(x: view.frame.width/2, y: inputLine2.frame.origin.y + 82, width: (view.frame.width - 30)/2, height: 40)
            return btn
        }()
        scrollView.addSubview(paymentMethodBtn)
    }
    
    @objc fileprivate func endEditTouch() {
        self.view.endEditing(true)
    }
    
    fileprivate func configTopBar() {
        
        customTopBarKit.CreatTopBar(view: view,showSeparator:true)
        customTopBarKit.CreatDoSomeThingTextBtn(text: "刊登")
        customTopBarKit.CreatCenterTitle(text: "發起相席")
        
        publishBtn = customTopBarKit.getDoSomeThingTextBtn()
        publishBtn.addTarget(self, action: #selector(publishBtnAct), for: .touchUpInside)
        publishBtn.isEnabled = false
        publishBtn.alpha = 0.25
        
        let gobackBtn = customTopBarKit.getGobackBtn()
        gobackBtn.addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
        
    }
    
    
    fileprivate func configPhotoTableView() {
        
        picker.modalPresentationStyle = .overCurrentContext
        
        tableViewContainer = UIView(frame: CGRect(x: 0, y: 16, width: view.frame.width, height: 135))
        tableViewContainer.backgroundColor = .clear
        scrollView.addSubview(tableViewContainer)
        
        photoTableView.frame = CGRect(x: 4, y: 0, width: 150, height: view.frame.width - 8)
        photoTableView.center = CGPoint(x: view.frame.width/2.0, y: 96/2.0)
        photoTableView.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi)/2)
        photoTableView.delegate = self
        photoTableView.dataSource = self
        photoTableView.tintColor = .primary()
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
        
    }
    
    
    fileprivate func addTakePhotoOrUsePhotoBtn(){
        let actionSheetText = ["取消","從相簿找圖","拍照"]
        actionSheetKit_addPhoto.creatActionSheet(containerView: view, actionSheetText: actionSheetText)
        actionSheetKit_addPhoto.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(addPhotoBtnAct), for: .touchUpInside)
        actionSheetKit_addPhoto.getActionSheetBtn(i: 2)?.addTarget(self, action: #selector(takePhotoBtnAct), for: .touchUpInside)
    }
    
    fileprivate func addDeleteAndCancealBtn() {
        let actionSheetText = ["取消","刪除"]
        actionSheetKit_deletePhoto.creatActionSheet(containerView: view, actionSheetText: actionSheetText)
        actionSheetKit_deletePhoto.getActionSheetBtn(i: 1)?.addTarget(self, action: #selector(deleteBtnAct), for: .touchUpInside)
    }
    
    
    func checkCanPublishOrNot(){
        //TODO
        
//        if  itemNameTextField.text != "" &&
//                priceTextField.text != ""{
//            publishBtn.isEnabled = true
//            publishBtn.alpha = 1
//        }else{
//            publishBtn.isEnabled = false
//            publishBtn.alpha = 0.25
//        }
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
    
    @objc fileprivate func deleteBtnAct(){
        
        photos.remove(at: currentSelectPhotoNumber)
        photoTableView.reloadData()
        
        //以下捨用，因為相席無法修改，沒有已上傳過的照片
//        //如果是已經上傳過的，需要記錄起來，之後如果按刊登，就一起刪除
//        if photoUrls[currentSelectPhotoNumber] != noURLString{
//            photoUrlsNeedToDelete.append(photoUrls[currentSelectPhotoNumber])
//        }
        
        //刪除photoUrl
        photoUrls.remove(at: currentSelectPhotoNumber)
        
        whenEditDoSomeThing()
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
    
    @objc private func dateTimeBtnAct(){
        print("dateTimeBtnAct")
    }
    
    @objc private func reviewTimeBtnAct(){
        print("reviewTimeBtnAct")
    }
    
    @objc private func oneToOneBtnAct(){
        print("oneToOneBtnAct")
    }
    
    @objc private func twoToTwoBtnAct(){
        print("twoToTwoBtnAct")
    }
    
    @objc private func addressSelectBtnAct(){
        print("addressSelectBtnAct")
    }
    
    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc fileprivate func publishBtnAct(){
        self.view.endEditing(true)
        
        publishBtn.isEnabled = false
        publishBtn.alpha = 0.25
        
//        uploadToFireBase()
    }
    
    
    
    
    // MARK: - UIImagePickerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            photos.append(image)
            photoUrls.append(noURLString)
            photoTableView.reloadData()
            checkCanPublishOrNot()
            picker.dismiss(animated: true, completion: nil)
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
            
            cell.loadingView.contentMode = .scaleAspectFit
            
            
            cell.loadingView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi)/2).scaledBy(x: 0.7, y: 0.7)
            
            //TODO 要給聚會的loading圖
            cell.loadingView.image = UIImage(named: "icons24ShopLocateFilledBk24")?.withRenderingMode(.alwaysTemplate)
            
            let loadingViewBorder = UIView(frame: CGRect(x: -cell.loadingView.frame.width * 0.2, y: -cell.loadingView.frame.height * 0.2, width: cell.loadingView.frame.width/0.55, height: cell.loadingView.frame.height/0.55))
            loadingViewBorder.layer.cornerRadius = 7/0.7
            loadingViewBorder.layer.borderWidth = 2.5/0.7
            loadingViewBorder.layer.borderColor = UIColor.lightGray.cgColor
            loadingViewBorder.backgroundColor = .clear
            cell.loadingView.addSubview(loadingViewBorder)
            
        }else{
            cell.deleteIcon.image = UIImage()
            cell.photo.image = UIImage(named: "AddPhotoIcon")?.withRenderingMode(.alwaysTemplate)
            cell.loadingView.alpha = 0
        }
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        cell.selectedBackgroundView = selectedBackgroundView
        cell.backgroundColor = .clear
        
        
        if isPhotosAlreadyDownload.count - 1 >= indexPath.row{
            if isPhotosAlreadyDownload[indexPath.row]{
                cell.deleteIcon.alpha = 1
            }else{
                cell.deleteIcon.alpha = 0
            }
        }else{
            cell.deleteIcon.alpha = 1
        }
        
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
    
    // MARK: - WordLimitForTypeDelegate 自製
    
    func whenEditDoSomeThing() {
        checkCanPublishOrNot()
    }
    
    func whenEndEditDoSomeThing() {
        checkCanPublishOrNot()
    }
    
}
