//
//  TwitterManager.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 9/14/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import UIKit
import Accounts

class TwitterManager: NSObject {
    class func sharedManager() -> TwitterManager {
        struct Static {
            static let instance: TwitterManager = TwitterManager()
        }
        
        return Static.instance
    }
    
    class func requestTwitterAccess(success: ((ACAccount) -> ())?, failure: FailureBlock?) {
        var accountStore = ACAccountStore()
        var accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccountsWithType(accountType, options: [NSObject: AnyObject](), completion: { granted, error in
            if error != nil || !granted {
                failure?(error)
            } else if granted {
                println("Access granted")
            }
        })
    }
}
