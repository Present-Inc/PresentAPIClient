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

public typealias VideoResourceSuccessBlock = (Video) -> ()
public typealias VideoCollectionSuccessBlock = ([Video], Int) -> ()

public class Video: Object {
    public var caption: String?
    
    public var startDate: NSDate {
        return _startDate
    }
    
    public var endDate: NSDate? {
        return _endDate
    }
    
    public var isLive: Bool {
        return _endDate == nil
    }
    
    public var watchUrl: NSURL {
        if isLive {
            return _liveUrl
        } else {
            return _replayUrl
        }
    }
    
    public var coverUrl: NSURL! {
        return _coverUrl
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
    
    public var creator: User {
        return _creator
    }
    
    public var isViewed: Bool {
        return subjectiveObjectMeta.view?.forward ?? false
    }
    
    public var isLiked: Bool {
        return subjectiveObjectMeta.like?.forward ?? false
    }
    
    private var _creator: User!
    
    private var _startDate: NSDate!
    private var _endDate: NSDate?
    
    private var _liveUrl: NSURL!
    private var _replayUrl: NSURL!
    
    private var _coverUrl: NSURL!
    
    private var subjectiveObjectMeta: SubjectiveObjectMeta!
    
    private var commentsCollection: CursoredCollection<Comment> = CursoredCollection<Comment>()
    private var likesCollection: CursoredCollection<Like> = CursoredCollection<Like>()
    
    private let logger = Video._logger()
    
    public override init() {
        super.init()
    }
    
    public init(creator: User, caption: String? = nil) {
        self._creator = creator
        self.caption = caption
        
        super.init()
    }
    
    public override init(id: String) {
        super.init(id: id)
    }
    
    public override init(json: JSON) {
        super.init(json: json["object"])
        
        self.initializeWithObject(json["object"])

        self.subjectiveObjectMeta = SubjectiveObjectMeta(json: json["subjectiveObjectMeta"])
        //UserSession.currentSession()?.storeObjectMeta(objectMeta, forObject: self)
    }
    
    private func initializeWithObject(json: JSON) {
        if let caption = json["title"].string {
            self.caption = caption
        }
        
        if let startDateString = json["creationTimeRange"]["startDate"].string {
            _startDate = NSDate.dateFromISOString(startDateString)
        }
        
        if let endDateString = json["creationTimeRange"]["endDate"].string {
            _endDate = NSDate.dateFromISOString(endDateString)
        }
        
        if let liveString = json["mediaUrls"]["playlists"]["live"]["master"].string {
            _liveUrl = NSURL(string: liveString)
        }
        
        if let replayString = json["mediaUrls"]["playlists"]["replay"]["master"].string {
            _replayUrl = NSURL(string: replayString)
        }
        
        // !!!: This is not a long-term solution. Prone to change.
        if let coverString = json["mediaUrls"]["images"]["480px"].string {
            _coverUrl = NSURL(string: coverString)
        }
        
        _creator = User(json: json["creatorUser"])
        
        if let mostRecentLikes = json["likes"]["results"].array {
            for jsonLike: JSON in mostRecentLikes {
                var like = Like(json: jsonLike["object"])
                like._video = self
                
                self.likesCollection.addObject(like)
            }
        }
        
        if let likeCount = json["likes"]["count"].int {
            self.likesCollection.cursor = likeCount
        }
        
        if let mostRecentComments = json["comments"]["results"].array {
            for jsonComment: JSON in mostRecentComments {
                var comment = Comment(json: jsonComment["object"])
                comment.video = self
                
                self.commentsCollection.addObject(comment)
            }
        }
        
        if let commentCount = json["comments"]["count"].int {
            self.commentsCollection.count = commentCount
        }
    }
    
    public func start() {
        _startDate = NSDate()
    }
    
    public func end() {
        _endDate = NSDate()
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
        var video = object as Video
        
        caption = video.caption
        
        super.mergeResultsFromObject(object)
    }
}

private extension Video {
    class func _logger() -> Logger {
        return Swell.getLogger("Video")
    }
}

public extension Video {
    // MARK: - Class Resource Methods

    // MARK: Create
    
