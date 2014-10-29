//
//  Level.swift
//  Swell
//
//  Created by Hubert Rabago on 6/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//
import Foundation

public typealias RawLevel = Int

public enum PredefinedLevel: RawLevel {
    case trace  = 100
    case debug  = 200
    case info   = 300
    case warn   = 400
    case error  = 500
    case severe = 600
}



public struct LogLevel {
    var level: RawLevel;
    var name: String;
    var label: String;
    
    static var allLevels = Dictionary<RawLevel, LogLevel>()
    
    public static let TRACE  = LogLevel.create(.trace,  name: "trace",   label: "TRACE")
    public static let DEBUG  = LogLevel.create(.debug,  name: "debug",   label: "DEBUG")
    public static let INFO   = LogLevel.create(.info,   name: "info",    label: " INFO")
    public static let WARN   = LogLevel.create(.warn,   name: "warn",    label: " WARN")
    public static let ERROR  = LogLevel.create(.error,  name: "error",   label: "ERROR")
    public static let SEVERE = LogLevel.create(.severe, name: "severe",  label: "SEVERE")
    
    public init(level: RawLevel, name: String, label: String) {
        self.level = level
        self.name  = name
        self.label = label
    }
    
    static func create(level: PredefinedLevel, name: String, label: String) -> LogLevel {
        var result = LogLevel(level:level.rawValue, name: name, label: label);
        //let key =
        allLevels[result.level] = result
        return result
    }
    
    public static func getLevel(level: PredefinedLevel) -> LogLevel {
        switch level {
        case .trace:  return TRACE
        case .debug:  return DEBUG
        case .info:   return INFO
        case .warn:   return WARN
        case .error:  return ERROR
        case .severe: return SEVERE
        }
    }
    
    static func getLevel(levelName: String) -> LogLevel {
        // we access all levels to make sure they've all been initialized
        let temp = [TRACE, DEBUG, INFO, WARN, ERROR, SEVERE]
        for level in allLevels.values {
            if (level.name == levelName) {
                return level
            }
        }
        return TRACE    // fallback option
    }
    
    public func desciption() -> String {
        return "LogLevel level=\(label)"
    }
}


