//
//  UserSession.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Foundation

public class UserSession: NSObject, NSCoding {
    private let logger = UserSession._logger()

    public var context: UserContext?

    lazy var relationStore: RelationStore = RelationStore()

    public var isAuthenticated: Bool {
    get {
        return context != nil ? true : false
    }
    }

    private struct Static {
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
        if Static.instance == nil {
            self.setCurrentSession(self.loadSession())
        }

        return Static.instance
    }

    public class func currentUser() -> User? {
        return self.currentSession()?.context?.user
    }

    public class func isValid() -> Bool {
        return self.currentSession()? != nil
    }

    public class func login(username: String, password: String, success: ((UserContext) -> ())?, failure: FailureBlock?) {
        var successBlock: ((UserContext) -> ()) = { userContext in
            self._logger().debug("Current user context is \(userContext.user)")
            self.setCurrentSession(UserSession(userContext: userContext))
            
            success?(userContext)
        }
        
        UserContext.authenticate(username, password: password, success: successBlock, failure: failure)
    }

    public class func register(user: User, success: ((UserContext) -> ())?, failure: FailureBlock?) {
        // TODO: Create the user
        user.create({ createdUser in
            self.login(createdUser.username, password: createdUser.password, success: success, failure: failure)
            }, failure: failure)
        // TODO: Authenticate the new user
        // TODO: Return the user context
    }
    
    public class func logOut(completion: ((AnyObject?) -> ())? = nil) {
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

            Static.instance = session!

            if self.currentSession()?.save() == true {
                logger.debug("Successfully saved current session.")
            } else {
                logger.debug("Failed to save current session.")
            }
        } else {
            APIManager.sharedInstance().clearUserContextHeaders()
            PFileManager.deleteFile("UserSession", inSearchPathDirectory: .DocumentDirectory)
        }
    }

    internal class func loadSession() -> UserSession? {
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

    public func storeObjectMeta(objectMeta: SubjectiveObjectMeta, forObject object: Object) {
        self.relationStore.store(objectMeta, forKey: object.id)
    }

    public func getObjectMetaForObject(object: Object) -> SubjectiveObjectMeta {
        let objectId = object.id
    
        var subjectiveObjectMeta = SubjectiveObjectMeta(
            like: self.relationStore.getLike(objectId),
            friendship: self.relationStore.getFriendship(objectId),
            view: self.relationStore.getView(objectId)
        )

        Swell.debug(subjectiveObjectMeta)

        return subjectiveObjectMeta
    }
}
