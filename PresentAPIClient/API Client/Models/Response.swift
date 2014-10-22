//
//  Response.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 10/22/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Foundation

public enum ResponseStatus: String {
    case Ok = "OK"
    case Error = "ERROR"
    case Unknown = "UNKNOWN"
}

class Response: JSONSerializable {
    let status: ResponseStatus?
    
    required init(json: ObjectJSON) {
        self.status = ResponseStatus(rawValue: json["status"].stringValue)
    }
}

class ResourceResponse<T: JSONSerializable>: Response {
    let result: T?
    
    required init(json: ObjectJSON) {
        super.init(json: json)
        
        self.result = T(json: json["result"])
    }
}

class CollectionResponse<T: JSONSerializable>: Response {
    let results: [T]?
    let nextCursor: Int?
    
    required init(json: ObjectJSON) {
        super.init(json: json)
        
        self.results = json["results"].array?.map { T(json: $0) }
        self.nextCursor = json["nextCursor"].int
    }
}