//
//  View.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 9/8/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

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
    // MARK: - Class Resource Methods
    
    // MARK: Create
    
    class func create(videoId: String, success: ViewResourceSuccess?, failure: FailureBlock?) -> Request {
        let successHandler: ResourceSuccess = { jsonResponse in
            UserSession.currentSession()?.getObjectMetaForKey(videoId).view?.forward = true
            
            let view = View(json: jsonResponse)
            success?(view)
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                ViewRouter.Create(videoId: videoId),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Destroy
    
    class func destroy(videoId: String, success: VoidBlock?, failure: FailureBlock?) -> Request {
        let successHandler: ResourceSuccess = { jsonResponse in
            UserSession.currentSession()?.getObjectMetaForKey(videoId).view?.forward = false
            
            if success != nil {
                success!()
            }
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                ViewRouter.Destroy(videoId: videoId),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Forward Views For User
    
    class func listForwardViewsForUser(user: User, cursor: Int? = 0, success: ViewCollectionSuccess?, failure: FailureBlock?) -> Request {
        let successHandler: CollectionSuccess = { jsonArray, nextCursor in
            let views = jsonArray.map { View(json: $0["object"]) }
            success?(views, nextCursor)
        }
        
        return APIManager
            .sharedInstance()
            .requestCollection(
                ViewRouter.ForwardViews(userId: user.id!, cursor: cursor!),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Backward Views For Video
    
    class func listBackwardViewsForVideo(video: Video, cursor: Int? = 0, success: ViewCollectionSuccess?, failure: FailureBlock?) -> Request {
        let successHandler: CollectionSuccess = { jsonArray, nextCursor in
            var views = jsonArray.map { View(json: $0["object"]) }
            success?(views, nextCursor)
        }
        
        return APIManager
            .sharedInstance()
            .requestCollection(
                ViewRouter.BackwardViews(videoId: video.id!, cursor: cursor!),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: - Instance Resource Methods
    
    // MARK: Create
    
    func create(success: ViewResourceSuccess?, failure: FailureBlock?) -> Request {
        return View.create(video.id!, success: { view in
            self.mergeResultsFromObject(view)
            success?(self)
        }, failure: failure)
    }
    
    // MARK: Destroy
    
    func destroy(success: ViewResourceSuccess?, failure: FailureBlock?) -> Request {
        return View.destroy(video.id!, success: {
            if success != nil {
                success!(self)
            }
        }, failure: failure)
    }
}
