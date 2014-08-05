//
//  Logger.swift
//  Swell
//
//  Created by Hubert Rabago on 6/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//


@objc
public class Logger {
    
    let name: String
    public var level: LogLevel
    public var formatter: LogFormatter
    var locations: [LogLocation]
    var enabled: Bool;
    
    public init(name: String,
                level: LogLevel = .INFO,
                formatter: LogFormatter = QuickFormatter(),
                logLocation: LogLocation = ConsoleLocation.getInstance()) {
        
        self.name = name
        self.level = level
        self.formatter = formatter
        self.locations = [LogLocation]()
        self.locations.append(logLocation)
        self.enabled = true;
        
        Swell.registerLogger(self);
    }
    
    
    public func log<T>(logLevel: LogLevel,
                        message: @autoclosure() -> T,
                        filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        if (self.enabled) && (logLevel.level >= level.level) {
            let logMessage = formatter.formatLog(self, level: logLevel, message: message,
                filename: filename, line: line, function: function);
            for location in locations {
                location.log(logMessage)
            }
        }
    }
    
    
    //**********************************************************************
    // Main log methods
    
    public func trace<T>(message: @autoclosure() -> T,
                         filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        self.log(.TRACE, message: message, filename: filename, line: line, function: function)
    }
    
    public func debug<T>(message: @autoclosure() -> T,
                         filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        self.log(.DEBUG, message: message, filename: filename, line: line, function: function)
    }
    
    public func info<T>(message: @autoclosure() -> T,
                        filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        self.log(.INFO, message: message, filename: filename, line: line, function: function)
    }
    
    public func warn<T>(message: @autoclosure() -> T,
                        filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        self.log(.WARN, message: message, filename: filename, line: line, function: function)
    }
    
    public func error<T>(message: @autoclosure() -> T,
                         filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        self.log(.ERROR, message: message, filename: filename, line: line, function: function)
    }
    
    public func severe<T>(message: @autoclosure() -> T,
                          filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        self.log(.SEVERE, message: message, filename: filename, line: line, function: function)
    }
    
    //*****************************************************************************************
    // Log methods that accepts closures - closures must accept no param and return a String
    
    public func log(logLevel: LogLevel,
                    fn: () -> String,
                    filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        
        if (self.enabled) && (logLevel.level >= level.level) {
            let message = fn()
            self.log(logLevel, message: message)
        }
    }
    
    public func trace(fn: () -> String,
                      filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        log(.TRACE, fn: fn, filename: filename, line: line, function: function)
    }
    
    public func debug(fn: () -> String,
                      filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        log(.DEBUG, fn: fn, filename: filename, line: line, function: function)
    }
    
    public func info(fn: () -> String,
                     filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        log(.INFO, fn: fn, filename: filename, line: line, function: function)
    }
    
    public func warn(fn: () -> String,
                     filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        log(.WARN, fn: fn, filename: filename, line: line, function: function)
    }
    
    public func error(fn: () -> String,
                      filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        log(.ERROR, fn: fn, filename: filename, line: line, function: function)
    }
    
    public func severe(fn: () -> String,
                       filename: String? = __FILE__, line: Int? = __LINE__,  function: String? = __FUNCTION__) {
        log(.SEVERE, fn: fn, filename: filename, line: line, function: function)
    }
    
    
    //**********************************************************************
    // Methods to expose this functionality to Objective C code
    
    
    public class func getLogger(name: String) -> Logger {
        return Logger(name: name);
    }
    
    public func traceMessage(message: String) {
        self.trace(message, filename: nil, line: nil, function: nil);
    }
    
    public func debugMessage(message: String) {
        self.debug(message, filename: nil, line: nil, function: nil);
    }
    
    public func infoMessage(message: String) {
        self.info(message, filename: nil, line: nil, function: nil);
    }
    
    public func warnMessage(message: String) {
        self.warn(message, filename: nil, line: nil, function: nil);
    }
    
    public func errorMessage(message: String) {
        self.error(message, filename: nil, line: nil, function: nil);
    }
    
    public func severeMessage(message: String) {
        self.severe(message, filename: nil, line: nil, function: nil);
    }
    
    
    
}


