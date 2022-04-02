//
//  FirstLogInViewController.swift
//  TabBarTest
//
//  Created by 金融研發一部-邱冠倫 on 2020/04/20.
//  Copyright © 2020 金融研發一部-邱冠倫. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import CoreLocation
import AuthenticationServices
import CryptoKit

class FirstLogInViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var fbLogInBtn: UIButton!
    @IBOutlet weak var googleLogInBtn: UIButton!
    @IBOutlet weak var appleLogInBtnContainer: UIView!
    @IBOutlet weak var servicePolicyBtn: UIButton!
    @IBOutlet weak var privacyPolicyBtn: UIButton!
    
    weak var logInPageViewController : LogInPageViewController!
    
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //樣式設定
        CustomBGKit().CreatDarkStyleBG(view: view)
        
        
        titleImageView.image = UIImage(named: "FaceTrader")?.withRenderingMode(.alwaysTemplate)
         
        #if FACETRADER
            titleImageView.tintColor = UIColor.hexStringToUIColor(hex: "#00cac7")
        #elseif VERYINCORRECT
            titleImageView.tintColor = UIColor.hexStringToUIColor(hex: "#BBBBBB")
        #endif
        
        googleLogInBtn.layer.cornerRadius = 7
        fbLogInBtn.layer.cornerRadius = 7
        
        //for google
        CoordinatorAndControllerInstanceHelper.logInPageViewController = logInPageViewController
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        //for apple
        let appleSignInBtn = ASAuthorizationAppleIDButton(type: .default, style: .white)
        appleSignInBtn.frame = CGRect(x: 0, y: 0, width: view.frame.width - 80, height: appleLogInBtnContainer.frame.height)
        appleLogInBtnContainer.addSubview(appleSignInBtn)
        appleLogInBtnContainer.layer.cornerRadius = 7
        appleSignInBtn.addTarget(self, action: #selector(appleLogInBtnAct), for: .touchUpInside)
        appleSignInBtn.layer.cornerRadius = 7

        
    }
    
    
    
    
    
    
    @IBAction func fbLogInBtnAct(_ sender: Any) {
        
        let loginManager = LoginManager()
        
        //for FB
        loginManager.logIn(permissions: ["public_profile"], from: self){
            [weak self] (result ,error) in
            
            
            
            // Check for error
            guard error == nil else {
                // Error occurred
                print(error!.localizedDescription)
                return
            }
            // Check for cancel
            guard let result = result, !result.isCancelled else {
                print("User cancelled login")
                return
            }
            
            self!.addLoadingView()
            
            self!.GetFBUserInfo()
            
            //去下一頁
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error)
                    self!.showToast(message: "登入失敗", font: .systemFont(ofSize: 14.0))
                    self!.removeLoadingView()
                    return
                }
                UserSetting.UID = Auth.auth().currentUser!.uid
                
                //如果已經有地點權限了，就跳過直接去填個人資訊，不然就去要求權限頁面
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    self!.logInPageViewController.goCheckLocationAccessPage()
                case .restricted:
                    self!.logInPageViewController.goCheckLocationAccessPage()
                case .denied:
                    self!.logInPageViewController.goCheckLocationAccessPage()
                case .authorizedAlways:
                    self!.logInPageViewController.goFillBasicInfoPage()
                case .authorizedWhenInUse:
                    self!.logInPageViewController.goFillBasicInfoPage()
                }
                
            }
            
            
        }
        
    }
    
    
    @IBAction func googleLogInBtnAct(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    //gender,age_range 需要申請
    //in your https://developers.facebook.com/ account, under App Review section, click Start a Submission, select user_gender from LOGIN PERMISSIONS and go through submission steps.
    fileprivate func GetFBUserInfo(){
        let params = ["fields":"name, picture.width(20).height(20).as(picture_small),picture.width(300).height(300).as(picture_large)"]
        let request = GraphRequest(graphPath: "/me", parameters: params)
        let connection1 = GraphRequestConnection()
        connection1.add(request, batchParameters: params) { (conn, result, error) in
            guard let fbResult = result as? Dictionary<String, Any>,
                  let pictureSmall = fbResult["picture_small"] as? Dictionary<String, Any>,
                  let pictureSmallData = pictureSmall["data"] as? Dictionary<String, Any>,
                  let smallUrl = pictureSmallData["url"] as? String,
                  let pictureLarge = fbResult["picture_large"] as? Dictionary<String, Any>,
                  let pictureLargeData = pictureLarge["data"] as? Dictionary<String, Any>,
                  let largeUrl = pictureLargeData["url"] as? String
            else { return }
            let name = fbResult["name"] as! String
            UserSetting.userName = name
            
        }
        connection1.start()
    }
    
    
    @objc func appleLogInBtnAct() {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    let blackAlphaView = UIView()
    let loadingAnimationView = UIView()
    func addLoadingView() {
        
        blackAlphaView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        blackAlphaView.backgroundColor = .black
        blackAlphaView.alpha = 0.5
        
        loadingAnimationView.frame = CGRect(x: view.frame.width/2 - 60/2, y: view.frame.height/2 - 60/2, width: 60, height: 60)
        loadingAnimationView.setupToLoadingView()
        view.addSubview(blackAlphaView)
        view.addSubview(loadingAnimationView)
    }
    
    func removeLoadingView() {
        blackAlphaView.removeFromSuperview()
        loadingAnimationView.removeFromSuperview()
    }
    
    @IBAction func servicePolicyBtnAct(_ sender: Any) {
    }
    
    @IBAction func privacyPolicyBtnAct(_ sender: Any) {
        
        let privacyViewController = InfoPopOverController.initFromStoryboard()
        privacyViewController.modalPresentationStyle = .popover
        present(privacyViewController, animated: true, completion: nil)
        
    }
    
    //MARK:- for Apple Sign In
    
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest{
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        
        return request
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    //MARK:- ASAuthorizationControllerDelegate
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential{
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            self.addLoadingView()
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    print(error?.localizedDescription)
                    self.showToast(message: "登入失敗", font: .systemFont(ofSize: 14.0))
                    self.removeLoadingView()
                    return
                }
                UserSetting.UID = Auth.auth().currentUser!.uid
                //如果已經有地點權限了，就跳過直接去填個人資訊，不然就去要求權限頁面
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    CoordinatorAndControllerInstanceHelper.logInPageViewController.goCheckLocationAccessPage()
                case .restricted:
                    CoordinatorAndControllerInstanceHelper.logInPageViewController.goCheckLocationAccessPage()
                case .denied:
                    CoordinatorAndControllerInstanceHelper.logInPageViewController.goCheckLocationAccessPage()
                case .authorizedAlways:
                    CoordinatorAndControllerInstanceHelper.logInPageViewController.goFillBasicInfoPage()
                case .authorizedWhenInUse:
                    CoordinatorAndControllerInstanceHelper.logInPageViewController.goFillBasicInfoPage()
                }
            }
        }
        
        
    }
    //MARK:- ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
