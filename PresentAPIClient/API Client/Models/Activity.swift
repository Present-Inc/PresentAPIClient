//
//  Activity.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 8/13/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Foundation

public enum ActivityType: String {
    case NewComment = "newComment"
    case NewCommentMention = "newCommentMention"
    case NewFollower = "newFollower"
    case NewLike = "newLike"
    case NewVideoByFriend = "newVideoByFriend"
    case NewVideoMention = "newVideoMention"
    case NewViewer = "newViewer"
}

public class Activity: Object {
    override class var apiResourcePath: String { return "activities" }
    
    public var subject: String {
        return _subject
    }
    public var fromUser: User {
        return _fromUser
    }
    public var comment: Comment {
        return _comment
    }
    public var video: Video {
        return _video
    }
    public var unread: Bool {
        return _unread
    }
    public var type: ActivityType {
        return _type
    }
    
    private var _subject: String!
    private var _fromUser: User!
    private var _comment: Comment!
    private var _video: Video!
    private var _unread: Bool!
    private var _type: ActivityType!
    
    private let logger = Activity._logger()
    
    public override init(json: JSONValue) {
        if let isUnread = json["isUnread"].bool {
            _unread = isUnread
        }
        
        if let subjectString = json["subject"].string {
            _subject = subjectString
        }
        
        if let activityType = json["type"].string {
            _type = ActivityType.fromRaw(activityType)
        }
        
        _fromUser = User(json: json["sourceUser"]["object"])
        _video = Video(json: json["video"]["object"])
        //_comment = Comment(json: ["comment"]["object"])
        
        super.init(json: json)
    }
}

private extension Activity {
    class func _logger() -> Logger {
        return Swell.getLogger("Activity")
    }
}

public extension Activity {
    // MARK: Class Resource Methods
    
    class func getActivities(cursor: Int? = 0, success: (([Activity], Int) -> ())?, failure: FailureBlock?) {
        var parameters = [
            "cursor": cursor!
        ],
        successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
            var activities = [Activity]()
            for jsonActivity in jsonArray {
                var activity = Activity(json: jsonActivity["object"])
                activities.append(activity)
            }
            
            println("Serialized data")
            
            success?(activities, nextCursor)
        }
        
        APIManager
            .sharedInstance()
            .getCollection(
                self.pathForResource("list_my_activities"),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    class func markAsRead(activities: [Activity], success: ((AnyObject) -> ())?, failure: FailureBlock?) {
        var markAsRead = [String]()
        for activity in activities {
            markAsRead.append(activity.id)
        }
        
        var parameters = [
            "activity_ids": markAsRead
        ],
        successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
            println("Successfully updated activities")
            success?(1)
        }
        
        APIManager
            .sharedInstance()
            .postCollection(
                self.pathForResource("batch_update"),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
}
