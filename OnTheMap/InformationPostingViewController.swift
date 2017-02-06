//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by pk on 1/27/17.
//  Copyright © 2017 TinyAppsDev. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class InformationPostingViewController : TextViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buttonFindOnMap: UIButton!
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var labelWhereAreYou: UILabel!
    @IBOutlet weak var textFieldLink: UITextField!
    @IBOutlet weak var textFieldLocation: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var mapItem: MKMapItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldLocation.delegate = self
        textFieldLink.delegate = self
        activityIndicator.isHidden = true
        
        gotoStepOne()
    }
    
    override func getScrollView() -> UIScrollView! {
        return scrollView
    }
    
    func gotoStepOne() {
        labelWhereAreYou.isHidden = false
        textFieldLocation.isHidden = false
        buttonFindOnMap.isHidden = false
        
        buttonSubmit.isHidden = true
        mapView.isHidden = true
        textFieldLink.isHidden = true
    }
    
    func gotoStepTwo() {
        labelWhereAreYou.isHidden = true
        textFieldLocation.isHidden = true
        buttonFindOnMap.isHidden = true
        
        buttonSubmit.isHidden = false
        mapView.isHidden = false
        textFieldLink.isHidden = false
    }
    
    @IBAction func onClickBarButtonCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onClickButtonFindOnMap(_ sender: Any) {
        if textFieldLocation.text!.isEmpty {
            Utils.showAlert(self, title: "Map Search", message: "Location Can't be Empty")
            return
        }
        
        startSearch(textFieldLocation.text!)
        buttonFindOnMap.isEnabled = false
    }
    
    func startSearch(_ toSearch: String) {
        let req = MKLocalSearchRequest()
        req.naturalLanguageQuery = toSearch
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        let search = MKLocalSearch(request: req)
        search.start { res, error in
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            self.buttonFindOnMap.isEnabled = true
            
            if error != nil {
                Utils.showAlert(self, title: "Map Search", message: "Error: \(error!.localizedDescription)")
                return
            }
            if res == nil || res!.mapItems.isEmpty {
                Utils.showAlert(self, title: "Map Search", message: "Location Not Found: \(toSearch)")
                return
            }
            
            self.gotoStepTwo()
            
            self.mapItem = res!.mapItems[0]
            self.mapView.addAnnotation(self.mapItem.placemark)
            //self.mapView.setCenter(self.mapItem.placemark.coordinate, animated: true)
            
            self.mapView.setRegion(
                MKCoordinateRegion(
                    center: self.mapItem.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                ),
                animated: true
            )
            
        }
    }
    
    @IBAction func onClickButtonSubmit(_ sender: Any) {
        if textFieldLink.text!.isEmpty {
            Utils.showAlert(self, title: "Website Info", message: "Website Can't be Empty")
            return
        }
        
        buttonSubmit.isEnabled = false
        
        let link = textFieldLink.text!
        let location = textFieldLocation.text!
        
        UdacityClient.getInstance().getMe { (error, js) in
            if let js = js, let user = js["user"] as? [String:Any], let key = user["key"] as? String {
                
                let firstName = (user["first_name"] as? String) ?? "NoBody"
                let lastName = (user["last_name"] as? String) ?? "NoBody"
                
                let rec = [
                    "uniqueKey" : key,
                    "firstName": firstName,
                    "lastName": lastName,
                    "mapString": location,
                    "mediaURL": link,
                    "latitude": self.mapItem.placemark.coordinate.latitude,
                    "longitude": self.mapItem.placemark.coordinate.longitude
                ] as [String : Any]
                
                UdacityClient.getInstance().setStudentLocation(studentLocation: StudentInformation(rec)) { error, js in
                    self.buttonSubmit.isEnabled = true
                    
                    if error != nil || js == nil {
                        Utils.showAlert(
                            self,
                            title: "Information Posting",
                            message: "Error: \(error)"
                        )
                        return
                    }
                    
                    if let _ = js!["objectId"] as? String {
                        self.dismiss(animated: true)
                    } else {
                        Utils.showAlert(self, title: "Information Posting", message: "Unable to Create A Location")
                    }
                }
                
            } else {
                self.buttonSubmit.isEnabled = true
                Utils.showAlert(self, title: "Information Posting", message: "Invalid User")
            }
        }
        
    }
    
    static func showView(_ callee: UIViewController, dismissCallee: Bool) {
        if dismissCallee {
            callee.dismiss(animated: false, completion: nil)
        }
        
        let controller = callee.storyboard!.instantiateViewController(withIdentifier: "InformationPostingViewController") as! InformationPostingViewController
        callee.present(controller, animated: true, completion: nil)
    }
    
}
