//
//  ThirdLogInViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/20.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit

class OpenNotificationViewController: UIViewController {

    @IBOutlet weak var birdAndMailImageView: UIImageView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var laterBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CustomBGKit().CreatDarkStyleBG(view: view)
        
        let birdAndMailIcon = UIImage(named: "飛鴿傳書icon")?.withRenderingMode(.alwaysTemplate)
        birdAndMailImageView.image = birdAndMailIcon
        birdAndMailImageView.tintColor = UIColor.hexStringToUIColor(hex: "#751010")
        
        continueBtn.layer.cornerRadius = 7
        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueBtnAct(_ sender: Any) {
        
    }
    
    @IBAction func laterBtnAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
