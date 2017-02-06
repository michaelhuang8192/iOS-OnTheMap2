//
//  ListViewController.swift
//  OnTheMap
//
//  Created by pk on 1/27/17.
//  Copyright © 2017 TinyAppsDev. All rights reserved.
//

import Foundation
import UIKit

class ListViewController : UITableViewController, SharedViewHelperProtocol {
    
    var viewHelper: SharedViewHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewHelper = SharedViewHelper(self)
        viewHelper.initView(navigationItem: self.navigationItem)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewHelper.loadRecentStudentLocations(reloaded: false)
    }
    
    func updateUI() {
        self.tableView.reloadData()
        
        //print(viewHelper.mLocations)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewHelper.mLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OnMapListCell")!
        
        let loc = viewHelper.mLocations[indexPath.row]
        cell.imageView?.image = UIImage(named: "pin")
        cell.textLabel?.text = "\(loc.firstName) \(loc.lastName)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let loc = viewHelper.mLocations[indexPath.row]
        if let url = URL(string: loc.mediaURL) {
            UIApplication.shared.open(url, options: [String : Any](), completionHandler: nil)
        }
    }
    
}
