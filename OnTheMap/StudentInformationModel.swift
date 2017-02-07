//
//  StudentInformationModel.swift
//  OnTheMap
//
//  Created by pk on 2/7/17.
//  Copyright © 2017 TinyAppsDev. All rights reserved.
//

import Foundation

class StudentInformationModel {
    static let shared: StudentInformationModel = StudentInformationModel()
    
    var recentStudentInformationList:[StudentInformation]! = nil
    
    func getRecentStudentInformationList(callback: @escaping (String?, [StudentInformation]?)->Void) {
        if recentStudentInformationList != nil {
            DispatchQueue.main.async {
                callback(nil, self.recentStudentInformationList)
            }
            return
        }
        
        print("->> getRecentStudentInformationList()")
        UdacityClient.getInstance().getRecentStudentLocations(cacheOk: false) { error, locs in
            if error != nil || locs == nil {
                self.recentStudentInformationList = nil
            } else {
                self.recentStudentInformationList = locs
            }
            callback(error, self.recentStudentInformationList)
        }
    }
    
    func refresh() {
        recentStudentInformationList = nil
    }
}
