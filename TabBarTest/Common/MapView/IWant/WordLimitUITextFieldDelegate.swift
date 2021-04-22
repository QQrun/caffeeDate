//
//  ItemNameUITextFieldDelegate,.swift
//  ForFastBuilding
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/24.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//


import UIKit

class WordLimitUITextFieldDelegate : NSObject, UITextFieldDelegate, UITextViewDelegate{
    
    var wordLimitLabel : UILabel!
    var wordLimit = 0
    var wordLimitForTypeDelegate : WordLimitForTypeDelegate?
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let countOfWords = string.count + textField.text!.count -  range.length
        if countOfWords > wordLimit{
            return false
        }
        if let label = wordLimitLabel{
            label.text = String(wordLimit - countOfWords)
        }
        if let delegate = wordLimitForTypeDelegate{
            delegate.whenEditDoSomeThing()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let delegate = wordLimitForTypeDelegate{
            delegate.whenEndEditDoSomeThing()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let countOfWords = text.count + textView.text!.count -  range.length
        if countOfWords > wordLimit{
            return false
        }
        if let label = wordLimitLabel{
            label.text = String(wordLimit - countOfWords)
        }
        return true
    }
    
    
    
    var placeholder = "在這寫下您提供的商品資訊與細節⋯⋯"
    var placeholderColor = UIColor.hexStringToUIColor(hex: "414141")
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == placeholder && textView.textColor == placeholderColor)
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = placeholder
            textView.textColor = placeholderColor
        }
        textView.resignFirstResponder()
    }
    
}


public protocol WordLimitForTypeDelegate {
    func whenEditDoSomeThing()
    func whenEndEditDoSomeThing()
}
