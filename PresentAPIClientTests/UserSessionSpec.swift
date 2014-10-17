//
//  UserSessionTests.swift
//  UserSessionTests
//
//  Created by Justin Makaila on 8/8/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Nimble
import Quick
import PresentAPIClient

class UserSessionSpec: QuickSpec {
    override func spec() {
        context("when a user is logged out") {
            var authenticatedUserContext: UserContext? = nil
            var loginError: NSError?
            
            it ("can log a user in") {
                UserSession.login("test", password: "itunesconnect001", success: { userContext in
                    authenticatedUserContext = userContext
                    }, failure: { error in
                        loginError = error
                    })
                
                expect { authenticatedUserContext }.toEventuallyNot(beNil(), timeout: 10)
                expect { loginError }.toEventually(beNil(), timeout: 10)
            }
        }
        
        context("when a user is logged in") {
            var sessionContext: UserContext? = nil
            var sessionUser: User? = nil
            var session: UserSession? = nil
            
            beforeEach {
                sessionUser = User(username: "justin", password: "password", fullName: "Justin Makaila", email: "justin@present.tv")
                sessionContext = UserContext(sessionToken: "456464363737hfhfh", user: sessionUser!)
                session = UserSession(userContext: sessionContext!)
                
                UserSession.setCurrentSession(session)
            }
            
            // TODO: This doesn't really prove anything when using a fake session
            /*
            it ("can log a user out") {
                var logOutError: NSError?
                UserSession.logOut { result in
                    logOutError = result as? NSError
                }
                
                expect { logOutError }.toEventually(beNil(), timeout: 5)
            }
            */
            
            it ("can provide the current user") {
                expect(UserSession.currentUser()).to(beIdenticalTo(sessionUser))
            }
            
            it ("can provide the current session") {
                expect(UserSession.currentSession()).to(beIdenticalTo(session))
            }
            
            it ("can tell if a user is authenticated") {
                expect(UserSession.currentSession()!.isAuthenticated).to(beTruthy())
            }
            
            it ("can provide the current user context") {
                expect(UserSession.currentSession()!.context).to(beIdenticalTo(sessionContext))
            }
            
            pending("can process and store subjective object meta") {
                let currentSession = UserSession.currentSession()!
                
                let someObject = Object(id: "666")
                let friendshipRelation = Relation(forward: true)
                let objectMeta = SubjectiveObjectMeta(like: nil, friendship: friendshipRelation, view: nil)
                
                currentSession.storeObjectMeta(objectMeta, forObject: someObject)
                
                var retrieved = currentSession.getObjectMetaForObject(someObject)
                expect(retrieved.friendship!.forward).to(beTruthy())
            }
            
            pending("can retrieve subjective object meta about an object") {
                let currentSession = UserSession.currentSession()!
                
                let someObject = Object(id: "666")
                let friendshipRelation = Relation(forward: true, backward: false)
                let objectMeta = SubjectiveObjectMeta(like: nil, friendship: friendshipRelation, view: nil)
                
                currentSession.storeObjectMeta(objectMeta, forObject: someObject)
                
                var retrieved = currentSession.getObjectMetaForObject(someObject)
                expect(retrieved.friendship!.forward).to(beTruthy())
            }
        }
    }
}
