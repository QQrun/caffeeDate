//
//  HomeViewController.swift
//  TabBarTest
//
//  Created by Howard Sun on 2021/6/3.
//  Copyright © 2021 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import MapKit
import SwifterSwift

extension UIButton {
    
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
    }
}

class HomeViewController: UIViewController {
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.tintColor = UIColor(hexString: "#F5A623")
        mapView.register(annotationViewWithClass: CoffeeMarkerAnnotationView.self)
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return mapView
    }()
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icons24PlusFilledWt24"), for: .normal)
        button.backgroundColor = UIColor(red: 0, green: 202 / 255, blue: 199 / 255, alpha: 1)
        button.layer.cornerRadius = 26
        button.addShadow()
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.height.width.equalTo(52)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.snp.bottomMargin).offset(-36)
        }
        return button
    }()
    
    lazy var acccountButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icons24AccountFilledGrey24"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.addShadow()
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.centerY.equalTo(addButton)
            make.right.equalTo(addButton.snp.left).offset(-48)
        }
        return button
    }()
    
    lazy var messageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icons24MessageFilledGrey24"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.addShadow()
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.centerY.equalTo(addButton)
            make.left.equalTo(addButton.snp.right).offset(48)
        }
        return button
    }()
    
    lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "slider"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.addShadow()
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.height.width.equalTo(32)
            make.top.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(-16)
        }
        return button
    }()
    
    lazy var locationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icons24LocationGrey24"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.addShadow()
        button.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.height.width.equalTo(32)
            make.top.equalToSuperview().offset(116)
            make.right.equalToSuperview().offset(-16)
        }
        return button
    }()
    
    lazy var notificationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icons24NotificationFilledGrey24"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.addShadow()
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.height.width.equalTo(32)
            make.top.equalToSuperview().offset(172)
            make.right.equalToSuperview().offset(-16)
        }
        return button
    }()
    
    var currentCoordinate: CLLocationCoordinate2D?
    var coffeeAnnotationGetter : CoffeeAnnotationGetter!
    var presonAnnotationGetter : PresonAnnotationGetter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isHidden = false
        addButton.isHidden = false
        acccountButton.isHidden = false
        messageButton.isHidden = false
        filterButton.isHidden = false
        locationButton.isHidden = false
        notificationButton.isHidden = false
        presonAnnotationGetter = PresonAnnotationGetter(mapView: mapView)
        presonAnnotationGetter.getPersonData()
        coffeeAnnotationGetter = CoffeeAnnotationGetter(mapView: mapView)
        coffeeAnnotationGetter.fetchCoffeeData()
        locationManager.startUpdatingLocation()
    }
    
    @objc func locationButtonTapped() {
        if let currentCoordinate = currentCoordinate {
            let region = MKCoordinateRegion(center: currentCoordinate, latitudinalMeters: 700, longitudinalMeters: 700)
            mapView.setRegion(region, animated: true)
        }
    }
}

