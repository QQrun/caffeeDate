//
//  CustomInputBox.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/05/29.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit


protocol CustomInputBoxKitDelegate: class {
    func publishCompletion()
    func textViewBeginEditing()
    func addBtnAction()
}


class CustomInputBoxKit : NSObject{
    
    var customInputBoxKitDelegate : CustomInputBoxKitDelegate?
    var isInMessageKit = false //如果在這個kit中，需要調整他們設計的InputBar高度50
    
    private var inputBox = UIView()
    private var inputBoxOriginFrame : CGRect!
    private var inputBoxOriginY: CGFloat!
    private var inputBoxOriginY_afterkeyBoardShow : CGFloat = 0
    
    private var inputBoxBG = UIImageView()
    private var bulletinBoardBG_BottomFadeInOriginFrame : CGRect!
    
    private var separatorForInput = UIImageView()
    private var separatorForInputOriginFrame : CGRect!
    
    private var publishBtn = UIButton()
    private var publishBtnOriginFrame : CGRect!
    private var addBtn = UIButton()
    private var addBtnOriginFrame : CGRect!
    
    private var inputBoxTextView = UITextView()
    private var inputBoxTextViewOriginFrame : CGRect!
    private var inputBoxTextViewTempHeight : CGFloat = 0
    
    private var keyBoardHeight : CGFloat = 0
    
    
    private var alreadyCreat = false
    
    private var bottomPadding : CGFloat = 0

    
    var placeholder = "輸入訊息"
    private var placeholderColor = UIColor.hexStringToUIColor(hex: "414141")
    
    private var withAddBtn = false
    
