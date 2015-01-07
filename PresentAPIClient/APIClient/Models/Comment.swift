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

public class Comment: Object, JSONSerializable {
    public private(set) var video: Video!
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
    
    public convenience init(json: ObjectJSON, video: Video) {
        self.init(json: json)
        self.video = video
    }
    
    public required init(json: ObjectJSON) {
        if let bodyString = json["object"]["body"].string {
            self.body = bodyString
        } else {
            self.body = ""
        }
        
        self.author = User(json: json["object"]["sourceUser"])
        self.video = Video(json: json["object"]["targetVideo"])
        
        super.init(json: json["object"])
    }
}

extension Comment {
    // MARK: Class Methods
    
    public class func getCommentsForVideo(video: Video, cursor: Int? = 0, success: (([Comment], Int) -> ())?, failure: ((NSError?) -> ())) -> APIRequest {
        return APIManager
            .requestCollection(
                CommentRouter.CommentsForVideo(videoId: video.id!, cursor: cursor!),
                success: success,
                failure: failure
        )
    }
    
    public class func getCommentWithId(id: String, success: ((Comment) -> ())?, failure: ((NSError?) -> ())) -> APIRequest {
        return APIManager
            .requestResource(
                CommentRouter.CommentForId(commentId: id),
                success: success,
                failure: failure
            )
    }
    
    // MARK: Instance Methods
    
    public func create(success: ((Comment) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        if body.isEmpty {
            let error = NSError(domain: "CommentErrorDomain", code: 100, userInfo: [NSLocalizedDescriptionKey: "Comment body is empty."])
            failure?(error)
        }
        
        return APIManager
            .requestResource(
                CommentRouter.Create(videoId: video.id!, body: body),
                success: { (comment: Comment) in
                    self.mergeResultsFromObject(comment)
                    self.video.addComment(comment)
                    success?(self)
                },
                failure: failure
            )
    }
    
    public func destroy(success: ((Comment) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: (Comment) -> () = { _ in
            self.video.deleteComment(self)
            if success != nil {
                success!(self)
            }
        }
        
        return APIManager
            .requestResource(
                CommentRouter.Destroy(commentId: self.id!),
                success: success,
                failure: failure
            )
    }
    
    public func updateBody(newBody: String, success: ((Comment) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return APIManager
            .requestResource(
                CommentRouter.Update(commentId: self.id!, body: self.body),
                success: { (comment: Comment) in
                    self.mergeResultsFromObject(comment)
                    success?(comment)
                },
                failure: failure
            )
    }
}
