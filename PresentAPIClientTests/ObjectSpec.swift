//
//  ObjectSpec.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/11/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Quick
import Nimble
import PresentAPIClient

class ObjectSpec: QuickSpec {
    override func spec() {
        // TODO: Test subclass protocol
        describe ("an instance") {
            it ("is equal to another instance if their _id is equal.") {
                var first = Object(id: "666")
                var second = Object(id: "666")
                
                expect(first.isEqual(second)).to(beTruthy())
            }
        }
    }
}
