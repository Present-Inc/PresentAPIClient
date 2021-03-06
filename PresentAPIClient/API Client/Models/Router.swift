//
//  Router.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 10/16/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import UIKit
import Alamofire

protocol PresetRouterProtocol {
    var method: Alamofire.Method { get }
    var resource: String { get }
    var path: String { get }
    var encoding: Alamofire.ParameterEncoding { get }
    var requestTuple: (path: String, parameters: [String: AnyObject]?) { get }
}

private func urlWithPath(path: String) -> NSURL {
    return APIEnvironment.baseUrl.URLByAppendingPathComponent(path)
}

// MARK: - Activity Router

enum ActivityRouter: URLRequestConvertible {
    case Activities(cursor: Int, limit: Int)
    case MarkAsRead(activityIds: [String])
    case Show(activityId: String)
    
    var method: Alamofire.Method {
        switch self {
        case .Activities, .Show:
            return .GET
        case .MarkAsRead:
            return .POST
        }
    }
    
    var encoding: Alamofire.ParameterEncoding {
        switch self {
        case .Activities, .Show:
            return .URL
        case .MarkAsRead:
            return .JSON
        }
    }
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .Activities(let cursor, let limit):
                return ("activities/list_my_activities", [
                    "cursor": cursor,
                    "limit": limit
                ])
            case .MarkAsRead(let activities):
                return ("activities/batch_update", [
                    "activity_ids": activities
                ])
            case .Show(let activityId):
                return ("activities/show", [
                    "activity_id": activityId
                ])
            }
        }()
            
        let URLRequest = NSMutableURLRequest(URL: urlWithPath(path))
        URLRequest.HTTPMethod = method.rawValue
            
        return self.encoding.encode(URLRequest, parameters: parameters).0
    }
}

// MARK: - Comment Router

enum CommentRouter: URLRequestConvertible {
    case Create(videoId: String, body: String)
    case Destroy(commentId: String)
    case Update(commentId: String, body: String)
    case CommentsForVideo(videoId: String, cursor: Int)
    case CommentForId(commentId: String)
    
    var method: Alamofire.Method {
        switch self {
        case .Create, .Destroy, .Update:
            return .POST
        case .CommentsForVideo, .CommentForId:
            return .GET
        }
    }
    
    var encoding: Alamofire.ParameterEncoding {
        switch self {
        case .Create, .Destroy, .Update:
            return .JSON
        case .CommentsForVideo, .CommentForId:
            return .URL
        }
    }
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .Create(let videoId, let body):
                return ("comments/create", [
                    "video_id": videoId,
                    "body": body
                ])
            case .Destroy(let commentId):
                return ("comments/destroy", [
                    "comment_id": commentId
                ])
            case .Update(let commentId, let body):
                return ("comments/update", [
                    "comment_id": commentId,
                    "body": body
                ])
            case .CommentsForVideo(let videoId, let cursor):
                return ("comments/list_video_comments", [
                    "video_id": videoId,
                    "cursor": cursor
                ])
            case .CommentForId(let commentId):
                return ("comments/show", [
                    "comment_id": commentId
                ])
            }
        }()
            
        let URLRequest = NSMutableURLRequest(URL: urlWithPath(path))
        URLRequest.HTTPMethod = method.rawValue
            
        return self.encoding.encode(URLRequest, parameters: parameters).0
    }
}

// MARK: - Friendship Router

enum FriendshipRouter: URLRequestConvertible {
    case ForwardFriendships(userId: String, cursor: Int)
    case BackwardFriendships(userId: String, cursor: Int)
    case Create(userId: String)
    case Destroy(userId: String)
    
    var method: Alamofire.Method {
        switch self {
        case .Create, .Destroy:
            return .POST
        case .ForwardFriendships, .BackwardFriendships:
            return .GET
        }
    }
    
    var encoding: Alamofire.ParameterEncoding {
        switch self {
        case .Create, .Destroy:
            return .JSON
        case .ForwardFriendships, .BackwardFriendships:
            return .URL
        }
    }
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .Create(let userId):
                return ("friendships/create", [
                    "user_id": userId
                ])
            case .Destroy(let userId):
                return ("friendships/destroy", [
                    "user_id": userId
                ])
            case .ForwardFriendships(let userId, let cursor):
                return ("friendships/list_user_forward_friendships", [
                    "user_id": userId,
                    "cursor": cursor
                ])
            case .BackwardFriendships(let userId, let cursor):
                return ("friendships/list_user_backward_friendships", [
                    "user_id": userId,
                    "cursor": cursor
                ])
            }
        }()
            
        let URLRequest = NSMutableURLRequest(URL: urlWithPath(path))
        URLRequest.HTTPMethod = method.rawValue
        
        return self.encoding.encode(URLRequest, parameters: parameters).0
    }
}

