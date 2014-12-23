//
//  Activity.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 8/13/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Foundation
import SwiftyJSON
import Swell
import Alamofire

public enum ActivityType: String {
    case NewComment = "newComment"
    case NewCommentMention = "newCommentMention"
    case NewFollower = "newFollower"
    case NewLike = "newLike"
    case NewVideoByFriend = "newVideoByFriend"
    case NewVideoMention = "newVideoMention"
    case NewViewer = "newViewer"
    case NewDemand = "newDemand"
    case Invalid = "invalid"

    public func isVideoType() -> Bool {
        return (self == .NewComment || self == .NewCommentMention || self == .NewVideoByFriend || self == .NewVideoMention || self == .NewLike)
    }
}

public class Activity: Object, JSONSerializable {
    public private(set) var subject: String = ""
    public private(set) var fromUser: User
    public private(set) var comment: Comment?
    public private(set) var video: Video?
    public private(set) var unread: Bool = false
    public private(set) var type: ActivityType = .Invalid
    
    private class var logger: Logger {
        return self._logger("Activity")
    }
    
    public required init(json: ObjectJSON) {
        if let isUnread = json["object"]["isUnread"].bool {
            self.unread = isUnread
        }
        
        if let subjectString = json["object"]["subject"].string {
            self.subject = subjectString
        }
        
        if let activityType = json["object"]["type"].string {
            self.type = ActivityType(rawValue: activityType) ?? .Invalid
        }
        
        self.fromUser = User(json: json["object"]["sourceUser"])
        self.video = Video(json: json["object"]["video"])
        
        super.init(json: json["object"])
    }
}

public extension Activity {
    // MARK: - Class Resource Methods
    
    public class func getActivities(cursor: Int? = 0, limit: Int? = 100, success: (([Activity], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return APIManager
            .requestCollection(
                ActivityRouter.Activities(cursor: cursor!, limit: limit!),
                success: success,
                failure: failure
        )
    }
    
    public class func markAsRead(activities: [Activity], success: (() -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let markAsRead = activities.filter { !$0.isNew }.map { $0.id! }
        let successHandler: ([Activity], Int) -> () = { _, _ in
            success?()
            return
        }
        
        return APIManager
            .requestCollection(
                ActivityRouter.MarkAsRead(activityIds: markAsRead),
                success: successHandler,
                failure: failure
        )
    }
    
    public class func show(activityId: String, success: ((Activity) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return APIManager
            .requestResource(
                ActivityRouter.Show(activityId: activityId),
                success: success,
                failure: failure
        )
    }
}