    func creatView(containerView:UIView,withAddBtn:Bool = false){
        
        if alreadyCreat{
            return
        }else{
            alreadyCreat = true
        }
        
        self.withAddBtn = withAddBtn
        
        let window = UIApplication.shared.keyWindow
        bottomPadding = window?.safeAreaInsets.bottom ?? 0
        inputBox = UIView(frame: CGRect(x: 0, y: containerView.frame.height + 10 - 70 - bottomPadding, width: containerView.frame.width, height: 70))
        if isInMessageKit{
            let topPadding = window?.safeAreaInsets.top ?? 0
            inputBox.frame.origin.y -= 45
            inputBox.frame.origin.y -= topPadding //我也不知道為啥要減掉topPadding
        }
        containerView.addSubview(inputBox)
        inputBoxOriginFrame = inputBox.frame
        inputBoxOriginY = inputBox.frame.origin.y
        
        
        inputBoxBG = {() -> UIImageView in
            let imageView = UIImageView()
            imageView.frame = CGRect(x: 0, y: 0, width: inputBox.frame.width, height: UIScreen.main.bounds.size.height)
            imageView.image = UIImage(named: "bulletinBoardParchmentBG_BottomFadeIn3")
            imageView.contentMode = .scaleToFill
            return imageView
        }()
        inputBox.addSubview(inputBoxBG)
        bulletinBoardBG_BottomFadeInOriginFrame = inputBoxBG.frame
        
        separatorForInput = { () -> UIImageView in
            let imageView = UIImageView()
            imageView.image = UIImage(named: "分隔線擦痕")
            if withAddBtn{
                imageView.frame = CGRect(x: 7 + 25, y:inputBox.frame.height - 6 - 3 - 10, width: inputBox.frame.width - 44 - 7 - 25, height: 3)
            }
            else{
               imageView.frame = CGRect(x: 7, y:inputBox.frame.height - 6 - 3 - 10, width: inputBox.frame.width - 44 - 7, height: 3)
            }
            imageView.contentMode = .scaleToFill
            return imageView
        }()
        inputBox.addSubview(separatorForInput)
        separatorForInputOriginFrame = separatorForInput.frame
        
        publishBtn = { () -> UIButton in
            let btn = UIButton()
            btn.setImage(UIImage(named: "inkIcon"), for: [])
            btn.frame = CGRect(x: inputBox.frame.width - 15 - 25, y: inputBox.frame.height/2 - 25/2, width: 25, height: 25)
            btn.isEnabled = false
            btn.alpha = 0.4
            btn.addTarget(self, action: #selector(publishBtnAct), for: .touchUpInside)
            return btn
        }()
        inputBox.addSubview(publishBtn)
        publishBtnOriginFrame = publishBtn.frame
        
        addBtn = { () -> UIButton in
            let btn = UIButton()
            btn.setImage(UIImage(named: "AddBtn"), for: [])
            btn.frame = CGRect(x: 10, y: inputBox.frame.height/2 - 25/2, width: 25, height: 25)
            btn.addTarget(self, action: #selector(addBtnAct), for: .touchUpInside)
            return btn
        }()
        if withAddBtn{
            inputBox.addSubview(addBtn)
        }
        addBtnOriginFrame = addBtn.frame
        
        inputBoxTextView = { () -> UITextView in
            let textView = UITextView()
            textView.tintColor = .white
            textView.returnKeyType = .done
            textView.textColor = placeholderColor
            textView.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            textView.backgroundColor = .clear
            textView.delegate = self
            textView.text = placeholder
            textView.returnKeyType = .default
            textView.sizeToFit()
            if withAddBtn{
                inputBoxTextViewOriginFrame = CGRect(x:18 + 25, y: 16, width: inputBox.frame.width - 18 - 15 - 25 - 25, height: textView.frame.height)
            }else{
                inputBoxTextViewOriginFrame = CGRect(x:18, y: 16, width: inputBox.frame.width - 18 - 15 - 25, height: textView.frame.height)
            }
            inputBoxTextViewTempHeight = textView.frame.height
            textView.frame = inputBoxTextViewOriginFrame
            textView.isScrollEnabled = false
            return textView
        }()
        inputBox.addSubview(inputBoxTextView)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    @objc func addBtnAct(){
        if let delegate = customInputBoxKitDelegate{
            delegate.addBtnAction()
        }
    }
    
    @objc func publishBtnAct(){
        
        
        if let delegate = customInputBoxKitDelegate{
            delegate.publishCompletion()
        }
        
        if !isInMessageKit{
            inputBoxTextView.resignFirstResponder()
            UIView.animate(withDuration: 0.1,delay: 0, animations: {
                self.inputBoxInitialization()
            })
        }else{
            inputBoxInitialization()
            var frame = self.inputBox.frame
            frame.origin.y = self.inputBoxOriginY - self.keyBoardHeight - (self.inputBox.frame.height - self.inputBoxOriginFrame.height)
            self.inputBoxOriginY_afterkeyBoardShow = self.inputBoxOriginY - self.keyBoardHeight - (self.inputBox.frame.height - self.inputBoxOriginFrame.height)
            self.inputBox.frame = frame
        }
        
        
        
    }
    
    //MARK: - notification
    @objc func keyboardWillShow(notification: NSNotification) {
        
        
        //得到鍵盤frame
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let value = userInfo.object(forKey: UIResponder.keyboardFrameEndUserInfoKey)
        let keyboardRec = (value as AnyObject).cgRectValue
        
        keyBoardHeight = 0

        if let keyboardRecheight = keyboardRec?.size.height{
            keyBoardHeight = keyboardRecheight - bottomPadding
        }
        if isInMessageKit{
            if keyBoardHeight < 51 + bottomPadding{
                return
            }else{
                keyBoardHeight = (keyboardRec?.size.height ?? 0)  - (50 + bottomPadding) 
            }
        }
        //讓textView bottom置於鍵盤頂部
        UIView.animate(withDuration: 0.1,delay: 0, animations: {
            var frame = self.inputBox.frame
            frame.origin.y = self.inputBoxOriginY - self.keyBoardHeight - (self.inputBox.frame.height - self.inputBoxOriginFrame.height)
            self.inputBoxOriginY_afterkeyBoardShow = self.inputBoxOriginY - self.keyBoardHeight - (self.inputBox.frame.height - self.inputBoxOriginFrame.height)
            self.inputBox.frame = frame
        })
        
    }
    
    func removeKeyBoardObserver(){
        NotificationCenter.default.removeObserver(self)
    }
    
    func addKeyBoardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    deinit {
        //移除监听
        NotificationCenter.default.removeObserver(self)
    }
    
    func inputBoxInitialization() {
        inputBoxBG.frame = bulletinBoardBG_BottomFadeInOriginFrame
        inputBox.frame = inputBoxOriginFrame
        publishBtn.frame = publishBtnOriginFrame
        addBtn.frame = addBtnOriginFrame
        separatorForInput.frame = separatorForInputOriginFrame
        inputBoxTextView.frame = inputBoxTextViewOriginFrame
        inputBoxTextView.text = ""
        inputBoxTextViewTempHeight = inputBoxTextViewOriginFrame.height
    }
    
    func getInputBoxTextViewText() -> String{
        return inputBoxTextView.text!
    }
    
}

//MARK: - UITextViewDelegate

extension CustomInputBoxKit : UITextViewDelegate{
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let delegate = customInputBoxKitDelegate{
            delegate.textViewBeginEditing()
        }
        if (textView.text == placeholder && textView.textColor == placeholderColor)
        {
            textView.text = ""
            textView.textColor = .black
        }
        
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        //還原inputBox位置
        UITextView.animate(withDuration: 0.1, animations: {
            UITextView.animate(withDuration: 0.1, animations: {
                var frame = self.inputBox.frame
                frame.origin.y = self.inputBoxOriginFrame.origin.y
                self.inputBox.frame = frame
            })
        })
        
        if (textView.text == "")
        {
            textView.text = placeholder
            textView.textColor = placeholderColor
        }
        
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == ""{
            changeInputBoxHeight(textView)
        }
        return true
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        //如果textView高度超過200，就不再繼續生長了
        if textView.frame.height > 200{
            textView.isScrollEnabled = true
            return
        }else{
            textView.isScrollEnabled = false
        }
        checkCanPublishOrNot()
        changeInputBoxHeight(textView)
        
        
    }
    fileprivate func checkCanPublishOrNot(){
        var tempString : String!
        tempString = inputBoxTextView.text
        tempString = tempString.replace(target: " ", withString: "")
        
        if tempString != "" {
            if !publishBtn.isEnabled{
                UIView.animate(withDuration: 0.3, animations: {
                    self.publishBtn.alpha = 1
                    self.publishBtn.isEnabled = true
                })
            }
        }else{
            if publishBtn.isEnabled{
                UIView.animate(withDuration: 0.3, animations: {
                    self.publishBtn.alpha = 0.4
                    self.publishBtn.isEnabled = false
                })
            }
        }
        
    }
    
    
    fileprivate func changeInputBoxHeight(_ textView: UITextView) {
        //如果inputBox高度沒超過200，持續生長
        textView.sizeToFit()
        
        if withAddBtn{
            textView.frame = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y, width: inputBox.frame.width - 18 - 15 - 25 - 25, height: textView.frame.height)
        }else{
            textView.frame = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y, width: inputBox.frame.width - 18 - 15 - 25, height: textView.frame.height)
        }
        
        let growHeight = textView.frame.height - inputBoxTextViewTempHeight
        
        inputBoxTextViewTempHeight = textView.frame.height
        inputBox.frame = CGRect(x: inputBoxOriginFrame.origin.x, y: inputBox.frame.origin.y - growHeight, width: inputBoxOriginFrame.width, height: inputBox.frame.height + growHeight)
        
        publishBtn.frame = CGRect(x: publishBtnOriginFrame.origin.x, y: publishBtn.frame.origin.y + growHeight, width: publishBtnOriginFrame.width, height: publishBtnOriginFrame.height)
        addBtn.frame = CGRect(x: addBtnOriginFrame.origin.x, y: addBtn.frame.origin.y + growHeight, width: addBtnOriginFrame.width, height: addBtnOriginFrame.height)
        separatorForInput.frame = CGRect(x: separatorForInputOriginFrame.origin.x, y: separatorForInput.frame.origin.y + growHeight, width: separatorForInputOriginFrame.width, height: separatorForInputOriginFrame.height)
        inputBoxTextViewTempHeight = textView.frame.height
    }
    
    
}


