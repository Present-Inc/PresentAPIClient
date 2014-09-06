//
//  User.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit

public class User: Object {
    override class var apiResourcePath: String { return "users" }
    
    private var _username: String!
    public var username: String! {
        return _username
    }
    
    public var password: String!
    public var fullName: String! = "No Name"
    public var email: String?
    
    private var profileImageUrlString: String!
    public var profileImageUrl: NSURL {
        return NSURL(string: self.profileImageUrlString)
    }
    
    public var userDescription: String = "No description yet."
    
    public var website: String?
    
    public var friendCount: Int = 0
    public var followerCount: Int = 0
    public var viewCount: Int = 0
    public var likeCount: Int = 0
    public var videoCount: Int = 0 /*{
        get {
            return videosCollection.count
        }
        set (newValue) {
            videosCollection.count = newValue
        }
    }*/
    
    public var videos: [Video] {
        return videosCollection.collection
    }
    
    public var videosCursor: Int {
        return videosCollection.cursor
    }
    
    private let logger = User._logger()
    private lazy var videosCollection = CursoredCollection<Video>()
    
    class func _logger() -> Logger {
        return Swell.getLogger("User")
    }

    public init(username: String, password: String, fullName: String, email: String) {
        self._username = username
        self.password = password
        self.fullName = fullName
        self.email = email
        
        super.init(id: "")
    }
    
    public override init(json: JSONValue) {
        super.init(json: json)
        
        if let username = json["displayUsername"].string {
            self._username = username
        }
        
        if let fullName = json["profile"]["fullName"].string {
            self.fullName = fullName
        }
        
        if let numberOfFriends = json["friends"]["count"].integer {
            self.friendCount = numberOfFriends
        }
        
        if let numberOfFollowers = json["followers"]["count"].integer {
            self.followerCount = numberOfFollowers
        }
        
        if let numberOfLikes = json["likes"]["count"].integer {
            self.likeCount = numberOfLikes
        }
        
        if let numberOfViews = json["views"]["count"].integer {
            self.viewCount = numberOfViews
        }
        
        if let numberOfVideos = json["videos"]["count"].integer {
            self.videoCount = numberOfVideos
        }
        
        if let profileImageString = json["profile"]["picture"]["url"].string {
            self.profileImageUrlString = profileImageString
        }
        
        if let description = json["profile"]["description"].string {
            self.userDescription = description
        }
    }
    
    public override init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        _username = aDecoder.decodeObjectForKey("username") as? String
        fullName = aDecoder.decodeObjectForKey("fullName") as? String
        email = aDecoder.decodeObjectForKey("email") as? String
        friendCount = aDecoder.decodeObjectForKey("friendCount") as Int
        followerCount = aDecoder.decodeObjectForKey("followerCount") as Int
        likeCount = aDecoder.decodeObjectForKey("likeCount") as Int
        viewCount = aDecoder.decodeObjectForKey("viewCount") as Int
        videoCount = aDecoder.decodeObjectForKey("videoCount") as Int
        
        if let description = aDecoder.decodeObjectForKey("userDescription") as? String {
            userDescription = description
        }
        
