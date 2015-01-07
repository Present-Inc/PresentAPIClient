//
//  JSONSerializable.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 10/22/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Foundation
import SwiftyJSON

public typealias ObjectJSON = JSON

public protocol JSONSerializable {
    init(json: ObjectJSON)
}