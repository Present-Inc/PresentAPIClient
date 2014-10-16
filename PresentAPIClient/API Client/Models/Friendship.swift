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

public class Friendship: Object {
    override class var apiResourcePath: String { return "friendships" }
    
    private(set) var sourceUser: User!
    private(set) var targetUser: User!
    
    internal let logger = Friendship._logger()
    
    public init(sourceUser: User, targetUser: User) {
        self.sourceUser = sourceUser
        self.targetUser = targetUser
        
        super.init()
    }
    
    public override init(json: JSON) {
        if let sourceUserId = json["sourceUser"].string {
            if sourceUserId == UserSession.currentUser()?.id {
                self.logger.debug("Setting the current user to the source user")
                self.sourceUser = UserSession.currentUser()
            }
        } else {
            self.sourceUser = User(json: json["sourceUser"])
        }
        
        if let targetUserId = json["targetUser"].string {
            if targetUserId == UserSession.currentUser()?.id {
                self.logger.debug("Setting the current user to the target user")
                self.targetUser = UserSession.currentUser()
            }
        } else {
            self.targetUser = User(json: json["targetUser"])
        }
        
        super.init(json: json)
    }
}

private extension Friendship {
    class func _logger() -> Logger {
        return Swell.getLogger("Friendship")
    }
}

public extension Friendship {
    // MARK: Forward Friendships
    
    public class func getForwardFriendships(user: User, cursor: Int? = 0, success: (([Friendship], Int) -> ())?, failure: FailureBlock) {
        var parameters = [
            "username": user.username as NSString,
            "cursor": cursor!
        ],
        successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
            self._logger().debug("Retrieved page \(cursor) of forward friendships. Next cursor is \(nextCursor)")
            
            var forwardFriendships = [Friendship]()
            for jsonFriendship: JSON in jsonArray {
                var friendship = Friendship(json: jsonFriendship["object"])
                friendship.sourceUser = user
                forwardFriendships.append(friendship)
            }
            
            success?(forwardFriendships, nextCursor)
        }
        
        APIManager
            .sharedInstance()
            .getCollection(
                Friendship.pathForResource("list_user_forward_friendships"),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Backward Friendships
    
    public class func getBackwardFriendships(user: User, cursor: Int? = 0, success: (([Friendship], Int) -> ())?, failure: FailureBlock) {
        var parameters = [
            "username": user.username as NSString,
            "cursor": cursor!
        ],
        successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
            self._logger().debug("Retrieved page \(cursor) of backward friendships. Next cursor is \(nextCursor)")
            
            var backwardFriendships = [Friendship]()
            for jsonFriendship: JSON in jsonArray {
                var friendship = Friendship(json: jsonFriendship["object"])
                friendship.targetUser = user
                backwardFriendships.append(friendship)
            }
            
            success?(backwardFriendships, nextCursor)
        }
        
        APIManager
            .sharedInstance()
            .getCollection(
                Friendship.pathForResource("list_user_backward_friendships"),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Instance Methods
    
    // MARK: Friendship Creation
    
    public func create(success: ((Friendship) -> ())?, failure: FailureBlock) {
        var parameters = [
            "user_id": self.targetUser.id
        ],
        successHandler: ResourceSuccessBlock = { jsonResponse in
            self.logger.debug("Successfully created friendship between \(self.sourceUser.username) and \(self.targetUser.username)")
            
            var friendship = Friendship(json: jsonResponse["result"]["object"])
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
