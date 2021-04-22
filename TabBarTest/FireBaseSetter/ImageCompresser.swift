//
//  ImageCompresser.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/25.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit



func ImageCompresser(originalImage: UIImage) -> UIImage{
    
    var compressedImage = originalImage
    var compressedImageData = originalImage.jpegData(compressionQuality: 1)
    
    print("compressedImageData!.count")
    print(compressedImageData!.count)
    while compressedImageData!.count > 102400 {
        compressedImageData = compressedImage.jpegData(compressionQuality: 0.5)
        compressedImage = UIImage(data: compressedImageData!)!
    }
    
    return UIImage(data: compressedImageData!)!
}
