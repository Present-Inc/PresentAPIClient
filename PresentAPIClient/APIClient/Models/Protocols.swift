//
//  Protocols.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 1/7/15.
//  Copyright (c) 2015 present. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

// MARK: - JSON

public typealias ObjectJSON = JSON

// MARK: JSON Serialization

public protocol JSONSerializable {
    init(json: ObjectJSON)
    
    // TODO: Add a toJSON method or something
}

// MARK: - Object Subclass

protocol ObjectSubclass {
    /**
        Used to merge to Object's together.
    */
    func mergeResultsFromObject(object: Object)
}

// MARK: - Router

enum APIResource: String {
    case User = "users"
    case Video = "videos"
    case Comment = "comments"
    case Like = "likes"
    case Activity = "activities"
}

typealias RequestParameters = (path: String, parameters: [String: AnyObject]?)

protocol PresentRouter {
    var method: Alamofire.Method { get }
    var encoding: Alamofire.ParameterEncoding { get }
    var requestParameters: RequestParameters { get }
}