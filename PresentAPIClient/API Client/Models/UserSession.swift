//
//  UserSession.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Foundation
import Swell

public class UserSession: NSObject, NSCoding {
    private let logger = UserSession._logger()

    public var context: UserContext?

    lazy var relationStore: RelationStore = RelationStore()

    public var isAuthenticated: Bool {
    get {
        return context != nil ? true : false
    }
    }

    private struct Singleton {
        static var instance: UserSession? = nil
    }
    
    private class func _logger() -> Logger {
        return Swell.getLogger("UserSession")
    }
    
    // MARK: Initializers

    public init(userContext: UserContext) {
        context = userContext
        super.init()
    }

    required public init(coder aDecoder: NSCoder) {
        context = aDecoder.decodeObjectOfClass(UserContext.self, forKey: "userContext") as? UserContext
        super.init()
    }
    
    // MARK: Class Methods

    public class func currentSession() -> UserSession? {
        if Singleton.instance == nil {
            self.setCurrentSession(self.loadSession())
        }

        return Singleton.instance
    }

    public class func currentUser() -> User? {
        return self.currentSession()?.context?.user
    }

    public class func isValid() -> Bool {
        return self.currentSession()? != nil
    }

    public class func login(username: String, password: String, success: ((UserContext) -> ())?, failure: ((NSError?) -> ())?) {
        var successBlock: ((UserContext) -> ()) = { userContext in
            self.setCurrentSession(UserSession(userContext: userContext))

            UserSession.refreshCurrentUser()
        }
        
        UserContext.authenticate(username, password: password, success: successBlock, failure: failure)
    }
    
    public class func refreshCurrentUser(success: ((User) -> ())? = nil, failure: ((NSError?) -> ())? = nil) {
        User.getCurrentUser(success: { (user: User) in
            UserSession.currentUser()?.mergeResultsFromObject(user)
            UserSession.currentSession()?.save()
        },
        failure: failure)
    }

    public class func register(user: User, success: ((UserContext) -> ())?, failure: ((NSError?) -> ())?) {
        user.create({ createdUser in
            self.login(createdUser.username, password: createdUser.password!, success: success, failure: failure)
        }, failure: failure)
    }
    
    public class func logOut(completion: ((NSError?) -> ())? = nil) {
        self._logger().debug("Logging out the current user")

        UserContext.logOut { result in
            self.setCurrentSession(nil)
            completion?(result)
        }
    }

    public class func setCurrentSession(session: UserSession?) {
        if session != nil {
            APIManager.sharedInstance().setUserContextHeaders(session!.context!)

            let logger = self._logger()
            logger.debug("Setting current session to: \(session!)")

            Singleton.instance = session!

            if self.currentSession()?.save() == true {
                logger.debug("Successfully saved current session.")
            } else {
                logger.debug("Failed to save current session.")
            }
        } else {
            APIManager.sharedInstance().clearUserContextHeaders()
            PFileManager.deleteFile("UserSession", inSearchPathDirectory: .DocumentDirectory)
            // TODO: This should cancel all outstanding requests for the APIManager
        }
    }

    private class func loadSession() -> UserSession? {
        return PFileManager.loadObjectFromLocation("UserSession", inSearchPathDirectory: .DocumentDirectory) as? UserSession
    }
    
    // MARK: Instance Methods

    public func save() -> Bool {
        return PFileManager.saveObject(self, location: "UserSession", inSearchPathDirectory: .DocumentDirectory)
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        if context != nil {
            aCoder.encodeObject(context!, forKey: "userContext")
        }
    }
}

// MARK: - Subjective Object Meta and Relations

public extension UserSession {
    
    // MARK: Storing Object Meta
    
    func storeObjectMeta(objectMeta: SubjectiveObjectMeta, forObject object: Object) {
        if let key = object.id {
            self.storeObjectMeta(objectMeta, forKey: key)
        }
    }
    
    func storeObjectMeta(objectMeta: SubjectiveObjectMeta, forKey key: String) {
        self.relationStore.store(objectMeta, forKey: key)
    }
    
    // MARK: Retrieving Object Meta
    
    func getObjectMetaForObject(object: Object) -> SubjectiveObjectMeta? {
        if !object.isNew {
            return getObjectMetaForKey(object.id!)
        }
        
        return nil
    }
    
    func getObjectMetaForKey(key: String) -> SubjectiveObjectMeta {
        return SubjectiveObjectMeta(
            like: self.relationStore.getLike(key),
            friendship: self.relationStore.getFriendship(key),
            view: self.relationStore.getView(key)
        )
    }
}
