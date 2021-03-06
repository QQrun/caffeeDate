//
//  ChooseLocationViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/02/25.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class ChooseLocationViewController: UIViewController{

    var holdShareSeatViewController : HoldShareSeatViewController
    
    var customTopBarKit = CustomTopBarKit()
    var finishBtn : UIButton!
    
    var mapView : MKMapView = MKMapView()
    var locationManager : CLLocationManager!
    var searchInputView : SearchInputView!
    
    var selectedAnnotation: MKAnnotation?
    var selectedMapItem: MKMapItem?
    
    let centerMapButton : UIButton = {
        let circleButton_reposition = UIButton()
        circleButton_reposition.backgroundColor = .sksWhite()
        let repositionImage = UIImage(named: "icons24LocationGrey24")
        circleButton_reposition.layer.cornerRadius = 16
        circleButton_reposition.layer.shadowRadius = 2
        circleButton_reposition.layer.shadowOffset = CGSize(width: 2, height: 2)
        circleButton_reposition.layer.shadowOpacity = 0.3
        circleButton_reposition.setImage(repositionImage, for: [])
        circleButton_reposition.isEnabled = true
        circleButton_reposition.addTarget(self, action: #selector(repositionBtnAct), for: .touchUpInside)
        return circleButton_reposition
    }()
    
    //隐藏狀態欄
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init(holdShareSeatViewController:HoldShareSeatViewController) {
        self.holdShareSeatViewController = holdShareSeatViewController
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        configureMapView()
        configTopBar()
        configComponents()
        
        centerMapOnUserLocation(shouldLoadAnnotations: true)
    }
    
    fileprivate func configComponents() {
        view.addSubview(centerMapButton)
        centerMapButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 120, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 32, height: 32)
        
        searchInputView = SearchInputView()
        searchInputView.delegate = self
        searchInputView.chooseLocationViewController = self
        view.addSubview(searchInputView)
        searchInputView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 88 + 320 )
    }
    
    
    fileprivate func configureMapView() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        mapView.showsPointsOfInterest = false
        mapView.tintColor = .primary() //這裡決定的是user那個點的顏色
        
        view.addSubview(mapView)
        mapView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 88 + 320, paddingRight: 0, width: 0, height: 0)
    }

    fileprivate func configTopBar() {
        
        customTopBarKit.CreatTopBar(view: view,showSeparator:true)
        customTopBarKit.CreatDoSomeThingTextBtn(text: "確認")
        customTopBarKit.CreatCenterTitle(text: "選擇地點")
        customTopBarKit.getTopBar().backgroundColor = .surface().withAlphaComponent(0.5)
        
        finishBtn = customTopBarKit.getDoSomeThingTextBtn()
        finishBtn.addTarget(self, action: #selector(finishBtnAct), for: .touchUpInside)
        finishBtn.isEnabled = false
        finishBtn.alpha = 0.25
        
        let gobackBtn = customTopBarKit.getGobackBtn()
        gobackBtn.addTarget(self, action: #selector(gobackBtnAct), for: .touchUpInside)
        
        
        
        
    }
    
    func zoomToFit(selectedAnnotation: MKAnnotation?) {
        if mapView.annotations.count == 0 {
            return
        }
        
        var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        if let selectedAnnotation = selectedAnnotation {
            for annotation in mapView.annotations {
                if let userAnno = annotation as? MKUserLocation {
                    topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, userAnno.coordinate.longitude)
                    topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, userAnno.coordinate.latitude)
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, userAnno.coordinate.longitude)
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, userAnno.coordinate.latitude)
                }
                
                if annotation.title == selectedAnnotation.title {
                    topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
                    topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
                }
            }
            
            var region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.65, topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.65), span: MKCoordinateSpan(latitudeDelta: fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 3.0, longitudeDelta: fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 3.0))
            
            region = mapView.regionThatFits(region)
            mapView.setRegion(region, animated: true)
        }
    }

    
    
    func searchBy(naturalLanguageQuery: String,region:MKCoordinateRegion,coordinates: CLLocationCoordinate2D,completion:@escaping (_ response: MKLocalSearch.Response?,_ error: NSError?) -> ()){
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = naturalLanguageQuery
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start{ (response,error) in
            
            guard let response = response else{
                completion(nil,error! as NSError)
                return
            }
            
            completion(response,nil)
        }
        
    }
    
    func centerMapOnUserLocation(shouldLoadAnnotations: Bool) {
        
        guard let coordinates = locationManager.location?.coordinate else { return }
        
        let zoomWidth = mapView.visibleMapRect.size.width
        var meter : Double = 500
        if zoomWidth < 3694{
            meter = zoomWidth * 500/3694
        }
        
        
//        if(searchInputView.expansionState == .PartiallyExpanded){
//            let coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinates.latitude - 0.002, longitude: coordinates.longitude), latitudinalMeters: meter, longitudinalMeters: meter)
//            mapView.setRegion(coordinateRegion, animated: true)
//        }else{
            let coordinateRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: meter, longitudinalMeters: meter)
            mapView.setRegion(coordinateRegion, animated: true)
