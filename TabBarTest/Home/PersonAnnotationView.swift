//
//  PersonAnnotationView.swift
//  TabBarTest
//
//  Created by Howard Sun on 2021/6/27.
//  Copyright © 2021 金融研發一部-邱冠倫. All rights reserved.
//

import MapKit

class PersonAnnotationView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let annotation = annotation as? PersonAnnotation else { return }
            switch annotation.markTypeToShow {
            case .openStore:
                glyphImage = UIImage(named: "天秤小icon_紫")
                break
            case .request:
                glyphImage = UIImage(named: "捲軸小icon_紫")
                break
            case .teamUp:
                glyphImage = UIImage(named: "旗子小icon_紫")
                break
            case .makeFriend:
                if let headShot = annotation.smallHeadShot {
                    glyphTintColor = .clear
                    let imageView = UIImageView(frame: CGRect(x: 2, y: 0, width: 25, height: 25))
                    imageView.tag = 1
                    imageView.image = headShot
                    imageView.contentMode = .scaleAspectFill
                    imageView.layer.cornerRadius = 12
                    imageView.clipsToBounds = true
                    addSubview(imageView)
                } else {
                    if annotation.gender == .Girl{
                        glyphImage = UIImage(named: "girlIcon")
                    } else {
                        glyphImage = UIImage(named: "boyIcon")
                    }
                }
                break
            case .none:
                markerTintColor = .clear
                tintColor = .clear
                glyphTintColor = .clear
                if let headShot = annotation.smallHeadShot{
                    let imageView = UIImageView(frame: CGRect(x: 2, y: 0, width: 25, height: 25))
                    imageView.tag = 1
                    imageView.contentMode = .scaleAspectFill
                    imageView.image = headShot
                    imageView.layer.cornerRadius = 12
                    imageView.clipsToBounds = true
                    addSubview(imageView)
                } else {
                    if annotation.gender == .Girl{
                        glyphImage = UIImage(named: "girlIcon")
                    }else{
                        glyphImage = UIImage(named: "boyIcon")
                    }
                }
            }
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        viewWithTag(1)?.removeFromSuperview()
    }
    
    func setupUI() {
        titleVisibility = .adaptive
        displayPriority = .required
        tintColor = .clear
        markerTintColor = .clear
        glyphTintColor = UIColor(red: 34/255, green: 113/255, blue: 234/255, alpha: 1)
    }
}

