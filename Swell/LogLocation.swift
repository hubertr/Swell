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
    
    func log(@autoclosure message: () -> String);
    
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
    
    public func log(@autoclosure message: () -> String) {
        if enabled {
            print(message())
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
        let temp = internalFileLocationDictionary[filename]
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
    
    public func log(@autoclosure message: () -> String) {
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
                self.filename = (self.filename as NSString).stringByExpandingTildeInPath
            }
            
            return
        }
        
        //let dirs : [String]? = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true) as? [String]
        let dirs:AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        if let dir: String = dirs as? String {
            //let dir = directories[0]; //documents directory
            let path = (dir as NSString).stringByAppendingPathComponent(self.filename);
            self.filename = path;
        }
    }
    
    func openFile() {
        // open our file
        //Swell.info("Opening \(self.filename)")
        let fileManager = NSFileManager()
        let lastPathComponent = ((filename as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
        let directoryPath = (filename as NSString).stringByDeletingLastPathComponent
        if !fileManager.fileExistsAtPath(filename) {
            do {
                try fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return
            }
            fileManager.createFileAtPath(filename, contents: nil, attributes: nil)
        } else {
            do {
                let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(filename)
                if let fileSize = fileAttributes[NSFileSize] as? NSNumber where fileSize.longLongValue > 1024*1024*10 {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
                    let date: NSDate = fileAttributes[NSFileModificationDate] as? NSDate ?? NSDate()
                    let dateString = dateFormatter.stringFromDate(date)
                    let newFilename = (lastPathComponent as NSString).stringByAppendingString("-\(dateString)")
                    let tempFile = ((directoryPath as NSString).stringByAppendingPathComponent(newFilename) as NSString).stringByAppendingPathExtension("log")!
                    let zipFile = ((directoryPath as NSString).stringByAppendingPathComponent(newFilename) as NSString).stringByAppendingPathExtension("zip")!
                    do {
                        try fileManager.moveItemAtPath(filename, toPath: tempFile)
                        performTask("/usr/bin/zip", arguments: ["-X", "-j", "-5", "-m", zipFile, tempFile])
                    }
                    catch {
                        try fileManager.removeItemAtPath(filename)
                    }

                    fileManager.createFileAtPath(filename, contents: nil, attributes: nil)
                }
            }
            catch {}
        }
        fileHandle = NSFileHandle(forWritingAtPath:filename);
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

func performTask(launchPath: String, arguments: [String], waitUntilExit: Bool = true) -> String? {
    let outputPipe = NSPipe()
    let outputFile = outputPipe.fileHandleForReading

    let task = NSTask()
    task.launchPath = launchPath
    task.arguments = arguments
    task.standardOutput = outputPipe
    task.launch()

    let outputData = outputFile.readDataToEndOfFile()

    if waitUntilExit {
        task.waitUntilExit()
    } else {
        task.terminate()
    }

    var output: String? = NSString(data: outputData, encoding: NSUTF8StringEncoding)?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    if output!.utf16.count == 0
    {
        output = nil
    }
    return output
}


