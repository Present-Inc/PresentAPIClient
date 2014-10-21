//
//  Error.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 9/2/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Error: NSObject, Printable {
    public private(set) var code: Int?
    public private(set) var errorDescription: String?
    public private(set) var stack: String?
    public private(set) var message: String?
    public private(set) var result: String?
    public private(set) var data: [String: AnyObject]?

    public override var description: String {
        return " {\n\tcode: \(self.code)\n\tdescription: \(self.errorDescription)\n\tmessage: \(self.message)\n\tresult: \(self.result)\ndata: \(self.data)\n}"
    }
    
    init(json: JSON) {
        if let errorCode = json["errorCode"].int {
            code = errorCode
        }
        
        if let description = json["errorInfo"]["description"].string {
            errorDescription = description
        }
        
        if let stacktrace = json["errorInfo"]["stack"].string {
            stack = stacktrace
        }
        
        if let errorMessage = json["errorInfo"]["message"].string {
            message = errorMessage
        }
        
        if let errorResult = json["result"].string {
            result = errorResult
        }
        
        if let errorData = json["errorInfo"]["data"].dictionaryObject {
            data = errorData
        }
    }
}
