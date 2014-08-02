//
//  LogSelector.swift
//  Swell
//
//  Created by Hubert Rabago on 7/2/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//


/// Implements the logic for determining which loggers are enabled to actually log anything.
/// The rules used by this are:
///  * By default, everything is enabled
///  * If a logger is specifically disabled, then that rule will be followed regardless of whether it was enabled by another rule
///  * If any one logger is specifically enabled, then all other loggers must be specifically enabled, too,
///    otherwise they wouldn't be enabled
public class LogSelector {
    
    public var enableRule: String = "" {
    didSet {
        enabled = parseCSV(enableRule)
    }
    }
    public var disableRule: String = "" {
    didSet {
        disabled = parseCSV(disableRule)
    }
    }
    
    public var enabled: [String] = [String]()
    public var disabled: [String] = [String]()
    
    public init() {

    }

    func shouldEnable(logger: Logger) -> Bool {
        let name = logger.name
        return shouldEnableLoggerWithName(name)
    }
    
    public func shouldEnableLoggerWithName(name: String) -> Bool {
        // If the default rules are in place, then yes
        if disableRule == "" && enableRule == "" {
            return true
        }
        
        // At this point, we know at least one rule has changed
        
        // If logger was specifically disabled, then no
        if isLoggerDisabled(name) {
            return false
        }
        
        // If logger was specifically enabled, then yes!
        if isLoggerEnabled(name) {
            return true
        }
        
        // At this point, we know that the logger doesn't have a specific rule
        
        // If any items were specifically enabled, then this wasn't, then NO
        if enabled.count > 0 {
            return false
        }
        
        // At this point, we know there weren't any loggers specifically enabled, but
        //  the disableRule has been modified, and yet this logger wasn't
        return true
    }
    
    /// Returns true if the given logger name was specifically configured to be disabled
    func isLoggerEnabled(name: String) -> Bool {
        for enabledName in enabled {
            if (name == enabledName) {
                return true
            }
        }
        
        return false
    }
    
    /// Returns true if the given logger name was specifically configured to be disabled
    func isLoggerDisabled(name: String) -> Bool {
        for disabledName in disabled {
            if (name == disabledName) {
                return true
            }
        }
        
        return false
    }
    
    
    func parseCSV(string: String) -> [String] {
        var result = [String]()
        let temp = string.componentsSeparatedByString(",")
        for s: String in temp {
            // 'countElements(s)' returns s.length
            if (countElements(s) > 0) {
                result.append(s)
            }
            //if (s.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
            //    result.append(s)
            //}
        }
        return result
    }
    

}


