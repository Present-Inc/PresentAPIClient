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

public class View: Object, JSONSerializable {
    let user: User
    let video: Video
    
    public convenience init(video: Video) {
        self.init(user: UserSession.currentUser()!, video: video)
    }
    
    public init(user: User, video: Video) {
        self.user = user
        self.video = video
        
        super.init()
    }
    
    public required init(json: ObjectJSON) {
        self.user = User(json: json["object"]["sourceUser"])
        self.video = Video(json: json["object"]["targetVideo"])
        
        super.init(json: json["object"])
    }
}

public extension View {
    // MARK: - Class Resource Methods
    
    // MARK: Create
    
    class func create(videoId: String, success: ((View) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: (View) -> () = { view in
            if let viewRelation = UserSession.currentSession()?.getObjectMetaForKey(videoId).view {
                viewRelation.forward = true
            } else {
                let viewRelation = Relation(forward: true, backward: false)
                UserSession.currentSession()?.storeView(viewRelation, forKey: videoId)
            }
            
            
            success?(view)
        }
        
        return APIManager
            .requestResource(
                ViewRouter.Create(videoId: videoId),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Destroy
    
    class func destroy(videoId: String, success: (() -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let successHandler: (View) -> () = { view in
            if let viewRelation = UserSession.currentSession()?.getObjectMetaForKey(videoId).view {
                viewRelation.forward = false
            } else {
                let viewRelation = Relation(forward: false, backward: false)
                UserSession.currentSession()?.storeView(viewRelation, forKey: videoId)
            }
            
            success?()
        }
        
        return APIManager
            .requestResource(
                ViewRouter.Destroy(videoId: videoId),
                success: successHandler,
                failure: failure
        )
    }
    
    // MARK: Forward Views For User
    
    class func listForwardViewsForUser(user: User, cursor: Int? = 0, success: (([View], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return APIManager
            .requestCollection(
                ViewRouter.ForwardViews(userId: user.id!, cursor: cursor!),
                success: success,
                failure: failure
        )
    }
    
    // MARK: Backward Views For Video
    
    class func listBackwardViewsForVideo(video: Video, cursor: Int? = 0, success: (([View], Int) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return APIManager
            .requestCollection(
                ViewRouter.BackwardViews(videoId: video.id!, cursor: cursor!),
                success: success,
                failure: failure
        )
    }
    
    // MARK: - Instance Resource Methods
    
    // MARK: Create
    
    func create(success: ((View) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return View.create(video.id!, success: { view in
            self.mergeResultsFromObject(view)
            success?(self)
        }, failure: failure)
    }
    
    // MARK: Destroy
    
    func destroy(success: ((View) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        return View.destroy(video.id!, success: {
            if success != nil {
                success!(self)
            }
        }, failure: failure)
    }
}
