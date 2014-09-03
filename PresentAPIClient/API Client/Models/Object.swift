//
//  Object.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit

public class Object: NSObject, ObjectSubclass {
    internal class var apiResourcePath: String { return "" }
    
    public var isNew: Bool {
        return _id.isEmpty
    }
    
    public var id: String {
        return _id
    }
    
    public var creationDate: NSDate? {
        return _creationDate
    }
    
    public var lastUpdated: NSDate? {
        return _lastUpdated
    }
    
    private var _id: String = ""
    private var _creationDate: NSDate? = nil
    private var _lastUpdated: NSDate? = nil
    
    // !!!: These need to remain here until variables can be overridden from extensions
    internal class func createResource() -> String {
        return self.pathForResource("create")
    }
    
    internal class func destroyResource() -> String {
        return self.pathForResource("destroy")
    }
    
    internal class func showResource() -> String {
        return self.pathForResource("show")
    }
    
    internal class func listResource() -> String {
        return self.pathForResource("list")
    }
    
    internal class func updateResource() -> String {
        return self.pathForResource("update")
    }
    
    internal class func searchResource() -> String {
        return self.pathForResource("search")
    }
    
    internal class func pathForResource(resource: String) -> String {
        return "\(self.apiResourcePath)/\(resource)"
    }
    
    public override init() {
        _creationDate = NSDate()
        super.init()
    }
    
    public init(id: String) {
        _id = id
        _creationDate = NSDate()
        super.init()
    }
    
    public init(json: JSONValue) {
        if let createdAt = json["_creationDate"].string {
            _creationDate = NSDate.dateFromISOString(createdAt)
        }
        
        if let updatedAt = json["_lastUpdateDate"].string {
            _lastUpdated = NSDate.dateFromISOString(updatedAt)
        }
        
        if let objectId = json["_id"].string {
            _id = objectId
        }
        
        super.init()
    }
    
    public init(coder aDecoder: NSCoder!) {
        _id = aDecoder.decodeObjectForKey("_id") as String
        _creationDate = aDecoder.decodeObjectForKey("creationDate") as? NSDate
        _lastUpdated = aDecoder.decodeObjectForKey("lastUpdated") as? NSDate
    }
    
    public func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(_id, forKey: "_id")
        
        if _creationDate != nil {
            aCoder.encodeObject(_creationDate!, forKey: "creationDate")
        }
        
        if _lastUpdated != nil {
            aCoder.encodeObject(_lastUpdated!, forKey: "lastUpdated")
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
    
    public func mergeResultsFromObject(object: Object) {
        if _id.isEmpty {
            _id = object._id
        }
        
        if _creationDate == nil {
            _creationDate = object._creationDate
        }
        
        _lastUpdated = object._lastUpdated
    }
}

func ==(lhs: Object, rhs: Object) -> Bool {
    return lhs._id == rhs._id
}
