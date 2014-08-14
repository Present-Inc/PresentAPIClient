//
//  Activity.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 8/13/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Foundation

public class Activity: Object {
    public var subject: String {
        return _subject
    }
    public var fromUser: User {
        return _fromUser
    }
    public var comment: Comment {
        return _comment
    }
    public var video: Video {
        return _video
    }
    
    private var _subject: String!
    private var _fromUser: User!
    private var _comment: Comment!
    private var _video: Video!
    
    private let logger = Activity._logger()
    
    public override init(json: JSONValue) {
        
        super.init(json: json)
    }
}

private extension Activity {
    class func _logger() -> Logger {
        return Swell.getLogger("Activity")
    }
}

public extension Activity {
    // MARK: Class Resource Methods
    
    // MARK: Instance Resource Methods
}
