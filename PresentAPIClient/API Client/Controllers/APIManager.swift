//
//  APIManager.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit
import Alamofire

public typealias ResourceSuccessBlock = (JSONValue) -> ()
public typealias CollectionSuccessBlock = ([JSONValue], Int) -> ()
public typealias FailureBlock = (NSError?) -> ()

#if DEBUG
    let apiVersion = "v1"
    let subDomain = "api-staging"
#else
    let apiVersion = "v1"
    let subDomain = "api"
#endif

let Version = "2014-09-09"

// !!!: This will only post to the staging API!
let baseURL = "https://api-staging.present.tv/\(apiVersion)/"

let PresentVersionHeader = "Present-Version"
let SessionTokenHeader = "Present-User-Context-Session-Token"
let UserIdHeader = "Present-User-Context-User-Id"

public class APIManager {
    private let logger = Swell.getLogger("APILogger")
    
    private var _callbackQueue = dispatch_queue_create("tv.Present.Present.PresentAPIClient.serializationQueue", DISPATCH_QUEUE_CONCURRENT)
    var callbackQueue: dispatch_queue_t {
        return _callbackQueue
    }
    
    private var multipartManager: AFHTTPSessionManager
    
    class func sharedInstance() -> APIManager {
        struct Static {
            static let instance: APIManager = APIManager()
        }

        return Static.instance
    }
    
    init() {
        self.multipartManager = AFHTTPSessionManager(baseURL: NSURL(string: baseURL))
        self.multipartManager.securityPolicy.allowInvalidCertificates = true
        self.multipartManager.requestSerializer = AFHTTPRequestSerializer()
        self.multipartManager.responseSerializer = AFJSONResponseSerializer()
        
        self.setValue(Version, forHeaderKey: PresentVersionHeader)
    }
    
    func setValue(value: String?, forHeaderKey key: String!) {
        Alamofire.Manager.sharedInstance.defaultHeaders[key] = value
        multipartManager.requestSerializer.setValue(value, forHTTPHeaderField: key)
    }
    
    func setValues(values: [String], forHeaderKeys keys: [String]) {
        for i in 0..<keys.count {
            self.setValue(values[i], forHeaderKey: keys[i])
        }
    }
    
    func setUserContextHeaders(userContext: UserContext) {
        self.setValue(userContext.sessionToken, forHeaderKey: SessionTokenHeader)
        self.setValue(userContext.user.id, forHeaderKey: UserIdHeader)
    }
    
    func clearUserContextHeaders() {
        self.setValue(nil, forHeaderKey: SessionTokenHeader)
        self.setValue(nil, forHeaderKey: UserIdHeader)
    }
    
    // MARK: GET
    
    func getResource(resource: String, parameters: [String: AnyObject]?, success: ResourceSuccessBlock?, failure: FailureBlock?) {
        self.requestResource(.GET, resource: resource, parameters: parameters, success: success, failure: failure)
    }
    
    func getCollection(resource: String, parameters: [String: AnyObject]?, success: CollectionSuccessBlock?, failure: FailureBlock?) {
        self.requestCollection(.GET, resource: resource, parameters: parameters, success: success, failure: failure)
    }
    
    // MARK: POST
    
    func postResource(resource: String, parameters: [String: AnyObject]?, success: ResourceSuccessBlock?, failure: FailureBlock?) {
        self.requestResource(.POST, resource: resource, parameters: parameters, success: success, failure: failure)
    }
    
    func postCollection(resource: String, parameters: [String: AnyObject]?, success: CollectionSuccessBlock?, failure: FailureBlock?) {
        self.requestCollection(.POST, resource: resource, parameters: parameters, success: success, failure: failure)
    }
    
    // MARK: Multi-part POST
    
    func multipartPost(url: NSURL, resource: String, parameters: [String: AnyObject]?, success: ResourceSuccessBlock?, failure: FailureBlock?) {
        var requestURL = baseURL + resource
        
        var fileData = NSData(contentsOfURL: url)
        
        var constructingBlock: (AFMultipartFormData!) -> Void = { formData in
            formData.appendPartWithFileData(fileData, name: "media_segment", fileName: "index.ts", mimeType: "video/mp2t")
        }
        
        multipartManager.POST(
            resource,
            parameters: parameters,
            constructingBodyWithBlock: constructingBlock,
            success: { dataTask, response in
                self.logger.debug("Multi-part POST \(dataTask.response?.URL) succeeded.")
                success?(JSONValue("Something Else"))
            },
            failure: { dataTask, error in
                self.logger.error("Multi-part POST \(dataTask.response?.URL) failed with error: \(error)")
                failure?(error)
            })
        
        logger.info("Multi-part POST \(requestURL) with \(url)")
    }
}

private extension APIManager {
    // MARK: Request
    
    private func requestResource(httpMethod: Alamofire.Method, resource: String, parameters: [String: AnyObject]?, success: ResourceSuccessBlock?, failure: FailureBlock?) {
        let requestURL = requestURLWithResource(resource)
        
        logger.info("\(httpMethod.toRaw()) \(requestURL) with parameters \(parameters)")
        
        Alamofire
            .request(httpMethod, requestURL, parameters: parameters, encoding: .URL)
            .resourceResponseJSON(resourceCompletionHandler(success, failure: failure))
    }
    
    private func requestCollection(httpMethod: Alamofire.Method, resource: String, parameters: [String: AnyObject]?, success: CollectionSuccessBlock?, failure: FailureBlock?) {
        let requestURL = requestURLWithResource(resource)
        
        logger.info("\(httpMethod.toRaw()) \(requestURL) with parameters \(parameters)")
        
        Alamofire
            .request(httpMethod, requestURL, parameters: parameters, encoding: .URL)
            .collectionResponseJSON(collectionCompletionHandler(success, failure: failure))
    }
    
    private func requestURLWithResource(resource: String) -> String {
        return baseURL + resource
    }
    
    private func resourceCompletionHandler(success: ResourceSuccessBlock?, failure: FailureBlock?) -> APIResourceResponseCompletionBlock {
        return { request, response, object, error in
            if error != nil || response?.statusCode >= 300 {
                self.logger.error("\(request.HTTPMethod!) \(request.URL) (\(response?.statusCode)) failed with error:\n\t\(error)")
                failure?(error)
            } else {
                self.logger.debug("\(request.HTTPMethod!) \(request.URL) (\(response?.statusCode)) succeeded.")
                success?(object!)
            }
        }
    }
    
    private func collectionCompletionHandler(success: CollectionSuccessBlock?, failure: FailureBlock?) -> APICollectionResponseCompletionBlock {
        return { request, response, results, nextCursor, error in
            if error != nil || response?.statusCode >= 300 {
                self.logger.error("\(request.HTTPMethod!) \(request.URL) (\(response?.statusCode)) failed with error:\n\t\(error)")
                failure?(error)
            } else {
                self.logger.debug("\(request.HTTPMethod!) \(request.URL) (\(response?.statusCode)) succeeded.")
                success?(results!, nextCursor!)
            }
        }
    }
}
