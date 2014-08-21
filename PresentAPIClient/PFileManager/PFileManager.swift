//
//  PFileManager.swift
//  PresentAPIClient-Swift
//
//  Created by Justin Makaila on 8/11/14.
//  Copyright (c) 2014 Present, Inc. All rights reserved.
//

import UIKit

public class PFileManager: NSObject {
    public class func pathToSearchPathDirectory(directory: NSSearchPathDirectory) -> String {
        return NSSearchPathForDirectoriesInDomains(directory, NSSearchPathDomainMask.UserDomainMask, true).first as String
    }
    
    public class func pathToFile(file: String, inSearchPathDirectory directory: NSSearchPathDirectory) -> String {
        return self.pathToFile(file, inDirectory: self.pathToSearchPathDirectory(directory))
    }
    
    public class func pathToFile(file: String, inDirectory directory: String) -> String {
        return directory.stringByAppendingPathComponent(file)
    }
    
    public class func fileExists(fileName: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(fileName)
    }
    
    public class func fileExists(file: String, inSearchPathDirectory directory: NSSearchPathDirectory) -> Bool {
        return self.fileExists(self.pathToFile(file, inSearchPathDirectory: directory))
    }
    
    // MARK: File Creation
    // TODO: Add `createIntermediateDirectories` option
    public class func createFile(fileName: String, withData data: NSData) -> Bool {
        if !fileExists(fileName) {
            return NSFileManager.defaultManager().createFileAtPath(fileName, contents: data, attributes: nil)
        }
        
        return false
    }
    
    public class func createFile(fileName: String, withData data: NSData, inDirectory directory: String) -> Bool {
        return createFile(pathToFile(fileName, inDirectory: directory), withData: data)
    }
    
    public class func createFile(fileName: String, withData data: NSData, inSearchPathDirectory directory: NSSearchPathDirectory) -> Bool {
        return createFile(fileName, withData: data, inDirectory: pathToSearchPathDirectory(directory))
    }
    
    // MARK: File Deletion
    public class func deleteFileWithName(fileName: String) -> Bool {
        var error: NSError?
        if !NSFileManager.defaultManager().removeItemAtPath(fileName, error: &error) {
            // TODO: Handle the error... AKA Swell
            return false
        } else {
            return true
        }
    }
    
    public class func deleteFileAtURL(fileUrl: NSURL) -> Bool {
        if let filePath = fileUrl.path {
            return deleteFileWithName(filePath)
        }
        
        return false
    }
    
    public class func deleteFile(fileName: String, inSearchPathDirectory directory: NSSearchPathDirectory) -> Bool {
        return deleteFileWithName(pathToFile(fileName, inSearchPathDirectory: directory))
    }
    
    // MARK: File Enumeration
    
    public class func enumerateFilesInDirectory(directoryName: String, withBlock block: ((String) -> ())?) {
        var fileManager = NSFileManager.defaultManager(),
            enumerator = fileManager.enumeratorAtPath(directoryName)
        
        while let filePath = enumerator.nextObject() as? String {
            block?(filePath)
        }
    }
    
    // MARK: Directory Creation
    
    public class func createDirectory(directoryName: String, inSearchPathDirectory directory: NSSearchPathDirectory) -> Bool {
        var fileManager = NSFileManager.defaultManager(),
            fullPath = pathToFile(directoryName, inSearchPathDirectory: directory)
        
        if !fileManager.fileExistsAtPath(fullPath) {
            return fileManager.createDirectoryAtPath(fullPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        return false
    }
    
    // MARK: Directory Deletion
    
    public class func deleteDirectory(directoryName: String, inSearchPathDirectory directory: NSSearchPathDirectory) -> Bool {
        // TODO: Figure this out
        return false
    }
    
    // MARK: I/O
    
    public class func saveObject(object: AnyObject, location: String, inSearchPathDirectory directory: NSSearchPathDirectory) -> Bool {
        var archivePath = pathToFile(location, inSearchPathDirectory: directory)
        
        if fileExists(archivePath) {
            deleteFileWithName(archivePath)
        }
        
        return NSKeyedArchiver.archiveRootObject(object, toFile: archivePath)
    }
    
    public class func loadObjectFromLocation(location: String, inSearchPathDirectory directory: NSSearchPathDirectory) -> AnyObject? {
        var archivePath = pathToFile(location, inSearchPathDirectory: directory)
        
        if fileExists(archivePath) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(archivePath)
        } else {
            return nil
        }
    }
}
