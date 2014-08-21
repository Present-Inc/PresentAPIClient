//
//  APIManager.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit

public typealias ResourceSuccessBlock = (JSONValue) -> ()
public typealias CollectionSuccessBlock = (Array<JSONValue>, Int) -> ()
public typealias FailureBlock = (NSError?) -> ()
public typealias RequestSuccessBlock = (NSHTTPURLResponse!, AnyObject!) -> ()
public typealias RequestFailureBlock = (NSHTTPURLResponse!, AnyObject!, NSError?) -> ()

#if DEBUG
    let apiVersion = "v1"
    let subDomain = "api-staging"
#else
    let apiVersion = "v1"
    let subDomain = "api"
#endif

// !!!: This will only post to the staging API!
let baseURL = "https://api-staging.present.tv/\(apiVersion)/"

let SessionTokenHeader = "Present-User-Context-Session-Token"
let UserIdHeader = "Present-User-Context-User-Id"

public class APIManager {
    private let logger = Swell.getLogger("APILogger")
    
    init() {
        Alamofire.Manager.sharedInstance.operationQueue.maxConcurrentOperationCount = 5
    }
    
    class func sharedInstance() -> APIManager {
        struct Static {
            static let instance: APIManager = APIManager()
        }

        return Static.instance
    }
    
    func setValue(value: String?, forHeaderKey key: String!) {
        Alamofire.Manager.sharedInstance.defaultHeaders[key] = value
    }
    
    func setValues(values: [String], forHeaderKeys keys: [String]) {
        for i in 0..<keys.count {
            self.setValue(values[i], forHeaderKey: keys[i])
        }
    }
    
    func setUserContextHeaders(userContext: UserContext) {
        self.setValue(userContext.sessionToken, forHeaderKey: SessionTokenHeader)
        self.setValue(userContext.user.id, forHeaderKey: UserIdHeader)
        
        logger.info("Default headers for all requests set to \(Alamofire.Manager.sharedInstance.defaultHeaders)")
    }
    
    func clearUserContextHeaders() {
        self.setValue(nil, forHeaderKey: SessionTokenHeader)
        self.setValue(nil, forHeaderKey: UserIdHeader)
        
        logger.info("Reset default headers to \(Alamofire.Manager.sharedInstance.defaultHeaders)")
    }
    
    // MARK: GET
    
    func getResource(resource: String, parameters: [String: AnyObject]?, success: ResourceSuccessBlock?, failure: FailureBlock?) {
        self.get(resource, parameters: parameters, success: self.resourceSuccessClosure(success), failure: self.failureClosure(failure))
    }
    
    func getCollection(resource: String, parameters: [String: AnyObject]?, success: CollectionSuccessBlock?, failure: FailureBlock?) {
        self.get(resource, parameters: parameters, success: self.collectionSuccessClosure(success), failure: self.failureClosure(failure))
    }
    
    // MARK: POST
    
    func postResource(resource: String, parameters: [String: AnyObject]?, success: ResourceSuccessBlock?, failure: FailureBlock?) {
        self.post(resource, parameters: parameters, success: self.resourceSuccessClosure(success), failure: self.failureClosure(failure))
    }
    
    func postCollection(resource: String, parameters: [String: AnyObject]?, success: CollectionSuccessBlock?, failure: FailureBlock?) {
        self.post(resource, parameters: parameters, success: self.collectionSuccessClosure(success), failure: self.failureClosure(failure))
    }
    
    func multipartPost(data: NSData, resource: String, parameters: [String: AnyObject]?, success: ResourceSuccessBlock?, failure: FailureBlock?) {
        // TODO: This is not implemented
    }
}

private extension APIManager {
    
    // MARK: Private POST Methods
    
    private func post(resource: String, parameters: [String: AnyObject]?, success: RequestSuccessBlock?, failure: RequestFailureBlock?) {
        let requestURL = baseURL + resource
        
        logger.info("POST \(requestURL) with parameters \(parameters)")
        
        Alamofire
            .request(.POST, requestURL, parameters: parameters, encoding: .URL)
            .responseJSON { request, response, JSON, error in
                if error != nil || response?.statusCode >= 300 {
                    self.logger.error("POST \(request.URL) (\(response?.statusCode)) failed with error:\n\t\(error)")
                    failure?(response, JSON, error)
                } else {
                    self.logger.info("POST \(request.URL) succeeded.")
                    success?(response, JSON)
                }
        }
    }
    
    // MARK: Private GET Methods
    
    private func get(resource: String, parameters: [String: AnyObject]?, success: RequestSuccessBlock?, failure: RequestFailureBlock?) {
        let requestURL = baseURL + resource
        
        logger.info("GET \(requestURL) with parameters \(parameters)")
        
        Alamofire
            .request(.GET, requestURL, parameters: parameters, encoding: .URL)
            .responseJSON { request, response, JSON, error in
                if error != nil || response?.statusCode >= 300 {
                    self.logger.error("GET \(request.URL) (\(response?.statusCode)) failed with error:\n\t\(error)")
                    failure?(response, JSON, error)
                } else {
                    self.logger.info("GET \(request.URL) succeeded.")
                    success?(response, JSON)
                }
        }
    }
    
    // MARK: Response Closures
    
    func resourceSuccessClosure(success: ResourceSuccessBlock?) -> RequestSuccessBlock? {
        var successBlock: RequestSuccessBlock? = { httpResponse, data in
            self.logger.info("Response status code: \(httpResponse.statusCode)")
            
            let jsonData = JSONValue(data)
            success?(jsonData)
        }
        
        return successBlock
    }
    
    func collectionSuccessClosure(success: CollectionSuccessBlock?) -> RequestSuccessBlock? {
        var requestSuccess: RequestSuccessBlock? = { httpResponse, data in
            self.logger.info("Response status code: \(httpResponse.statusCode)")
            
            let jsonData = JSONValue(data)
            
            var results = jsonData["results"].array,
                nextCursor = jsonData["nextCursor"].integer
            
            success?(results!, nextCursor!)
        }
        
        return requestSuccess
    }
    
    func failureClosure(failure: FailureBlock?) -> RequestFailureBlock? {
        var requestFailure: RequestFailureBlock? = { httpResponse, data, error in
            self.logger.error("Response Error:\n\t\(data)")
            
            failure?(error)
        }
        
        return requestFailure
    }
}
