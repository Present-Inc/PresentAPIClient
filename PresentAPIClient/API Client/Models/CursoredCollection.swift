//
//  CursoredCollection.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/13/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Foundation

public class CursoredCollection<T: Equatable> {
    private var _collection: [T] = [T]()
    public var collection: [T] {
        return _collection
    }
    
    public var cursor: Int = 0
    public var count: Int = 0
    
    public init() { }
    
    public func reset() {
        self._collection.removeAll(keepCapacity: false)
        self.cursor = 0
    }
    
    public func addObject(object: T) {
        self._collection.append(object)
        count++
    }
    
    public func addObjects(objects: [T]) {
        for i in objects {
            self.addObject(i)
        }
    }
    
    public func removeObject(index: Int) -> Bool {
        if index >= 0 && index < self._collection.count {
            self._collection.removeAtIndex(index)
            count--
            return true
        }
        
        return false
    }
    
    public func removeObject(object: T) -> Bool {
        var index = find(self._collection, object)
        if index != nil {
            return self.removeObject(index!)
        }
        
        return false
    }
}
