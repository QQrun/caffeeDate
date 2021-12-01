//
//  Colors.swift
//  StockSelect
//
//  Created by 金融產規部-梁雅軒 on 2021/8/25.
//  Copyright © 2021 mitake. All rights reserved.
//

import UIKit

extension UIColor {
    //背景
    @objc
    class func baseBackground() -> UIColor {
        return UIColor(hexString: StockSelectColorManagerModel.shared.baseBackground)
    }
    //主色
    @objc
    class func primary() -> UIColor {
        return UIColor(hexString: StockSelectColorManagerModel.shared.primary)
    }
    
    //Night mode
    class func isNightMode() -> Bool {
        return StockSelectColorManagerModel.shared.isNightMode
    }
    //介面
    @objc
    class func surface() -> UIColor {
        let h = UIColor.isNightMode() ? UIColor.primary().hsba.hue : 200
        let s: CGFloat = UIColor.baseBackground().hsba.brightness > 0.5 ? 0 : 0.3
        let b: CGFloat = UIColor.baseBackground().hsba.brightness > 0.5 ? 1 : UIColor.baseBackground().hsba.brightness + 0.05
        return UIColor(hue: h / 360, saturation: s, brightness: b, alpha: 1)
    }
    //錯誤
    static let error = UIColor(hexString: StockSelectColorManagerModel.shared.error)
    //強調
    @objc
    static let accent = UIColor(hexString: StockSelectColorManagerModel.shared.accent)
    //內容
    @objc
    class func on() -> UIColor {
        return UIColor.surface().hsba.brightness > 0.5 ? UIColor.black : UIColor.white
    }
    //漲
    static let rise = UIColor(hexString: StockSelectColorManagerModel.shared.rise)
    @objc
    static let riseRed = UIColor.surface().hsba.brightness > 0.8 ? UIColor(hue: UIColor.rise.hsba.hue/360 , saturation: UIColor.rise.hsba.saturation, brightness: UIColor.rise.hsba.brightness - 0.1, alpha: UIColor.rise.hsba.alpha) : .rise
    //跌
    static let fall = UIColor(hexString: StockSelectColorManagerModel.shared.fall)
    @objc
    static let fallGreen = UIColor.surface().hsba.brightness > 0.8 ? UIColor(hue: UIColor.fall.hsba.hue/360 , saturation: UIColor.fall.hsba.saturation, brightness: UIColor.fall.hsba.brightness - 0.1, alpha: UIColor.fall.hsba.alpha) : .fall
    //平
    static let unchaged = UIColor(hexString: StockSelectColorManagerModel.shared.unchaged)
    @objc
    static let unchagedOrange = UIColor.surface().hsba.brightness > 0.8 ? UIColor(hue: UIColor.unchaged.hsba.hue/360 , saturation: UIColor.unchaged.hsba.saturation, brightness: UIColor.unchaged.hsba.brightness - 0.1, alpha: UIColor.unchaged.hsba.alpha) : .unchaged
    //色彩管理器內固定alpha
    enum StockSelectColorModel: CGFloat {
        case `default` = 0.9
        case midHighEmphasis = 0.7
        case mediumEmphasis = 0.5
        case disabled = 0.3
    }
    
    func alphaComponent(_ model: StockSelectColorModel) -> UIColor {
        return self.withAlphaComponent(model.rawValue)
    }
    
    //混色
    @objc
    static func addColor(_ color1: UIColor, with color2: UIColor) -> UIColor {
        var (r1, g1, b1, a1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        var (r2, g2, b2, a2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        // add the components, but don't let them go above 1.0
        return UIColor(red: min(r1 + r2, 1), green: min(g1 + g2, 1), blue: min(b1 + b2, 1), alpha: (a1 + a2) / 2)
    }
    
    @objc
    class func sksGray() -> UIColor {
        return isNightMode() ? UIColor.init(hexString: "#B3B3B3") : UIColor.init(hexString: "#888888")
    }
    
    @objc
    class func sksOrange() -> UIColor {
        return isNightMode() ? UIColor.init(hexString: "#FFA159") : UIColor.init(hexString: "#F27E00")
    }
    
    @objc
    class func sksYellow() -> UIColor {
        return isNightMode() ? UIColor.init(hexString: "#E0DB3F") : UIColor.init(hexString: "#C79500")
    }
    
    @objc
    class func sksGreen() -> UIColor {
        return isNightMode() ? UIColor.init(hexString: "#5CC400") : UIColor.init(hexString: "#2AB300")
    }

    @objc
    class func sksTeal() -> UIColor {
        return isNightMode() ? UIColor.init(hexString: "#00C4DB") : UIColor.init(hexString: "#00A4B3")
    }
    
    @objc
    class func sksBlue() -> UIColor {
        return isNightMode() ? UIColor.init(hexString: "#3BA3FF") : UIColor.init(hexString: "#0F8FFF")
    }
    
    @objc
    class func sksIndigo() -> UIColor {
        return isNightMode() ? UIColor.init(hexString: "#7581FF") : UIColor.init(hexString: "#606CF0")
    }
    
    @objc
    class func sksIndigoLight() -> UIColor {
        return isNightMode() ? UIColor.init(hexString: "#B3B9FF") : UIColor.init(hexString: "#99A0F0")
    }
    
    @objc
    class func sksPurple() -> UIColor {
        return isNightMode() ? UIColor.init(hexString: "#DA82FF") : UIColor.init(hexString: "#BB70DB")
    }
    
    @objc
    class func sksPink() -> UIColor {
        return isNightMode() ? UIColor.init(hexString: "#FF66A5") : UIColor.init(hexString: "#F50066")
    }
    
    func getSKSColor(_ index: CGFloat) -> UIColor {
        let aAvoid = UIColor.accent.hsba.hue
        let bAvoid = UIColor.primary().hsba.hue
        print(aAvoid)
        print(bAvoid)
        let h = index * 40 / 360
        let s = UIColor.primary().hsba.saturation
        let b = UIColor.surface().hsba.brightness > 0.8 ? 0.7 : 0.85
        return UIColor(hue: h, saturation: s, brightness: b, alpha: 1)
    }

    @objc
    static func multiplyColor(_ color: UIColor, by multiplier: CGFloat) -> UIColor {
        var (r, g, b, a) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r * multiplier, green: g * multiplier, blue: b * multiplier, alpha: a)
    }
    // 如果設計說 surface + on 0.04
    // 即 on * 0.04 + surface * 0.96
    // 如果設計說 surface + on 0.4
    // 即 on * 0.4 + surface * 0.6 以此類推
    static func +(color1: UIColor, color2: UIColor) -> UIColor {
        return addColor(color1, with: color2)
    }

    static func *(color: UIColor, multiplier: Double) -> UIColor {
        return multiplyColor(color, by: CGFloat(multiplier))
    }
    
    // hue 色相
    // saturation 飽和度
    // brightness 亮度
    // alpha 透明度
    public var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h * 360, s, b, a)
    }
}
