//
//  SubjectiveObjectMeta.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import SwiftyJSON

public class SubjectiveObjectMeta: NSObject {
    public private(set) var like: Relation?
    public private(set) var friendship: Relation?
    public private(set) var view: Relation?
    
    public override init() {
        super.init()
    }
    
    public init(like: Relation? = nil, friendship: Relation? = nil, view: Relation? = nil) {
        self.like = like
        self.friendship = friendship
        self.view = view
        
        super.init()
    }
    
    public init(json: ObjectJSON) {
        self.friendship = Relation(json: json["friendship"])
        self.like = Relation(json: json["like"])
        self.view = Relation(json: json["view"])
        
        super.init()
    }
}
