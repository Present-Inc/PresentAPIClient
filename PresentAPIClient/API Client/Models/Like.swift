//
//  Like.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/13/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Swell
import Alamofire

public class Like: Object {
    public private(set) var user: User
    public private(set) var video: Video
    
    public init(user: User, video: Video) {
        self.user = user
        self.video = video
        
        super.init()
    }
    
    public init(json: JSON, user: User? = nil, video: Video? = nil) {
        if let user = user {
            self.user = user
        } else {
            self.user = User(json: json["sourceUser"])
        }

        if let video = video {
            self.video = video
        } else {
            self.video = Video(json: json["targetVideo"])
        }
        
        super.init(json: json)
    }
}

public extension Like {
    // MARK: - Class Resource Methods
    
    // MARK: Create
    
    class func create(videoId: String, success: LikeResourceSuccess?, failure: FailureBlock?) -> Request {
        let successHandler: ResourceSuccess = { jsonResponse in
            UserSession.currentSession()?.getObjectMetaForKey(videoId).like?.forward = true
            
            let like = Like(json: jsonResponse["object"])
            success?(like)
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                LikeRouter.Create(videoId: videoId),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Destroy
    
    class func destroy(videoId: String, success: VoidBlock?, failure: FailureBlock?) -> Request {
        let successHandler: ResourceSuccess = { jsonResponse in
            UserSession.currentSession()?.getObjectMetaForKey(videoId).like?.forward = false
            
            if success != nil {
                success?()
            }
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                LikeRouter.Destroy(videoId: videoId),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Forward Likes For User
    
    class func getForwardLikes(user: User, cursor: Int? = 0, success: LikeCollectionSuccess?, failure: FailureBlock?) -> Request {
        let successHandler: CollectionSuccess = { jsonArray, nextCursor in
            let likeResults = jsonArray.map { Like(json: $0["object"], user: user) }
            success?(likeResults, nextCursor)
        }
        
        return APIManager
            .sharedInstance()
            .requestCollection(
                LikeRouter.ForwardLikes(userId: user.id!, cursor: cursor!),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Backward Likes For User
    
    class func getBackwardLikes(video: Video, cursor: Int? = 0, success: LikeCollectionSuccess?, failure: FailureBlock?) -> Request {
        let successHandler: CollectionSuccess = { jsonArray, nextCursor in
            let likeResults = jsonArray.map { Like(json: $0["object"], video: video) }
            success?(likeResults, nextCursor)
        }
        
        return APIManager
            .sharedInstance()
            .requestCollection(
                LikeRouter.BackwardLikes(videoId: video.id!, cursor: cursor!),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: - Instance Resource Methods
    
    // MARK: Create
    
    func create(success: LikeResourceSuccess?, failure: FailureBlock?) -> Request {
        return Like.create(video.id!, success: { like in
            self.mergeResultsFromObject(like)
            success?(self)
        }, failure: failure)

    }
    
    // MARK: Destroy
    
    func destroy(success: LikeResourceSuccess?, failure: FailureBlock?) -> Request {
        return Like.destroy(video.id!, success: {
            if success != nil {
                success!(self)
            }
        }, failure: failure)
    }
}
