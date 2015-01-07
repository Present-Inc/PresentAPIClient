//
//  SocialData.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 10/1/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Accounts

/**
    A class to represent a user's linked social accounts
 */
public class SocialData: NSObject, NSCoding {
    public private(set) var accessGranted: Bool = false
    
    public private(set) var accountIdentifier: String?
    
    public private(set) var accessToken: String?
    public private(set) var expirationDate: NSDate?
    
    public private(set) var userId: String?
    public private(set) var username: String?
    
    public var isEmpty: Bool {
        return ((accountIdentifier == nil || accessToken == nil) && userId == nil && username == nil)
    }
    
    public override var description: String {
        return "<PresentAPIClient.SocialData> {\n\taccessGranted: \(accessGranted)\n\taccountIdentifier: \(accountIdentifier)\n\tuserId: \(userId)\n\tusername:\(username)\n}"
    }
    
    public override init() {
        super.init()
    }
    
    /**
        Initializes `SocialData` with `account`
     */
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
    
    /**
        Initializes `SocialData` with an username, user id, an oAuth access token, and and expiration date.
     */
    public init(username: String, userId: String, accessToken: String? = nil, expirationDate: NSDate? = nil) {
        self.username = username
        self.userId = userId
        
        self.accessToken = accessToken
        self.expirationDate = expirationDate
        
        self.accessGranted = true
    }
    
    public required init(coder aDecoder: NSCoder) {
        accessGranted = aDecoder.decodeBoolForKey("accessGranted")
        
        if let identifier = aDecoder.decodeObjectForKey("accountIdentifier") as? String {
            self.accountIdentifier = identifier
        }
        
        if let accessToken = aDecoder.decodeObjectForKey("accessToken") as? String {
            self.accessToken = accessToken
        }
        
        if let expirationDate = aDecoder.decodeObjectForKey("expirationDate") as? NSDate {
            self.expirationDate = expirationDate
        }
        
        if let userId = aDecoder.decodeObjectForKey("userId") as? String {
            self.userId = userId
        }
        
        if let username = aDecoder.decodeObjectForKey("username") as? String {
            self.username = username
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeBool(accessGranted, forKey: "accessGranted")
        
        if self.accountIdentifier != nil {
            aCoder.encodeObject(accountIdentifier!, forKey: "accountIdentifier")
        }
        
        if self.accessToken != nil {
            aCoder.encodeObject(accessToken!, forKey: "accessToken")
        }
        
        if self.expirationDate != nil {
            aCoder.encodeObject(expirationDate!, forKey: "expirationDate")
        }
        
        if self.userId != nil {
            aCoder.encodeObject(userId!, forKey: "userId")
        }
        
        if self.username != nil {
            aCoder.encodeObject(username!, forKey: "username")
        }
    }
    
    /**
        Clears the social data from self.
     */
    public func clear() {
        self.userId = nil
        self.username = nil
        self.accountIdentifier = nil
        
        self.accessGranted = false
    }
}
