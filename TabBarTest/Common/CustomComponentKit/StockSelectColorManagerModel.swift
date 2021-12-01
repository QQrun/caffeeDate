//
//  StockSelectColorManagerModel.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2021/12/01.
//  Copyright © 2021 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit

class StockSelectColorManagerModel {
    static var shared = StockSelectColorManagerModel()
    var baseBackground: String
    var primary: String
    var isNightMode: Bool
    var error: String
    var accent: String
    var rise: String
    var fall: String
    var unchaged: String
    init() {
        isNightMode = false
        baseBackground = ""
        primary = ""
        error = ""
        accent = ""
        rise = ""
        fall = ""
        unchaged = ""
        do {
            var jsonString: String?
            = MFServiceManager.content(withFileName: "SKS_ColorManager.json")
            if jsonString == nil || jsonString == "" {
                if let path = Bundle.main.path(forResource: "SKS_ColorManager", ofType: "json") {
                    jsonString = try String(contentsOfFile: path)
                }
            }
            
            if let jsonData = jsonString?.data(using: .utf8) {
                let colors = try JSONDecoder().decode(ColorModel.self, from: jsonData)
                if let userSettingBackground = UserSetting.background {
                    baseBackground = userSettingBackground
                } else {
                    baseBackground = colors.baseBackground
                }
                
                if let userSettingPrimary = UserSetting.primary {
                    primary = userSettingPrimary
                } else {
                    primary = colors.primary
                }
                isNightMode = UserSetting.isNightMode
                error = colors.error
                accent = colors.accent
                rise = colors.rise
                fall = colors.fall
                unchaged = colors.unchaged
            }
        }
        catch {
            print("JSONError \(error)")
        }
    }
}


struct ColorModel: Codable {
    var baseBackground: String
    var primary: String
    var isNightMode: Bool
    var error: String
    var accent: String
    var rise: String
    var fall: String
    var unchaged: String
    private enum CodingKeys : String, CodingKey {
        case baseBackground = "baseBackground"
        case primary = "primary"
        case isNightMode = "isNightMode"
        case error = "error"
        case accent = "accent"
        case rise = "rise"
        case fall = "fall"
        case unchaged = "unchaged"
    }
}
