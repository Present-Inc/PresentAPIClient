//
//  Error.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 9/2/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Foundation

public class Error: NSObject, JSONSerializable, Printable {
    public private(set) var code: Int?
    public private(set) var message: String?
    public private(set) var errorDescription: String?
    public private(set) var stack: String?
    public private(set) var data: [String: AnyObject]?
    
    public override var description: String {
        return " {\n\tcode: \(self.code)\n\tdescription: \(self.errorDescription)\n\tmessage: \(self.message)\n\tdata: \(self.data)}"
    }
    
    public required init(json: ObjectJSON) {
        code = json["code"].int
        errorDescription = json["description"].string
        stack = json["stack"].string
        message = json["message"].string
        data = json["data"].dictionaryObject
    }
}
