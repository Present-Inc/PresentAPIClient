//
//  MultipartExtensions.swift
//  PresentAPIClient
//
//  Created by Justin Makaila on 8/26/14.
//  Copyright (c) 2014 present. All rights reserved.
//
/*
import Foundation

private static func multipartURLRequest(URL: String, files: [(fileURL: NSURL, name: String, filename: String, mimeType: String)], parameters: [String: AnyObject]?) -> NSURLRequest {
    var urlRequest: NSMutableURLRequest!
    
    let boundary = "AlamofireFormBoundaryx3857dkjsi"
    
    /**
    *  Configure the data for the request.
    */
    
    var requestBody = NSMutableData()
    
    // Append any provided parameters.
    if parameters != nil {
        for (key, value) in parameters! {
            requestBody.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBody.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBody.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBody.appendData("\(value)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
    }
    
    // Iterate through any supplied files and filenames.
    for fileTuple in files {
        let fileData = NSData(contentsOfFile: fileTuple.fileURL.absoluteString!)
        
        requestBody.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        requestBody.appendData("Content-Disposition: form-data; name=\"\(fileTuple.name)\"; filename=\"\(fileTuple.filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBody.appendData("Content-Type: \(fileTuple.mimeType)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        requestBody.appendData(fileData)
        requestBody.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    requestBody.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    
    urlRequest = mutableURLRequest(.POST, URL)
    
    // Set the multipart headers.
    urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    urlRequest.HTTPBody = requestBody
    
    println("Headers for request:\n\t\(urlRequest.allHTTPHeaderFields)")
    
    return urlRequest
}
*/