// MARK: - Like Router

enum LikeRouter: URLRequestConvertible {
    case Create(videoId: String)
    case Destroy(videoId: String)
    case ForwardLikes(userId: String, cursor: Int)
    case BackwardLikes(videoId: String, cursor: Int)
    
    var method: Alamofire.Method {
        switch self {
        case .Create, .Destroy:
            return .POST
        case .ForwardLikes, .BackwardLikes:
            return .GET
        }
    }
    
    var encoding: Alamofire.ParameterEncoding {
        switch self {
        case .Create, .Destroy:
            return .JSON
        case .ForwardLikes, .BackwardLikes:
            return .URL
        }
    }
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .Create(let videoId):
                return ("likes/create", [
                    "video_id": videoId
                ])
            case .Destroy(let videoId):
                return ("likes/destroy", [
                    "video_id": videoId
                ])
            case .ForwardLikes(let userId, let cursor):
                return ("likes/list_user_forward_likes", [
                    "user_id": userId,
                    "cursor": cursor
                ])
            case .BackwardLikes(let videoId, let cursor):
                return ("likes/list_video_backward_likes", [
                    "video_id": videoId,
                    "cursor": cursor
                ])
            }
        }()
            
        let URLRequest = NSMutableURLRequest(URL: urlWithPath(path))
        URLRequest.HTTPMethod = method.rawValue
        
        return self.encoding.encode(URLRequest, parameters: parameters).0
    }
}

// MARK: User Router

enum UserRouter: URLRequestConvertible {
    case Create(username: String, password: String, email: String)
    case Search(query: String, cursor: Int)
    case Update(properties: [String: AnyObject])
    case BatchSearch(parameters: [String: [String]])
    case CurrentUser()
    case UserForId(id: String)
    case UserForUsername(username: String)
    case RequestPasswordReset(email: String)
    
    var method: Alamofire.Method {
        switch self {
        case .Create, .Update, .BatchSearch, .RequestPasswordReset:
            return .POST
        case .UserForId, .UserForUsername, .Search, .CurrentUser():
            return .GET
        }
    }
    
    var encoding: Alamofire.ParameterEncoding {
        switch self {
        case .Create, .Update, .BatchSearch, .RequestPasswordReset:
            return .JSON
        case .UserForId, .UserForUsername, .Search, .CurrentUser():
            return .URL
        }
    }
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .Create(let username, let password, let email):
                return ("users/create", [
                    "username": username,
                    "password": password,
                    "email": email
                ])
            case .Update(let properties):
                return ("users/update", properties)
            case .Search(let query, let cursor):
                return ("users/search", [
                    "query": "username:*\(query)* OR username:\(query)* OR profile.fullName:*\(query)*",
                    "cursor": cursor
                ])
            case .BatchSearch(let batchSearchParameters):
                return ("users/batch_search", batchSearchParameters)
            case .UserForId(let id):
                return ("users/show", [
                    "user_id": id
                ])
            case .UserForUsername(let username):
                return ("users/show", [
                    "username": username
                ])
            case .RequestPasswordReset(let email):
                return ("users/request_password_reset", [
                    "username": email
                ])
            case .CurrentUser():
                return ("users/show_me", nil)
            }
        }()
            
        let URLRequest = NSMutableURLRequest(URL: urlWithPath(path))
        URLRequest.HTTPMethod = method.rawValue
            
        return self.encoding.encode(URLRequest, parameters: parameters).0
    }
}

// MARK: - User Context Router

enum UserContextRouter: URLRequestConvertible {
    case Authenticate(username: String, password: String)
    case AuthenticateWithPushCredentials(username: String, password: String, deviceId: String, platform: String)
    case Update(deviceIdentifier: String, platform: String)
    case Destroy()
    
    var method: Alamofire.Method {
        return .POST
    }
    
