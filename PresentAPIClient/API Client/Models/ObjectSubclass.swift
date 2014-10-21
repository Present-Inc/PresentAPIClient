//
//  ObjectSubclass.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

protocol ObjectSubclass {
    /**
        Used to merge to Object's together.
     */
    func mergeResultsFromObject(object: Object)
}