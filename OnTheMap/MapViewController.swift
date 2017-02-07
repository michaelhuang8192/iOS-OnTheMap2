//
//  MapViewController.swift
//  OnTheMap
//
//  Created by pk on 1/27/17.
//  Copyright © 2017 TinyAppsDev. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController : UIViewController, SharedViewHelperProtocol, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var viewHelper: SharedViewHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewHelper = SharedViewHelper(self)
        viewHelper.initView(navigationItem: self.navigationItem)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewHelper.loadList()
    }
    
    func updateUI() {
        mapView.removeAnnotations(mapView.annotations)

        var annotations = [MKPointAnnotation]()
        if let locs = StudentInformationModel.shared.recentStudentInformationList {
            for loc in locs {
                let coordinate = CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(loc.latitude),
                    longitude: CLLocationDegrees(loc.longitude)
                )
            
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(loc.firstName) \(loc.lastName)"
                annotation.subtitle = loc.mediaURL
            
                annotations.append(annotation)
            }
        }
        mapView.addAnnotations(annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle, let url = URL(string: toOpen!) {
                UIApplication.shared.open(url, options: [String : Any](), completionHandler: nil)
            }
        }
    }
    
}
