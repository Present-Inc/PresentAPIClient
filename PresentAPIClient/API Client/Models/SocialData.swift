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
    var accessGranted: Bool = false
    
    /**
        Will only be present on the current user
     */
    var accountIdentifier: String?
    
    var userId: String?
    
    override init() {
        super.init()
    }
    
    init(account: ACAccount) {
        var accountStore = ACAccountStore()
        var twitterType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        var facebookType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
        
        if account.accountType == twitterType {
            self.userId = account.valueForKey("properties").valueForKey("user_id") as? String
        } else if account.accountType == facebookType {
            self.userId = account.valueForKey("properties").valueForKey("uid") as? String
        }
        
        self.accountIdentifier = account.identifier
    }
    
    public required init(coder aDecoder: NSCoder) {
        accessGranted = aDecoder.decodeBoolForKey("accessGranted")
        
        if let identifier = aDecoder.decodeObjectForKey("accountIdentifier") as? String {
            self.accountIdentifier = identifier
        }
        
        if let userId = aDecoder.decodeObjectForKey("userId") as? String {
            self.userId = userId
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeBool(accessGranted, forKey: "accessGranted")
        
        if self.accountIdentifier != nil {
            aCoder.encodeObject(accountIdentifier!, forKey: "accountIdentifier")
        }
        
        if self.userId != nil {
            aCoder.encodeObject(userId!, forKey: "userId")
        }
    }
}
