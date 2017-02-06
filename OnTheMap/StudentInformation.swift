//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by pk on 1/29/17.
//  Copyright © 2017 TinyAppsDev. All rights reserved.
//

import Foundation


struct StudentInformation {
    var objectId: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    var createdAt: String
    var updatedAt: String
    
    init(_ dict: [String: Any]) {
        objectId = dict["objectId"] as? String ?? ""
        uniqueKey = dict["uniqueKey"] as? String ?? ""
        firstName = dict["firstName"] as? String ?? ""
        lastName = dict["lastName"] as? String ?? ""
        mapString = dict["mapString"] as? String ?? ""
        mediaURL = dict["mediaURL"] as? String ?? ""
        latitude = dict["latitude"] as? Double ?? 0.0
        longitude = dict["longitude"] as? Double ?? 0.0
        createdAt = dict["createdAt"] as? String ?? ""
        updatedAt = dict["updatedAt"] as? String ?? ""
    }
    
    func toDict() -> [String: Any] {
        return [
            "objectId": objectId,
            "uniqueKey": uniqueKey,
            "firstName": firstName,
            "lastName": lastName,
            "mapString": mapString,
            "mediaURL": mediaURL,
            "latitude": latitude,
            "longitude": longitude,
        ]
    }
    
}
