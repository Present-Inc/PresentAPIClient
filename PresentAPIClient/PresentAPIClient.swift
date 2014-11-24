//
//  PresentAPIClient.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 10/17/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Foundation

internal struct APIEnvironment {
    // API version to use
    static let Version = "2014-09-09"
    
    // Version header key
    static let PresentVersionHeader = "Present-Version"
    
    // Session token header key
    static let SessionTokenHeader = "Present-User-Context-Session-Token"
    
    // User id header key
    static let UserIdHeader = "Present-User-Context-User-Id"
    
    // The base URL for all request
    static let baseUrl: NSURL = {
        var webProtocol: String = "https"
        var subdomain: String
        var version: String = "v1"
        
        #if DEVELOPMENT
            subdomain = "api-dev"
            webProtocol = "http"
        #elseif STAGING
            subdomain = "api-staging"
        #else
            subdomain = "api"
        #endif
        
        return NSURL(string: "\(webProtocol)://\(subdomain).present.tv/\(version)/")!
    }()
    
    // The push notification platform for the client
    static let PushNotificationPlatform: String = {
        #if DEVELOPMENT
            return "APNS_SANDBOX"
        #elseif STAGING
            return"APNS_SANDBOX"
        #else
            return "APNS"
        #endif
    }()
}
