//  PrintableTests.swift
//
//  Copyright (c) 2014 Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import XCTest
import SwiftyJSON

class PrintableTests: XCTestCase {
    func testNumber() {
        var json:JSON = 1234567890.876623
        XCTAssertEqual(json.description, "1234567890.876623")
        XCTAssertEqual(json.debugDescription, "1234567890.876623")
    }
    
    func testBool() {
        var jsonTrue:JSON = true
        XCTAssertEqual(jsonTrue.description, "true")
        XCTAssertEqual(jsonTrue.debugDescription, "true")
        var jsonFalse:JSON = false
        XCTAssertEqual(jsonFalse.description, "false")
        XCTAssertEqual(jsonFalse.debugDescription, "false")
    }
    
    func testString() {
        var json:JSON = "abcd efg, HIJK;LMn"
        XCTAssertEqual(json.description, "abcd efg, HIJK;LMn")
        XCTAssertEqual(json.debugDescription, "abcd efg, HIJK;LMn")
    }
    
    func testNil() {
        var jsonNil_1:JSON = nil
        XCTAssertEqual(jsonNil_1.description, "null")
        XCTAssertEqual(jsonNil_1.debugDescription, "null")
        var jsonNil_2:JSON = JSON(NSNull())
        XCTAssertEqual(jsonNil_2.description, "null")
        XCTAssertEqual(jsonNil_2.debugDescription, "null")
    }
    
    func testArray() {
        var json:JSON = [1,2,"4",5,"6"]
        XCTAssertEqual(json.description, "[1, 2, 4, 5, 6]")
        XCTAssertEqual(json.debugDescription, "[1, 2, 4, 5, 6]")
    }
    
    func testDictionary() {
        var json:JSON = ["1":2,"2":2, "3":3]
        XCTAssertEqual(json.description, "[2: 2, 3: 3, 1: 2]")
        XCTAssertEqual(json.debugDescription, "[\"2\": 2, \"3\": 3, \"1\": 2]")
    }
}
