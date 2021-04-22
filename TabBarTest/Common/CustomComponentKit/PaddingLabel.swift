//
//  PaddingLabel.swift
//
//  Created by Tom on 2020/5/25.
//

import UIKit

@IBDesignable
class PaddingLabel: DesignableLabel {
   @IBInspectable var topInset: CGFloat = 0.0
   @IBInspectable var bottomInset: CGFloat = 0.0
   @IBInspectable var leftInset: CGFloat = 0.0
   @IBInspectable var rightInset: CGFloat = 0.0

   override func drawText(in rect: CGRect) {
      let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
      super.drawText(in: rect.inset(by: insets))
   }

   override var intrinsicContentSize: CGSize {
      get {
         var contentSize = super.intrinsicContentSize
         contentSize.height += topInset + bottomInset
         contentSize.width += leftInset + rightInset
         return contentSize
      }
   }
}
