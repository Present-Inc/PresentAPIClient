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
    public internal(set) var sourceUser: User
    public internal(set) var targetUser: User
    
    private class var logger: Logger {
        return self._logger("Friendship")
    }
    
    public init(sourceUser: User, targetUser: User) {
        self.sourceUser = sourceUser
        self.targetUser = targetUser
        
        super.init()
    }
    
    public required init(json: JSON) {
        self.targetUser = User(json: json["targetUser"])
        self.sourceUser = User(json: json["sourceUser"])
        
        super.init(json: json)
    }
}

public extension Friendship {
    // MARK: - Class Resource Methods
    
    // MARK: Create
    
    class func create(targetUserId: String, success: ((Friendship) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: (Friendship) -> () = { friendship in
            UserSession.currentSession()?.getObjectMetaForKey(targetUserId).friendship?.forward = true
            success?(friendship)
        }
        
        return APIManager
            .requestResource(
                FriendshipRouter.Create(userId: targetUserId),
                type: Friendship.self,
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Destroy
    
    class func destroy(targetUserId: String, success: (() -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: (Friendship) -> () = { _ in
            UserSession.currentSession()?.getObjectMetaForKey(targetUserId).friendship?.forward = false
            success?()
        }
        
        return APIManager
            .requestResource(
                FriendshipRouter.Destroy(userId: targetUserId),
                type: Friendship.self,
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Forward Friendships
    
    class func getForwardFriendships(user: User, cursor: Int? = 0, success: (([Friendship], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: ([Friendship], Int) -> () = { friendships, nextCursor in
            for friendship in friendships {
                friendship.sourceUser = user
            }

            success?(friendships, nextCursor)
        }
        
        return APIManager
            .requestCollection(
                FriendshipRouter.ForwardFriendships(userId: user.id!, cursor: cursor!),
                type: Friendship.self,
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Backward Friendships
    
    class func getBackwardFriendships(user: User, cursor: Int? = 0, success: (([Friendship], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: ([Friendship], Int) -> () = { friendships, nextCursor in
            for friendship in friendships {
                friendship.targetUser = user
            }
    
            success?(friendships, nextCursor)
        }
        
        return APIManager
            .requestCollection(
                FriendshipRouter.BackwardFriendships(userId: user.id!, cursor: cursor!),
                type: Friendship.self,
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: - Instance Resource Methods
    
    // MARK: Friendship Creation
    
    func create(success: ((Friendship) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return Friendship.create(targetUser.id!, success: { friendship in
            self.mergeResultsFromObject(friendship)
            success?(self)
        }, failure: failure)
    }
    
    // MARK: Friendship Destruction
    
    func destroy(success: ((Friendship) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return Friendship.destroy(targetUser.id!, success: {
            if success != nil {
                success!(self)
            }
        }, failure: failure)
    }
}