extension HomeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // 創建一個重複使用的 AnnotationView
        var mkMarker = mapView.dequeueReusableAnnotationView(withIdentifier: "Markers") as? MKMarkerAnnotationView
       
        
        if mkMarker == nil {
            mkMarker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Markers")
        }
        
        
        let markColor = UIColor(red: 34/255, green: 113/255, blue: 234/255, alpha: 1)
        
        if annotation is CoffeeAnnotation {
           return mapView.dequeueReusableAnnotationView(withClass: CoffeeMarkerAnnotationView.self, for: annotation)
        }
        
        if annotation is PersonAnnotation{
            var decideWhichIcon = false
            mkMarker?.titleVisibility = .adaptive
            mkMarker?.displayPriority = .required
            mkMarker?.tintColor = .clear
            
            //加上距離標籤
            let userloc = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
            let loc = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            var distance = userloc.distance(from: loc)
            
            let distanceLabel = UILabel()
            distanceLabel.font = UIFont(name: "HelveticaNeue", size: 12)
            
            if Int(distance) >= 1000{
                distance = distance/1000
                distance = Double(Int(distance * 10))/10
                distanceLabel.text = "\(distance)" + "km"
            }else{
                distanceLabel.text = "\(Int(distance))" + "m"
            }
            distanceLabel.frame = CGRect(x: mkMarker!.frame.width/2 - distanceLabel.intrinsicContentSize.width/2, y:  mkMarker!.frame.height - distanceLabel.intrinsicContentSize.height, width: distanceLabel.intrinsicContentSize.width, height: distanceLabel.intrinsicContentSize.height)
            distanceLabel.alpha = 0
            mkMarker?.addSubview(distanceLabel)
            
            mkMarker?.glyphTintColor = markColor
            mkMarker?.titleVisibility = .adaptive
            mkMarker?.displayPriority = .required
            mkMarker?.viewWithTag(1)?.removeFromSuperview() //如果有加imageView，就刪除
            switch (annotation as! PersonAnnotation).markTypeToShow {
            case .openStore:
                mkMarker?.glyphImage = UIImage(named: "天秤小icon_紫")
                break
            case .request:
                mkMarker?.glyphImage = UIImage(named: "捲軸小icon_紫")
                break
            case .teamUp:
                mkMarker?.glyphImage = UIImage(named: "旗子小icon_紫")
                break
            case .makeFriend:
                if let headShot = (annotation as! PersonAnnotation).smallHeadShot{
                    mkMarker?.glyphTintColor = .clear
                    let imageView = UIImageView(frame: CGRect(x: 2, y: 0, width: 25, height: 25))
                    imageView.tag = 1
                    imageView.image = headShot
                    imageView.contentMode = .scaleAspectFill
                    imageView.layer.cornerRadius = 12
                    imageView.clipsToBounds = true
                    mkMarker?.addSubview(imageView)
                }else{
                    if (annotation as! PersonAnnotation).gender == .Girl{
                        mkMarker?.glyphImage = UIImage(named: "girlIcon")
                    }else{
                        mkMarker?.glyphImage = UIImage(named: "boyIcon")
                    }
                }
                break
            case .none:
                let imageView = UIImageView(frame: CGRect(x: 2, y: 0, width: 25, height: 25))
                mkMarker?.markerTintColor = .clear
                mkMarker?.tintColor = .clear
                mkMarker?.glyphTintColor = .clear
                if let headShot = (annotation as! PersonAnnotation).smallHeadShot{
                    let imageView = UIImageView(frame: CGRect(x: 2, y: 0, width: 25, height: 25))
                    imageView.tag = 1
                    imageView.contentMode = .scaleAspectFill
                    imageView.image = headShot
                    imageView.layer.cornerRadius = 12
                    imageView.clipsToBounds = true
                    mkMarker?.addSubview(imageView)
                }else{
                    if (annotation as! PersonAnnotation).gender == .Girl{
                        mkMarker?.glyphImage = UIImage(named: "girlIcon")
                    }else{
                        mkMarker?.glyphImage = UIImage(named: "boyIcon")
                    }
                }
            }
        }
        
        mkMarker?.markerTintColor = .clear
        
        // 判斷標記點是否與使用者相同，若為 true 就回傳 nil
        if annotation is MKUserLocation {
            (annotation as! MKUserLocation).title = "我想在這⋯⋯"
            //            var mkPin = mapView.dequeueReusableAnnotationView(withIdentifier: "userPin") as? MKPinAnnotationView
            //
            //            if mkPin == nil{
            //                mkPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "userPin")
            //                mkPin!.canShowCallout = true
            //                mkPin!.image = UIImage(named: "魔法羽毛(紫)")
            //            }
            return nil
        }else{
            return mkMarker
        }
        
        
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        if currentCoordinate == nil {
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 700, longitudinalMeters: 700)
            mapView.setRegion(region, animated: true)
        }
        currentCoordinate = coordinate
    }
}

