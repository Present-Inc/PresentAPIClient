//
//  Video.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Swell
import Alamofire

public class Video: Object {
    /**
        These are set as implicitly unwrapped in order to use the initializeWithObject(...)
        inside init.
     */
    public private(set) var caption: String?
    public private(set) var startDate: NSDate!
    public private(set) var endDate: NSDate?
    public private(set) var coverUrl: NSURL!
    public private(set) var creator: User!
    
    public var isLive: Bool {
        return endDate == nil
    }
    
    public var watchUrl: NSURL {
        if isLive {
            return liveUrl
        } else {
            return replayUrl
        }
    }
    
    public var comments: [Comment] {
        return commentsCollection.collection
    }
    
    public var commentsCursor: Int {
        return commentsCollection.cursor
    }
    
    public var commentsCount: Int {
        return commentsCollection.count
    }
    
    public var likes: [Like] {
        return likesCollection.collection
    }
    
    public var likesCursor: Int {
        return likesCollection.cursor
    }
    
    public var likesCount: Int {
        return likesCollection.count
    }
    
    public var isViewed: Bool {
        return subjectiveObjectMeta.view?.forward ?? false
    }
    
    public var isLiked: Bool {
        return subjectiveObjectMeta.like?.forward ?? false
    }
    
    private var liveUrl: NSURL!
    private var replayUrl: NSURL!
    
    private var subjectiveObjectMeta: SubjectiveObjectMeta!
    
    private var commentsCollection: CursoredCollection<Comment> = CursoredCollection<Comment>()
    private var likesCollection: CursoredCollection<Like> = CursoredCollection<Like>()
    
    private class var logger: Logger {
        return self._logger("Video")
    }
    
    public init(creator: User, caption: String? = nil) {
        self.creator = creator
        self.caption = caption
        
        super.init()
    }
    
    public required override init(coder aDecoder: NSCoder!) {
        caption = aDecoder.decodeObjectForKey("caption") as? String
        startDate = aDecoder.decodeObjectForKey("startDate") as? NSDate
        endDate = aDecoder.decodeObjectForKey("endDate") as? NSDate
        
        super.init(coder: aDecoder)
    }
    
    public init(json: JSON, creator: User? = nil) {
        super.init(json: json["object"])
        
        self.initializeWithObject(json["object"])
        
        if let user = creator {
            self.creator = user
        }

        if let objectId = self.id {
            self.subjectiveObjectMeta = SubjectiveObjectMeta(json: json["subjectiveObjectMeta"])
            UserSession.currentSession()?.storeObjectMeta(self.subjectiveObjectMeta, forKey: self.id!)
        }
    }
    
    private func initializeWithObject(json: JSON) {
        if let caption = json["title"].string {
            self.caption = caption
        }
        
        if let startDateString = json["creationTimeRange"]["startDate"].string {
            startDate = NSDate.dateFromISOString(startDateString)
        }
        
        if let endDateString = json["creationTimeRange"]["endDate"].string {
            endDate = NSDate.dateFromISOString(endDateString)
        }
        
        if let liveString = json["mediaUrls"]["playlists"]["live"]["master"].string {
            liveUrl = NSURL(string: liveString)
        }
        
        if let replayString = json["mediaUrls"]["playlists"]["replay"]["master"].string {
            replayUrl = NSURL(string: replayString)
        }
        
        // !!!: This is not a long-term solution. Prone to change.
        if let coverString = json["mediaUrls"]["images"]["480px"].string {
            coverUrl = NSURL(string: coverString)
        }
        
        creator = User(json: json["creatorUser"])
        
        if let mostRecentLikes = json["likes"]["results"].array {
            for jsonLike: JSON in mostRecentLikes {
                let like = Like(json: jsonLike["object"], video: self)
                self.likesCollection.addObject(like)
            }
        }
        
        if let likeCount = json["likes"]["count"].int {
            self.likesCollection.cursor = likeCount
        }
        
        if let mostRecentComments = json["comments"]["results"].array {
            for jsonComment: JSON in mostRecentComments {
                var comment = Comment(json: jsonComment["object"], video: self)
                self.commentsCollection.addObject(comment)
            }
        }
        
        if let commentCount = json["comments"]["count"].int {
            self.commentsCollection.count = commentCount
        }
    }
    
    public func start() {
        startDate = NSDate()
    }
    
    public func end() {
        endDate = NSDate()
    }
    
