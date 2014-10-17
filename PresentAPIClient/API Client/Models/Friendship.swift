//
//  Friendship.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Swell
import Alamofire

public class Friendship: Object {
    public private(set) var sourceUser: User
    public private(set) var targetUser: User
    
    private class var logger: Logger {
        return self._logger("Friendship")
    }
    
    public init(sourceUser: User, targetUser: User) {
        self.sourceUser = sourceUser
        self.targetUser = targetUser
        
        super.init()
    }
    
    public init(json: JSON, sourceUser: User? = nil, targetUser: User? = nil) {
        if let sourceUser = sourceUser {
            self.sourceUser = sourceUser
        } else {
            self.sourceUser = User(json: json["sourceUser"])
        }
        
        if let targetUser = targetUser {
            self.targetUser = targetUser
        } else {
            self.targetUser = User(json: json["targetUser"])
        }
        
        super.init(json: json)
    }
}

public extension Friendship {
    // MARK: - Class Resource Methods
    
    // MARK: Create
    
    class func create(targetUserId: String, success: FriendshipResourceSuccess?, failure: FailureBlock?) -> Request {
        let successHandler: ResourceSuccess = { jsonResponse in
            UserSession.currentSession()?.getObjectMetaForKey(targetUserId).friendship?.forward = true
            
            let friendship = Friendship(json: jsonResponse["result"]["object"])
            success?(friendship)
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                FriendshipRouter.Create(userId: targetUserId),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Destroy
    
    class func destroy(targetUserId: String, success: VoidBlock?, failure: FailureBlock?) -> Request {
        let successHandler: ResourceSuccess = { jsonResponse in
            UserSession.currentSession()?.getObjectMetaForKey(targetUserId).friendship?.forward = false
            
            if success != nil {
                success!()
            }
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                FriendshipRouter.Destroy(userId: targetUserId),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Forward Friendships
    
    class func getForwardFriendships(user: User, cursor: Int? = 0, success: FriendshipCollectionSuccess?, failure: FailureBlock?) -> Request {
        let successHandler: CollectionSuccess = { jsonArray, nextCursor in
            let forwardFriendships = jsonArray.map { Friendship(json: $0["object"], sourceUser: user) }
            success?(forwardFriendships, nextCursor)
        }
        
        return APIManager
            .sharedInstance()
            .requestCollection(
                FriendshipRouter.ForwardFriendships(userId: user.id!, cursor: cursor!),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Backward Friendships
    
    class func getBackwardFriendships(user: User, cursor: Int? = 0, success: FriendshipCollectionSuccess?, failure: FailureBlock?) -> Request {
        let successHandler: CollectionSuccess = { jsonArray, nextCursor in
            let backwardFriendships = jsonArray.map { Friendship(json: $0["object"], targetUser: user) }
            success?(backwardFriendships, nextCursor)
        }
        
        return APIManager
            .sharedInstance()
            .requestCollection(
                FriendshipRouter.BackwardFriendships(userId: user.id!, cursor: cursor!),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: - Instance Resource Methods
    
    // MARK: Friendship Creation
    
    func create(success: FriendshipResourceSuccess?, failure: FailureBlock?) -> Request {
        return Friendship.create(targetUser.id!, success: { friendship in
            self.mergeResultsFromObject(friendship)
            success?(self)
        }, failure: failure)
    }
    
    // MARK: Friendship Destruction
    
    func destroy(success: FriendshipResourceSuccess?, failure: FailureBlock?) -> Request {
        return Friendship.destroy(targetUser.id!, success: {
            if success != nil {
                success!(self)
            }
        }, failure: failure)
    }
}
