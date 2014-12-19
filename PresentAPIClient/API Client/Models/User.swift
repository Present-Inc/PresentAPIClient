//
//  User.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit
import Accounts
import SwiftyJSON
import Swell
import Alamofire

public class User: Object, JSONSerializable {
    public private(set) var username: String!
    public private(set) var password: String?
    public private(set) var fullName: String = "No Name"
    public private(set) var email: String?
    public private(set) var userDescription: String = "No description yet."
    
    public private(set) var website: String?
    public private(set) var location: String?
    public private(set) var phoneNumber: String?
    
    public private(set) var friendCount: Int = 0
    public private(set) var followerCount: Int = 0
    public private(set) var viewCount: Int = 0
    public private(set) var likeCount: Int = 0
    public private(set) var videoCount: Int = 0
    
    public private(set) var isAdmin: Bool = false
    
    public private(set) var facebookData: SocialData = SocialData()
    public private(set) var twitterData: SocialData = SocialData()
    
    public var profileImageUrl: NSURL {
        return NSURL(string: self.profileImageUrlString)!
    }
    
    public var linkedWithFacebook: Bool {
        return facebookData.accessGranted
    }

    public var linkedWithTwitter: Bool {
        return twitterData.accessGranted
    }
    
    public var isCurrentUser: Bool {
        return self == UserSession.currentUser()
    }
    
    public var isFollowed: Bool {
        get {
            return UserSession.currentSession()?.getObjectMetaForObject(self)?.friendship?.forward ?? false
        }
        set {
            UserSession.currentSession()?.getObjectMetaForObject(self)?.friendship?.forward = newValue
        }
    }
    
    private var profileImageUrlString: String = "https://user-assets.present.tv/profile-pictures/default.png"
    private var subjectiveObjectMeta: SubjectiveObjectMeta!
    
    private class var logger: Logger {
        return User._logger("User")
    }

    public init(username: String, password: String, fullName: String, email: String, phoneNumber: String? = nil) {
        self.username = username
        self.password = password
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        
        super.init(id: "")
    }
    
    public required init(json: ObjectJSON) {
        super.init(json: json["object"])
        
        self.initializeWithObject(json["object"])
        
        if let objectId = self.id {
            self.subjectiveObjectMeta = SubjectiveObjectMeta(json: json["subjectiveObjectMeta"])
            UserSession.currentSession()?.storeObjectMeta(self.subjectiveObjectMeta, forKey: objectId)
        }
    }
    
    private func initializeWithObject(json: ObjectJSON) {
        if let admin = json["_isAdmin"].bool {
            self.isAdmin = admin
        }
        
        if let username = json["displayUsername"].string {
            self.username = username
        }
        
        if let fullName = json["profile"]["fullName"].string {
            self.fullName = fullName
        }
        
        if let numberOfFriends = json["friends"]["count"].int {
            self.friendCount = numberOfFriends
        }
        
        if let numberOfFollowers = json["followers"]["count"].int {
            self.followerCount = numberOfFollowers
        }
        
        if let numberOfLikes = json["likes"]["count"].int {
            self.likeCount = numberOfLikes
        }
        
        if let numberOfViews = json["views"]["count"].int {
            self.viewCount = numberOfViews
        }
        
        if let numberOfVideos = json["videos"]["count"].int {
            self.videoCount = numberOfVideos
        }
        
        if let profileImageString = json["profile"]["picture"]["url"].string {
            self.profileImageUrlString = profileImageString
        }
        
        if let description = json["profile"]["description"].string {
            self.userDescription = description
        }
        
        self.email = json["email"].string
        self.phoneNumber = json["phoneNumber"].string
        self.location = json["profile"]["location"].string
        self.website = json["profile"]["website"].string
        
        let facebookId: String? = json["externalServices"]["facebook"]["userId"].string
        let facebookUsername: String? = json["externalServices"]["facebook"]["username"].string
        
        if facebookId != nil && facebookUsername != nil {
            self.facebookData = SocialData(username: facebookUsername!, userId: facebookId!)
        }
        
        let twitterId: String? = json["externalServices"]["twitter"]["userId"].string
        let twitterUsername: String? = json["externalServices"]["twitter"]["username"].string
        
        if twitterId != nil && twitterUsername != nil {
            self.twitterData = SocialData(username: twitterUsername!, userId: twitterId!)
        }
    }
    
