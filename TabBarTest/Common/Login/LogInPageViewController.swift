//
//  LogInPageViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/20.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import Firebase

class LogInPageViewController: UIPageViewController {
    
    var viewControllerList: [UIViewController] = [UIViewController]()
    weak var mapViewController: MapViewController!
    weak var pageViewControllerDelegate: PageViewControllerDelegate?
    
    let firstLogInPage = UIStoryboard(name: "FirstLogInViewController", bundle: nil).instantiateViewController(withIdentifier: "FirstLogInViewController")
    
    let checkLocationAccessPage = UIStoryboard(name: "CheckLocationAccessViewController", bundle: nil).instantiateViewController(withIdentifier: "CheckLocationAccessViewController")
    
    let fillBasicInfoPage = UIStoryboard(name: "FillBasicInfoViewController", bundle: nil).instantiateViewController(withIdentifier: "FillBasicInfoViewController")
    
//    let fourPage = UIStoryboard(name: "ThirdLogInViewController", bundle: nil).instantiateViewController(withIdentifier: "ThirdLogInViewController")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        
        self.viewControllerList.append(firstLogInPage)
        (firstLogInPage as! FirstLogInViewController).logInPageViewController = self
        self.viewControllerList.append(checkLocationAccessPage)
        (checkLocationAccessPage as! CheckLocationAccessViewController).logInPageViewController = self
        self.viewControllerList.append(fillBasicInfoPage)
        (fillBasicInfoPage as! FillBasicInfoViewController).logInPageViewController = self
        self.delegate = self
        self.dataSource = self
        // 設定 pageViewControoler 的首頁
        self.setViewControllers([self.viewControllerList.first!], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        self.isPagingEnabled = false
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CoordinatorAndControllerInstanceHelper.rootCoordinator.setDefaultTabView()
    }
    
