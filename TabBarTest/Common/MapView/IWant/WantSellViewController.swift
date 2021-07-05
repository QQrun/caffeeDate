//
//  WantSellViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/23.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class WantSellViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WordLimitForTypeDelegate {
    
    
    weak var mapViewController: MapViewController?
    weak var shopEditViewController : ShopEditViewController? //TODO 這個可以會刪除，不在這邊改了
    
    
    let photoLimitAmount = 10 //照片最多十張
    var photos : [UIImage] = []
    var photoUrls : [String] = []
    var photoUrlsNeedToDelete : [String] = []
    let noURLString = "noURL"
    let picker = UIImagePickerController()
    
    var photoTableView = UITableView()
    
    
    let fullScreenGrayBG = UIButton()
    let concealBtn = UIButton()
    let deleteBtn = UIButton()
    let addPhotoBtn = UIButton()
    let takePhotoBtn = UIButton()
    var rootWidth : CGFloat = 0
    
    var currentSelectPhotoNumber = 0
    
    var scrollView : UIScrollView!
    
    let storeNameWordLimit = 12
    let itemNameWordLimit = 20
    let itemNameTextFieldDelegate = WordLimitUITextFieldDelegate()
    let priceWordLimit = 10
    let priceTextFieldDelegate = WordLimitUITextFieldDelegate()
    let itemInfoWordLimit = 500
    let itemInfoTextViewDelegate = WordLimitUITextFieldDelegate()
    var itemNameTextField : UITextField!
    var itemNameTextFieldCountLabel = UILabel()
    var priceTextField : UITextField!
    var priceTextFieldCountLabel = UILabel()
    var itemInfoTextView : UITextView!
    var itemInfoTextFieldCountLabel = UILabel()
    var itemInfoPlaceholder =  "\n   在這寫下您提供的商品資訊與細節⋯"
    
    
    var publishBtn : UIButton!
    
    let compressedSizeForPhoto = 1024 * 1024 //照片的目標壓縮大小
    
    var iWantType : Item.ItemType = .Sell
    
    var photoNumberNeedToPut = 0 //需要上傳的照片數量
    var successedPutPhotoNumber = 0 //已經照片上傳的數量
    var thumbnailUrl : String?
    var originalFirstPhotoUrl : String?  //這是如果有defaultItem，defaultItem的第一張照片，以此去判斷之後要不要更新thumbnailUrl
    var itemInfo = ""
    
    var defaultItem : Item? //有defaultItem，代表是編輯舊商品，而非新刊登
    
    var loadingView = UIView()
    var tableViewContainer = UIView()
    
    var customTopBarKit = CustomTopBarKit()
    
    var isPhotosAlreadyDownload : [Bool] = [] //這個為了處理WantAddPhotoTableViewCell的deleteIcon隨著loadingView浮現的問題
    
    
    //隐藏狀態欄
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init(defaultItem: Item?) {
        self.defaultItem = defaultItem
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
        setDefaultItem()
        checkCanPublishOrNot()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
    }
    
    func setDefaultItem(){
        if let item = defaultItem{
            itemNameTextField.text = item.name
            itemNameTextFieldCountLabel.text = "\(itemNameWordLimit - item.name.count)"
            priceTextField.text = item.price
            priceTextFieldCountLabel.text = "\(priceWordLimit - item.price.count)"
            itemInfoTextView.text = item.descript
            itemInfoTextFieldCountLabel.text = "\(itemInfoWordLimit - item.descript.count)"
            if item.photosUrl != nil{
                if item.photosUrl!.count > 0{
                    for i in 0...item.photosUrl!.count - 1{
                        photos.append(UIImage())
                        photoUrls.append(item.photosUrl![i])
                    }
                    self.photoTableView.reloadData()
                    for i in 0...item.photosUrl!.count - 1{
                        isPhotosAlreadyDownload.append(false)
                        AF.request(item.photosUrl![i]).response { (response) in
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
                    originalFirstPhotoUrl = item.photosUrl![0]
                }
                
            }
        }
    }
    
    fileprivate func setBackground() {
        let bgKit = CustomBGKit()
        bgKit.CreatParchmentBG(view: view)
        scrollView = bgKit.GetScrollView()
        
        let endEditTouchRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditTouch))
        endEditTouchRecognizer.cancelsTouchesInView = false
        endEditTouchRecognizer.numberOfTapsRequired = 1
        endEditTouchRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(endEditTouchRecognizer)
    }
    
    fileprivate func configTopBar() {
        
        customTopBarKit.CreatTopBar(view: view)
        customTopBarKit.CreatDoSomeThingTextBtn(text: "刊登")
        if iWantType == .Sell{
            customTopBarKit.CreatCenterTitle(text: "我想販賣⋯⋯")
        }else if iWantType == .Buy{
            customTopBarKit.CreatCenterTitle(text: "我想徵求⋯⋯")
        }
        publishBtn = customTopBarKit.getDoSomeThingTextBtn()
        publishBtn.addTarget(self, action: #selector(publishBtnAct), for: .touchUpInside)
        publishBtn.isEnabled = false
        publishBtn.alpha = 0.25
        
        let gobackBtn = customTopBarKit.getGobackBtn()
        gobackBtn.addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
    }
    
    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    fileprivate func configPhotoTableView() {
        
        picker.modalPresentationStyle = .overCurrentContext
        
        tableViewContainer = UIView(frame: CGRect(x: 0, y: 6, width: view.frame.width, height: 135))
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
        
        
        
        
    }
    
    
    fileprivate func configItemInfoInputField(){
        
        let itemNameLabel = { () -> UILabel in
            let label = UILabel()
            if iWantType == .Sell{
                label.text = "商品名稱"
            }else if iWantType == .Buy{
                label.text = "任務名稱"
            }
            label.textColor = UIColor.hexStringToUIColor(hex: "472411")
            label.font = UIFont(name: "HelveticaNeue", size: 16)
            label.frame = CGRect(x: 14, y: tableViewContainer.frame.maxY + 3, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(itemNameLabel)
        
        let separator2_1 = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "分隔線擦痕")
            imageView.frame = CGRect(x: -20, y:itemNameLabel.frame.origin.y + itemNameLabel.frame.height + 7, width: view.frame.width + 40, height: 1.3)
            imageView.contentMode = .scaleToFill
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            return imageView
        }()
        scrollView.addSubview(separator2_1)
        
        let separator2_2 = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "分隔線擦痕")
            imageView.frame = CGRect(x: 15, y:separator2_1.frame.origin.y + 60, width: view.frame.width - 40, height: 1.3)
            imageView.contentMode = .scaleToFill
            return imageView
        }()
        scrollView.addSubview(separator2_2)
        
        
        
        itemNameTextFieldCountLabel  = { () -> UILabel in
            let label = UILabel()
            label.text = "\(itemNameWordLimit)"
            label.textColor = UIColor.hexStringToUIColor(hex: "414141")
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.textAlignment = .right
            label.frame = CGRect(x:view.frame.width - 14 - 26, y: separator2_1.frame.origin.y - label.intrinsicContentSize.height - 7, width: 26, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(itemNameTextFieldCountLabel)
        
        
        
        itemNameTextField = { () -> UITextField in
            let textField = UITextField()
            textField.tintColor = .white
            textField.frame = CGRect(x:20, y: separator2_1.frame.origin.y + separator2_1.frame.height, width: view.frame.width - 20 * 2, height: 60)
            
            if iWantType == .Sell{
                textField.attributedPlaceholder = NSAttributedString(string:
                                                                        "    ex：二手書、手工品、個人平面設計接案⋯⋯", attributes:
                                                                            [NSAttributedString.Key.foregroundColor:UIColor.hexStringToUIColor(hex: "414141")])
                
            }else if iWantType == .Buy{
                textField.attributedPlaceholder = NSAttributedString(string:
                                                                        "    ex：一場約會、二手Switch、某項正職、打工⋯⋯", attributes:
                                                                            [NSAttributedString.Key.foregroundColor:UIColor.hexStringToUIColor(hex: "414141")])
                
            }
            textField.clearButtonMode = .whileEditing
            textField.returnKeyType = .done
            textField.textColor = .black
            textField.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            textField.backgroundColor = .clear
            itemNameTextFieldDelegate.wordLimit = itemNameWordLimit
            itemNameTextFieldDelegate.wordLimitLabel = itemNameTextFieldCountLabel
            itemNameTextFieldDelegate.wordLimitForTypeDelegate = self
            textField.delegate = itemNameTextFieldDelegate
            return textField
        }()
        scrollView.addSubview(itemNameTextField)
        
        
        let separator3_1 = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "分隔線擦痕")
            imageView.frame = CGRect(x: -20, y:separator2_2.frame.origin.y + 60, width: view.frame.width + 40, height: 1.3)
            imageView.contentMode = .scaleToFill
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            return imageView
        }()
        scrollView.addSubview(separator3_1)
        
        let separator3_2 = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "分隔線擦痕")
            imageView.frame = CGRect(x: 15, y:separator3_1.frame.origin.y + 60, width: view.frame.width - 40, height: 1.3)
            imageView.contentMode = .scaleToFill
            return imageView
        }()
        scrollView.addSubview(separator3_2)
        
        let priceLabel = { () -> UILabel in
            let label = UILabel()
            if iWantType == .Sell{
                label.text = "商品價格"
            }else if iWantType == .Buy{
                label.text = "任務報酬"
            }
            label.textColor = UIColor.hexStringToUIColor(hex: "472411")
            label.font = UIFont(name: "HelveticaNeue", size: 16)
            label.frame = CGRect(x: 14, y: separator3_1.frame.origin.y - label.intrinsicContentSize.height - 7, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(priceLabel)
        
        priceTextFieldCountLabel  = { () -> UILabel in
            let label = UILabel()
            label.text = "\(priceWordLimit)"
            label.textColor = UIColor.hexStringToUIColor(hex: "414141")
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.textAlignment = .right
            label.frame = CGRect(x:view.frame.width - 14 - 26, y: separator3_1.frame.origin.y - label.intrinsicContentSize.height - 7, width: 26, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(priceTextFieldCountLabel)
        
        priceTextField = { () -> UITextField in
            let textField = UITextField()
            textField.tintColor = .white
            textField.frame = CGRect(x:20, y: separator3_1.frame.origin.y + separator3_1.frame.height, width: view.frame.width - 20 * 2, height: 60)
            textField.attributedPlaceholder = NSAttributedString(string:
                                                                    "    ex：一杯咖啡、一頓飯、250元、聊天室談⋯⋯", attributes:
                                                                        [NSAttributedString.Key.foregroundColor:UIColor.hexStringToUIColor(hex: "414141")])
            textField.clearButtonMode = .whileEditing
            textField.returnKeyType = .done
            textField.textColor = .black
            textField.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            textField.backgroundColor = .clear
            priceTextFieldDelegate.wordLimit = priceWordLimit
            priceTextFieldDelegate.wordLimitLabel = priceTextFieldCountLabel
            priceTextFieldDelegate.wordLimitForTypeDelegate = self
            textField.delegate = priceTextFieldDelegate
            return textField
        }()
        scrollView.addSubview(priceTextField)
        
        
        let separator4_1 = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "分隔線擦痕")
            imageView.frame = CGRect(x: -20, y:separator3_2.frame.origin.y + 60, width: view.frame.width + 40, height: 1.3)
            imageView.contentMode = .scaleToFill
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            return imageView
        }()
        scrollView.addSubview(separator4_1)
        
        let separator4_2 = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "分隔線擦痕")
            imageView.frame = CGRect(x: -20, y:separator4_1.frame.origin.y + 605, width: view.frame.width + 40, height: 1.3)
            imageView.contentMode = .scaleToFill
            
            return imageView
        }()
        scrollView.addSubview(separator4_2)
        
        
        
        let itemInfoLabel = { () -> UILabel in
            let label = UILabel()
            if iWantType == .Sell{
                label.text = "商品資訊"
            }else if iWantType == .Buy{
                label.text = "任務資訊"
            }
            label.textColor = UIColor.hexStringToUIColor(hex: "472411")
            label.font = UIFont(name: "HelveticaNeue", size: 16)
            label.frame = CGRect(x: 14, y: separator4_1.frame.origin.y - label.intrinsicContentSize.height - 7, width: label.intrinsicContentSize.width, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(itemInfoLabel)
        
        itemInfoTextFieldCountLabel  = { () -> UILabel in
            let label = UILabel()
            label.text = "\(itemInfoWordLimit)"
            label.textColor = UIColor.hexStringToUIColor(hex: "414141")
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.textAlignment = .right
            label.frame = CGRect(x:view.frame.width - 14 - 26, y: separator4_1.frame.origin.y - label.intrinsicContentSize.height - 7, width: 26, height: label.intrinsicContentSize.height)
            return label
        }()
        scrollView.addSubview(itemInfoTextFieldCountLabel)
        
        if iWantType == .Sell{
            itemInfoPlaceholder = "\n   在這寫下您提供的商品資訊與細節⋯⋯"
        }else if iWantType == .Buy{
            itemInfoPlaceholder = "\n   在這寫下您發布的任務細節⋯⋯"
        }
        
        itemInfoTextView = { () -> UITextView in
            let textView = UITextView()
            textView.tintColor = .white
            textView.frame = CGRect(x:20, y: separator4_1.frame.origin.y + separator4_1.frame.height, width: view.frame.width - 20 * 2, height: 600)
            textView.returnKeyType = .default
            textView.textColor =  UIColor.hexStringToUIColor(hex: "414141")
            textView.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            textView.backgroundColor = .clear
            textView.text = itemInfoPlaceholder
            itemInfoTextViewDelegate.placeholder = itemInfoPlaceholder
            itemInfoTextViewDelegate.placeholderColor = UIColor.hexStringToUIColor(hex: "414141")
            
            itemInfoTextViewDelegate.wordLimit = itemInfoWordLimit
            itemInfoTextViewDelegate.wordLimitLabel = itemInfoTextFieldCountLabel
            textView.delegate = itemInfoTextViewDelegate
            return textView
        }()
        scrollView.addSubview(itemInfoTextView)
        
        
        scrollView.contentSize = CGSize(width: view.frame.width,height: separator4_2.frame.origin.y + 400)
    }
    
    @objc fileprivate func endEditTouch() {
        self.view.endEditing(true)
    }
    
    
    fileprivate func addTakePhotoOrUsePhotoBtn(){
        
        
        
        addPhotoBtn.frame = CGRect(x: 6, y:2 * view.frame.height - 177, width: rootWidth - 12, height: 53)
        addPhotoBtn.setImage(UIImage(named: "ActionSheet_上方有弧度"), for: .normal)
        addPhotoBtn.imageView?.contentMode = .scaleToFill
        let addPhotoLabel = UILabel()
        addPhotoLabel.text = "從相簿找圖"
        addPhotoLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        addPhotoLabel.textColor = UIColor.hexStringToUIColor(hex: "751010")
        addPhotoLabel.frame = CGRect(x: addPhotoBtn.frame.width/2 - addPhotoLabel.intrinsicContentSize.width/2, y: addPhotoBtn.frame.height/2 -  addPhotoLabel.intrinsicContentSize.height/2, width: addPhotoLabel.intrinsicContentSize.width, height: addPhotoLabel.intrinsicContentSize.height)
        addPhotoBtn.addSubview(addPhotoLabel)
        view.addSubview(addPhotoBtn)
        addPhotoBtn.addTarget(self, action: #selector(addPhotoBtnAct), for: .touchUpInside)
        
        takePhotoBtn.frame = CGRect(x: 6, y:2 * view.frame.height - 124, width: rootWidth - 12, height: 53)
        takePhotoBtn.setImage(UIImage(named: "ActionSheet_下方有弧度"), for: .normal)
        takePhotoBtn.imageView?.contentMode = .scaleToFill
        let takePhotLabel = UILabel()
        takePhotLabel.text = "拍照"
        takePhotLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        takePhotLabel.textColor = UIColor.hexStringToUIColor(hex: "751010")
        takePhotLabel.frame = CGRect(x: takePhotoBtn.frame.width/2 - takePhotLabel.intrinsicContentSize.width/2, y: takePhotoBtn.frame.height/2 -  takePhotLabel.intrinsicContentSize.height/2, width: takePhotLabel.intrinsicContentSize.width, height: takePhotLabel.intrinsicContentSize.height)
        takePhotoBtn.addSubview(takePhotLabel)
        view.addSubview(takePhotoBtn)
        takePhotoBtn.addTarget(self, action: #selector(takePhotoBtnAct), for: .touchUpInside)
        
        
    }
    
    fileprivate func addDeleteAndCancealBtn() {
        
        fullScreenGrayBG.isHidden = true
        fullScreenGrayBG.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        fullScreenGrayBG.backgroundColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 0.56)
        fullScreenGrayBG.addTarget(self, action: #selector(concealBtnAct), for: .touchUpInside)
        view.addSubview(fullScreenGrayBG)
        
        rootWidth = UIScreen.main.bounds.size.width
        concealBtn.frame = CGRect(x: 6, y: 2 * view.frame.height - 53 - 9, width: rootWidth - 12, height: 53)
        concealBtn.setImage(UIImage(named: "ActionSheet_兩邊有弧度"), for: .normal)
        concealBtn.imageView?.contentMode = .scaleToFill
        let concealLabel = UILabel()
        concealLabel.text = "取消"
        concealLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        concealLabel.textColor = UIColor.hexStringToUIColor(hex: "6D6D6D")
        concealLabel.frame = CGRect(x: concealBtn.frame.width/2 - concealLabel.intrinsicContentSize.width/2, y: concealBtn.frame.height/2 -  concealLabel.intrinsicContentSize.height/2, width: concealLabel.intrinsicContentSize.width, height: concealLabel.intrinsicContentSize.height)
        concealBtn.addSubview(concealLabel)
        view.addSubview(concealBtn)
        concealBtn.addTarget(self, action: #selector(concealBtnAct), for: .touchUpInside)
        //
        deleteBtn.frame = CGRect(x: 6, y:2 * view.frame.height - 124, width: rootWidth - 12, height: 53)
        deleteBtn.setImage(UIImage(named: "ActionSheet_兩邊有弧度"), for: .normal)
        deleteBtn.imageView?.contentMode = .scaleToFill
        let deleteLabel = UILabel()
        deleteLabel.text = "刪除"
        deleteLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        deleteLabel.textColor = UIColor.hexStringToUIColor(hex: "751010")
        deleteLabel.frame = CGRect(x: deleteBtn.frame.width/2 - deleteLabel.intrinsicContentSize.width/2, y: deleteBtn.frame.height/2 -  deleteLabel.intrinsicContentSize.height/2, width: deleteLabel.intrinsicContentSize.width, height: deleteLabel.intrinsicContentSize.height)
        deleteBtn.addSubview(deleteLabel)
        view.addSubview(deleteBtn)
        deleteBtn.addTarget(self, action: #selector(deleteBtnAct), for: .touchUpInside)
        
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
            cell.deleteIcon.image = UIImage(named: "PhotoDeleteIcon")!
            cell.photo.image = photos[indexPath.row]
            
            cell.loadingView.contentMode = .scaleAspectFit
            
            
            cell.loadingView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi)/2).scaledBy(x: 0.7, y: 0.7)
            if iWantType == .Sell{
                
                cell.loadingView.image = UIImage(named: "天秤小icon")?.withRenderingMode(.alwaysTemplate)
            }else{
                cell.loadingView.image = UIImage(named: "捲軸小icon")?.withRenderingMode(.alwaysTemplate)
            }
            
            let loadingViewBorder = UIView(frame: CGRect(x: -cell.loadingView.frame.width * 0.2, y: -cell.loadingView.frame.height * 0.2, width: cell.loadingView.frame.width/0.55, height: cell.loadingView.frame.height/0.55))
            loadingViewBorder.layer.cornerRadius = 7/0.7
            loadingViewBorder.layer.borderWidth = 2.5/0.7
            loadingViewBorder.layer.borderColor = UIColor.hexStringToUIColor(hex: "5E1A11").cgColor
            loadingViewBorder.backgroundColor = .clear
            cell.loadingView.addSubview(loadingViewBorder)
            
        }else{
            cell.deleteIcon.image = UIImage()
            cell.photo.image = UIImage(named: "AddPhotoIcon")
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
    
    // MARK: - BtnAct
    @objc fileprivate func showDeletePhotoBtn() {
        //跳出是否要刪除照片鈕
        self.view.endEditing(true)
        fullScreenGrayBG.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            self.deleteBtn.frame = CGRect(x: 6, y: self.view.frame.height - 53 - 9 - 53 - 9, width: self.rootWidth - 12, height: 53)
            self.concealBtn.frame = CGRect(x: 6, y: self.view.frame.height - 53 - 9, width: self.rootWidth - 12, height: 53)
        })
    }
    
    @objc fileprivate func showSelectPhotoBtn() {
        
        //跳出是否要新增照片鈕 從相簿、從相機
        self.view.endEditing(true)
        fullScreenGrayBG.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            
            
            self.addPhotoBtn.frame = CGRect(x: 6, y: self.view.frame.height - 177, width: self.rootWidth - 12, height: 53)
            self.takePhotoBtn.frame = CGRect(x: 6, y: self.view.frame.height - 124, width: self.rootWidth - 12, height: 53)
            self.concealBtn.frame = CGRect(x: 6, y: self.view.frame.height - 62, width: self.rootWidth - 12, height: 53)
        })
        
    }
    
    
    @objc fileprivate func concealBtnAct(){
        fullScreenGrayBG.isHidden = true
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            self.deleteBtn.frame = CGRect(x: 6, y: 2 * self.view.frame.height - 124, width: self.rootWidth - 12, height: 53)
            self.concealBtn.frame = CGRect(x: 6, y: 2 * self.view.frame.height - 53 - 9, width: self.rootWidth - 12, height: 53)
            self.addPhotoBtn.frame = CGRect(x: 6, y: 2 * self.view.frame.height - 177, width: self.rootWidth - 12, height: 53)
            self.takePhotoBtn.frame = CGRect(x: 6, y: 2 * self.view.frame.height - 124, width: self.rootWidth - 12, height: 53)
        })
    }
    @objc fileprivate func deleteBtnAct(){
        
        photos.remove(at: currentSelectPhotoNumber)
        photoTableView.reloadData()
        
        //如果是已經上傳過的，需要記錄起來，之後如果按刊登，就一起刪除
        if photoUrls[currentSelectPhotoNumber] != noURLString{
            photoUrlsNeedToDelete.append(photoUrls[currentSelectPhotoNumber])
        }
        //刪除photoUrl
        photoUrls.remove(at: currentSelectPhotoNumber)
        
        fullScreenGrayBG.isHidden = true
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            self.deleteBtn.frame = CGRect(x: 6, y: 2 * self.view.frame.height - 124, width: self.rootWidth - 12, height: 53)
            self.concealBtn.frame = CGRect(x: 6, y: 2 * self.view.frame.height - 53 - 9, width: self.rootWidth - 12, height: 53)
        })
        
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
        concealBtnAct()
    }
    @objc fileprivate func addPhotoBtnAct(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true // 可對照片作編輯
            picker.modalPresentationStyle = .overCurrentContext
            self.present(picker, animated: true, completion: nil)
        }
        concealBtnAct()
    }
    
    
    @objc fileprivate func publishBtnAct(){
        self.view.endEditing(true)
        
        publishBtn.isEnabled = false
        publishBtn.alpha = 0.25
        
        uploadToFireBase()
    }
    
    //TODO 刪除，不這樣更新
    fileprivate func updateLocalData_shopEditViewController(_ myItem: Item) {
        
        if shopEditViewController != nil && defaultItem == nil{
            if iWantType == .Sell{
                shopEditViewController!.shopModel.personInfo.sellItems.insert(myItem, at: 0)
                shopEditViewController!.bigItemTableView.reloadData()
            }else if iWantType == .Buy{
                shopEditViewController!.shopModel.personInfo.buyItems.insert(myItem, at: 0)
                shopEditViewController!.bigItemTableView.reloadData()
            }
        }
    }
    
    fileprivate func putPersonDetailToFireBase(itemID:String) {
        
        let ref = Database.database().reference()
        //上傳item
        var itemWithIDRef = ref.child("SellItem/" +  UserSetting.UID + "/" + itemID)
        if self.iWantType == .Sell{
            itemWithIDRef = ref.child("PersonDetail/" +  UserSetting.UID + "/SellItems/" + itemID)
        }else if self.iWantType == .Buy{
            itemWithIDRef = ref.child("PersonDetail/" +  UserSetting.UID + "/BuyItems/" + itemID)
        }
        
        
        var itemCount = 0
        if self.iWantType == .Sell{
            UserSetting.sellItemsID.append(itemID)
            itemCount = UserSetting.sellItemsID.count
        }else if self.iWantType == .Buy{
            UserSetting.buyItemsID.append(itemID)
            itemCount = UserSetting.buyItemsID.count
        }
        var myItem = Item(itemID:nil,thumbnailUrl:self.thumbnailUrl,photosUrl: self.photoUrls, name: self.itemNameTextField.text!, price: self.priceTextField.text!, descript: self.itemInfo, order: itemCount,done: false,likeUIDs: [],subscribedIDs: [],commentIDs: [],itemType: iWantType)
        itemWithIDRef.setValue(myItem.toAnyObject()){ (error, ref) -> Void in
            if error != nil{
                print(error ?? "上傳Item失敗")
                self.publishBtn.isEnabled = true
                self.publishBtn.alpha = 1
                self.loadingView.removeFromSuperview()
            }
            //調整UserSetting.isWantSell/BuySomething+上傳subscribedID
            var subscribedIDRef : DatabaseReference!
            if self.iWantType == .Sell{
                UserSetting.isWantSellSomething = true
                subscribedIDRef = Database.database().reference(withPath: "PersonDetail/" + UserSetting.UID + "/SellItems/" + itemID + "/subscribedIDs/" + UserSetting.UID)
            }else if self.iWantType == .Buy{
                UserSetting.isWantBuySomething = true
                subscribedIDRef = Database.database().reference(withPath: "PersonDetail/" + UserSetting.UID + "/BuyItems/" + itemID + "/subscribedIDs/" + UserSetting.UID)
            }
            subscribedIDRef.setValue(UserSetting.userName)
            
            //上傳item成功就回到上一頁
            self.gobackBtnAct()
            //更新userAnnotation造成即時顯示效果
            self.mapViewController?.presonAnnotationGetter.reFreshUserAnnotation()
            
            //更新本地端，如果有shopEditViewController並且沒有defaultItem時
            if self.photos.count > 0 {
                myItem.thumbnail = self.photos[0]
            }
            myItem.itemID = itemID
            self.updateLocalData_shopEditViewController(myItem)
            
        }
    }
    
    
    func uploadToFireBase() {
        
        loadingView = UIView(frame: CGRect(x: view.frame.width/2 - 40, y: view.frame.height/2 - 40, width: 80, height: 80))
        view.addSubview(loadingView)
        loadingView.setupToLoadingView()
        
        if self.iWantType == .Sell{
            UserSetting.isWantSellSomething = true
        }else if self.iWantType == .Buy{
            UserSetting.isWantBuySomething = true
        }
        
        if UserSetting.storeName == ""{
            UserSetting.storeName = "Hi!"
        }
        //上傳TradeAnnotation
        FirebaseHelper.updateTradeAnnotation()
        
        var itemID : String!
        if defaultItem != nil {
            itemID = defaultItem?.itemID
        }else{
            itemID = NSUUID().uuidString
        }
        
        if self.itemInfoTextView.text! != itemInfoPlaceholder{
            itemInfo = self.itemInfoTextView.text!
        }else{
            itemInfo = ""
        }
        successedPutPhotoNumber = 0
        
        ////先刪除需要刪除的photo，就是過去已經上傳過，但是在編輯時把它刪除的照片
        for photoUrl in photoUrlsNeedToDelete {
            let photoStorageRef = Storage.storage().reference(forURL: photoUrl)
            photoStorageRef.delete(completion: { (error) in
                if let error = error {
                    print(error)
                } else {
                    // success
                    print("deleted \(photoUrl)")
                }
            })
        }
        
        
        
        ////如果沒有照片就直接上傳item
        if photos.count == 0{
            
            //有thumbnailUrl就刪掉，代表原本有照片，但是後來刪除了
            if let item = self.defaultItem{
                if let thumbnailUrl = item.thumbnailUrl{
                    let photoStorageRef = Storage.storage().reference(forURL: thumbnailUrl)
                    photoStorageRef.delete(completion: { (error) in
                        if let error = error {
                            print(error)
                        } else {
                            // success
                            print("deleted \(thumbnailUrl)")
                        }
                    })
                }
                
            }
            self.thumbnailUrl = nil
            defaultItem?.thumbnailUrl = nil
            defaultItem?.thumbnail = UIImage()
            putPersonDetailToFireBase(itemID: itemID)
            self.changeLocalData()
            return
        }
        
        ////計算需要上傳的photo數量
        for url in photoUrls{
            
            if url == noURLString{
                photoNumberNeedToPut += 1
            }
        }
        //縮圖也算一個
        photoNumberNeedToPut += 1
        
        if let item = self.defaultItem{
            //處理縮圖，如果第一張照片跟原先的第一張照片不一致，就刪除再重新上傳
            if originalFirstPhotoUrl != nil{
                if originalFirstPhotoUrl! != photoUrls[0]{
                    if let thumbnailUrl = item.thumbnailUrl{
                        let photoStorageRef = Storage.storage().reference(forURL: thumbnailUrl)
                        //刪除原有縮圖
                        photoStorageRef.delete(completion: { (error) in
                            //上傳新縮圖
                            FirebaseHelper.putThumbnail(image: self.photos[0], completion: {url -> () in
                                                            self.thumbnailUrl = url
                                                            self.successedPutPhotoNumber += 1
                                                            if self.successedPutPhotoNumber == self.photoNumberNeedToPut{
                                                                self.putPersonDetailToFireBase(itemID: itemID)
                                                                self.changeLocalData()
                                                            }})
                            if let error = error {
                                print(error)
                            }
                        })}
                }else{
                    putThumbnail(img: photos[0],itemID:itemID)
                }
                
            }else{
                putThumbnail(img: photos[0],itemID:itemID)
            }
        }else{
            //上傳新縮圖
            putThumbnail(img: photos[0],itemID:itemID)
        }
        ////如果有照片就先存起來拿到url，都湊齊就都上傳PersonDetail
        for i in 0...photos.count - 1{
            
            if photoUrls[i] == noURLString{
                FirebaseHelper.putItemPhoto(image: photos[i], completion:  {url -> () in
                                                self.photoUrls[i] = url
                                                self.successedPutPhotoNumber += 1
                                                
                                                if self.successedPutPhotoNumber == self.photoNumberNeedToPut{
                                                    self.putPersonDetailToFireBase(itemID: itemID)
                                                    self.changeLocalData()
                                                }})
            }
            
        }
        
        
        
    }
    
    //上傳新縮圖
    func putThumbnail(img:UIImage,itemID:String){
        FirebaseHelper.putThumbnail(image: img, completion: {url -> () in
                                        self.thumbnailUrl = url
                                        self.successedPutPhotoNumber += 1
                                        if self.successedPutPhotoNumber == self.photoNumberNeedToPut{
                                            self.putPersonDetailToFireBase(itemID: itemID)
                                            self.changeLocalData()
                                        }})
        
    }
    
    ////修改本地端資料
    func changeLocalData(){
        
        if shopEditViewController != nil && defaultItem != nil{
            defaultItem?.name = itemNameTextField.text!
            defaultItem?.price = priceTextField.text!
            defaultItem?.descript = itemInfoTextView.text!
            if self.photos.count > 0{
                defaultItem?.thumbnail = self.photos[0]
            }else{
                defaultItem?.thumbnail = UIImage()
            }
            defaultItem?.thumbnailUrl = self.thumbnailUrl
            defaultItem?.photosUrl = self.photoUrls
            if shopEditViewController!.shopModel.personInfo.sellItems.count > 0{
                for i in 0 ... shopEditViewController!.shopModel.personInfo.sellItems.count - 1{
                    if defaultItem!.itemID! == shopEditViewController!.shopModel.personInfo.sellItems[i].itemID!{
                        shopEditViewController!.shopModel.personInfo.sellItems[i] = defaultItem!
                        print("覆蓋掉mapViewModel.storeSellItems")
                    }
                }}
            if shopEditViewController!.shopModel.personInfo.buyItems.count > 0 {
                for i in 0 ... shopEditViewController!.shopModel.personInfo.buyItems.count - 1{
                    if defaultItem!.itemID! == shopEditViewController!.shopModel.personInfo.buyItems[i].itemID!{
                        shopEditViewController!.shopModel.personInfo.buyItems[i] = defaultItem!
                        print("覆蓋掉mapViewModel.storeBuyItems")
                    }
                }
                
            }
            shopEditViewController!.bigItemTableView.reloadData()
        }
    }
    // MARK: - WordLimitForTypeDelegate 自製
    
    func whenEditDoSomeThing(){
        checkCanPublishOrNot()
    }
    
    func whenEndEditDoSomeThing() {
        checkCanPublishOrNot()
    }
    
    func checkCanPublishOrNot(){
        if  itemNameTextField.text != "" &&
                priceTextField.text != ""{
            publishBtn.isEnabled = true
            publishBtn.alpha = 1
        }else{
            publishBtn.isEnabled = false
            publishBtn.alpha = 0.25
        }
    }
    
    
    
}


