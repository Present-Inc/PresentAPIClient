//
//  CommentSpec.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/11/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Quick
import Nimble
import PresentAPIClient

class CommentSpec: QuickSpec {
    override func spec() {
        var video = Video(id: "53e124806c3a19080097bbd9"),
            testCommentId = "53e6d4676c3a19080097bf81"
        
        describe ("the class") {
            it ("can retrieve comments for a video") {
                var fetchedComments: [Comment]?,
                    commentCursor: Int?,
                    fetchError: NSError?
                
                Comment.getCommentsForVideo(video, cursor: 0, success: { comments, nextCursor in
                    fetchedComments = comments
                    commentCursor = nextCursor
                    }, failure: { error in
                        fetchError = error
                    })
                
                expect { fetchedComments }.toEventuallyNot(beNil(), timeout: defaultTimeoutLength)
                expect { commentCursor }.toEventuallyNot(beNil(), timeout: defaultTimeoutLength)
                expect { fetchError }.toEventually(beNil(), timeout: defaultTimeoutLength)
            }
            
            it ("can fetch a comment by ID") {
                var fetchedComment: Comment?,
                    fetchError: NSError?
                
                Comment.getCommentWithId(testCommentId, success: { comment in
                    fetchedComment = comment
                    }, failure: { error in
                        fetchError = error
                    })
                
                expect { fetchedComment }.toEventuallyNot(beNil(), timeout: defaultTimeoutLength)
                expect { fetchError }.toEventually(beNil(), timeout: defaultTimeoutLength)
            }
        }
        
        describe ("an instance") {
            var user = UserSession.currentUser()!
            var comment: Comment!
            
            context ("not created") {
                beforeEach {
                    comment = Comment(body: "Tell Shannon her crafts are ready.", author: user, video: video)
                }
                
                it ("can be created") {
                    expect(comment.isNew).to(beTruthy())
                    
                    var createdComment: Comment?,
                        createError: NSError?
                    
                    comment.create({ newComment in
                        createdComment = newComment
                        }, failure: { error in
                            createError = error
                        })
                    
                    expect { createdComment }.toEventually(beNil(), timeout: defaultTimeoutLength)
                    expect { createError }.toEventually(beNil(), timeout: defaultTimeoutLength)
                    expect { comment.isNew }.toEventually(beTruthy(), timeout: defaultTimeoutLength)
                    expect { comment.id }.toEventually(beIdenticalTo(createdComment!.id))
                    expect { comment.body }.toEventually(beIdenticalTo(createdComment!.body))
                }
            }
            
            it ("can update it's body") {
                
            }
        }
    }
}
