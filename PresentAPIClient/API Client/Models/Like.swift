//
//  Like.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/13/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit

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
    
    public override init(json: JSONValue) {
        
        
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
    
    class func getForwardLikes(user: User, cursor: Int? = 0, success: (([Like], Int) -> ())?, failure: FailureBlock?) {
        var parameters: [String: AnyObject] = [
            "cursor": cursor!,
            "user_id": user.id
        ],
        successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
            self._logger().debug("JSON Array results: \(jsonArray)")
            
            var likeResults = [Like]()
            for jsonLike: JSONValue in jsonArray {
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
            
            var likeResults = [Like]()
            for jsonLike: JSONValue in jsonArray {
                var like = Like(json: jsonLike["object"])
                like._video = video
                likeResults.append(like)
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
                success?(like)
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
        var parameters: [String: AnyObject] = [
            "comment_id": self.id
        ],
        successHandler: ResourceSuccessBlock = { jsonResponse in
            if success != nil {
                success?(self)
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
}
