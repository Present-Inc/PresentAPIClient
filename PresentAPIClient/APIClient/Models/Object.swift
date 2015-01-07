//
//  Object.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Swell

public class Object: NSObject, ObjectSubclass, JSONSerializable {
    public var isNew: Bool {
        return id == nil
    }
    
    public private(set) var id: String?
    public private(set) var creationDate: NSDate = NSDate()
    public private(set) var lastUpdatedDate: NSDate?
    
    class func _logger(var name: String?) -> Logger {
        if name == nil {
            name = "Default"
        }
        
        return Swell.getLogger(name!)
    }
    
    public override init() {
        super.init()
    }
    
    public init(id: String) {
        self.id = id
        super.init()
    }
    
    public required init(json: ObjectJSON) {
        if let createdAt = json["_creationDate"].string {
            creationDate = NSDate.dateFromISOString(createdAt)
        }
        
        if let updatedAt = json["_lastUpdateDate"].string {
            lastUpdatedDate = NSDate.dateFromISOString(updatedAt)
        }
        
        if let objectId = json["_id"].string {
            id = objectId
        }
        
        super.init()
    }
    
    public init(coder aDecoder: NSCoder!) {
        id = aDecoder.decodeObjectForKey("id") as? String
        creationDate = aDecoder.decodeObjectForKey("creationDate") as NSDate
        lastUpdatedDate = aDecoder.decodeObjectForKey("lastUpdatedDate") as? NSDate
    }
    
    public func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(creationDate, forKey: "creationDate")
        
        if id != nil {
            aCoder.encodeObject(id!, forKey: "id")
        }
        
        if lastUpdatedDate != nil {
            aCoder.encodeObject(lastUpdatedDate!, forKey: "lastUpdatedDate")
        }
    }
    
    public override func isEqual(object: AnyObject!) -> Bool {
        if self === object {
            return true
        }
        
        if let objectInstance = object as? Object {
            if self == objectInstance {
                return true
            }
        }
        
        return false
    }
    
    /**
        If this method is overridden, subclasses must invoke super.mergeResultsFromObject
     */
    public func mergeResultsFromObject(object: Object) {
        id = object.id
        creationDate = object.creationDate
        lastUpdatedDate = object.lastUpdatedDate
    }
}

func ==(lhs: Object, rhs: Object) -> Bool {
    return lhs.id == rhs.id
}
