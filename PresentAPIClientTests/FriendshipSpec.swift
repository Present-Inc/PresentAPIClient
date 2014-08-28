//
//  FriendshipSpec.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/12/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Quick
import Nimble
import PresentAPIClient

class FriendshipSpec: QuickSpec {
    override func spec() {
        describe ("the class") {
            it ("can retrieve forward friendships for a user") {
                var forwardFriendships: [Friendship]?,
                    forwardCursor: Int = 0,
                    friendshipError: NSError?,
                justin = User(username: "justin", password: "password", fullName: "Justin Makaila", email: "justin@present.tv")
                
                Friendship.getForwardFriendships(justin, cursor: 0, success: { friendships, nextCursor in
                    forwardFriendships = friendships
                    forwardCursor = nextCursor
                    }, failure: { error in
                        friendshipError = error
                    })
                
                expect { forwardFriendships }.toEventuallyNot(beNil(), timeout: 10)
                expect { forwardCursor }.toEventually(beLessThanOrEqualTo(30), timeout: 10)
                expect { friendshipError }.toEventually(beNil(), timeout: 10)
            }
            
            it ("can retrieve backward friendships for a user") {
                var backwardFriendships: [Friendship]?,
                    backwardCursor: Int = 0,
                    friendshipError: NSError?,
                    justin = User(username: "justin", password: "password", fullName: "Justin Makaila", email: "justin@present.tv")
                
                Friendship.getBackwardFriendships(justin, cursor: 0, success: { friendships, nextCursor in
                    backwardFriendships = friendships
                    backwardCursor = nextCursor
                    }, failure: { error in
                        friendshipError = error
                    })
                
                expect { backwardFriendships }.toEventuallyNot(beNil(), timeout: 10)
                expect { backwardCursor }.toEventually(beLessThanOrEqualTo(30), timeout: 10)
                expect { friendshipError }.toEventually(beNil(), timeout: 10)
            }
        }
        
        pending ("an instance") {
            it ("can be created to represent a friendship between two users") {
                var sourceUser = User(username: "herb", password: "password", fullName: "Herb Adis", email: "herb@present.tv"),
                    targetUser = User(username: "justin", password: "password", fullName: "Justin Makaila", email: "justin@present.tv"),
                    friendshipInstance = Friendship(sourceUser: sourceUser, targetUser: targetUser),
                    createdFriendship: Friendship?,
                    createError: NSError?
                
                expect(friendshipInstance).toNot(beNil())
                
                friendshipInstance.create({ friendship in
                    createdFriendship = friendship
                    }, failure: { error in
                        createError = error
                    })
                
                expect { createdFriendship }.toEventuallyNot(beNil(), timeout: 10)
                //expect { friendshipInstance }.toEventually(beIdenticalTo(createdFriendship), timeout: 10)
                expect { createError }.toEventually(beNil(), timeout: 10)
            }
            
            pending ("existing friendship") {
                pending ("can be destroyed to represent the lack of a friendship between two users") {
                    
                }
            }
        }
    }
}
