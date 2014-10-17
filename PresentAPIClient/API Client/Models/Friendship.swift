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

public typealias FriendshipResourceSuccessBlock = (Friendship) -> ()
public typealias FriendshipCollectionSuccessBlock = ([Friendship], Int) -> ()

public class Friendship: Object {
    public private(set) var sourceUser: User!
    public private(set) var targetUser: User!
    
    private class var logger: Logger {
        return self._logger("Friendship")
    }
    
    public init(sourceUser: User, targetUser: User) {
        self.sourceUser = sourceUser
        self.targetUser = targetUser
        
        super.init()
    }
    
    public init(json: JSON, targetUser: User? = nil, sourceUser: User? = nil) {
        if let sourceUserId = json["sourceUser"].string {
            if sourceUserId == UserSession.currentUser()?.id {
                Friendship.logger.debug("Setting the current user to the source user")
                self.sourceUser = UserSession.currentUser()
            }
        } else {
            self.sourceUser = User(json: json["sourceUser"])
        }
        
        if let targetUserId = json["targetUser"].string {
            if targetUserId == UserSession.currentUser()?.id {
                Friendship.logger.debug("Setting the current user to the target user")
                self.targetUser = UserSession.currentUser()
            }
        } else {
            self.targetUser = User(json: json["targetUser"])
        }
        
        super.init(json: json)
    }
}

public extension Friendship {
    // MARK: Create
    
    public class func create(targetUserId: String, success: FriendshipResourceSuccessBlock?, failure: FailureBlock?) -> Request {
        let successHandler: ResourceSuccessBlock = { jsonResponse in
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
    
    public class func destroy(targetUserId: String, success: VoidBlock?, failure: FailureBlock?) -> Request {
        let successHandler: ResourceSuccessBlock = { jsonResponse in
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
    
    public class func getForwardFriendships(user: User, cursor: Int? = 0, success: (([Friendship], Int) -> ())?, failure: FailureBlock) -> Request {
        let successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
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
    
    public class func getBackwardFriendships(user: User, cursor: Int? = 0, success: (([Friendship], Int) -> ())?, failure: FailureBlock) -> Request {
        let successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
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
    
    // MARK: Instance Methods
    
    // MARK: Friendship Creation
    
    public func create(success: ((Friendship) -> ())?, failure: FailureBlock) {
        let successHandler: ResourceSuccessBlock = { jsonResponse in
            let friendship = Friendship(json: jsonResponse["result"]["object"])
            self.mergeResultsFromObject(friendship)
            success?(self)
        }
        
        APIManager
            .sharedInstance()
            .postResource(
                Friendship.createResource(),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Friendship Destruction
    
    public func destroy(success: ((Friendship) -> ())?, failure: FailureBlock) {
        var parameters = [
            "user_id": self.targetUser.id
        ],
        successHandler: ResourceSuccessBlock = { jsonResponse in
            self.logger.debug("Successfully destroyed friendship between \(self.sourceUser.username) and \(self.targetUser.username)")
            success?(self)
        }
        
        APIManager
            .sharedInstance()
            .postResource(
                Friendship.destroyResource(),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
}
