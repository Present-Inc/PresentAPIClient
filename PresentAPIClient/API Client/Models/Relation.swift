//
//  Relation.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit

public class Relation: NSObject {
    public var forward: Bool = false
    public var backward: Bool = false
    
    public override init() {
        super.init()
    }
    
    public init(forward: Bool, backward: Bool) {
        self.forward = forward
        self.backward = backward
        
        super.init()
    }
}
