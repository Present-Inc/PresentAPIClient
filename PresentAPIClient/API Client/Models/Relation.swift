//
//  Relation.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

public class Relation: NSObject {
    public var forward: Bool = false
    public var backward: Bool = false
    
    public override init() {
        super.init()
    }
    
    public init(forward: Bool = false, backward: Bool = false) {
        self.forward = forward
        self.backward = backward
        
        super.init()
    }
    
    public init(json: JSON) {
        if let forwardJSON = json["forward"].bool {
            forward = forwardJSON
        }
        
        if let backwardJSON = json["backward"].bool {
            backward = backwardJSON
        }
        
        super.init()
    }
}