        if let urlString = aDecoder.decodeObjectForKey("profileImageUrlString") as? String {
            profileImageUrlString = urlString
        }
    }
    
    override public func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(_username, forKey: "username")
        aCoder.encodeObject(fullName, forKey: "fullName")
        
        if email != nil {
            aCoder.encodeObject(email!, forKey: "email")
        }
        
        aCoder.encodeObject(friendCount, forKey: "friendCount")
        aCoder.encodeObject(followerCount, forKey: "followerCount")
        aCoder.encodeObject(likeCount, forKey: "likeCount")
        aCoder.encodeObject(viewCount, forKey: "viewCount")
        aCoder.encodeObject(videoCount, forKey: "videoCount")
        aCoder.encodeObject(profileImageUrlString, forKey: "profileImageUrlString")
        aCoder.encodeObject(userDescription, forKey: "userDescription")
        
        super.encodeWithCoder(aCoder)
    }

    // MARK: Fetch Users
    
    public class func getTeam(success: (([User]) -> ())?, failure: FailureBlock?) {
        var successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
            println(jsonArray)
            var teamUsers: [User] = [User]()
            for jsonUser: JSONValue in jsonArray {
                let objectMeta = SubjectiveObjectMeta(json: jsonUser["subjectiveObjectMeta"]),
                    user = User(json: jsonUser["object"])
                
                UserSession.currentSession()?.storeObjectMeta(objectMeta, forObject: user)
                teamUsers.append(user)
            }
            
            success?(teamUsers)
        }
        
        APIManager
            .sharedInstance()
            .getCollection(
                self.pathForResource("list_team_users"),
                parameters: nil,
                success: successHandler,
                failure: failure
        )
    }
    
    public class func getUserWithUsername(username: String, success: ((User) -> ())?, failure: FailureBlock?) {
        self.getUserWithParameters(["username": username], success: success, failure: failure)
    }
    
    public class func getUserWithId(id: String, success: ((User) -> ())?, failure: FailureBlock?) {
        self.getUserWithParameters(["user_id": id], success: success, failure: failure)
    }
    
    private class func getUserWithParameters(parameters: [String: NSObject], success: ((User) -> ())?, failure: FailureBlock?) {
        var successHandler: ResourceSuccessBlock = { jsonResponse in
            let objectMeta = SubjectiveObjectMeta(json: jsonResponse["result"]["subjectiveObjectMeta"]),
                user = User(json: jsonResponse["result"]["object"])
            
            UserSession.currentSession()?.storeObjectMeta(objectMeta, forObject: user)
            
            success?(user)
        }
        
        APIManager
            .sharedInstance()
            .getResource(
                self.showResource(),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Search Users
    
    public class func search(queryString: String, cursor: Int? = 0, success: (([User], Int) -> ())?, failure: FailureBlock?) {
        var parameters = [
            "query": queryString as NSString,
            "cursor": cursor!
        ],
        successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
            self._logger().debug("JSON Array results: \(jsonArray)")
            
            var userResults = jsonArray.map { User(json: $0["object"]) }
            success?(userResults, nextCursor)
        }
        
        self._logger().debug("Searching for page \(cursor) of \"\(queryString)\" results")
        println("Searching for page \(cursor) of \"\(queryString)\" results")
        
        APIManager
            .sharedInstance()
            .getCollection(
                self.searchResource(),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    public func create(success: ((User) -> ())?, failure: FailureBlock?) {
        if !self.id.isEmpty {
            failure?(nil)
        }
        
        var parameters = [
            "username": self.username as NSString,
            "password": self.password as NSString,
        ],
        successHandler: ResourceSuccessBlock = { jsonResponse in
            self.logger.debug("Successfully created user")
            
            var user = User(json: jsonResponse["object"])
            self.mergeResultsFromObject(user)
            success?(self)
        }
        
        if let email = self.email {
            parameters["email"] = email as NSString
        }
        
        APIManager
            .sharedInstance()
            .postResource(
                User.createResource(),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Friendships
    
    public func getFollowers(success: (([User], Int) -> ())?, failure: FailureBlock?) {
        // TODO: Use the Friendships.getBackwardFriendships() method
    }
    
    public func getFriends(success: (([User], Int) -> ())?, failure: FailureBlock?) {
        // TODO: Use the Friendships.getForwardFriendships() method
    }
    
    // MARK: Likes
    
    public func getLikes(success: (([Like], Int) -> ())?, failure: FailureBlock?) {
        // TODO: Use the Likes.getLikesForUser() method
        //Like.getForwardLikes(self, cursor: self.likesCursor, success: <#(([Like], Int) -> ())?##([Like], Int) -> ()#>, failure: <#FailureBlock?##(NSError?) -> ()#>)
    }
    
    // MARK: Videos
    
    public func getVideos(success: (([Video], Int) -> ())?, failure: FailureBlock?) {
        Video.getVideosForUser(self, cursor: self.videosCursor, success: { videos, nextCursor in
            self.videosCollection.addObjects(videos)
            self.videosCollection.cursor = nextCursor
            
            success?(videos, nextCursor)
            }, failure: { error in
                self.logger.error("Failed to get videos for user: \(self)")
                failure?(error)
            })
    }

}
