//
//  PushNotification.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 11/3/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Foundation

public class PushNotification: NSObject {
    public let alert: String?
    public let contentAvailable: Int?
    public let badge: Int?
    public let activityId: String?
    public let type: ActivityType?
    
    public init(dictionary: [NSObject: AnyObject]) {
        if let aps = dictionary["aps"] as? [NSObject: AnyObject] {
            alert = aps["alert"] as? String
            contentAvailable = aps["contentAvailable"] as? Int
            badge = aps["badge"] as? Int
        }
        
        activityId = dictionary["_id"] as? String
        
        if let rawType = dictionary["type"] as? String {
            type = ActivityType(rawValue: rawType)
        } else {
            type = .Invalid
        }
    }
}
