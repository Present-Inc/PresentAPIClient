//
//  APIRequest.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 10/20/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Alamofire

public class APIRequest {
    let request: Alamofire.Request
    
    init(request: Alamofire.Request) {
        self.request = request
    }
    
    public func resume() {
        self.request.resume()
    }
    
    public func suspend() {
        self.request.suspend()
    }
    
    public func cancel() {
        self.request.cancel()
    }
}