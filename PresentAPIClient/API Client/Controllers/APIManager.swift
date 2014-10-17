//
//  APIManager.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Swell

public class APIManager {
    private let logger = Swell.getLogger("APILogger")
    
    private var _callbackQueue = dispatch_queue_create(CallbackQueueIdentifier, DISPATCH_QUEUE_CONCURRENT)
    var callbackQueue: dispatch_queue_t {
        return _callbackQueue
    }
    
    private var headers: [String: String] = [:]
    private var manager: Alamofire.Manager!
    private var multipartManager: AFHTTPRequestOperationManager
    
    class func sharedInstance() -> APIManager {
        struct Static {
            static let instance: APIManager = APIManager()
        }

        return Static.instance
    }
    
    init() {
        self.multipartManager = AFHTTPRequestOperationManager(baseURL: baseURL)
        //self.multipartManager.securityPolicy.allowInvalidCertificates = true
        self.multipartManager.requestSerializer = AFHTTPRequestSerializer()
        self.multipartManager.responseSerializer = AFJSONResponseSerializer()
        
        self.setValue(Version, forHeaderKey: PresentVersionHeader)
        self.configureManager()
    }
    
    func configureManager() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = headers
        
        self.manager = Alamofire.Manager(configuration: configuration)
    }
    
    func setValue(value: String?, forHeaderKey key: String!) {
        headers[key] = value
        //Alamofire.Manager.sharedInstance.defaultHeaders[key] = value
        multipartManager.requestSerializer.setValue(value, forHTTPHeaderField: key)
    }
    
    // Complexity: O(n) where n = values.count
    func setValues(values: [String], forHeaderKeys keys: [String]) {
        for i in 0..<keys.count {
            self.setValue(values[i], forHeaderKey: keys[i])
        }
    }
    
    // Complexity: O(n) where n = headers.count
    func setHeaders(headers: [String: String]) {
        for (key, value) in headers {
            self.setValue(value, forHeaderKey: key)
        }
    }
    
    func setUserContextHeaders(userContext: UserContext) {
        self.setValue(userContext.sessionToken, forHeaderKey: SessionTokenHeader)
        self.setValue(userContext.user.id, forHeaderKey: UserIdHeader)
        
        self.configureManager()
    }
    
    func clearUserContextHeaders() {
        self.setValue(nil, forHeaderKey: SessionTokenHeader)
        self.setValue(nil, forHeaderKey: UserIdHeader)

        self.configureManager()
    }
    
    // MARK: GET
    
    func requestResource(request: URLRequestConvertible, success: ResourceSuccess, failure: FailureBlock?) -> Alamofire.Request {
        var request = manager.request(request).validate(statusCode: 200...299)
        request.resourceResponseJSON(resourceCompletionHandler(success, failure: failure))
        
        debugPrintln(request)
        
        return request
    }
    
    func requestCollection(request: URLRequestConvertible, success: CollectionSuccess, failure: FailureBlock?) -> Alamofire.Request {
        var request = manager.request(request)
        request.collectionResponseJSON(collectionCompletionHandler(success, failure: failure))
        
        debugPrintln(request)
        
        return request
    }
    
    // MARK: Multi-part POST
    
    func multipartPost(url: NSURL, resource: String, parameters: [String: AnyObject]?, success: ResourceSuccess?, failure: FailureBlock?) {
        var requestURL = baseURL.absoluteString! + resource,
            fileData = NSData(contentsOfURL: url),
            constructingBlock: (AFMultipartFormData!) -> Void = { formData in
                formData.appendPartWithFileData(fileData, name: "media_segment", fileName: "index.ts", mimeType: "application/octet-stream")
            }
        
        multipartManager.POST(
            resource,
            parameters: parameters,
            constructingBodyWithBlock: constructingBlock,
            success: { dataTask, response in
                self.logger.debug("Multi-part POST \(dataTask.response?.URL!) succeeded.")
                success?(JSON("Something Else"))
            },
            failure: { dataTask, error in
                self.logger.error("Multi-part POST \(dataTask.response?.URL!) failed with error: \(error)")
                failure?(error)
            })
        
        logger.info("Multi-part POST \(requestURL) with \(url)")
    }
}

private extension APIManager {
    // MARK: Request
    
    private func requestResource(httpMethod: Alamofire.Method, resource: String, parameters: [String: AnyObject]?, success: ResourceSuccess?, failure: FailureBlock?) {
        let requestURL = requestURLWithResource(resource)
        
        logger.info("\(httpMethod.toRaw()) \(requestURL) with parameters \(parameters)")
        
        Alamofire
            .request(httpMethod, requestURL, parameters: parameters, encoding: .URL)
            .resourceResponseJSON(resourceCompletionHandler(success, failure: failure))
    }
    
    private func requestCollection(httpMethod: Alamofire.Method, resource: String, parameters: [String: AnyObject]?, success: CollectionSuccess?, failure: FailureBlock?) {
        let requestURL = requestURLWithResource(resource)
        
        logger.info("\(httpMethod.toRaw()) \(requestURL) with parameters \(parameters)")
        
        Alamofire
            .request(httpMethod, requestURL, parameters: parameters, encoding: .URL)
            .collectionResponseJSON(collectionCompletionHandler(success, failure: failure))
    }
    
    private func requestURLWithResource(resource: String) -> String {
        return baseURL.absoluteString! + resource
    }
    
    private func resourceCompletionHandler(success: ResourceSuccess?, failure: FailureBlock?) -> APIResourceResponseCompletionBlock {
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
    
    private func collectionCompletionHandler(success: CollectionSuccess?, failure: FailureBlock?) -> APICollectionResponseCompletionBlock {
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
