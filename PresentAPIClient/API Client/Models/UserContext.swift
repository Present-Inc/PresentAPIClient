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
import Alamofire

#if DEBUG
let PushNotificationPlatform = "APNS_SANDBOX"
#else
let PushNotificationPlatform = "APNS"
#endif

public class UserContext: Object {
    public var sessionToken: String!
    public var user: User!
    
    private struct PushNotificationCredentials {
        static var pushNotificationIdentifier: String? = nil
    }
    
    public class var pushNotificationIdentifier: String? {
        set {
            PushNotificationCredentials.pushNotificationIdentifier = newValue
        
            // If the user is logged in and the push notification identifier is not nil, update the current user context
            if newValue != nil && UserSession.currentSession() != nil {
                UserContext.updatePushNotificationIdentifier()
            }
        }
        get {
            return PushNotificationCredentials.pushNotificationIdentifier
        }
    }
    
    private class var logger: Logger {
        return self._logger("UserContext")
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
    
    public class func authenticate(username: String, password: String, success: UserContextResourceSuccess?, failure: FailureBlock?) -> APIRequest {
        let successHandler: ResourceSuccess = { jsonResponse in
            let currentUserContext = UserContext(json: jsonResponse["result"]["object"])
            success?(currentUserContext)
        }
        
        let requestConvertible: URLRequestConvertible = {
            if let pushNotificationIdentifier = PushNotificationCredentials.pushNotificationIdentifier {
                return UserContextRouter.AuthenticateWithPushCredentials(username: username, password: password, deviceId: pushNotificationIdentifier, platform: PushNotificationPlatform)
            } else {
                return UserContextRouter.Authenticate(username: username, password: password)
            }
        }()
        
        return APIManager
            .sharedInstance()
            .requestResource(
                requestConvertible,
                success: successHandler,
                failure: failure
        )
    }
    
    public class func updatePushNotificationIdentifier(success: UserContextResourceSuccess? = nil, failure: FailureBlock? = nil) -> APIRequest? {
        if let deviceIdentifier = self.pushNotificationIdentifier {
            let successHandler: ResourceSuccess = { jsonResponse in
                let currentUserContext = UserContext(json: jsonResponse["result"]["object"])
                success?(currentUserContext)
            }
            
            return APIManager
                .sharedInstance()
                .requestResource(
                    UserContextRouter.Update(deviceIdentifier: deviceIdentifier, platform: PushNotificationPlatform),
                    success: successHandler,
                    failure: failure
            )
        } else {
            return nil
        }
    }
    
    public class func logOut(completion: FailureBlock? = nil) -> APIRequest {
        let successHandler: ResourceSuccess = { _ in
            if completion != nil {
                completion!(nil)
            }
        },
        errorHandler: FailureBlock = { error in
            if completion != nil {
                completion!(error)
            }
        }
        
        return APIManager
            .sharedInstance()
            .requestResource(
                UserContextRouter.Destroy(),
                success: successHandler,
                failure: errorHandler
        )
    }
}
