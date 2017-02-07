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
        
        viewHelper.loadList()
    }
    
    func updateUI() {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformationModel.shared.recentStudentInformationList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OnMapListCell")!
        
        let locs = StudentInformationModel.shared.recentStudentInformationList
        if locs != nil && indexPath.row < locs!.count {
            let loc = locs![indexPath.row]
            cell.imageView?.image = UIImage(named: "pin")
            cell.textLabel?.text = "\(loc.firstName) \(loc.lastName)"
        } else {
            cell.imageView?.image = UIImage(named: "pin")
            cell.textLabel?.text = ""
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locs = StudentInformationModel.shared.recentStudentInformationList
        if locs != nil && indexPath.row < locs!.count {
            let loc = locs![indexPath.row]
            
            if let url = URL(string: loc.mediaURL) {
                UIApplication.shared.open(url, options: [String : Any](), completionHandler: nil)
            }
        }
    }
    
}
