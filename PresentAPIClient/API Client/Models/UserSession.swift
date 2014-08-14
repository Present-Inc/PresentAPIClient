//
//  UserSession.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 6/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Foundation

/**
 *  The class holding the current UserContext
 *  for the logged in user. This class handles
 *  authenticating a user with the Present API.
 */
public class UserSession: NSObject, NSCoding {
    private let logger = Swell.getLogger("UserSession")
    
    /**
     *  The current UserSession.
     *
     *  @discussion This should be the only
     *  UserSession instance in the application.
     */
    public class var currentUserSession: UserSession? {
        return _currentUserSession
    }
    
    /**
     *  The UserContext associated with the
     *  UserSession.
     *
     *  @discussion This property is set upon authentication
     *  with the API.
     */
    public var context: UserContext?
    
    /**
     *  The relation store used for managing user
     *  relationships throughout the app.
     *  
     *  @discussion The relation store is lazy-loaded
     *  for performance. This should be reset for every
     *  session.
     */
    lazy var relationStore: RelationStore = RelationStore()
    
    /*
     *  Returns whether the user is authenticated
     *  or not.
     *
     *  @discussion A user is authenticated when there is
     *  a context set.
     *
     *  @return true if the user is authenticated, else false
     */
    public var isAuthenticated: Bool {
    get {
        return context != nil ? true : false
    }
    }
    
    // MARK: Initializers
    
    /**
     *  Initializes an instance of a UserSession struct
     *  with the supplied UserContext
     */
    public init(userContext: UserContext) {
        context = userContext
        super.init()
    }

    required public init(coder aDecoder: NSCoder!) {
        context = aDecoder.decodeObjectOfClass(UserContext.self, forKey: "userContext") as? UserContext
        super.init()
    }
    
    // MARK: Class Methods
    
    /**
     *  Returns the current session for the Present API.
     *
     *  @discussion If there is no session initially,
     *  the class attempts to load a saved user session
     *  from disk. If no session is found, returns nil.
     *  this is not yet optimized for multiple user sessions.
     *
     *  @return UserSession? of the current session.
     */
    public class func currentSession() -> UserSession? {
        if _currentUserSession == nil {
            self.setCurrentSession(self.loadSession())
        }

        self._logger().debug("Returning \(_currentUserSession) as current user session")
        return _currentUserSession
    }

    public class func currentUser() -> User? {
        return self.currentSession()?.context?.user
    }

    public class func isValid() -> Bool {
        return self.currentSession()? != nil
    }
    
    /**
     *  Logs the user in to the API with the supplied
     *  username and password.
     *  
     *  @discussion Wraps the supplied success block to ensure
     *  the returned user context is saved to disk.
     *
     *  @param username the username of the user
     *  @param password the password of the user
     *  @param success the success block to be called on success
     *  @param failure the failure block to be called on failure
     *
     */
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
        // TODO: Authenticate the new user
        // TODO: Return the user context
    }
    
    /**
     *  Logs the user out from the API.
     *
     *  @discussion Calls completion upon completion. If an error
     *  occurred, the error property will not be nil.
     *
     *  @param completion a block to be called on completion, with
     *  with an optional error.
     */
    public class func logOut(completion: ((AnyObject?) -> ())?) {
        self._logger().debug("Logging out the current user")

        UserContext.logOut { result in
            self.setCurrentSession(nil)

            completion?(result)
        }
    }

    /**
     *  Sets the current session for the Present API.
     *
     *  @discussion Sets the global variable, CurrentUserSession,
     *  to the value of session.
     *
     *  @param session the UserSession? to set as the current
     *  session.
     */
    public class func setCurrentSession(session: UserSession?) {
        if session != nil {
            APIManager.sharedInstance().setUserContextHeaders(session!.context!)

            let logger = self._logger()
            logger.debug("Setting current session to: \(session!)")

            _currentUserSession = session!

            if _currentUserSession?.save() == true {
                logger.debug("Successfully saved current session.")
            } else {
                logger.debug("Failed to save current session.")
                // ???: Recursion?
            }
        } else {
            APIManager.sharedInstance().clearUserContextHeaders()
        }
    }
    
    /**
     *  Attempts to load a UserSession from disk
     *
     *  @return UserSession? of a UserSession from disk, else nil
     */
    internal class func loadSession() -> UserSession? {
        return PFileManager.loadObjectFromLocation("UserSession", inSearchPathDirectory: .DocumentDirectory) as? UserSession
    }
    
    // MARK: Instance Methods
    
    /**
     *  Saves self to disk
     *
     *  @return true if save is successful, else no
     */
    public func save() -> Bool {
        return PFileManager.saveObject(self, location: "UserSession", inSearchPathDirectory: .DocumentDirectory)
    }

    public func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(context, forKey: "userContext")
    }

    public func storeObjectMeta(objectMeta: SubjectiveObjectMeta, forObject object: Object) {
        self.relationStore.store(objectMeta, forKey: object.id)
    }

    public func getObjectMetaForObject(object: Object) -> SubjectiveObjectMeta {
        let objectId = object.id
    
        var subjectiveObjectMeta = SubjectiveObjectMeta()
        subjectiveObjectMeta.friendship = self.relationStore.getFriendship(objectId)
        subjectiveObjectMeta.like = self.relationStore.getLike(objectId)

        Swell.debug(subjectiveObjectMeta)

        return subjectiveObjectMeta
    }
}

private extension UserSession {
    class func _logger() -> Logger {
        return Swell.getLogger("UserSession")
    }
}

private var _currentUserSession: UserSession? = nil
