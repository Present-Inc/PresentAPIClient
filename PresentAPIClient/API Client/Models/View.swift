//
//  View.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 9/8/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import UIKit
import SwiftyJSON

public class View: Object {
    var user: User
    var video: Video
    
    init(user: User, video: Video) {
        self.user = user
        self.video = video
        
        super.init()
    }
    
    override init(json: JSON) {
        self.user = User(json: json["sourceUser"])
        self.video = Video(json: json["targetVideo"])
        
        super.init(json: json)
    }
}

public extension View {
    class func listForwardViewsForUser(user: User, cursor: Int = 0, success: (([View], Int) -> ())?, failure: FailureBlock?) {
        let parameters = [
            "cursor": cursor,
            "user_id": user.id as NSString
        ],
        successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
            var views = jsonArray.map { View(json: $0["object"]) }
            success?(views, nextCursor)
        }
        
        APIManager
            .sharedInstance()
            .getCollection(
                View.pathForResource("list_user_forward_views"),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    class func listBackwardViewsForVideo(video: Video, cursor: Int = 0, success: (([View], Int) -> ())?, failure: FailureBlock?) {
        let parameters = [
            "cursor": cursor,
            "video_id": video.id as NSString
        ],
        successHandler: CollectionSuccessBlock = { jsonArray, nextCursor in
            var views = jsonArray.map { View(json: $0["object"]) }
            success?(views, nextCursor)
        }
        
        APIManager
            .sharedInstance()
            .getCollection(
                View.pathForResource("list_video_backward_views"),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    func create(success: ((View) -> ())?, failure: FailureBlock?) {
        let parameters = [
            "video_id": video.id
        ],
        successHandler: ResourceSuccessBlock = { jsonResponse in
            var view = View(json: jsonResponse)
            self.mergeResultsFromObject(view)
            
            success?(self)
        }
        
        APIManager
            .sharedInstance()
            .postResource(
                View.createResource(),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
    
    func destroy(success: ((View) -> ())?, failure: FailureBlock?) {
        let parameters = [
            "video_id": self.video.id as NSString
        ],
        successHandler: ResourceSuccessBlock = { jsonResponse in
            if success != nil {
                success?(self)
            }
        }
        
        APIManager
            .sharedInstance()
            .postResource(
                View.destroyResource(),
                parameters: parameters,
                success: successHandler,
                failure: failure
        )
    }
}
