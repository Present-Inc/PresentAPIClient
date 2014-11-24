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

let CallbackQueueIdentifier = "tv.Present.Present.PresentAPIClient.serializationQueue"
public let InvalidUserContextNotification = "InvalidUserContextNotification"

public class APIManager {
    private let logger = Swell.getLogger("APILogger")
    
    public let callbackQueue = dispatch_queue_create(CallbackQueueIdentifier, DISPATCH_QUEUE_CONCURRENT)
    
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
        multipartManager = AFHTTPRequestOperationManager(baseURL: APIEnvironment.baseUrl)
        //self.multipartManager.securityPolicy.allowInvalidCertificates = true
        multipartManager.requestSerializer = AFHTTPRequestSerializer()
        multipartManager.responseSerializer = AFJSONResponseSerializer(readingOptions: NSJSONReadingOptions.MutableContainers)
        
        setValue(APIEnvironment.Version, forHeaderKey: APIEnvironment.PresentVersionHeader)
        configureManager()
    }
    
    func configureManager() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = headers
        
        manager = Alamofire.Manager(configuration: configuration)
    }
    
    func setValue(value: String?, forHeaderKey key: String!) {
        headers[key] = value
        multipartManager.requestSerializer.setValue(value, forHTTPHeaderField: key)
    }
    
    // Complexity: O(n) where n = values.count
    func setValues(values: [String], forHeaderKeys keys: [String]) {
        for i in 0..<keys.count {
            setValue(values[i], forHeaderKey: keys[i])
        }
    }
    
    // Complexity: O(n) where n = headers.count
    func setHeaders(headers: [String: String]) {
        for (key, value) in headers {
            setValue(value, forHeaderKey: key)
        }
    }
    
    func setUserContextHeaders(userContext: UserContext) {
        setValue(userContext.sessionToken, forHeaderKey: APIEnvironment.SessionTokenHeader)
        setValue(userContext.user.id, forHeaderKey: APIEnvironment.UserIdHeader)
        
        configureManager()
    }
    
    func clearUserContextHeaders() {
        setValue(nil, forHeaderKey: APIEnvironment.SessionTokenHeader)
        setValue(nil, forHeaderKey: APIEnvironment.UserIdHeader)

        configureManager()
    }
    
    // MARK: GET
    
    class func requestResource<T: JSONSerializable>(request: URLRequestConvertible, success: ((T) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return sharedInstance().requestResource(request, success: success, failure: failure)
    }
    
    class func requestCollection<T: JSONSerializable>(request: URLRequestConvertible, success: (([T], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return sharedInstance().requestCollection(request, success: success, failure: failure)
    }
    
    func requestResource<T: JSONSerializable>(request: URLRequestConvertible, success: ((T) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let networkRequest = self.request(request).resourceResponseJSON(resourceCompletionHandler(success, failure: failure))
        
        return APIRequest(request: networkRequest)
    }
    
    func requestCollection<T: JSONSerializable>(request: URLRequestConvertible, success: (([T], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let networkRequest = self.request(request).collectionResponseJSON(collectionCompletionHandler(success, failure: failure))
        
        return APIRequest(request: networkRequest)
    }
    
    private func request(request: URLRequestConvertible) -> Request {
        return manager.request(request).validate(statusCode: 200..<400)
    }
    
    // MARK: Multi-part POST
    
    func multipartPost(fileUrl: NSURL, name: String, fileName: String, mimeType: String, resource: String, parameters: [String: AnyObject]?, success: ((AnyObject?) -> ())?, failure: ((NSError?) -> ())?) {
        if let data = NSData(contentsOfURL: fileUrl) {
            multipartPost(
                resource,
                parameters: parameters,
                data: data,
                name: name,
                fileName: fileName,
                mimeType: mimeType,
                success: success,
                failure: failure
            )
        } else {
            let error = NSError(domain: "APIManagerErrorDomain", code: 1000, userInfo: [
                NSLocalizedDescriptionKey: "Failed to retrieve data from \(fileUrl)"
            ])
            
            failure?(error)
        }
    }
    
    func multipartPost(resource: String, parameters: [String: AnyObject]?, data: NSData, name: String, fileName: String, mimeType: String, success: ((AnyObject?) -> ())?, failure: ((NSError?) -> ())?) {
        let constructingBlock: (AFMultipartFormData!) -> Void = { formData in
            formData.appendPartWithFileData(data, name: name, fileName: fileName, mimeType: mimeType)
        }
        
        multipartManager.POST(
            resource,
            parameters: parameters,
            constructingBodyWithBlock: constructingBlock,
            success: { dataTask, response in
                self.logger.debug("Multi-part POST \(dataTask.response?.URL!) succeeded.")
                success?(response)
            },
            failure: { dataTask, error in
                self.logger.error("Multi-part POST \(dataTask.response?.URL!) failed with error: \(error)")
                self.checkForUserContextError(error)
                failure?(error)
            }
        )
    }
    
    func multipartPost(resource: String, parameters: [String: AnyObject]?, data: NSData, name: String, fileName: String, mimeType: String, progress: ((Double) -> ())?, success: ((AnyObject?) -> ())?, failure: ((NSError?) -> ())?) {
        let serializer = multipartManager.requestSerializer
        let constructingBlock: (AFMultipartFormData!) -> Void = { formData in
            formData.appendPartWithFileData(data, name: name, fileName: fileName, mimeType: mimeType)
        }
        
        var urlString = APIEnvironment.baseUrl.absoluteString!.stringByAppendingPathComponent(resource)
        
        var requestError: NSError?
        let request = serializer.multipartFormRequestWithMethod(
            Alamofire.Method.POST.rawValue,
            URLString: urlString,
            parameters: parameters,
            constructingBodyWithBlock: constructingBlock,
            error: &requestError
        )
        
        let manager = AFHTTPRequestOperationManager()
        let operation = manager.HTTPRequestOperationWithRequest(request, success: { dataTask, response in
            self.logger.debug("Multi-part POST \(dataTask.response?.URL!) succeeded.")
            success?(response)
            return
        }, failure: { dataTask, error in
            let requestError = self.serializeErrorResponse(dataTask.responseObject, error: error)
            
            self.logger.error("Multi-part POST \(dataTask.response?.URL!) failed with error: \(requestError)")
            self.checkForUserContextError(requestError)
            failure?(requestError)
        })
        
        operation.setUploadProgressBlock { _, totalBytesWritten, totalBytesExpectedToWrite in
            let percentComplete = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            progress?(percentComplete)
        }
        
        operation.start()
    }
}

// MARK: - Completion Handlers
private extension APIManager {
    func resourceCompletionHandler<T: JSONSerializable>(success: ((T) -> ())?, failure: ((NSError?) -> ())?) -> ((NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) {
        return { request, response, object, error in
            if error != nil {
                self.logger.error("\(request.HTTPMethod!) \(request.URL) (\(response?.statusCode)) failed with error:\n\(error)")
                self.checkForUserContextError(error)
                failure?(error)
            } else {
                self.logger.debug("\(request.HTTPMethod!) \(request.URL) (\(response?.statusCode)) succeeded.")
                success?(object!)
            }
        }
    }
    
    func collectionCompletionHandler<T: JSONSerializable>(success: (([T], Int) -> ())?, failure: ((NSError?) -> ())?) -> ((NSURLRequest, NSHTTPURLResponse?, [T]?, Int?, NSError?) -> Void) {
        return { request, response, results, nextCursor, error in
            if error != nil {
                self.logger.error("\(request.HTTPMethod!) \(request.URL) (\(response?.statusCode)) failed with error:\n\(error)")
                self.checkForUserContextError(error)
                failure?(error)
            } else {
                self.logger.debug("\(request.HTTPMethod!) \(request.URL) (\(response?.statusCode)) succeeded.")
                success?(results!, nextCursor!)
            }
        }
    }
}

// MARK: - Error Utilities
private extension APIManager {
    func serializeErrorResponse(responseObject: AnyObject?, error: NSError?) -> NSError? {
        if let responseObject: AnyObject = responseObject {
            let jsonResponse = JSON(responseObject)
            
            // Create an ErrorResponse object
            let errorResponse = ErrorResponse(json: jsonResponse)
            
            // Add the error to the userInfo dictionary
            var userInfo = error!.userInfo ?? [String: AnyObject]()
            userInfo["APIError"] = errorResponse.error ?? NSNull()
            
            // Create a new NSError to be returned with the new user info
            return NSError(domain: error!.domain, code: error!.code, userInfo: userInfo)
        } else {
            return error
        }
    }
    
    func checkForUserContextError(error: NSError?) {
        if let userInfo = error?.userInfo {
            if let error = userInfo["APIError"] as? Error {
                if error.code == 10002 {
                    NSNotificationCenter.defaultCenter().postNotificationName(InvalidUserContextNotification, object: error)
                }
            }
        }
    }
}