    func goFillBasicInfoPage(){
        
        let ref = Database.database().reference()
        ref.child("PersonDetail/" + UserSetting.UID).observeSingleEvent(of: .value, with:{(snapshot) in
            if snapshot.exists(){
                
                let userDetail = PersonDetailInfo(snapshot: snapshot)

                //做出sellItemsID
                var storeSellItems : [Item] = []
                if let childSnapshots = snapshot.childSnapshot(forPath: "SellItems").children.allObjects as? [DataSnapshot] {
                    for childSnapshot in childSnapshots{
                        let item = Item(snapshot: childSnapshot)
                        item.itemID = childSnapshot.key
                        item.thumbnail = UIImage()
                        storeSellItems.append(item)
                    }
                }
                storeSellItems = Util.quicksort_Item(storeSellItems)
                var sellItemsID : [String] = []
                for item in storeSellItems{
                    sellItemsID.append(item.itemID!)
                }
                //做出buyItemsID
                var storeBuyItems : [Item] = []
                if let childSnapshots = snapshot.childSnapshot(forPath: "BuyItems").children.allObjects as? [DataSnapshot] {
                    for childSnapshot in childSnapshots{
                        let item = Item(snapshot: childSnapshot)
                        item.itemID = childSnapshot.key
                        item.thumbnail = UIImage()
                        storeBuyItems.append(item)
                    }
                }
                storeBuyItems = Util.quicksort_Item(storeBuyItems)
                var buyItemsID : [String] = []
                for item in storeBuyItems{
                    buyItemsID.append(item.itemID!)
                }
                
                //做出isWantSellSomething
                var isWantSellSomething = false
                if sellItemsID.count > 0 {
                    isWantSellSomething = true
                }
                
                //做出isWantBuySomething
                var isWantBuySomething = false
                if buyItemsID.count > 0{
                    isWantBuySomething = true
                }
                
                //做出photoURLs
                var photoURLs : [String] = []
                var photoURLsDict : [Int : String] =  [:]
                if let childSnapshots = snapshot.childSnapshot(forPath: "photos").children.allObjects as? [DataSnapshot] {
                    for childSnapshot in childSnapshots{
                        let photoNumber = Int(childSnapshot.key)
                        photoURLsDict[photoNumber!] = childSnapshot.value as? String ?? ""
                    }
                    let sortedByKeyDictionary = photoURLsDict.sorted { firstDictionary, secondDictionary in
                        return firstDictionary.0 < secondDictionary.0 // 由小到大排序
                    }
                    
                    for data in sortedByKeyDictionary{
                        photoURLs.append(data.value)
                    }
                }
                
                let dic = ["alreadyUpdatePersonDetail":true,
                           "UID":UserSetting.UID,
                           "userName":userDetail.name,
                           "userBirthDay":userDetail.birthday,
                           "userGender":userDetail.gender,
                           "userSelfIntroduction":userDetail.selfIntroduction,
                           "isMapShowOpenStore": UserSetting.isMapShowTeamUp,
                           "isMapShowRequest":UserSetting.isMapShowRequest,
                           "isMapShowTeamUp":UserSetting.isMapShowTeamUp,
                           "isMapShowCoffeeShop":UserSetting.isMapShowCoffeeShop,
                           "isMapShowMakeFriend_Boy":UserSetting.isMapShowMakeFriend_Boy,
                           "isMapShowMakeFriend_Girl":UserSetting.isMapShowMakeFriend_Girl,
                           "perferIconStyleToShowInMap":userDetail.perferIconStyleToShowInMap,
                           "isWantSellSomething":isWantSellSomething,
                           "isWantBuySomething":isWantBuySomething,
                           "isWantTeamUp":false,
                           "isWantMakeFriend":false,
                           "sellItemsID":sellItemsID,
                           "buyItemsID":buyItemsID,
                           "userPhotosUrl":photoURLs,
                           "currentChatTarget":"",] as [String : Any]
                for data in dic {
                    UserDefaults.standard.set(data.value, forKey: data.key)
                }
                if let headshot = userDetail.headShot{
                    UserDefaults.standard.set(headshot, forKey: "userSmallHeadShotURL")
                }
                
                FirebaseHelper.updateSignInTime()
                FirebaseHelper.updateToken()
                self.dismiss(animated: true, completion: nil)
            }else{
                self.setViewControllers([self.fillBasicInfoPage], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
            }
        })
    }
    
    func goCheckLocationAccessPage(){
        self.setViewControllers([checkLocationAccessPage], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
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

protocol PageViewControllerDelegate: class {
    
    /// 設定頁數
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - numberOfPage: _
    func pageViewController(_ pageViewController: LogInPageViewController, didUpdateNumberOfPage numberOfPage: Int)
    
    /// 當 pageViewController 切換頁數時，設定 pageControl 的頁數
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - pageIndex: _
    func pageViewController(_ pageViewController: LogInPageViewController, didUpdatePageIndex pageIndex: Int)
}

extension LogInPageViewController: UIPageViewControllerDataSource {
    
    /// 上一頁
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - viewController: _
    /// - Returns: _
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // 取得當前頁數的 index(未翻頁前)
        let currentIndex: Int =  self.viewControllerList.index(of: viewController)!
        
        // 設定上一頁的 index
        let priviousIndex: Int = currentIndex - 1
        
        // 判斷上一頁的 index 是否小於 0，若小於 0 則停留在當前的頁數
        return priviousIndex < 0 ? nil : self.viewControllerList[priviousIndex]
    }
    
    /// 下一頁
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - viewController: _
    /// - Returns: _
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // 取得當前頁數的 index(未翻頁前)
        let currentIndex: Int =  self.viewControllerList.index(of: viewController)!
        
        // 設定下一頁的 index
        let nextIndex: Int = currentIndex + 1
        
        // 判斷下一頁的 index 是否大於總頁數，若大於則停留在當前的頁數
        return nextIndex > self.viewControllerList.count - 1 ? nil : self.viewControllerList[nextIndex]
    }
    
}

extension LogInPageViewController: UIPageViewControllerDelegate {
    
    /// 切換完頁數觸發的 func
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - finished: _
    ///   - previousViewControllers: _
    ///   - completed: _
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // 取得當前頁數的 viewController
        let currentViewController: UIViewController = (self.viewControllers?.first)!
        
        // 取得當前頁數的 index
        let currentIndex: Int =  self.viewControllerList.index(of: currentViewController)!
        
        self.pageViewControllerDelegate?.pageViewController(self, didUpdatePageIndex: currentIndex)
    }
}


