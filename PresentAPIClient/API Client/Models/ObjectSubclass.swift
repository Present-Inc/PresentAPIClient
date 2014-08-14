//
//  ObjectSubclass.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Foundation

@objc protocol ObjectSubclass {
    optional class var apiResourcePath: String { get }
    class func pathForResource(resource: String) -> String
    func mergeResultsFromObject(object: Object)
}