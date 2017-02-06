//
//  Utils.swift
//  OnTheMap
//
//  Created by pk on 2/4/17.
//  Copyright © 2017 TinyAppsDev. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    static func showAlert(_ callee: UIViewController, title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { uiAction in
            alertController.dismiss(animated: true, completion: nil)
        })
        callee.present(alertController, animated: true, completion: nil)
    }
    
    
    static func presentView(_ callee: UIViewController, dismissCallee: Bool, controllerId: String) {
        if dismissCallee {
            callee.dismiss(animated: false, completion: nil)
        }
        
        let controller = callee.storyboard!.instantiateViewController(withIdentifier: controllerId) 
        callee.present(controller, animated: true, completion: nil)
    }
    
}
