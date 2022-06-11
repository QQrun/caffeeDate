//
//  Extensions.swift
//  MapStuff
//
//  Created by Stephen Dowless on 1/21/19.
//  Copyright © 2019 Stephan Dowless. All rights reserved.
//

import UIKit
import Alamofire
import SystemConfiguration


extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func hexStringToUIColor (hex:String,alpha:Float = 1) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    //
    //    static func mainPink() -> UIColor {
    //        return UIColor.rgb(red: 221, green: 94, blue: 86)
    //    }
    //
    //    static func mainBlue() -> UIColor {
    //        return UIColor.rgb(red: 55, green: 120, blue: 250)
    //    }
    //
    //    static func directionsGreen() -> UIColor {
    //        return UIColor.rgb(red: 76, green: 217, blue: 100)
    //    }
    
}

extension UIView {
    
    func center(inView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func centerX(inView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func addConstraintsToFillView(view: UIView) {
        self.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func setupToLoadingView() {
        
        let cycleLayer: CAShapeLayer = CAShapeLayer()
        
        cycleLayer.lineWidth = 4
        cycleLayer.fillColor = UIColor.clear.cgColor
        cycleLayer.strokeColor = UIColor.on().cgColor
        
        cycleLayer.lineCap = CAShapeLayerLineCap.round
        cycleLayer.lineJoin = CAShapeLayerLineJoin.round
        
        cycleLayer.frame = self.bounds
        cycleLayer.path = UIBezierPath(ovalIn: self.bounds).cgPath
        self.layer.addSublayer(cycleLayer)
        
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.fromValue = -1
        strokeStartAnimation.toValue = 1.0
        strokeStartAnimation.repeatCount = Float.infinity
        cycleLayer.add(strokeStartAnimation, forKey: "strokeStartAnimation")
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1.0
        strokeEndAnimation.repeatCount = Float.infinity
        cycleLayer.add(strokeEndAnimation, forKey: "strokeStartAnimation")
        let animationGroup = CAAnimationGroup()
        animationGroup.repeatCount = Float.infinity
        animationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
        animationGroup.duration = 1.5
        cycleLayer.add(animationGroup, forKey: "animationGroup")
        
    }
    
}


func verifyUrl (urlString: String?) -> Bool {
    if let urlString = urlString {
        if let url = NSURL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
    }
    return false
}


extension Date {
    
    func years(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.year], from: sinceDate, to: self).year
    }
    
    func months(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.month], from: sinceDate, to: self).month
    }
    
    func days(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.day], from: sinceDate, to: self).day
    }
    
    func hours(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.hour], from: sinceDate, to: self).hour
    }
    
    func minutes(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.minute], from: sinceDate, to: self).minute
    }
    
    func seconds(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.second], from: sinceDate, to: self).second
    }
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    
}


extension UIPageViewController {
    var isPagingEnabled: Bool {
        get {
            var isEnabled: Bool = true
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    isEnabled = subView.isScrollEnabled
                }
            }
            return isEnabled
        }
        set {
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    subView.isScrollEnabled = newValue
                }
            }
        }
    }
}


//壓縮方式
extension UIImage{
    
    public func imageWithNewSize(size: CGSize) -> UIImage? {
        
        if self.size.height > size.height {
            
            let width = size.height / self.size.height * self.size.width
            
            let newImgSize = CGSize(width: width, height: size.height)
            
            UIGraphicsBeginImageContext(newImgSize)
            
            self.draw(in: CGRect(x: 0, y: 0, width: newImgSize.width, height: newImgSize.height))
            
            let theImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            guard let newImg = theImage else { return  nil}
            
            return newImg
            
        } else {
            
            let newImgSize = CGSize(width: size.width, height: size.height)
            
            UIGraphicsBeginImageContext(newImgSize)
            
            self.draw(in: CGRect(x: 0, y: 0, width: newImgSize.width, height: newImgSize.height))
            
            let theImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            guard let newImg = theImage else { return  nil}
            
            return newImg
        }
        
    }
    
    func compressQuality(maxLength:NSInteger) -> UIImage {
        var compression:CGFloat = 1
        var data = self.jpegData(compressionQuality: compression)!
        if data.count < maxLength {
            return UIImage(data: data)!
        }
        var max:CGFloat = 1
        var min:CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min)/2
            data = self.jpegData(compressionQuality: compression)!
            if Double(data.count) < Double(maxLength)*0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
        
