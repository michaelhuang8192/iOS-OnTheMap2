//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by pk on 1/29/17.
//  Copyright © 2017 TinyAppsDev. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class UdacityClient: NSObject {
    static var sInstance: UdacityClient? = nil
    
    let appId: String
    let restId: String
    //var cache: [StudentInformation]! = nil
    var me: [String: Any]? = nil
    
    init(appId: String, restId: String) { 
        self.appId = appId
        self.restId = restId
        
        super.init()
    }
    
    static func getInstance() -> UdacityClient {
        if let inst = UdacityClient.sInstance {
            return inst
        } else {
            UdacityClient.sInstance = UdacityClient(
                appId: "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
                restId: "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
            )
            return UdacityClient.sInstance!
        }
    }
    
    
    static func filter(_ data: Data) -> Data {
        let range = Range(uncheckedBounds: (5, data.count))
        return data.subdata(in: range)
    }
    
    func login(username: String, password: String, callback: @escaping (String?, [String: Any]?)->Void) {
        me = nil
        
        let auth = ["udacity" : ["username": username, "password": password]]
        let authJs = try! JSONSerialization.data(withJSONObject: auth)
        
        let request = newUdacityRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = authJs
        
        executeRequest(request: request, filterRawData: UdacityClient.filter, callback: callback)
    }
    
    func loginWithFacebookToken(token: String, callback: @escaping (String?, [String: Any]?)->Void) {
        me = nil
        
        let auth = ["facebook_mobile" : ["access_token": token]]
        let authJs = try! JSONSerialization.data(withJSONObject: auth)
        
        let request = newUdacityRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = authJs
        
        executeRequest(request: request, filterRawData: UdacityClient.filter, callback: callback)
    }
    
    func loginFacebook(callback: @escaping (String?, String?)->Void) {
        if(FBSDKAccessToken.current() != nil) {
            DispatchQueue.main.async {
                callback(nil, FBSDKAccessToken.current().tokenString)
            }
            return
        }
        
        let loginMgr = FBSDKLoginManager()
        loginMgr.loginBehavior = FBSDKLoginBehavior.browser
        loginMgr.logIn(withReadPermissions: ["public_profile"], from: nil) { (result, error) in
            if error != nil || result == nil {
                callback(error?.localizedDescription, nil)
                print("FB Login Error \(error) \(result)")
            } else if result!.isCancelled {
                callback(nil, nil)
            } else {
                callback(nil, result!.token.tokenString)
            }
        }
        
    }
    
    func newUdacityRequest(url: URL) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: url)
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
                break
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        return request
    }
    
    func getMe(callback: @escaping (String?, [String: Any]?)->Void) {
        if let me = self.me {
            DispatchQueue.main.async {
                callback(nil, me)
            }
            return
        }
        
        let request = newUdacityRequest(url: URL(string: "https://www.udacity.com/api/users/me")!)
        executeRequest(request: request, filterRawData: UdacityClient.filter) {
            error, js in
            if error == nil && js != nil {
                self.me = js
                //print(js)
            }
            callback(error, js)
        }
    }
    
    func logout(callback: @escaping (String?, [String: Any]?)->Void) {
        me = nil
        
        FBSDKLoginManager().logOut()
        
        let request = newUdacityRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        
        executeRequest(request: request, filterRawData: UdacityClient.filter, callback: callback)
    }
    
    func newParseRequest(url: URL) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: url)
        request.addValue(appId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restId, forHTTPHeaderField: "X-Parse-REST-API-Key")
        return request
    }
    
    func executeRequest(request: NSMutableURLRequest, filterRawData: @escaping ((Data)-> Data), callback: @escaping (String?, [String: Any]?)->Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                print(">>>Request Error - \(error)")
                DispatchQueue.main.async {
                    callback(error!.localizedDescription, nil)
                }
                return
            }
            
            var retJs : [String: Any]? = nil
            var retError : String? = nil
            do {
                if let data = data, let js = try JSONSerialization.jsonObject(with: filterRawData(data)) as? [String: Any] {
                    retJs = js
                } else {
                    retError = "Invalid Response"
                    print(">>>Invalid Response \(data)")
                }
            } catch {
                retError = "Parse Response Error - \(error.localizedDescription)"
                print(">>>Parse Response Error - \(error)")
            }
            
            DispatchQueue.main.async {
                callback(retError, retJs)
            }
        }
        task.resume()
    }
    
    func executeRequest(request: NSMutableURLRequest, callback: @escaping (String?, [String: Any]?)->Void) {
        executeRequest(request: request, filterRawData: {$0}, callback: callback)
    }
    
    func findStudentLocations(filter: [String: Any]?, pageNo: Int, numberPerPage: Int, orderBy: String, callback: @escaping (String?, [StudentInformation]?)->Void) {
        let urlComponents = NSURLComponents(string: "https://parse.udacity.com/parse/classes/StudentLocation")!
        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: String(numberPerPage)),
            URLQueryItem(name: "skip", value: String((pageNo - 1) * numberPerPage)),
            URLQueryItem(name: "order", value: orderBy),
        ]
        if let filter = filter {
            let whereS = try! JSONSerialization.data(withJSONObject: filter)
            urlComponents.queryItems?.append(
                URLQueryItem(
                    name: "where",
                    value: String(data: whereS, encoding: String.Encoding.utf8)
                )
            )
        }
        
        let request = newParseRequest(url: urlComponents.url!)
        executeRequest(request: request) { error, js in
            if error != nil {
                callback(error, nil)
                return
            }
            
            if let js = js, let results = js["results"] as? [[String: Any]] {
                var locs = [StudentInformation]()
                for loc in results {
                    locs.append(StudentInformation(loc))
                }
                callback(nil, locs)
            } else {
                callback("Invalid Data", nil)
                print("Invalid Data \(js)")
            }
        }
    }
    
    func getStudentLocation(studentId: String, callback: @escaping (String?, [StudentInformation]?)->Void) {
        return findStudentLocations(filter: ["uniqueKey": studentId], pageNo: 1, numberPerPage: 100, orderBy: "", callback: callback)
    }
    
    func setStudentLocation(studentLocation: StudentInformation, callback: @escaping (String?, [String: Any]?)->Void) {
        let request = newParseRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let studentLocationS = try! JSONSerialization.data(withJSONObject: studentLocation.toDict())
        request.httpBody = studentLocationS
        
        executeRequest(request: request, callback: callback)
    }
    
    func getRecentStudentLocations(callback: @escaping (String?, [StudentInformation]?)->Void) {
        findStudentLocations(filter: nil, pageNo: 1, numberPerPage: 100, orderBy: "-updatedAt", callback: callback)
    }
    
}

