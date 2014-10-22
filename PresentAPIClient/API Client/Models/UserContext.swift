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
    
    public required init(json: JSON) {
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
    
    public class func authenticate(username: String, password: String, success: ((UserContext) -> ())?, failure: ((NSError?) -> ())?) -> APIRequest {
        let requestConvertible: URLRequestConvertible = {
            if let pushNotificationIdentifier = PushNotificationCredentials.pushNotificationIdentifier {
                return UserContextRouter.AuthenticateWithPushCredentials(username: username, password: password, deviceId: pushNotificationIdentifier, platform: PushNotificationPlatform)
            } else {
                return UserContextRouter.Authenticate(username: username, password: password)
            }
        }()
        
        return APIManager
            .requestResource(
                requestConvertible,
                type: UserContext.self,
                success: success,
                failure: failure
        )
    }
    
    public class func updatePushNotificationIdentifier(success: ((UserContext) -> ())? = nil, failure: ((NSError?) -> ())? = nil) -> APIRequest? {
        if let deviceIdentifier = self.pushNotificationIdentifier {
            return APIManager
                .requestResource(
                    UserContextRouter.Update(deviceIdentifier: deviceIdentifier, platform: PushNotificationPlatform),
                    type: UserContext.self,
                    success: success,
                    failure: failure
            )
        } else {
            return nil
        }
    }
    
    public class func logOut(completion: ((NSError?) -> ())? = nil) -> APIRequest {
        let successHandler: (UserContext) -> () = { _ in
            if completion != nil {
                completion!(nil)
            }
        },
        errorHandler: (NSError?) -> () = { error in
            if completion != nil {
                completion!(error)
            }
        }
        
        return APIManager
            .requestResource(
                UserContextRouter.Destroy(),
                type: UserContext.self,
                success: successHandler,
                failure: errorHandler
        )
    }
}