    public override init(coder aDecoder: NSCoder!) {
        username = aDecoder.decodeObjectForKey("username") as String
        fullName = aDecoder.decodeObjectForKey("fullName") as String
        email = aDecoder.decodeObjectForKey("email") as? String
        friendCount = aDecoder.decodeObjectForKey("friendCount") as Int
        followerCount = aDecoder.decodeObjectForKey("followerCount") as Int
        likeCount = aDecoder.decodeObjectForKey("likeCount") as Int
        viewCount = aDecoder.decodeObjectForKey("viewCount") as Int
        videoCount = aDecoder.decodeObjectForKey("videoCount") as Int
        location = aDecoder.decodeObjectForKey("location") as? String
        phoneNumber = aDecoder.decodeObjectForKey("phoneNumber") as? String
        website = aDecoder.decodeObjectForKey("website") as? String
        isAdmin = aDecoder.decodeBoolForKey("admin")
        
        if let facebook = aDecoder.decodeObjectForKey("facebookData") as? SocialData {
            facebookData = facebook
        }
        
        if let twitter = aDecoder.decodeObjectForKey("twitterData") as? SocialData {
            twitterData = twitter
        }
        
        if let description = aDecoder.decodeObjectForKey("userDescription") as? String {
            userDescription = description
        }
        
        if let urlString = aDecoder.decodeObjectForKey("profileImageUrlString") as? String {
            profileImageUrlString = urlString
        }
        
        super.init(coder: aDecoder)
    }
    
    public override func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(fullName, forKey: "fullName")
        
        if email != nil {
            aCoder.encodeObject(email!, forKey: "email")
        }
        
        if location != nil {
            aCoder.encodeObject(location!, forKey: "location")
        }
        
        if phoneNumber != nil {
            aCoder.encodeObject(phoneNumber!, forKey: "phoneNumber")
        }
        
        if website != nil {
            aCoder.encodeObject(website!, forKey: "website")
        }
        
        aCoder.encodeObject(friendCount, forKey: "friendCount")
        aCoder.encodeObject(followerCount, forKey: "followerCount")
        aCoder.encodeObject(likeCount, forKey: "likeCount")
        aCoder.encodeObject(viewCount, forKey: "viewCount")
        aCoder.encodeObject(videoCount, forKey: "videoCount")
        aCoder.encodeObject(profileImageUrlString, forKey: "profileImageUrlString")
        aCoder.encodeObject(userDescription, forKey: "userDescription")
        aCoder.encodeBool(isAdmin, forKey: "admin")
        
        if !facebookData.isEmpty {
            aCoder.encodeObject(facebookData, forKey: "facebookData")
        }
        
        if !twitterData.isEmpty {
            aCoder.encodeObject(twitterData, forKey: "twitterData")
        }
        
        super.encodeWithCoder(aCoder)
    }
    
    // MARK: Merge
    
    public override func mergeResultsFromObject(object: Object) {
        let user = object as User
        
        self.isAdmin = user.isAdmin
        
        if self.website != user.website && user.website != nil {
            self.website = user.website
        }
        
        if self.location != user.location {
            self.location = user.location
        }
        
        if self.fullName != user.fullName {
            self.fullName = user.fullName
        }
        
        if self.userDescription != user.userDescription {
            self.userDescription = user.userDescription
        }
        
        if self.profileImageUrlString != user.profileImageUrlString {
            self.profileImageUrlString = user.profileImageUrlString
        }
        
        if self.email != user.email && user.email != nil {
            self.email = user.email
        }
        
        if self.phoneNumber != user.phoneNumber {
            self.phoneNumber = user.phoneNumber
        }
        
        super.mergeResultsFromObject(object)
    }
}

public extension User {
    func updateFacebookAccount(account: ACAccount) {
        self.facebookData = SocialData(account: account)
        UserSession.currentSession()?.save()
    }
    
    func updateFacebookAccount(username: String, userId: String, accessToken: String, expirationDate: NSDate) {
        self.facebookData = SocialData(username: username, userId: userId, accessToken: accessToken, expirationDate: expirationDate)
        UserSession.currentSession()?.save()
    }
    
    func removeFacebookAccount() {
        self.facebookData.clear()
        UserSession.currentSession()?.save()
    }
    
    func updateTwitterAccount(account: ACAccount) {
        self.twitterData = SocialData(account: account)
        UserSession.currentSession()?.save()
    }
    
    func removeTwitterAccount() {
        self.twitterData.clear()
        UserSession.currentSession()?.save()
    }
}

public enum UserBatchSearchType: String {
    case FacebookIDs = "facebook_ids"
    case FacebookUsernames = "facebook_usernames"
    case TwitterIDs = "twitter_ids"
    case TwitterUsernames = "twitter_usernames"
    case Emails = "emails"
    case PhoneNumbers = "phone_numbers"
}

public extension User {
    