//        }
        
                
    }
    
    func removeAnnotations(){
        mapView.annotations.forEach{ (annotation) in
            if let annotation = annotation as? MKPointAnnotation{
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    
    
    @objc private func repositionBtnAct(){
        enableLocationServices()
        centerMapOnUserLocation(shouldLoadAnnotations: false)
    }

    
    @objc private func gobackBtnAct(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc private func finishBtnAct(){
        holdShareSeatViewController.mapItem = selectedMapItem
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    

}

// MARK: - SearchInputViewDelegate

extension ChooseLocationViewController: SearchInputViewDelegate{
   
    func selectedAnnotation(withMapItem mapItem: MKMapItem) {
        mapView.annotations.forEach { (annotation) in
            if annotation.coordinate.latitude == mapItem.placemark.coordinate.latitude && annotation.coordinate.longitude == mapItem.placemark.coordinate.longitude{
                self.mapView.selectAnnotation(annotation, animated: true)
                self.zoomToFit(selectedAnnotation: annotation)
                self.selectedAnnotation = annotation
                
                selectedMapItem = mapItem
                
                self.finishBtn.isEnabled = true
                self.finishBtn.alpha = 1
            }
        }
    }
    
    func handleSearch(_ searchText: String) {
        
        removeAnnotations()
        
        guard let coordinate = locationManager.location?.coordinate else {return}
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 0, longitudinalMeters: 0)
        searchBy(naturalLanguageQuery: searchText, region: region,coordinates: coordinate){
            (response,error) in
            
            self.searchInputView.searchResults = []
            response?.mapItems.forEach({(mapItem) in
                let annotation = MKPointAnnotation()
                annotation.title = mapItem.name
                annotation.coordinate = mapItem.placemark.coordinate

                if(mapItem.placemark.country == "台灣" || mapItem.placemark.country == "台湾"){
                    self.mapView.addAnnotation(annotation)
                    self.searchInputView.searchResults?.append(mapItem)
                }
//                self.mapView.addAnnotation(annotation)
//                self.searchInputView.searchResults?.append(mapItem)
            })
            
        }
    }
    
    
}


// MARK: - CLLocationManagerDelegate
extension ChooseLocationViewController: CLLocationManagerDelegate{
    
    
    
    
    
    func enableLocationServices(){
        
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
            print("MapViewController:Location auth status is NOT DETERMINED")
            
            DispatchQueue.main.async {
                let controller = UIStoryboard(name: "CheckLocationAccessViewController", bundle: nil).instantiateViewController(withIdentifier: "CheckLocationAccessViewController") as! CheckLocationAccessViewController
                controller.modalPresentationStyle = .fullScreen
                controller.mapViewController = CoordinatorAndControllerInstanceHelper.rootCoordinator.mapViewController
                self.present(controller, animated: true, completion: nil)
            }
        case .restricted:
            print("MapViewController:Location auth status is RESTRICTED")
        case .denied:
            print("MapViewController:Location auth status is DENIED")
            DispatchQueue.main.async {
                if let bundleID = Bundle.main.bundleIdentifier,let url = URL(string:UIApplication.openSettingsURLString + bundleID) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        case .authorizedAlways:
            print("MapViewController:Location auth status is AUTHORIZED ALWAYS")
        case .authorizedWhenInUse:
            print("MapViewController:Location auth status is AUTHORIZED WHEN IN USE")
        }
        
    }
}


// MARK: - MKMapViewDelegate

extension ChooseLocationViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView){
        searchInputView.tableView.deselectSelectedRow(animated: true)
        self.finishBtn.isEnabled = false
        self.finishBtn.alpha = 0.25
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let searchResults = searchInputView.searchResults{
            for i in 0 ... searchResults.count - 1{
                if searchResults[i].placemark.coordinate.longitude == view.annotation!.coordinate.longitude && searchResults[i].placemark.coordinate.latitude == view.annotation!.coordinate.latitude{
                    
                    let selectedRow = IndexPath(row: i, section: 0)
                    searchInputView.tableView.selectRow(at: selectedRow, animated: true, scrollPosition: .top)
                    
                    selectedMapItem = searchResults[i]
                    
                    self.finishBtn.isEnabled = true
                    self.finishBtn.alpha = 1
                }
            }
        }
        
    }

    
}


// MARK: - SearchCellDelegate

extension ChooseLocationViewController: SearchCellDelegate {
    
    func getDirections(forMapItem mapItem: MKMapItem) {
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    func distanceFromUser(location: CLLocation) -> CLLocationDistance? {
        guard let userLocation = locationManager.location else { return nil }
        return userLocation.distance(from: location)
    }
}

