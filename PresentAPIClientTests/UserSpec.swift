//
//  UserSpec.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/11/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Nimble
import Quick
import PresentAPIClient

let defaultTimeoutLength: NSTimeInterval = 5

class UserSpec: QuickSpec {
    override func spec() {
        beforeSuite {
            UserSession.login("test", password: "itunesconnect001", success: nil, failure: nil)
        }
        
        afterSuite {
            UserSession.logOut(nil)
        }
        
        describe ("the class") {
            it ("can search for users matching string") {
                var userResults: [User]? = nil,
                    searchError: NSError? = nil
                
                User.search("a", cursor: 0, success: { users, nextCursor in
                    userResults = users
                    }, failure: { error in
                        searchError = error
                    })
                
                expect { userResults }.toEventuallyNot(beNil(), timeout: defaultTimeoutLength)
                expect { searchError }.toEventually(beNil(), timeout: defaultTimeoutLength)
            }
            
            context("while fetching an individual user") {
                var userResult: User?,
                    fetchError: NSError?
                
                beforeEach {
                    userResult = nil
                    fetchError = nil
                }
                
                it ("can fetch a user matching a username") {
                    User.getUserWithUsername("justin", success: { user in
                        userResult = user
                        }, failure: { error in
                            fetchError = error
                        })
                    
                    expect { userResult }.toEventuallyNot(beNil(), timeout: defaultTimeoutLength)
                    expect { fetchError }.toEventually(beNil(), timeout: defaultTimeoutLength)
                }
                
                it ("can fetch user matching an ID") {
                    User.getUserWithId("53744bf4650762a97c8c93c0", success: { user in
                        userResult = user
                        }, failure: { error in
                            fetchError = error
                    })
                    
                    expect { userResult }.toEventuallyNot(beNil(), timeout: defaultTimeoutLength)
                    expect { fetchError }.toEventually(beNil(), timeout: defaultTimeoutLength)
                }
                
            }
        }
        
        describe ("a user") {
            var currentUser: User! = UserSession.currentUser()
            
            it ("can retrieve it's likes") {
                currentUser.getLikes(cursor: 0, success: { likes in
                    
                    }, failure: { error in
                        
                    })
            }
            
            it ("can retrieve it's followers") {
                currentUser.getFollowers(cursor: 0, success: { users in
                    
                    }, failure: { error in
                        
                    })
            }
            
            it ("can retrieve it's friends") {
                currentUser.getFriends(cursor: 0, success: { users in
                    
                    }, failure: { error in
                        
                    })
            }
            
            it ("can retrieve it's videos") {
                currentUser.getVideos(cursor: 0, success: { videos in
                    
                    }, failure: { error in
                        
                    })
            }
            
            pending ("can update it's properties on the API") {
            
            }
            
            pending ("can add a friend") {
            
            }
            
            pending ("can add a follower") {
            
            }
        }
    }
}
