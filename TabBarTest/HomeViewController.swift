//
//  HomeViewController.swift
//  TabBarTest
//
//  Created by Howard Sun on 2021/6/3.
//  Copyright © 2021 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import MapKit

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
//        button.addTarget(self, action: #selector(addBtnAct), for: .touchUpInside)
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
        //        button.addTarget(self, action: #selector(addBtnAct), for: .touchUpInside)
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
        //        button.addTarget(self, action: #selector(addBtnAct), for: .touchUpInside)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isHidden = false
        addButton.isHidden = false
        acccountButton.isHidden = false
        messageButton.isHidden = false
        locationManager.startUpdatingLocation()
        
    }
}

extension HomeViewController: MKMapViewDelegate {
    
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 700, longitudinalMeters: 700)
        mapView.setRegion(region, animated: true)
    }
}

