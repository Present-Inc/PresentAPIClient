//
//  UserContext.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Swell

let PushNotificationPlatform = "APNS_SANDBOX"

public class UserContext: Object {
    override class var apiResourcePath: String { return "user_contexts" }
    
    public var sessionToken: String!
    public var user: User!
    
    private struct Static {
        static var pushNotificationIdentifier: String? = nil
    }

    class func _logger() -> Logger {
        return Swell.getLogger("UserContext")
    }
    
    public init(sessionToken: String, user: User) {
        self.sessionToken = sessionToken
        self.user = user
        
        super.init(id: "")
    }
    
    public override init(json: JSON) {
        if let token = json["sessionToken"].string {
            sessionToken = token
        }
        
        user = User(json: json["user"])
        
        super.init(json: json)
    }
    
    public override init(coder aDecoder: NSCoder!) {
        sessionToken = aDecoder.decodeObjectForKey("sessionToken") as String
        user = aDecoder.decodeObjectForKey("user") as User
        
        super.init(coder: aDecoder)
    }
    
    override public func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(sessionToken, forKey: "sessionToken")
        aCoder.encodeObject(user, forKey: "user")
        
        super.encodeWithCoder(aCoder)
    }
    
    public class func setPushNotificationDeviceIdentifier(deviceIdentifier: String) {
        Static.pushNotificationIdentifier = deviceIdentifier
    }
    
    public class func authenticate(username: String, password: String, success: ((UserContext) -> ())?, failure: FailureBlock?) {
        var authCredentials: [String: AnyObject] = [
            "username": username,
            "password": password,
            // This should be part of the DEBUG definition
            "push_notification_platform": PushNotificationPlatform
        ],
        successHandler: ResourceSuccessBlock = { jsonResponse in
            let currentUserContext = UserContext(json: jsonResponse["result"]["object"])
            success?(currentUserContext)
        }
        
        if let deviceIdentifier = Static.pushNotificationIdentifier {
            authCredentials["device_identifier"] = deviceIdentifier
        }
        
        APIManager
            .sharedInstance()
            .postResource(
                self.createResource(),
                parameters: authCredentials,
                success: successHandler,
                failure: failure
        )
    }
    
    public class func updatePushNotificationIdentifier(pushIdentifier: String, success: ((UserContext) -> ())? = nil, failure: FailureBlock? = nil) {
        self.setPushNotificationDeviceIdentifier(pushIdentifier)
        
        if UserSession.currentSession() != nil {
            var pushCredentials = [
                "device_identifier": pushIdentifier,
                "push_notification_platform": PushNotificationPlatform
            ],
            successHandler: ResourceSuccessBlock = { jsonResponse in
                let currentUserContext = UserContext(json: jsonResponse["result"]["object"])
                success?(currentUserContext)
            }
            
            APIManager
                .sharedInstance()
                .postResource(
                    self.updateResource(),
                    parameters: pushCredentials,
                    success: successHandler,
                    failure: failure
            )
        }
    }
    
    public class func logOut(completion: ((NSError?) -> ())? = nil) {
        var successHandler: ResourceSuccessBlock = { _ in
            if completion != nil {
                completion!(nil)
            }
        },
        errorHandler: FailureBlock = { error in
            if completion != nil {
                completion!(error)
            }
        }
        
        APIManager
            .sharedInstance()
            .postResource(
                self.destroyResource(),
                parameters: nil,
                success: successHandler,
                failure: errorHandler
        )
    }
}
