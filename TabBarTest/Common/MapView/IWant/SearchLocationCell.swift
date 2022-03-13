//
//  SearchLocationCell.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2022/02/25.
//  Copyright © 2022 金融研發一部-邱冠倫. All rights reserved.
//

import Foundation
import UIKit
import MapKit

protocol SearchCellDelegate {
    func distanceFromUser(location: CLLocation) -> CLLocationDistance?
    func getDirections(forMapItem mapItem: MKMapItem)
}

class SearchLocationCell : UITableViewCell{
    
    var delegate: SearchCellDelegate?
    
    var mapItem: MKMapItem? {
        didSet {
            configureCell()
        }
    }
    
    lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .sksPink()
        view.addSubview(locationImageView)
        view.alpha = 0
        locationImageView.center(inView: view)
        locationImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        locationImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        return view
     }()
    
    let locationImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.image = UIImage(named: "baseline_location_on_white_24pt_3x")?.withRenderingMode(.alwaysTemplate)
        return iv
    }()
    
    let locationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .on().withAlphaComponent(0.9)
        return label
    }()
    
    let locationAddressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .on().withAlphaComponent(0.7)
        return label
    }()
    
    
    let locationDistanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = .on().withAlphaComponent(0.5)
        label.textAlignment = .center
        return label
    }()
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(imageContainerView)
        let dimension: CGFloat = 20
        imageContainerView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 6, paddingBottom: 20, paddingRight: 0, width: dimension, height: dimension)
        imageContainerView.layer.cornerRadius = dimension/2
        imageContainerView.centerY(inView: self)
        
        addSubview(locationDistanceLabel)
        locationDistanceLabel.anchor(top: imageContainerView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 32, height: 0)
        
        addSubview(locationTitleLabel)
        locationTitleLabel.anchor(top: topAnchor, left: imageContainerView.rightAnchor, bottom: nil, right: nil, paddingTop: 7, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(locationAddressLabel)
        locationAddressLabel.anchor(top: locationTitleLabel.bottomAnchor, left: imageContainerView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.primary().withAlphaComponent(0.3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not been implement")
    }
    
    
    func configureCell() {
        
        if(mapItem == nil){
            locationTitleLabel.text = ""
            locationAddressLabel.text = ""
            locationDistanceLabel.text = ""
            imageContainerView.alpha = 0
            selectionStyle = .none
        }else{
            locationTitleLabel.text = mapItem?.name

            let distanceFormatter = MKDistanceFormatter()
            distanceFormatter.unitStyle = .abbreviated
            
            guard let mapItemLocation = mapItem?.placemark.location else { return }
            guard let distanceFromUser = delegate?.distanceFromUser(location: mapItemLocation) else { return }
            let distanceAsString = distanceFormatter.string(fromDistance: distanceFromUser)
            
            locationDistanceLabel.text = distanceAsString
            
            if let thoroughfare = mapItem?.placemark.thoroughfare , let subThoroughfare = mapItem?.placemark.subThoroughfare{
                locationAddressLabel.text = thoroughfare + subThoroughfare + "號"
            }
            
            
            
            imageContainerView.alpha = 1
            selectionStyle = .default
        }
        
    }
    
}

