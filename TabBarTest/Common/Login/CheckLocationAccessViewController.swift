//
//  SecondLogInViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/20.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import CoreLocation

class CheckLocationAccessViewController: UIViewController {
    
    @IBOutlet weak var relocationImage: UIImageView!
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var laterBtn: UIButton!
    
    weak var mapViewController : MapViewController?
    weak var logInPageViewController : LogInPageViewController!
    
    private let locationManagerInstance = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomBGKit().CreatDarkStyleBG(view: view)
        
        relocationImage.image = UIImage(named: "定位icon")?.withRenderingMode(.alwaysTemplate)
        relocationImage.tintColor = UIColor.hexStringToUIColor(hex: "#00cac7")

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        continueBtn.layer.cornerRadius = 7
    }
    
    
    
    @IBAction func continueAct(_ sender: Any) {
        
        locationManagerInstance.delegate = self
        locationManagerInstance.requestWhenInUseAuthorization()

        
    }
    
    @IBAction func laterAct(_ sender: Any) {
        
        if let controller = logInPageViewController{
            controller.goFillBasicInfoPage()
        }else{
            dismiss(animated: true, completion: {})
        }
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension CheckLocationAccessViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        print("locationManager didChangeAuthorization")
        
        if mapViewController != nil{
            self.dismiss(animated: true, completion: nil)
        }
        
        if logInPageViewController != nil{
            logInPageViewController.goFillBasicInfoPage()
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
