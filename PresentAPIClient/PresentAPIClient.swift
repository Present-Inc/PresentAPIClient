//
//  PresentAPIClient.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 10/17/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct APIEnvironment {
    static let Version = "2014-09-09"
    static let PresentVersionHeader = "Present-Version"
    static let SessionTokenHeader = "Present-User-Context-Session-Token"
    static let UserIdHeader = "Present-User-Context-User-Id"
    
    static let baseUrl: NSURL = {
        var subdomain: String
        var version: String = "v1"
        
        #if DEVELOPMENT
            subdomain = "api-dev"
        #elseif STAGING
            subdomain = "api-staging"
        #else
            subdomain = "api"
        #endif
        
        return NSURL(string: "https://\(subdomain).present.tv/\(version)/")!
    }()
}
