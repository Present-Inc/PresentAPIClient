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

typealias APIResourceResponseCompletionBlock = (NSURLRequest, NSHTTPURLResponse?, JSON?, NSError?) -> Void
typealias APICollectionResponseCompletionBlock = (NSURLRequest, NSHTTPURLResponse?, [JSON]?, Int?, NSError?) -> Void

internal extension Alamofire.Request {
    func collectionResponseJSON(completionHandler: APICollectionResponseCompletionBlock) -> Self {
        let completion: AlamofireResponseCompletionBlock = { request, response, json, error in
            var jsonData: JSON!,
                results: [JSON]?,
                nextCursor: Int!,
                requestError: NSError?
            
            if let data: AnyObject = json {
                jsonData = JSON(data)
                
                if error != nil {
                    requestError = self.serializeRequestError(jsonData, error: error!)
                } else {
                    results = jsonData["results"].array
                    nextCursor = jsonData["nextCursor"].int
                }
            }
            
            completionHandler(request, response, results, nextCursor, requestError ?? error)
        }
        
        return response(
            queue: APIManager.sharedInstance().callbackQueue,
            serializer: Request.JSONResponseSerializer(),
            completionHandler: completion
        )
    }
    
    func resourceResponseJSON(completionHandler: APIResourceResponseCompletionBlock) -> Self {
        let completion: AlamofireResponseCompletionBlock = { request, response, json, error in
            var jsonData: JSON!,
                requestError: NSError?
            
            if let data: AnyObject = json {
                jsonData = JSON(data)
                
                if error != nil {
                    requestError = self.serializeRequestError(jsonData, error: error)
                }
            }
            
            completionHandler(request, response, jsonData, requestError ?? error)
        }
        
        return response(
            queue: APIManager.sharedInstance().callbackQueue,
            serializer: Request.JSONResponseSerializer(),
            completionHandler: completion
        )
    }
    
    /**
    *  Attempts to serialize error json into an NSError object.
    *  @discussion If `json` is nil, returns `error`
    *
    *  @param json JSONValue representing the error
    *  @param error NSError that came back from Alamofire
    *
    *  @return NSError with JSON error serialized in userInfo["APIError"]
    */
    private func serializeRequestError(json: JSON?, error: NSError?) -> NSError? {
        var apiError: Error?,
            requestError: NSError? = error
        
        if let jsonError: JSON = json {
            apiError = Error(json: jsonError)
        }
        
        if apiError != nil {
            requestError = NSError(domain: "APIManagerErrorDomain", code: apiError!.code ?? -1111, userInfo: [
                "APIError": apiError!
                ])
        }
        
        return requestError
    }
}

