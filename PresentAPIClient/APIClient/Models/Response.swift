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

class Response: JSONSerializable, Printable {
    let status: ResponseStatus?
    
    var description: String {
        return "{\n\tstatus: \(status?.rawValue)\n}"
    }
    
    required init(json: ObjectJSON) {
        self.status = ResponseStatus(rawValue: json["status"].stringValue)
    }
}

class ResourceResponse<T: JSONSerializable>: Response, Printable {
    let result: T?
    
    override var description: String {
        return "{\n\tstatus: \(status?.rawValue)\n\tresult: \(result)\n}"
    }
    
    required init(json: ObjectJSON) {
        super.init(json: json)
        
        self.result = T(json: json["result"])
    }
}

class CollectionResponse<T: JSONSerializable>: Response, Printable {
    let results: [T]?
    let nextCursor: Int?
    
    override var description: String {
        return "{\n\tstatus: \(status?.rawValue)\n\tresults: \(results)\n\tnextCursor: \(nextCursor)\n}"
    }
    
    required init(json: ObjectJSON) {
        super.init(json: json)
        
        self.results = json["results"].array?.map { T(json: $0) }
        self.nextCursor = json["nextCursor"].int
    }
}

class ErrorResponse: Response, Printable {
    let error: Error?
    
    override var description: String {
        return "{\n\tstatus: \(status?.rawValue)\n\terror: \(error)\n}"
    }
    
    required init(json: ObjectJSON) {
        super.init(json: json)
        
        self.error = Error(json: json["result"])
    }
}