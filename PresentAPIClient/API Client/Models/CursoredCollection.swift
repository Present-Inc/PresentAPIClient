//
//  CursoredCollection.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/13/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Foundation

public class CursoredCollection<T: Equatable> {
    var collection: [T] = [T]()
    var cursor: Int = 0
    var count: Int = 0
    
    func reset() {
        self.collection.removeAll(keepCapacity: false)
        self.cursor = 0
    }
    
    func addObject(object: T) {
        self.collection.append(object)
    }
    
    func addObjects(objects: [T]) {
        for i in objects {
            self.addObject(i)
        }
    }
    
    func removeObject(index: Int) -> Bool {
        if index >= 0 && index < self.collection.count {
            self.collection.removeAtIndex(index)
            return true
        }
        
        return false
    }
    
    func removeObject(object: T) -> Bool {
        var index = find(self.collection, object)
        if index != nil {
            return self.removeObject(index!)
        }
        
        return false
    }
}