    public func addComment(comment: Comment) {
        self.commentsCollection.addObject(comment)
    }
    
    public func deleteComment(comment: Comment) {
        self.commentsCollection.removeObject(comment)
    }
    
    public func addLike(like: Like) {
        self.likesCollection.addObject(like)
    }
    
    public func deleteLike(like: Like) {
        self.likesCollection.removeObject(like)
    }
    
    public override func mergeResultsFromObject(object: Object) {
        let video = object as Video
        
        caption = video.caption
        
        super.mergeResultsFromObject(object)
    }
    
    public override func encodeWithCoder(aCoder: NSCoder!) {
        if caption != nil {
            aCoder.encodeObject(caption!, forKey: "caption")
        }
        
        if startDate != nil {
            aCoder.encodeObject(startDate, forKey: "startDate")
        }
        
        if endDate != nil {
            aCoder.encodeObject(endDate!, forKey: "endDate")
        }
        
        super.encodeWithCoder(aCoder)
    }
}

public extension Video {
    // MARK: - Class Resource Methods

    // MARK: Create
    
    public class func create(startDateISOString: String, success: VideoResourceSuccess?, failure: FailureBlock?) -> APIRequest {
        let successHandler: ResourceSuccess = { jsonResponse in
            let video = Video(json: jsonResponse["result"])
            success?(video)
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                VideoRouter.Create(startDateISOString: startDateISOString),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Destroy
    
    public class func destroy(videoId: String, success: VoidBlock?, failure: FailureBlock?) -> APIRequest {
        let successHandler: ResourceSuccess = { jsonResponse in
            if success != nil {
                success!()
            }
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                VideoRouter.Destroy(id: videoId),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Hide
    
    public class func hide(videoId: String, success: VoidBlock?, failure: FailureBlock?) -> APIRequest {
        let successHandler: ResourceSuccess = { jsonResponse in
            if success != nil {
                success!()
            }
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                VideoRouter.Hide(id: videoId),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Append
    // !!!: This doesn't return a request...
    public class func append(videoId: String, segmentUrl: NSURL, mediaSequence: Int, success: VoidBlock?, failure: FailureBlock?) {
        let parameters = [
            "video_id": videoId as NSString,
            "media_sequence": mediaSequence
        ]
        
        APIManager
            .sharedInstance()
            .multipartPost(
                segmentUrl,
                name: "media_segment",
                fileName: "index.ts",
                mimeType: "application/octet-stream",
                resource: "videos/append",
                parameters: parameters,
                success: success,
                failure: failure
            )

    }
    
    // MARK: Search

    public class func search(queryString: String, cursor: Int? = 0, success: VideoCollectionSuccess?, failure: FailureBlock?) -> APIRequest {
        return APIManager
            .sharedInstance()
            .requestCollection(
                VideoRouter.Search(query: queryString, cursor: cursor!),
                success: collectionSuccessWithCompletion(success),
                failure: failure
        )
    }
    
    // MARK: Fetch
    
    public class func getVideoWithId(id: String, success: VideoResourceSuccess?, failure: FailureBlock?) -> APIRequest {
        return APIManager
            .sharedInstance()
            .requestResource(
                VideoRouter.VideoForId(id: id),
                success: resourceSuccessWithCompletion(success),
                failure: failure
        )
    }
    
    // MARK: List
    
    // !!!: This is a big old red flag for what I'm trying to avoid.
    public class func getVideosForUser(user: User, cursor: Int? = 0, success: VideoCollectionSuccess?, failure: FailureBlock?) -> APIRequest {
        return APIManager
            .sharedInstance()
            .requestCollection(
                VideoRouter.VideosForUser(userId: user.id!, cursor: cursor!),
                success: { jsonArray, nextCursor in
                    let videos = jsonArray.map { Video(json: $0, creator: user) }
                    success?(videos, nextCursor)
                },
                failure: failure
        )
    }
    
    public class func getHomeVideos(cursor: Int? = 0, success: VideoCollectionSuccess?, failure: FailureBlock?) -> APIRequest {
        return APIManager
            .sharedInstance()
            .requestCollection(
                VideoRouter.HomeFeed(cursor: cursor!),
                success: collectionSuccessWithCompletion(success),
                failure: failure
        )
    }
    
    // MARK: - Instance Resource Methods
    
    // MARK: Create
    
    public func create(success: VideoResourceSuccess?, failure: FailureBlock?) -> APIRequest {
        return Video.create(NSDate.ISOStringFromDate(startDate), success: { video in
            self.mergeResultsFromObject(video)
            success?(self)
        }, failure: failure)
    }
    
    // MARK: Destroy
    
    public func destroy(success: VideoResourceSuccess?, failure: FailureBlock?) -> APIRequest {
        return Video.destroy(self.id!, success: {
            if success != nil {
                success!(self)
            }
        }, failure: failure)
    }
    
    // MARK: Hide
    
    public func hide(success: VideoResourceSuccess?, failure: FailureBlock?) -> APIRequest {
        return Video.hide(self.id!, success: {
            if success != nil {
                success!(self)
            }
        }, failure: failure)
    }
    
    // MARK: Update Caption
    
    public func updateCaption(caption: String, success: VideoResourceSuccess?, failure: FailureBlock?) -> APIRequest {
        self.caption = caption
        
        let successHandler: ResourceSuccess = { jsonResponse in
            var videoResponse = Video(json: jsonResponse)
            self.mergeResultsFromObject(videoResponse)
            
            Video.logger.debug("Successfully updated video \(self)")
            
            success?(self)
        }

        return APIManager
            .sharedInstance()
            .requestResource(
                VideoRouter.Update(id: self.id!, caption: caption),
                success: successHandler,
                failure: failure
        )
    }
}

// MARK: Video Resource Helpers

public extension Video {
    public func refreshComments(success: CommentCollectionSuccess?, failure: FailureBlock?) -> APIRequest {
        commentsCollection.reset()
        return getComments(commentsCursor, success: success, failure: failure)
    }
    
    public func loadMoreComments(success: CommentCollectionSuccess?, failure: FailureBlock?) -> APIRequest {
        return getComments(commentsCursor, success: success, failure: failure)
    }
    
    public func refreshLikes(success: LikeCollectionSuccess?, failure: FailureBlock?) -> APIRequest {
        likesCollection.reset()
        return getLikes(likesCursor, success: success, failure: failure)
    }
    
    public func loadMoreLikes(success: LikeCollectionSuccess?, failure: FailureBlock?) -> APIRequest {
        return getLikes(likesCursor, success: success, failure: failure)
    }
    
    public func createLike(success: LikeResourceSuccess?, failure: FailureBlock?) -> APIRequest {
        let like = Like(user: UserSession.currentUser()!, video: self)
        addLike(like)
        
        return like.create(success, failure: failure)
    }
    
    public func destroyLike(success: VoidBlock?, failure: FailureBlock?) -> APIRequest {
        return Like.destroy(self.id!, success: {
            // Delete the like from the collection
            for like in self.likes {
                if like.user == UserSession.currentUser()! {
                    self.deleteLike(like)
                    break
                }
            }
        }, failure: failure)
    }
}

// MARK: - Convenience

private extension Video {
    func getComments(cursor: Int, success: CommentCollectionSuccess?, failure: FailureBlock?) -> APIRequest {
        return Comment.getCommentsForVideo(self, cursor: cursor, success: { comments, nextCursor in
            self.commentsCollection.addObjects(comments)
            self.commentsCollection.cursor = nextCursor
            
            success?(comments, nextCursor)
            }, failure: { error in
                Video.logger.error("Failed to load more coments.\n\(error)")
                failure?(error)
        })
    }
    
    func getLikes(cursor: Int, success: LikeCollectionSuccess?, failure: FailureBlock?) -> APIRequest {
        return Like.getBackwardLikes(self, cursor: cursor, success: { likeResults, nextCursor in
            self.likesCollection.addObjects(likeResults)
            self.likesCollection.cursor = nextCursor
            
            success?(likeResults, nextCursor)
        }, failure: { error in
            Video.logger.error("Failed to load more likes.\n\(error)")
            failure?(error)
        })
    }
}

// MARK: - Serialization

private extension Video {
    class func resourceSuccessWithCompletion(completion: VideoResourceSuccess?) -> ResourceSuccess {
        return { jsonResponse in
            let video = Video(json: jsonResponse)
            completion?(video)
        }
    }
    
    class func collectionSuccessWithCompletion(completion: VideoCollectionSuccess?) -> CollectionSuccess {
        return { jsonArray, nextCursor in
            let videos = jsonArray.map { Video(json: $0) }
            
            if completion != nil {
                completion!(videos, nextCursor)
            }
        }
    }
}
