//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by pk on 1/26/17.
//  Copyright © 2017 TinyAppsDev. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: TextViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonSignin: UIButton!
    @IBOutlet weak var buttonSigninWithFB: UIButton!
    @IBOutlet weak var labelSignup: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    @IBOutlet weak var textFieldLoginName: UITextField!
    
    var loginInProgressing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldLoginPassword.delegate = self
        textFieldLoginName.delegate = self
        activityIndicator.isHidden = true
        
        labelSignup.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoSignup)))
    }
    
    func enableLoginButton(_ enable: Bool) {
        loginInProgressing = !enable
        
        buttonSignin.isEnabled = enable
        buttonSigninWithFB.isEnabled = enable
        
        if enable {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if loginInProgressing {
            return
        }
        enableLoginButton(false)
        UdacityClient.getInstance().getMe() { error, js in
            self.enableLoginButton(true)
            if let js = js, let user = js["user"] as? [String:Any], let _ = user["key"] as? String {
                LoginViewController.showHome(self, dismissCallee: true)
            }
        }
    }

    override func getScrollView() -> UIScrollView! {
        return scrollView
    }
    
    @IBAction func onClickButtonSignIn(_ sender: Any) {
        enableLoginButton(false)
        UdacityClient.getInstance().login(
            username: textFieldLoginName.text!,
            password: textFieldLoginPassword.text!,
            callback: onLoginResponse
        )
    }
    
    func onLoginResponse(_ error: String?, _ js: [String: Any]?) {
        enableLoginButton(true)
        
        if error != nil || js == nil {
            Utils.showAlert(self, title: "Login Error", message: "Network Error")
            return
        }
        
        if let js = js, let _ = js["account"] as? [String: Any] {
            LoginViewController.showHome(self, dismissCallee: true)
        } else {
            Utils.showAlert(self, title: "Login Error", message: "Invalid Username or Password")
        }
    }
    
    func loginWithFB(_ token: String) {
        UdacityClient.getInstance().loginWithFacebookToken(token: token, callback: onLoginResponse)
    }
    
    @IBAction func onClickButtonSignInWithFB(_ sender: Any) {
        enableLoginButton(false)
        
        if(FBSDKAccessToken.current() != nil) {
            loginWithFB(FBSDKAccessToken.current().tokenString)
            return
        }
        
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile"], from: self) { (result, error) in
            if error != nil || result!.isCancelled {
                if error != nil {
                    Utils.showAlert(self, title: "Login Error", message: "Error: \(error!.localizedDescription)")
                    print(error!)
                }
                
                self.enableLoginButton(true)
            } else {
                self.loginWithFB(FBSDKAccessToken.current().tokenString)
            }
        }
    }
    
    static func showHome(_ callee: UIViewController, dismissCallee: Bool) {
        if dismissCallee {
            callee.dismiss(animated: false, completion: nil)
        }
        
        let controller = callee.storyboard!.instantiateViewController(withIdentifier: "HomeTabBarController") as! UITabBarController
        callee.present(controller, animated: true, completion: nil)
    }
    
    static func showView(_ callee: UIViewController, dismissCallee: Bool) {
        if dismissCallee {
            callee.dismiss(animated: false, completion: nil)
        }
        
        let controller = callee.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        callee.present(controller, animated: true, completion: nil)
    }
    
    func gotoSignup(gestureRecognizer: UIGestureRecognizer) {
        UIApplication.shared.open(
            URL(string: "https://www.udacity.com/account/auth#!/signup")!,
            options: [String : Any](),
            completionHandler: nil
        )
    }
    
}

