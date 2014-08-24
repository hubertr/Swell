//
//  LogLocation.swift
//  Swell
//
//  Created by Hubert Rabago on 6/26/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//
import Foundation

public protocol LogLocation {
    //class func getInstance(param: AnyObject? = nil) -> LogLocation

    func log(message: @autoclosure() -> String);
    
    func enable();
    
    func disable();
    
    func description() -> String
}



public class ConsoleLocation: LogLocation {
    var enabled = true
    
    // Use the static-inside-class-var approach to getting a class var instance
    class var instance: ConsoleLocation {
        struct Static {
            static let internalInstance = ConsoleLocation()
        }
        return Static.internalInstance
    }

    public class func getInstance() -> LogLocation {
        return instance
    }

    public func log(message: @autoclosure() -> String) {
        if enabled {
            println(message())
        }
    }
    
    public func enable() {
        enabled = true
    }
    
    public func disable() {
        enabled = false
    }
    
    public func description() -> String {
        return "ConsoleLocation"
    }
}

// Use the globally-defined-var approach to getting a class var dictionary
var internalFileLocationDictionary = Dictionary<String, FileLocation>()

public class FileLocation: LogLocation {
    var enabled = true
    var filename: String
    var fileHandle: NSFileHandle?
    
    public class func getInstance(filename: String) -> LogLocation {
        var temp = internalFileLocationDictionary[filename]
        if let result = temp {
            return result
        } else {
            let result: FileLocation = FileLocation(filename: filename)
            internalFileLocationDictionary[filename] = result
            return result
        }
    }
    

    init(filename: String) {
        self.filename = filename
        self.setDirectory()
        fileHandle = nil
        openFile()
    }
    
    deinit {
        closeFile()
    }
    
    public func log(message: @autoclosure() -> String) {
        //message.writeToFile(filename, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
        if (!enabled) {
            return
        }
        
        let output = message() + "\n"
        if let handle = fileHandle {
            handle.seekToEndOfFile()
            if let data = output.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                handle.writeData(data)
            }
        }

    }
    
    func setDirectory() {
        let temp: NSString = self.filename
        if temp.rangeOfString("/").location != Foundation.NSNotFound {
            // "/" was found in the filename, so we use whatever path is already there
            if (self.filename.hasPrefix("~/")) {
                self.filename = self.filename.stringByExpandingTildeInPath
            }
            
            return
        }

        //let dirs : [String]? = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true) as? [String]
        let dirs:AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
        if let dir: String = dirs as? String {
            //let dir = directories[0]; //documents directory
            let path = dir.stringByAppendingPathComponent(self.filename);
            self.filename = path;
        }
    }
    
    func openFile() {
        // open our file
        //Swell.info("Opening \(self.filename)")
        if !NSFileManager.defaultManager().fileExistsAtPath(self.filename) {
            NSFileManager.defaultManager().createFileAtPath(self.filename, contents: nil, attributes: nil)
        }
        fileHandle = NSFileHandle(forWritingAtPath:self.filename);
        //Swell.debug("fileHandle is now \(fileHandle)")
    }
    
    func closeFile() {
        // close the file, if it's open
        if let handle = fileHandle {
            handle.closeFile()
        }
        fileHandle = nil
    }
    
    public func enable() {
        enabled = true
    }
    
    public func disable() {
        enabled = false
    }
    
    public func description() -> String {
        return "FileLocation filename=\(filename)"
    }
}


