//
//  Error.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 9/2/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Foundation

public class Error: NSObject, Printable {
    public var code: Int? {
        return _code
    }
    
    public var errorDescription: String? {
        return _description
    }
    
    public var stack: String? {
        return _stack
    }
    
    public var message: String? {
        return _message
    }
    
    public var result: String? {
        return _result
    }
    
    private var _code: Int!
    private var _description: String!
    private var _stack: String!
    private var _message: String!
    private var _result: String!
    
    public override var description: String {
        return " {\n\tcode: \(self.code)\n\tdescription: \(self.errorDescription)\n\tmessage: \(self.message)\n\tresult: \(self.result)}"
    }
    
    init(json: JSONValue) {
        if let errorCode = json["errorCode"].integer {
            _code = errorCode
        }
        
        if let errorDescription = json["errorInfo"]["description"].string {
            _description = errorDescription
        }
        
        if let stacktrace = json["errorInfo"]["stack"].string {
            _stack = stacktrace
        }
        
        if let errorMessage = json["errorInfo"]["message"].string {
            _message = errorMessage
        }
        
        if let result = json["result"].string {
            _result = result
        }
    }
}