        return UIImage(data: data)!
    }
    
}


extension UIImageView{
    
    public func downloadURL(url:String){
        
        let loadingView = UIView(frame: CGRect(x: self.frame.width/4, y: self.frame.height/4, width: self.frame.width/2, height: self.frame.height/2))
        loadingView.setupToLoadingView()
        self.addSubview(loadingView)
        AF.request(url).response { (response) in
            guard let data = response.data, let image = UIImage(data: data)
            else {
                print("讀取圖片url失敗")
                return }
            self.image = image
            loadingView.removeFromSuperview()
        }
    }
    
}

extension Date{
    
    public func getCurrentTimeString() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHmmss"
        return dateFormatter.string(from: self)
    }
}

extension UIButton {
    
    func setBackgroundColor(_ color: UIColor, forState controlState: UIControl.State) {
        let colorImage = UIGraphicsImageRenderer(size: CGSize(width: self.frame.width, height: self.frame.height)).image { _ in
            color.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)).fill()
        }
        setBackgroundImage(colorImage, for: controlState)
    }
    
}

extension UIView {
    func parentView<T: UIView>(of type: T.Type) -> T? {
        guard let view = superview else {
            return nil
        }
        return (view as? T) ?? view.parentView(of: T.self)
    }
}

extension UITableViewCell {
    var tableView: UITableView? {
        return parentView(of: UITableView.self)
    }
}

extension String{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}



extension UIViewController {
    
    func showToast(message : String, font: UIFont,duration:Double = 4) {
        
        let toastLabel = UILabel()
        toastLabel.backgroundColor = .on().withAlphaComponent(0.6)
        toastLabel.textColor = .baseBackground()
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.frame = CGRect(x: self.view.frame.size.width/2 - (toastLabel.intrinsicContentSize.width + 8)/2, y: self.view.frame.size.height-100, width: toastLabel.intrinsicContentSize.width + 8, height: 35)
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.5, delay: duration - 1.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func showToast(message : String) {
        showToast(message: message, font: .systemFont(ofSize: 14.0))
    }
    
    func showToast(message : String,duration:Double) {
        showToast(message: message, font: .systemFont(ofSize: 14.0),duration: duration)
    }
}




extension UIColor {
    /*
     使UIColor能處理HEX字串, 前綴#有無帶入皆可
     範例: UIColor.init(hexString: "#0C5D89") , UIColor.init(hexString: "0C5D89")
     */
    convenience init(hexString: String, alpha:CGFloat? = 1.0) {
        var hexInt: UInt64 = 0
        let scanner = Scanner(string: hexString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt64(&hexInt)
        
        let red = CGFloat((hexInt & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexInt & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexInt & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /*
     隨機產生顏色
     */
    static func randomColor() -> UIColor {
        let red = CGFloat(arc4random_uniform(256)) / 255.0
        let green = CGFloat(arc4random_uniform(256)) / 255.0
        let blue = CGFloat(arc4random_uniform(256)) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// 圖片顏色
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

extension UITableView {
    
    func deselectSelectedRow(animated: Bool)
    {
        if let indexPathForSelectedRow = self.indexPathForSelectedRow {
            self.deselectRow(at: indexPathForSelectedRow, animated: animated)
        }
    }
    
}


extension Array {
    mutating func removeSpecifiedIndices(_ indices: [Int]) {
        let sortedIndices = indices.sorted().reversed()
        for i in sortedIndices {
            guard i < count else { return }
            remove(at: i)
        }
    }
}


extension UILabel {
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }

    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: rect.inset(by: insets))
        } else {
            self.drawText(in: rect)
        }
    }

    override open var intrinsicContentSize: CGSize {
        guard let text = self.text else { return super.intrinsicContentSize }

        var contentSize = super.intrinsicContentSize
        var textWidth: CGFloat = frame.size.width
        var insetsHeight: CGFloat = 0.0
        var insetsWidth: CGFloat = 0.0

        if let insets = padding {
            insetsWidth += insets.left + insets.right
            insetsHeight += insets.top + insets.bottom
            textWidth -= insetsWidth
        }

        let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                        attributes: [NSAttributedString.Key.font: self.font], context: nil)

        contentSize.height = ceil(newSize.size.height) + insetsHeight
        contentSize.width = ceil(newSize.size.width) + insetsWidth

        return contentSize
    }
}
