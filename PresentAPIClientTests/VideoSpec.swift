//
//  VideoSpec.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/11/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import Quick
import Nimble
import PresentAPIClient

class VideoSpec: QuickSpec {
    override func spec() {
        describe ("the class") {
            it ("can search for videos matching a query string") {
                var searchResults: [Video]?,
                    searchCursor: Int?,
                    searchError: NSError?
                
                Video.search("a", cursor: 0, success: { videoResults, nextCursor in
                    searchResults = videoResults
                    searchCursor = nextCursor
                    }, failure: { error in
                        searchError = error
                    })
                
                expect { searchResults }.toEventually(beNil(), timeout: defaultTimeoutLength)
                expect { searchCursor }.toEventually(beLessThanOrEqualTo(30), timeout: defaultTimeoutLength)
                expect { searchError }.toEventually(beNil(), timeout: defaultTimeoutLength)
            }
        }
        
        pending ("a video") {
            var video: Video!
            beforeEach {
                video = Video()
            }
            
            it ("can merge in values from another object") {
                var aVideo = Video(id: "123456")
                aVideo.caption = "This is a video with a title"
                
                expect(video.caption).to(beNil())
                expect(video.id).to(beNil())
                
                video.mergeResultsFromObject(aVideo)
                
                expect(video.caption).to(beIdenticalTo(aVideo.caption))
                expect(video.id).to(beIdenticalTo(aVideo.id))
            }
            
            pending ("can add a comment") { }
            pending ("can add a like") { }
            pending ("can tell if it's live or not") { }
            pending ("can update it's title") { }
            pending ("can update it's location") { }
        }
    }
}