    public class func create(startDateISOString: String, success: VideoResourceSuccessBlock?, failure: FailureBlock?) -> Request {
        let successHandler: ResourceSuccessBlock = { jsonResponse in
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
    
    public class func destroy(videoId: String, success: VoidBlock?, failure: FailureBlock?) -> Request {
        let successHandler: ResourceSuccessBlock = { jsonResponse in
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
    
    public class func hide(videoId: String, success: VoidBlock?, failure: FailureBlock?) -> Request {
        let successHandler: ResourceSuccessBlock = { jsonResponse in
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
    
    // MARK: Append Segments
    
    public class func append(videoId: String, segmentUrl: NSURL, mediaSequence: Int, success: VideoResourceSuccessBlock?, failure: FailureBlock?) {
        var parameters = [
            "video_id": videoId as NSString,
            "media_sequence": mediaSequence
        ]

        APIManager
            .sharedInstance()
            .multipartPost(
                segmentUrl,
                resource: "videos/append",
                parameters: parameters,
                success: resourceSuccessWithCompletion(success),
                failure: failure
            )

    }
    
    // MARK: Search Videos

    public class func search(queryString: String, cursor: Int? = 0, success: VideoCollectionSuccessBlock?, failure: FailureBlock?) -> Request {
        return APIManager
            .sharedInstance()
            .requestCollection(
                VideoRouter.Search(query: queryString, cursor: cursor!),
                success: collectionSuccessWithCompletion(success),
                failure: failure
        )
    }
    
    // MARK: Fetch Videos
    
    public class func getVideoWithId(id: String, success: VideoResourceSuccessBlock?, failure: FailureBlock?) -> Request {
        return APIManager
            .sharedInstance()
            .requestResource(
                VideoRouter.VideoForId(id: id),
                success: resourceSuccessWithCompletion(success),
                failure: failure
        )
    }
    
    // MARK: List Videos
    
    public class func getVideosForUser(user: User, cursor: Int? = 0, success: VideoCollectionSuccessBlock?, failure: FailureBlock?) -> Request {
        return APIManager
            .sharedInstance()
            .requestCollection(
                VideoRouter.VideosForUser(userId: user.id!, cursor: cursor!),
                success: collectionSuccessWithCompletion(success),
                failure: failure
        )
    }
    
    public class func getHomeVideos(cursor: Int? = 0, success: VideoCollectionSuccessBlock?, failure: FailureBlock?) -> Request {
        return APIManager
            .sharedInstance()
            .requestCollection(
                VideoRouter.HomeFeed(cursor: cursor!),
                success: collectionSuccessWithCompletion(success),
                failure: failure
        )
    }
    
    // MARK: Instance Resource Methods
    
    public func create(success: VideoResourceSuccessBlock?, failure: FailureBlock?) -> Request {
        return Video.create(NSDate.ISOStringFromDate(startDate), success: { video in
            self.mergeResultsFromObject(video)
            self.logger.debug("Successfully created video \(self)")
            
            success?(self)
        }, failure: failure)
    }
    
    public func destroy(success: VideoResourceSuccessBlock?, failure: FailureBlock?) -> Request {
        return Video.destroy(self.id!, success: {
            if success != nil {
                success!(self)
            }
        }, failure: failure)
    }
    
    public func hide(success: VideoResourceSuccessBlock?, failure: FailureBlock?) -> Request {
        return Video.hide(self.id!, success: {
            if success != nil {
                success!(self)
            }
        }, failure: failure)
    }
    
    public func updateCaption(caption: String, success: VideoResourceSuccessBlock?, failure: FailureBlock?) -> Request {
        self.caption = caption
        
        let successHandler: ResourceSuccessBlock = { jsonResponse in
            var videoResponse = Video(json: jsonResponse)
            self.mergeResultsFromObject(videoResponse)
            
            self.logger.debug("Successfully updated video \(self)")
            
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
    public func refreshComments(success: (([Comment], Int) -> ())?, failure: FailureBlock?) {
        self.commentsCollection.reset()
        self.getComments(self.commentsCursor, success: success, failure: failure)
    }
    
    public func loadMoreComments(success: (([Comment], Int) -> ())?, failure: FailureBlock?) {
        self.getComments(self.commentsCursor, success: success, failure: failure)
    }
    
    private func getComments(cursor: Int, success: (([Comment], Int) -> ())?, failure: FailureBlock?) {
        Comment.getCommentsForVideo(self, cursor: cursor, success: { commentResults, nextCursor in
            self.commentsCollection.addObjects(commentResults)
            self.commentsCollection.cursor = nextCursor
            
            success?(commentResults, nextCursor)
            }, failure: { error in
                self.logger.error("\(self) failed to load more from the comments collection. Error: \(error)")
                failure?(error)
        })
    }
    
    public func refreshLikes(success: (([Like], Int) -> ())?, failure: FailureBlock?) {
        self.likesCollection.reset()
        self.getLikes(self.likesCursor, success: success, failure: failure)
    }
    
    public func loadMoreLikes(success: (([Like], Int) -> ())?, failure: FailureBlock?) {
        self.getLikes(self.likesCursor, success: success, failure: failure)
    }
    
    private func getLikes(cursor: Int, success: (([Like], Int) -> ())?, failure: FailureBlock?) {
        Like.getBackwardLikes(self, cursor: cursor, success: { likeResults, nextCursor in
            self.likesCollection.addObjects(likeResults)
            self.likesCollection.cursor = nextCursor
            
            success?(likeResults, nextCursor)
            }, failure: { error in
                self.logger.error("\(self) failed to load more from the likes collection. Error \(error)")
                failure?(error)
            })
    }
    
    public func createLike(success: ((Like) -> ())?, failure: FailureBlock?) {
        var like = Like(user: UserSession.currentUser()!, video: self)
        like.create(success, failure: failure)
        
        self.addLike(like)
    }
    
    public func destroyLike(success: (() -> ())?, failure: FailureBlock?) {
        Like.destroyLikeForVideo(self, success: success, failure: failure)
        
        for like in likes {
            if like.user == UserSession.currentUser()! {
                self.deleteLike(like)
                break
            }
        }
    }
}

private extension Video {
    class func resourceSuccessWithCompletion(completion: ((Video) -> ())?) -> ResourceSuccessBlock {
        return { jsonResponse in
            var video = Video(json: jsonResponse)
            completion?(video)
        }
    }
    
    class func collectionSuccessWithCompletion(completion: (([Video], Int) -> ())?) -> CollectionSuccessBlock {
        return { jsonArray, nextCursor in
            var videos = jsonArray.map { Video(json: $0) }
            completion?(videos, nextCursor)
        }
    }
}
