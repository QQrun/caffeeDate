//
//  PhotoTableViewCell.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/13.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class WantAddPhotoTableViewCell: UITableViewCell {
    
    
    var photo : UIImageView = UIImageView()
    var deleteIcon : UIImageView = UIImageView()
    var photoBtn : UIButton = UIButton()
    var loadingView : UIImageView = UIImageView()
    
    var indexOfRow = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        contentView.frame =  CGRect(x: 0, y: 0, width: 96, height: 96)
//        contentView.backgroundColor = .blue
        
        
                
        photo = {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: 4, y: 10, width: 96, height: 96)
            let oneDegree = CGFloat.pi / 180
            imageView.transform = CGAffineTransform(rotationAngle: oneDegree * 90)
            imageView.contentMode = .scaleAspectFill
            imageView.backgroundColor = .clear
            imageView.layer.cornerRadius = 6
            imageView.clipsToBounds = true
            return imageView
        }()
        loadingView = {
            let imageView = UIImageView(frame: CGRect(x: photo.frame.minX + photo.frame.width * 1/8, y: photo.frame.minY + photo.frame.height * 1/8, width: photo.frame.width * 3/4, height: photo.frame.height * 3/4))
            imageView.tintColor = UIColor.hexStringToUIColor(hex: "5E1A11")
            imageView.contentMode = .scaleAspectFill
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi)/2)
            return imageView
        }()
        contentView.addSubview(loadingView)
        contentView.addSubview(photo)
        
        deleteIcon = {
            let imageView = UIImageView()
            imageView.frame = CGRect(x: 0, y: 89, width: 23, height: 23)
            let oneDegree = CGFloat.pi / 180
            imageView.transform = CGAffineTransform(rotationAngle: oneDegree * 90)
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .clear
            return imageView
        }()
        contentView.addSubview(deleteIcon)
        
        photoBtn = {
            let btn = UIButton()
            btn.frame = contentView.frame
            btn.setTitle("", for: [])
            return btn
        }()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if let reorderView = findReorderView(self) {
            for sv in reorderView.subviews {
                if sv is UIImageView {
                    let img = UIImage(named: "bk_icon_order_20_n2")!
                    (sv as! UIImageView).image = img
                    (sv as! UIImageView).contentMode = .center
                    let oneDegree = CGFloat.pi / 180
                    (sv as! UIImageView).transform = CGAffineTransform(rotationAngle: oneDegree * 90)
                    
                    contentView.addSubview(photoBtn)
                }
            }
        }
        
    }
    
    func findReorderView(_ view: UIView) -> UIView? {
        var reorderView: UIView?
        for subView in view.subviews {
            if subView.className.contains("Reorder") {
                reorderView = subView
                break
            }
            else {
                reorderView = findReorderView(subView)
                if reorderView != nil {
                    break
                }
            }
        }
        return reorderView
    }
    
    
    //調整ReorderControl位置至下方
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        for view in cell.subviews {
    //            if view.self.description.contains("UITableViewCellReorderControl") {
    //                let movedReorderControl = UIView(frame: CGRect(x: -30, y: -10, width: view.frame.maxX, height: view.frame.maxY))
    //                movedReorderControl.addSubview(view)
    //                cell.addSubview(movedReorderControl)
    //                let moveLeft = CGSize(width: movedReorderControl.frame.size.width - view.frame.size.width, height: movedReorderControl.frame.size.height - view.frame.size.height)
    //                var transform: CGAffineTransform = .identity
    //                transform = transform.translatedBy(x: -moveLeft.width, y: -moveLeft.height)
    //                movedReorderControl.transform = transform
    //                movedReorderControl.backgroundColor = .blue
    //            }
    //        }
    //    }
    
}
