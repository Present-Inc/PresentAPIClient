//
//  AlamofireExtensions.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 9/4/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Alamofire

// MARK: Alamofire Extensions

typealias AlamofireResponseCompletionBlock = (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void

typealias APIResourceResponseCompletionBlock = (NSURLRequest, NSHTTPURLResponse?, JSONValue?, NSError?) -> Void
typealias APICollectionResponseCompletionBlock = (NSURLRequest, NSHTTPURLResponse?, [JSONValue]?, Int?, NSError?) -> Void

internal extension Alamofire.Request {
    func collectionResponseJSON(completionHandler: APICollectionResponseCompletionBlock) -> Self {
        let completion: AlamofireResponseCompletionBlock = { request, response, JSON, error in
            var jsonData: JSONValue!,
                results: [JSONValue]?,
                nextCursor: Int!,
                requestError: NSError?
            
            if let data: AnyObject = JSON {
                jsonData = JSONValue(data)
                
                if error != nil {
                    requestError = self.serializeRequestError(jsonData, error: error!)
                } else {
                    results = jsonData["results"].array
                    nextCursor = jsonData["nextCursor"].integer
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(request, response, results, nextCursor, (requestError != nil) ? requestError! : error)
            })
        }
        
        return response(
            priority: 0,
            queue: APIManager.sharedInstance().callbackQueue,
            serializer: Request.JSONResponseSerializer(),
            completionHandler: completion
        )
    }
    
    func resourceResponseJSON(completionHandler: APIResourceResponseCompletionBlock) -> Self {
        let completion: AlamofireResponseCompletionBlock = { request, response, JSON, error in
            var jsonData: JSONValue!,
                requestError: NSError?
            
            if let data: AnyObject = JSON {
                jsonData = JSONValue(data)
                
                if error != nil || response?.statusCode >= 300 {
                    requestError = self.serializeRequestError(jsonData, error: error)
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(request, response, jsonData, (requestError != nil) ? requestError! : error)
            })
        }
        
        return response(
            priority: 0,
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
    private func serializeRequestError(json: JSONValue?, error: NSError?) -> NSError? {
        var apiError: Error?,
            requestError: NSError? = error
        
        if let jsonError: JSONValue = json {
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

