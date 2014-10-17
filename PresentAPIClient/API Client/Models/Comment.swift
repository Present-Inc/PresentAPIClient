//
//  Comment.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/13/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Swell
import Alamofire

public class Comment: Object {
    public internal(set) var video: Video
    public private(set) var author: User
    public private(set) var body: String
    
    private class var logger: Logger {
        return Comment._logger("Comment")
    }

    public init(body: String, author: User, video: Video) {
        self.body = body
        self.author = author
        self.video = video
        
        super.init()
    }
    
    public init(json: JSON, video: Video? = nil) {
        if let bodyString = json["body"].string {
            self.body = bodyString
        } else {
            self.body = ""
        }
        
        self.author = User(json: json["sourceUser"])
        
        if let video = video {
            self.video = video
        } else {
            self.video = Video(json: json["targetVideo"])
        }
        
        super.init(json: json)
    }
    
    internal func setVideo(video: Video) {
        self.video = video
    }
}

extension Comment {
    // MARK: Class Methods
    
    public class func getCommentsForVideo(video: Video, cursor: Int? = 0, success: CommentCollectionSuccess?, failure: FailureBlock) -> Request {
        let successHandler: CollectionSuccess = { jsonArray, nextCursor in
            let commentResults = jsonArray.map { Comment(json: $0["object"], video: video) }
            success?(commentResults, nextCursor)
        }
        
        return APIManager
            .sharedInstance()
            .requestCollection(
                CommentRouter.CommentsForVideo(videoId: video.id!, cursor: cursor!),
                success: collectionSuccessWithCompletion(success),
                failure: failure
        )
    }
    
    public class func getCommentWithId(id: String, success: CommentResourceSuccess?, failure: FailureBlock) -> Request {
        return APIManager
            .sharedInstance()
            .requestResource(
                CommentRouter.CommentForId(commentId: id),
                success: resourceSuccessWithCompletion(success),
                failure: failure
        )
    }
    
    // MARK: Instance Methods
    
    public func create(success: CommentResourceSuccess?, failure: FailureBlock?) -> Request {
        if body.isEmpty {
            let error = NSError(domain: "CommentErrorDomain", code: 100, userInfo: [NSLocalizedDescriptionKey: "Comment body is empty."])
            failure?(error)
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                CommentRouter.Create(videoId: video.id!, body: body),
                success: instanceSuccessWithCompletion(success),
                failure: failure
        )
    }
    
    public func destroy(success: CommentResourceSuccess?, failure: FailureBlock?) -> Request {
        let successHandler: ResourceSuccess = { jsonResponse in
            if success != nil {
                success!(self)
            }
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                CommentRouter.Destroy(commentId: self.id!),
                success: successHandler,
                failure: failure
        )
    }
    
    public func updateBody(newBody: String, success: CommentResourceSuccess?, failure: FailureBlock?) -> Request {
        return APIManager
            .sharedInstance()
            .requestResource(
                CommentRouter.Update(commentId: self.id!, body: self.body),
                success: instanceSuccessWithCompletion(success),
                failure: failure
        )
    }
}

// MARK: Serialization
private extension Comment {
    
    // MARK: Class Level
    
    class func resourceSuccessWithCompletion(completion: CommentResourceSuccess?) -> ResourceSuccess {
        return { jsonResponse in
            var comment = Comment(json: jsonResponse["object"])
            completion?(comment)
        }
    }
    
    class func collectionSuccessWithCompletion(completion: CommentCollectionSuccess?) -> CollectionSuccess {
        return { jsonArray, nextCursor in
            var commentResults = jsonArray.map { Comment(json: $0["object"]) }
            completion?(commentResults, nextCursor)
        }
    }
    
    // MARK: Instance Level
    
    func instanceSuccessWithCompletion(completion: CommentResourceSuccess?) -> ResourceSuccess {
        return { jsonResponse in
            let commentResponse = Comment(json: jsonResponse["object"])
            self.mergeResultsFromObject(commentResponse)
            completion?(self)
        }
    }
    
}
