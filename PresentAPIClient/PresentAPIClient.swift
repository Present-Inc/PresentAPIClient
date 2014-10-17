//
//  PresentAPIClient.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 10/17/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Foundation
import SwiftyJSON

public typealias VoidBlock = () -> ()
public typealias ResourceSuccess = (JSON) -> ()
public typealias CollectionSuccess = ([JSON], Int) -> ()
public typealias FailureBlock = (NSError?) -> ()
// MARK: Activities
public typealias ActivityResourceSuccess = (Activity) -> ()
public typealias ActivityCollectionSuccess = ([Activity], Int) -> ()
// MARK: Comments
public typealias CommentResourceSuccess = (Comment) -> ()
public typealias CommentCollectionSuccess = ([Comment], Int) -> ()
// MARK: Friendships
public typealias FriendshipResourceSuccess = (Friendship) -> ()
public typealias FriendshipCollectionSuccess = ([Friendship], Int) -> ()
// MARK: Likes
public typealias LikeResourceSuccess = (Like) -> ()
public typealias LikeCollectionSuccess = ([Like], Int) -> ()
// MARK: Users
public typealias UserResourceSuccess = (User) -> ()
public typealias UserCollectionSuccess = ([User], Int) -> ()
// MARK: UserContext
public typealias UserContextResourceSuccess = (UserContext) -> ()
// MARK: Video
public typealias VideoResourceSuccess = (Video) -> ()
public typealias VideoCollectionSuccess = ([Video], Int) -> ()
// MARK: View
public typealias ViewResourceSuccess = (View) -> ()
public typealias ViewCollectionSuccess = ([View], Int) -> ()

#if DEBUG
    let apiVersion = "v1"
    let subDomain = "api-staging"
#else
    let apiVersion = "v1"
    let subDomain = "api"
#endif

let baseURL: NSURL = {
    var apiVersion = "v1"
    var subdomain = "api"
    
    if NSProcessInfo.processInfo().environment["DEBUG"] != nil {
        apiVersion = "v1"
        subdomain = "api-staging"
    }
    
    return NSURL(string: "https://\(subdomain).present.tv/\(apiVersion)/")
}()

let Version = "2014-09-09"

let PresentVersionHeader = "Present-Version"
let SessionTokenHeader = "Present-User-Context-Session-Token"
let UserIdHeader = "Present-User-Context-User-Id"

let CallbackQueueIdentifier = "tv.Present.Present.PresentAPIClient.serializationQueue"
