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

public class Like: Object, JSONSerializable {
    public internal(set) var user: User
    public internal(set) var video: Video
    
    public init(user: User, video: Video) {
        self.user = user
        self.video = video
        
        super.init()
    }
    
    
    public convenience init(json: ObjectJSON, video: Video) {
        self.init(json: json)
        self.video = video
    }
    
    public convenience init(json: ObjectJSON, user: User) {
        self.init(json: json)
        self.user = user
    }
    
    public required init(json: ObjectJSON) {
        self.user = User(json: json["object"]["sourceUser"])
        self.video = Video(json: json["object"]["targetVideo"])

        super.init(json: json["object"])
    }
}

public extension Like {
    // MARK: - Class Resource Methods
    
    // MARK: Create
    
    class func create(videoId: String, success: ((Like) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: (Like) -> () = { like in
            UserSession.currentSession()?.getObjectMetaForKey(videoId).like?.forward = true
            success?(like)
        }
        
        return APIManager
            .requestResource(
                LikeRouter.Create(videoId: videoId),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Destroy
    
    class func destroy(videoId: String, success: (() -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: (Like) -> () = { like in
            UserSession.currentSession()?.getObjectMetaForKey(videoId).like?.forward = false
            success?()
        }
        
        return APIManager
            .requestResource(
                LikeRouter.Destroy(videoId: videoId),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Forward Likes For User
    
    class func getForwardLikes(user: User, cursor: Int? = 0, success: (([Like], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: ([Like], Int) -> () = { likes, nextCursor in
            for like in likes {
                like.user = user
            }

            success?(likes, nextCursor)
        }
        
        return APIManager
            .requestCollection(
                LikeRouter.ForwardLikes(userId: user.id!, cursor: cursor!),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Backward Likes For User
    
    class func getBackwardLikes(video: Video, cursor: Int? = 0, success: (([Like], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: ([Like], Int) -> () = { likes, nextCursor in
            for like in likes {
                like.video = video
            }

            success?(likes, nextCursor)
        }
        
        return APIManager
            .requestCollection(
                LikeRouter.BackwardLikes(videoId: video.id!, cursor: cursor!),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: - Instance Resource Methods
    
    // MARK: Create
    
    func create(success: ((Like) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return Like.create(video.id!, success: { like in
            self.mergeResultsFromObject(like)
            success?(self)
        }, failure: failure)

    }
    
    // MARK: Destroy
    
    func destroy(success: ((Like) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return Like.destroy(video.id!, success: {
            if success != nil {
                success!(self)
            }
        }, failure: failure)
    }
}
