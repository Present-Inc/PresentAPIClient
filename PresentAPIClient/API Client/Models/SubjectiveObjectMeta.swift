//
//  SubjectiveObjectMeta.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Foundation

public class SubjectiveObjectMeta: NSObject {
    public var like: Relation? = nil
    public var friendship: Relation? = nil
    
    public override init() {
        super.init()
    }
    
    public init(json: JSONValue) {
        
    }
}
