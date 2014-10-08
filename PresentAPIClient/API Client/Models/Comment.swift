//
//  Comment.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/13/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

public class Comment: Object {
    override class var apiResourcePath: String { return "comments" }
    
    public var video: Video {
        return _video
    }
    
    public var author: User {
        return _author
    }
    
    public var body: String {
        return _body
    }
    
    internal var _video: Video!
    internal var _author: User!
    internal var _body: String!
    
    private var logger = Comment._logger()

    private class func _logger() -> Logger {
        return Swell.getLogger("Comment")
    }

    public init(body: String, author: User, video: Video) {
        _body = body
        _author = author
        _video = video
        
        super.init()
    }
    
    public override init(json: JSON) {
        if let bodyString = json["body"].string {
            _body = bodyString
        }
        
        _author = User(json: json["sourceUser"])
        _video = Video(json: json["targetVideo"])
        
        super.init(json: json)
    }
}

extension Comment {
    class func resourceSuccessWithCompletion(completion: ((Comment) -> ())?) -> ResourceSuccessBlock {
        return { jsonResponse in
            var comment = Comment(json: jsonResponse["object"])
            completion?(comment)
        }
    }
    
    class func collectionSuccessWithCompletion(completion: (([Comment], Int) -> ())?) -> CollectionSuccessBlock {
        return { jsonArray, nextCursor in
            var commentResults = jsonArray.map { Comment(json: $0["object"]) }
            completion?(commentResults, nextCursor)
        }
    }
    
    public class func getCommentsForVideo(video: Video, cursor: Int? = 0, success: (([Comment], Int) -> ())?, failure: FailureBlock) {
        var parameters: [String: AnyObject] = [
            "video_id": video.id,
            "cursor": cursor!
        ],
        successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
            self._logger().debug("JSON Array results: \(jsonArray)")
            
            var commentResults = [Comment]()
            for jsonComment: JSON in jsonArray {
                var comment = Comment(json: jsonComment["object"])
                comment._video = video
                commentResults.append(comment)
            }
            
            success?(commentResults, nextCursor)
        }
        
        APIManager
            .sharedInstance()
            .getCollection(
                Comment.pathForResource("list_video_comments"),
                parameters: parameters,
                success: Comment.collectionSuccessWithCompletion(success),
                failure: failure
        )
    }
    
    public class func getCommentWithId(id: String, success: ((Comment) -> ())?, failure: FailureBlock) {
        var parameters: [String: AnyObject] = [
            "comment_id": id
        ]
        
        APIManager
            .sharedInstance()
            .getResource(
                Comment.showResource(),
                parameters: parameters,
                success: Comment.resourceSuccessWithCompletion(success),
                failure: failure
        )
    }
    
    public func create(success: ((Comment) -> ())?, failure: FailureBlock?) {
        if body.isEmpty {
            var error = NSError(domain: "CommentErrorDomain", code: 100, userInfo: [NSLocalizedDescriptionKey: "Comment body is empty."])
            failure?(error)
        }
        
        var parameters: [String: AnyObject] = [
            "video_id": self.video.id,
            "body": self.body
        ],
        successHandler: ResourceSuccessBlock = { jsonResponse in
            var commentResponse = Comment(json: jsonResponse["object"])
            self.mergeResultsFromObject(commentResponse)
            success?(self)
        }
        
        APIManager
            .sharedInstance()
            .postResource(
                Comment.createResource(),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    public func destroy(success: ((Comment) -> ())?, failure: FailureBlock?) {
        var parameters: [String: AnyObject] = [
            "comment_id": self.id
        ],
        successHandler: ResourceSuccessBlock = { jsonResponse in
            if success != nil {
                success!(self)
            }
        }
        
        APIManager
            .sharedInstance()
            .postResource(
                Comment.destroyResource(),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    public func updateBody(newBody: String, success:((Comment) -> ())?, failure: FailureBlock?) {
        var parameters: [String: AnyObject] = [
            "comment_id": self.id,
            "body": newBody
        ],
        successHandler: ResourceSuccessBlock = { jsonResponse in
            var commentResponse = Comment(json: jsonResponse["object"])
            self.mergeResultsFromObject(commentResponse)
            success?(self)
        }
        
        APIManager.sharedInstance().postResource(
            Comment.updateResource(),
            parameters: parameters,
            success: successHandler,
            failure: failure
        )
    }
}
