//
//  PresentAPIClient.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 10/17/14.
//  Copyright (c) 2014 present. All rights reserved.
//

import Foundation
import SwiftyJSON

let baseURL = NSURL(string: "https://api-staging.present.tv/v1/")!

let Version = "2014-09-09"

let PresentVersionHeader = "Present-Version"
let SessionTokenHeader = "Present-User-Context-Session-Token"
let UserIdHeader = "Present-User-Context-User-Id"

let CallbackQueueIdentifier = "tv.Present.Present.PresentAPIClient.serializationQueue"