    class func getUserWithUsername(username: String, success: ((User) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return getUserWithParameters(username: username, success: success, failure: failure)
    }
    
    class func getUserWithId(id: String, success: ((User) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return getUserWithParameters(id: id, success: success, failure: failure)
    }
    
    // MARK: Search Users

    class func batchSearch(parameters: [UserBatchSearchType: [String]], cursor: Int? = 0, success: (([User], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        var requestParameters = [String: [String]]()
        for (key, value) in parameters {
            requestParameters[key.rawValue] = value
        }
        
        return APIManager
            .requestCollection(
                UserRouter.BatchSearch(parameters: requestParameters),
                success: success,
                failure: failure
        )
    }
    
    class func search(queryString: String, cursor: Int? = 0, success: (([User], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return APIManager
            .requestCollection(
                UserRouter.Search(query: queryString, cursor: cursor!),
                success: success,
                failure: failure
        )
    }
    
    // MARK: Password Reset
    
    class func requestPasswordReset(email: String, success: (() -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: (User) -> () = { _ in
            if success != nil {
                success!()
            }
        }
        
        return APIManager
            .requestResource(
                UserRouter.RequestPasswordReset(email: email),
                success: successHandler,
                failure: failure
            )
    }
    
    // MARK: Fetch User
    
    internal class func getCurrentUser(success: ((User) -> ())? = nil, failure: ((NSError?) -> ())? = nil) -> APIRequest {
        return APIManager
            .requestResource(
                UserRouter.CurrentUser(),
                success: success,
                failure: failure
            )
    }
    
    func fetch(success: ((User) -> ())? = nil, failure: ((NSError?) -> ())? = nil) -> APIRequest {
        return User.getUserWithId(self.id!, success: { user in
            self.mergeResultsFromObject(user)
            success?(user)
        }, failure: failure)
    }
    
    // MARK: Create
    
    func create(success: ((User) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: (User) -> () = { user in
            self.mergeResultsFromObject(user)
            success?(self)
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                UserRouter.Create(username: username, password: password!, email: email!),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Update
    
    func update(properties: [String: String], success: ((User) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: (User) -> () = { user in
            self.mergeResultsFromObject(user)
            success?(self)
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                UserRouter.Update(properties: properties),
                success: successHandler,
                failure: failure
        )
    }
    
    func updateProfilePicture(profilePicture: UIImage, success: (() -> ())?, failure: ((NSError?) -> ())?) {
        let imageData = UIImagePNGRepresentation(profilePicture)
        
        APIManager
            .sharedInstance()
            .multipartPost(
                "users/update_profile_picture",
                parameters: nil,
                data: imageData,
                name: "profile_picture",
                fileName: "profile_picture_\(self.id!).png",
                mimeType: "image/png",
                success: { responseData in
                    if let responseData: AnyObject = responseData {
                        let json = JSON(responseData)
                        let user = User(json: json["result"])
                        
                        self.mergeResultsFromObject(user)
                    }
                    
                    success?()
                },
                failure: failure
        )
    }
    
}

// MARK: Convenience Methods

public extension User {
    // MARK: Followers
    
    func getFollowers(cursor: Int? = 0, success: (([User], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return Friendship.getBackwardFriendships(self, cursor: cursor, success: { friendships, nextCursor in
            let followers = friendships.map { $0.sourceUser }
            success?(followers, nextCursor)
        }, failure: failure)
    }
    
    // MARK: Friends
    
    func getFriends(cursor: Int? = 0, success: (([User], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return Friendship.getForwardFriendships(self, cursor: cursor, success: { friendships, nextCursor in
            let friends = friendships.map { $0.targetUser }
            success?(friends, nextCursor)
        }, failure: failure)
    }
    
    // MARK: Likes
    
    func getLikes(cursor: Int? = 0, success: (([Video], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return Like.getForwardLikes(self, cursor: cursor, success: { likes, nextCursor in
            let likedVideos = likes.map { $0.video }
            success?(likedVideos, nextCursor)
        }, failure: failure)
    }
    
    // MARK: Videos
    
    func getVideos(cursor: Int? = 0, success: (([Video], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return Video.getVideosForUser(self, cursor: cursor, success: success, failure: failure)
    }
}

// MARK: Private Convenience

private extension User {
    class func getUserWithParameters(username: String? = nil, id: String? = nil, success: ((User) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let requestConvertible: URLRequestConvertible = {
            if username != nil {
                return UserRouter.UserForUsername(username: username!)
            } else {
                return UserRouter.UserForId(id: id!)
            }
        }()
        
        return APIManager
            .requestResource(
                requestConvertible,
                success: success,
                failure: failure
        )
    }
}
