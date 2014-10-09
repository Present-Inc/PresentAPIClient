//
//  SocialData.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 10/1/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Accounts

public class SocialData: NSObject, NSCoding {
    /**
        Will only be present on the current user
     */
    public var accessGranted: Bool = false
    
    /**
        Will only be present on the current user
     */
    public var accountIdentifier: String?
    
    public var userId: String?
    public var username: String?
    
    public var isEmpty: Bool {
        return accountIdentifier == nil && userId == nil && username == nil
    }
    
    public override var description: String {
        return "<PresentAPIClient.SocialData> {\n\taccessGranted: \(accessGranted)\n\taccountIdentifier: \(accountIdentifier)\n\tuserId: \(userId)\n\tusername:\(username)\n}"
    }
    
    public override init() {
        super.init()
    }
    
    public init(account: ACAccount) {
        let accountProperties = account.valueForKey("properties") as NSDictionary
        
        if account.accountType.identifier == ACAccountTypeIdentifierTwitter {
            self.userId = accountProperties["user_id"] as? String
        } else if account.accountType.identifier == ACAccountTypeIdentifierFacebook {
            self.userId = accountProperties["uid"] as? String
        }
        
        self.username = account.username
        self.accountIdentifier = account.identifier
        self.accessGranted = true
    }
    
    public required init(coder aDecoder: NSCoder) {
        accessGranted = aDecoder.decodeBoolForKey("accessGranted")
        
        if let identifier = aDecoder.decodeObjectForKey("accountIdentifier") as? String {
            self.accountIdentifier = identifier
        }
        
        if let userId = aDecoder.decodeObjectForKey("userId") as? String {
            self.userId = userId
        }
        
        if let username = aDecoder.decodeObjectForKey("username") as? String {
            self.username = username
        }
    }
    
    public func clear() {
        self.userId = nil
        self.username = nil
        self.accountIdentifier = nil
        
        self.accessGranted = false
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeBool(accessGranted, forKey: "accessGranted")
        
        if self.accountIdentifier != nil {
            aCoder.encodeObject(accountIdentifier!, forKey: "accountIdentifier")
        }
        
        if self.userId != nil {
            aCoder.encodeObject(userId!, forKey: "userId")
        }
        
        if self.username != nil {
            aCoder.encodeObject(username!, forKey: "username")
        }
    }
}
