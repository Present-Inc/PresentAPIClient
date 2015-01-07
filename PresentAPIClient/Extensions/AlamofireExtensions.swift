//
//  AlamofireExtensions.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 9/4/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Alamofire
import SwiftyJSON

// MARK: Alamofire Extensions

typealias AlamofireResponseCompletionBlock = (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void

internal extension Alamofire.Request {
    var callbackQueue: dispatch_queue_t {
        return APIManager.sharedInstance().callbackQueue
    }
    
    func collectionResponseJSON<T: JSONSerializable>(completionHandler: ((NSURLRequest, NSHTTPURLResponse?, [T]?, Int?, NSError?) -> Void)) -> Self {
        return responseSwiftyJSON(queue: self.callbackQueue, options: .MutableContainers, completionHandler: { request, response, json, error in
            var collectionResponse: CollectionResponse<T>?
            var errorResponse: ErrorResponse
            var requestError: NSError?
            
            if error != nil {
                errorResponse = ErrorResponse(json: json)
                
                var userInfo = error!.userInfo ?? [String: AnyObject]()
                userInfo["APIError"] = errorResponse.error ?? NSNull()
                requestError = NSError(domain: error!.domain, code: error!.code, userInfo: userInfo)
            } else {
                collectionResponse = CollectionResponse<T>(json: json)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(request, response, collectionResponse?.results, collectionResponse?.nextCursor, requestError)
            })
        })
    }
    
    func resourceResponseJSON<T: JSONSerializable>(completionHandler: ((NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void)) -> Self {
        return responseSwiftyJSON(queue: self.callbackQueue, options: .MutableContainers, completionHandler: { request, response, json, error in
            var resourceResponse: ResourceResponse<T>?
            var errorResponse: ErrorResponse
            var requestError: NSError?
            
            if error != nil {
                errorResponse = ErrorResponse(json: json)

                var userInfo = error!.userInfo ?? [String: AnyObject]()
                userInfo["APIError"] = errorResponse.error ?? NSNull()
                requestError = NSError(domain: error!.domain, code: error!.code, userInfo: userInfo)
            } else {
                resourceResponse = ResourceResponse<T>(json: json)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(request, response, resourceResponse?.result, requestError)
            })
        })
    }
}

// MARK: - Request for Swift JSON

extension Request {
    
    /**
    Adds a handler to be called once the request has finished.
    
    :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the SwiftyJSON enum, if one could be created from the URL response and data, and any error produced while creating the SwiftyJSON enum.
    
    :returns: The request.
    */
    public func responseSwiftyJSON(completionHandler: (NSURLRequest, NSHTTPURLResponse?, SwiftyJSON.JSON, NSError?) -> Void) -> Self {
        return responseSwiftyJSON(queue: nil, options: NSJSONReadingOptions.AllowFragments, completionHandler: completionHandler)
    }
    
    /**
    Adds a handler to be called once the request has finished.
    
    :param: queue The queue on which the completion handler is dispatched.
    :param: options The JSON serialization reading options. `.AllowFragments` by default.
    :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the SwiftyJSON enum, if one could be created from the URL response and data, and any error produced while creating the SwiftyJSON enum.
    
    :returns: The request.
    */
    public func responseSwiftyJSON(queue: dispatch_queue_t? = nil, options: NSJSONReadingOptions = .AllowFragments, completionHandler: (NSURLRequest, NSHTTPURLResponse?, JSON, NSError?) -> Void) -> Self {
        
        return response(queue: queue, serializer: Request.JSONResponseSerializer(options: options), completionHandler: { (request, response, object, error) -> Void in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                var responseJSON: JSON
                if object == nil{
                    responseJSON = JSON.nullJSON
                } else {
                    responseJSON = SwiftyJSON.JSON(object!)
                }
                
                dispatch_async(queue ?? dispatch_get_main_queue(), {
                    completionHandler(self.request, self.response, responseJSON, error)
                })
            })
        })
    }
}

