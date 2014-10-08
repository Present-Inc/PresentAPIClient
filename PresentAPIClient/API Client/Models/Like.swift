//
//  Like.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/13/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

public class Like: Object {
    override class var apiResourcePath: String { return "likes" }
    
    public var user: User {
        return _user
    }
    
    public var video: Video {
        return _video
    }
    
    internal var _user: User!
    internal var _video: Video!
    
    private let logger = Like._logger()
    
    public init(user: User, video: Video) {
        _user = user
        _video = video
        
        super.init()
    }
    
    public override init(json: JSON) {
        var userId: String? = json["sourceUser"].string
        if userId == nil {
            _user = User(json: json["sourceUser"])
        }
        
        var videoId: String? = json["targetVideo"].string
        if videoId == nil {
            _video = Video(json: json["targetVideo"])
        }
        
        super.init(json: json)
    }
}

private extension Like {
    class func _logger() -> Logger {
        return Swell.getLogger("Like")
    }
}

public extension Like {
    // MARK: Class Resource Methods
    
    class func destroyLikeForVideo(video: Video, success: (() -> ())?, failure: FailureBlock?) {
        var parameters: [String: AnyObject] = [
            "video_id": video.id
        ],
        successHandler: ResourceSuccessBlock = { jsonResponse in
            UserSession.currentSession()?
                .storeObjectMeta(
                    SubjectiveObjectMeta(
                        like: Relation(forward: false),
                        friendship: nil,
                        view: nil
                    ),
                    forObject: video
            )
            
            if success != nil {
                success?()
            }
        }
        
        APIManager
            .sharedInstance()
            .postResource(
                Like.destroyResource(),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    class func getForwardLikes(user: User, cursor: Int? = 0, success: (([Like], Int) -> ())?, failure: FailureBlock?) {
        var parameters: [String: AnyObject] = [
            "cursor": cursor!,
            "user_id": user.id
        ],
        successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
            self._logger().debug("JSON Array results: \(jsonArray)")
            
            var likeResults = [Like]()
            for jsonLike: JSON in jsonArray {
                var like = Like(json: jsonLike["object"])
                like._user = user
                likeResults.append(like)
            }
            
            success?(likeResults, nextCursor)
        }
        
        APIManager
            .sharedInstance()
            .getCollection(
                Like.pathForResource("list_user_forward_likes"),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    class func getBackwardLikes(video: Video, cursor: Int? = 0, success: (([Like], Int) -> ())?, failure: FailureBlock?) {
        var parameters: [String: AnyObject] = [
            "cursor": cursor!,
            "video_id": video.id
        ],
        successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
            self._logger().debug("JSON Array results: \(jsonArray)")
            
            var likeResults = jsonArray.map { jsonLike -> Like in
                var like = Like(json: jsonLike["object"])
                like._video = video
                
                return like
            }
            
            success?(likeResults, nextCursor)
        }
        
        APIManager
            .sharedInstance()
            .getCollection(
                Like.pathForResource("list_video_backward_likes"),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Instance Resource methods
    
    func create(success: ((Like) -> ())?, failure: FailureBlock?) {
        var parameters: [String: AnyObject] = [
            "video_id": self.video.id
        ],
        successHandler: ResourceSuccessBlock = { jsonResponse in
            if success != nil {
                var like = Like(json: jsonResponse["object"])
                self.mergeResultsFromObject(like)
                success?(self)
            }
        }
        
        APIManager
            .sharedInstance()
            .postResource(
                Like.createResource(),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    func destroy(success: ((Like) -> ())?, failure: FailureBlock?) {
        Like.destroyLikeForVideo(self.video, success: {
            if success != nil {
                success!(self)
            }
        }, failure: failure)
    }
}
