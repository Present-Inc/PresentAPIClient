//
//  SubjectiveObjectMeta.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Foundation

public class SubjectiveObjectMeta: NSObject {
    public var like: Relation? {
        return _like
    }
    public var friendship: Relation? {
        return _friendship
    }
    public var view: Relation? {
        return _view
    }
    
    private var _like: Relation? = nil
    private var _friendship: Relation? = nil
    private var _view: Relation? = nil
    
    public override init() {
        super.init()
    }
    
    public init(like: Relation? = nil, friendship: Relation? = nil, view: Relation? = nil) {
        _like = like
        _friendship = friendship
        _view = view
        
        super.init()
    }
    
    public init(json: JSONValue) {
        _friendship = Relation(json: json["friendship"])
        _like = Relation(json: json["like"])
        _view = Relation(json: json["view"])
        
        super.init()
    }
}