    var encoding: Alamofire.ParameterEncoding {
        return .JSON
    }
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .Authenticate(let username, let password):
                return ("user_contexts/create", [
                    "username": username,
                    "password": password
                ])
            case .AuthenticateWithPushCredentials(let username, let password, let deviceId, let platform):
                return ("user_contexts/create", [
                    "username": username,
                    "password": password,
                    "device_identifier": deviceId,
                    "push_notification_platform": platform
                ])
            case .Update(let deviceId, let platform):
                return ("user_contexts/update", [
                    "device_identifier": deviceId,
                    "push_notification_platform": platform
                ])
            case .Destroy():
                return ("user_contexts/destroy", nil)
            }
        }()
            
        let URLRequest = NSMutableURLRequest(URL: urlWithPath(path))
        URLRequest.HTTPMethod = method.rawValue
            
        return self.encoding.encode(URLRequest, parameters: parameters).0
    }
}

// MARK: - Video Router

enum VideoRouter: URLRequestConvertible {
    case Search(query: String, cursor: Int)
    case VideoForId(id: String)
    case VideosForUser(userId: String, cursor: Int)
    case HomeFeed(cursor: Int)
    case Create(startDateISOString: String, caption: String?)
    case Destroy(id: String)
    case Hide(id: String)
    case Update(id: String, caption: String)
    
    var method: Alamofire.Method {
        switch self {
        case .Search, .VideoForId, .HomeFeed, .VideosForUser:
            return .GET
        case .Create, .Destroy, .Hide, .Update:
            return .POST
        }
    }
    
    var encoding: Alamofire.ParameterEncoding {
        switch self {
        case .Search, .VideoForId, .HomeFeed, .VideosForUser:
            return .URL
        case .Create, .Destroy, .Hide, .Update:
            return .JSON
        }
    }
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .Search(let query, let cursor):
                return ("videos/search", [
                    "query": query,
                    "cursor": cursor
                ])
            case .VideoForId(let id):
                return ("videos/show", [
                    "video_id": id
                ])
            case .HomeFeed(let cursor):
                return ("videos/list_home_videos", [
                    "cursor": cursor
                ])
            case .Create(let startDate, var caption):
                var parameters = [
                    "creation_time_range_start_date": startDate
                ]
                
                if caption != nil {
                    parameters["title"] = caption
                }
                
                return ("videos/create", parameters)
            case .Destroy(let id):
                return ("videos/destroy", [
                    "video_id": id
                ])
            case .Hide(let id):
                return ("videos/hide", [
                    "video_id": id
                ])
            case .Update(let id, let caption):
                return ("videos/update", [
                    "video_id": id,
                    "title": caption
                ])
            case .VideosForUser(let userId, let cursor):
                return ("videos/list_user_videos", [
                    "user_id": userId,
                    "cursor": cursor
                ])
            }
        }()
            
        let URLRequest = NSMutableURLRequest(URL: urlWithPath(path))
        URLRequest.HTTPMethod = method.rawValue
        
        return self.encoding.encode(URLRequest, parameters: parameters).0
    }
}

// MARK: - View Router

enum ViewRouter: URLRequestConvertible {
    case Create(videoId: String)
    case Destroy(videoId: String)
    case ForwardViews(userId: String, cursor: Int)
    case BackwardViews(videoId: String, cursor: Int)
    
    var method: Alamofire.Method {
        switch self {
        case .Create, .Destroy:
            return .POST
        case .ForwardViews, .BackwardViews:
            return .GET
        }
    }
    
    var encoding: Alamofire.ParameterEncoding {
        switch self {
        case .Create, .Destroy:
            return .JSON
        case .ForwardViews, .BackwardViews:
            return .URL
        }
    }
    
    var URLRequest: NSURLRequest {
        let (path: String, parameters: [String: AnyObject]?) = {
            switch self {
            case .Create(let videoId):
                return ("views/create", [
                    "video_id": videoId
                ])
            case .Destroy(let videoId):
                return ("views/destroy", [
                    "video_id": videoId
                ])
            case .ForwardViews(let userId, let cursor):
                return ("views/list_user_forward_views", [
                    "user_id": userId,
                    "cursor": cursor
                ])
            case .BackwardViews(let videoId, let cursor):
                return ("views/list_video_backward_views", [
                    "video_id": videoId,
                    "cursor": cursor
                ])
            }
        }()
            
        let URLRequest = NSMutableURLRequest(URL: urlWithPath(path))
        URLRequest.HTTPMethod = method.rawValue
            
        return self.encoding.encode(URLRequest, parameters: parameters).0
    }
}
