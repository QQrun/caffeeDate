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
import FloatingPanel

class HomeViewController: UIViewController {
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.tintColor = UIColor(hexString: "#F5A623")
        mapView.register(annotationViewWithClass: CoffeeMarkerAnnotationView.self)
        mapView.register(annotationViewWithClass: TradeAnnotationView.self)
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
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
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
    
    lazy var floatingPanelController: FloatingPanelController = {
        let fpc = FloatingPanelController()
        fpc.delegate = self
        fpc.isRemovalInteractionEnabled = true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.contentMode = .fitToBounds
        fpc.contentInsetAdjustmentBehavior = .always
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 24
        fpc.surfaceView.appearance = appearance
        fpc.layout = TradePanelLayout()
        return fpc
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
    
    @objc func addButtonTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
//        alert.addAction(UIAlertAction(title: "我想買東西", style: .default , handler: { _ in
//            let wantBuyViewController = WantSellViewController(defaultItem: nil)
//            wantBuyViewController.modalPresentationStyle = .overCurrentContext
////            wantBuyViewController.shopEditViewController = shopEditViewController
//            wantBuyViewController.iWantType = .Buy
//            self.present(wantBuyViewController, animated: true)
//        }))
        for type in CreateTradeViewController.TradeType.allCases {
            alert.addAction(UIAlertAction(title: type.title, style: .default) { _ in
                self.createTrade(type: type)
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true) {
            print("completion block")
        }
    }
    
    func createTrade(type: CreateTradeViewController.TradeType) {
        let vc = CreateTradeViewController(type: type)
        let nav = UINavigationController(rootViewController: vc)
        floatingPanelController.set(contentViewController: nav)
        present(floatingPanelController, animated: true)
    }
}

extension HomeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is CoffeeAnnotation {
            return mapView.dequeueReusableAnnotationView(withClass: CoffeeMarkerAnnotationView.self)
        } else if annotation is TradeAnnotation {
            return mapView.dequeueReusableAnnotationView(withClass: TradeAnnotationView.self)
        }
        return nil
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

extension HomeViewController: FloatingPanelControllerDelegate {
    
    open func floatingPanel(_ fpc: FloatingPanelController, shouldRemoveAt location: CGPoint, with velocity: CGVector) -> Bool {
        return velocity.dy > 3
    }
}

extension UIButton {
    
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
    }
}

class TradePanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full
    
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0.0, edge: .top, referenceGuide: .safeArea)
        ]
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.3
    }
}
