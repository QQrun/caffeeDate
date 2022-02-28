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
        locationImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        locationImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        return view
     }()
    
    let locationImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .sksPink()
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
    
    let locationDistanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .on().withAlphaComponent(0.7)
        return label
    }()
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(imageContainerView)
        let dimension: CGFloat = 32
        imageContainerView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: dimension, height: dimension)
        imageContainerView.layer.cornerRadius = dimension/2
        imageContainerView.centerY(inView: self)
        
        addSubview(locationTitleLabel)
        locationTitleLabel.anchor(top: imageContainerView.topAnchor, left: imageContainerView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(locationDistanceLabel)
        locationDistanceLabel.anchor(top: nil, left: imageContainerView.rightAnchor, bottom: imageContainerView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not been implement")
    }
    
    
    func configureCell() {
        
        if(mapItem == nil){
            locationTitleLabel.text = ""
            locationDistanceLabel.text = ""
            imageContainerView.alpha = 0
        }
    
        locationTitleLabel.text = mapItem?.name

        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.unitStyle = .abbreviated
        
        guard let mapItemLocation = mapItem?.placemark.location else { return }
        guard let distanceFromUser = delegate?.distanceFromUser(location: mapItemLocation) else { return }
        let distanceAsString = distanceFormatter.string(fromDistance: distanceFromUser)
        locationDistanceLabel.text = distanceAsString
        
        imageContainerView.alpha = 1
        
    }
    
}

