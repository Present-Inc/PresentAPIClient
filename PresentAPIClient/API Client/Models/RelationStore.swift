//
//  RelationStore.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit

/**
 *  Controls a store for user relationships
 */
public class RelationStore: NSObject {
    var friendships: NSCache = NSCache()
    var likes: NSCache = NSCache()
    var views: NSCache = NSCache()
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: Accessors/Mutators
    
    internal func store(relation: Relation, forKey key: String, inCache cache: NSCache) {
        cache.setObject(relation, forKey: key)
    }
    
    internal func getRelation(key: String, inCache cache: NSCache) -> Relation? {
        return cache.objectForKey(key) as? Relation
    }
}

// MARK: Subjective Object Meta
extension RelationStore {
    public func store(objectMeta: SubjectiveObjectMeta, forKey key: String) {
        if let friendship = objectMeta.friendship {
            self.storeFriendship(friendship, forKey: key)
        }
        
        if let like = objectMeta.like {
            self.storeLike(like, forKey: key)
        }
        
        if let view = objectMeta.view {
            self.storeView(view, forKey: key)
        }
    }
}

// MARK: Views

extension RelationStore {
    func storeView(viewRelation: Relation, forKey key: String) {
        self.store(viewRelation, forKey: key, inCache: self.views)
    }
    
    func getView(key: String) -> Relation? {
        return self.getRelation(key, inCache: self.views)
    }
}

// MARK: Friendships

extension RelationStore {
    func storeFriendship(friendshipRelation: Relation, forKey key: String) {
        self.store(friendshipRelation, forKey: key, inCache: self.friendships)
    }
    
    func getFriendship(key: String) -> Relation? {
        return self.getRelation(key, inCache: self.friendships)
    }
}

// MARK: Likes

extension RelationStore {
    func storeLike(likeRelation: Relation, forKey key: String) {
        self.store(likeRelation, forKey: key, inCache: self.likes)
    }
    
    func getLike(key: String) -> Relation? {
        return self.getRelation(key, inCache: self.likes)
    }
}
