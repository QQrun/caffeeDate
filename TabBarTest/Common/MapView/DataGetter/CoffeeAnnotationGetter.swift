//
//  CoffeeData.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/12.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import MapKit

class CoffeeAnnotationGetter{
    
    var mapView : MKMapView
    
    var coffeeAnnotations : [CoffeeAnnotation] = []
    
    init(mapView:MKMapView) {
        self.mapView = mapView
    }
    
    func fetchCoffeeData() {
        
        //        let address = "https://cafenomad.tw/api/v1.2/cafes/taipei"
        let address = "https://cafenomad.tw/api/v2.0/cafes?token=b666e32f665a6842dd1e507518f1939f"
        if let url = URL(string: address) {
            // GET
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let _ = response as? HTTPURLResponse,let data = data {
//                    let decoder = JSONDecoder()
                    do{
                        let coffeeData = try JSONDecoder().decode([CoffeeData].self, from: data)
                        DispatchQueue.main.async{
                            for coffee in coffeeData {
                                let annotation = CoffeeAnnotation()
                                annotation.coordinate = CLLocationCoordinate2D(latitude:  CLLocationDegrees((coffee.latitude as NSString).floatValue), longitude: CLLocationDegrees((coffee.longitude as NSString).floatValue))
                                annotation.name = coffee.name
                                annotation.city = coffee.city
                                annotation.wifi = coffee.wifi
                                annotation.seat = coffee.seat
                                annotation.quiet = coffee.quiet
                                annotation.tasty = coffee.tasty
                                annotation.cheap = coffee.cheap
                                annotation.music = coffee.music
                                annotation.url = coffee.url
                                annotation.address = coffee.address
                                annotation.latitude = coffee.latitude
                                annotation.longitude = coffee.longitude
                                annotation.wishes = coffee.wishes
                                annotation.favorites = coffee.favorites
                                annotation.checkins = coffee.checkins
                                annotation.reviews = coffee.reviews
                                annotation.tags = coffee.tags
                                annotation.business_hours = coffee.business_hours
                                //                                annotation.open_time = coffee.open_time
                                self.coffeeAnnotations.append(annotation)
                            }
                            
                            if UserSetting.isMapShowCoffeeShop{
                                for annotation in self.coffeeAnnotations{
                                    self.mapView.addAnnotation(annotation)
                                }
                            }
                        }
                    }catch{
                        print(error)
                    }
                    
//                    if let coffeeData = try? decoder.decode([CoffeeData].self, from: data) {
//                        DispatchQueue.main.async{
//                            for coffee in coffeeData {
//                                let annotation = CoffeeAnnotation()
//                                annotation.coordinate = CLLocationCoordinate2D(latitude:  CLLocationDegrees((coffee.latitude as NSString).floatValue), longitude: CLLocationDegrees((coffee.longitude as NSString).floatValue))
//                                annotation.name = coffee.name
//                                annotation.city = coffee.city
//                                annotation.wifi = coffee.wifi
//                                annotation.seat = coffee.seat
//                                annotation.quiet = coffee.quiet
//                                annotation.tasty = coffee.tasty
//                                annotation.cheap = coffee.cheap
//                                annotation.music = coffee.music
//                                annotation.url = coffee.url
//                                annotation.address = coffee.address
//                                annotation.latitude = coffee.latitude
//                                annotation.longitude = coffee.longitude
//                                //                                annotation.open_time = coffee.open_time
//                                self.coffeeAnnotations.append(annotation)
//                            }
//
//                            if UserSetting.isMapShowCoffeeShop{
//                                for annotation in self.coffeeAnnotations{
//                                    self.mapView.addAnnotation(annotation)
//                                }
//                            }
//                        }
//                    }
                }
                
            }.resume()
        } else {
            print("Invalid URL.")
        }
    }
}


struct CoffeeData: Codable {
    var name: String
    var city: String
    var wifi: CGFloat
    var seat: CGFloat
    var quiet: CGFloat
    var tasty: CGFloat
    var cheap: CGFloat
    var music: CGFloat
    var url: String
    var address: String
    var latitude: String
    var longitude: String
    var limited_time: String
    var socket: String
    var standing_desk: String
    var business_hours:Business_hours
//        var open_time: String
    
    var wishes: Int
    var favorites: Int
    var checkins: Int
    var reviews: Int
    var tags:[String]




}

struct Business_hours :Codable{
    var monday: OPEN_CLOSE_TIME
    var tuesday: OPEN_CLOSE_TIME
    var wednesday: OPEN_CLOSE_TIME
    var thursday: OPEN_CLOSE_TIME
    var friday: OPEN_CLOSE_TIME
    var saturday: OPEN_CLOSE_TIME
    var sunday: OPEN_CLOSE_TIME
    struct OPEN_CLOSE_TIME :Codable{
        var open: String?
        var close: String?
    }
}
