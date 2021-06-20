//
//  CoffeeMarkerAnnotationView.swift
//  TabBarTest
//
//  Created by Howard Sun on 2021/6/20.
//  Copyright © 2021 金融研發一部-邱冠倫. All rights reserved.
//

import MapKit

class CoffeeMarkerAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        tintColor = .clear
        markerTintColor = .clear
        glyphTintColor = UIColor(red: 34/255, green: 113/255, blue: 234/255, alpha: 1)
        glyphImage = UIImage(named: "咖啡小icon_紫")
    }
}
