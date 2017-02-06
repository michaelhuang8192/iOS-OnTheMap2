//
//  SharedViewHelper.swift
//  OnTheMap
//
//  Created by pk on 1/27/17.
//  Copyright © 2017 TinyAppsDev. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

protocol SharedViewHelperProtocol {
    func updateUI()
}

class SharedViewHelper : NSObject {
    
    var mController: SharedViewHelperProtocol!
    var mLocations = [StudentInformation]()
    
    init(_ controller: SharedViewHelperProtocol) {
        mController = controller
    }
    
    func initView(navigationItem: UINavigationItem) {

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logout)
        )
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: .refresh,
                target: self,
                action: #selector(refresh)
            ),
            UIBarButtonItem(
                image: UIImage(named: "pin"),
                style: .plain,
                target: self,
                action: #selector(dropPin)
            )
        ]
        
    }
    
    func logout() {
        FBSDKLoginManager().logOut()
        UdacityClient.getInstance().logout() {
            error, js in
            LoginViewController.showView(self.mController as! UIViewController, dismissCallee: true)
        }
    }
    
    func refresh() {
        loadRecentStudentLocations(reloaded: true)
    }
    
    func dropPin() {
        InformationPostingViewController.showView(self.mController as! UIViewController, dismissCallee: false)
    }
    
    func loadRecentStudentLocations(reloaded: Bool) {
        UdacityClient.getInstance().getRecentStudentLocations(cacheOk: !reloaded) { error, locs in
            if let locs = locs {
                self.mLocations = locs
            } else {
                self.mLocations = [StudentInformation]()
                Utils.showAlert(
                    self.mController as! UIViewController,
                    title: "Loading Data",
                    message: "Error Occurred: \(error ?? "unexpected error")"
                )
            }
            
            self.mController.updateUI()
        }
    }
}

