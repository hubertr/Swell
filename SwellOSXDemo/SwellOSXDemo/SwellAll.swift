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
        var result = LogLevel(level:level.toRaw(), name: name, label: label);
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


//
//  Formatter.swift
//  Swell
//
//  Created by Hubert Rabago on 6/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

/// A Log Formatter implementation generates the string that will be sent to a log location
/// if the log level requirement is met by a call to log a message.
public protocol LogFormatter {
    
    /// Formats the message provided for the given logger
    func formatLog<T>(logger: Logger, level: LogLevel, message: @autoclosure() -> T,
                      filename: String?, line: Int?,  function: String?) -> String;
    
    /// Returns an instance of this class given a configuration string
    class func logFormatterForString(formatString: String) -> LogFormatter;
    
    /// Returns a string useful for describing this class and how it is configured
    func description() -> String;
}



public enum QuickFormatterFormat: Int {
    case MessageOnly = 0x0001
    case LevelMessage = 0x0101
    case NameMessage = 0x0011
    case LevelNameMessage = 0x0111
    case DateLevelMessage = 0x1101
    case DateMessage = 0x1001
    case All = 0x1111
}


/// QuickFormatter provides some limited options for formatting log messages.
/// Its primary advantage over FlexFormatter is speed - being anywhere from 20% to 50% faster
/// because of its limited options.
public class QuickFormatter: LogFormatter {
    
    let format: QuickFormatterFormat
    
    public init(format: QuickFormatterFormat = .LevelNameMessage) {
        self.format = format
    }
    
    public func formatLog<T>(logger: Logger, level: LogLevel, message givenMessage: @autoclosure() -> T,
                             filename: String?, line: Int?,  function: String?) -> String {
        var s: String;
        let message = givenMessage()
        switch format {
        case .LevelNameMessage:
            s = "\(level.label) \(logger.name): \(message)";
        case .DateLevelMessage:
            s = "\(NSDate()) \(level.label): \(message)";
        case .MessageOnly:
            s = "\(message)";
        case .NameMessage:
            s = "\(logger.name): \(message)";
        case .LevelMessage:
            s = "\(level.label): \(message)";
        case .DateMessage:
            s = "\(NSDate()) \(message)";
        case .All:
            s = "\(NSDate()) \(level.label) \(logger.name): \(message)";
        }
        return s
    }
    
    public class func logFormatterForString(formatString: String) -> LogFormatter {
        var format: QuickFormatterFormat
        switch formatString {
        case "LevelNameMessage": format = .LevelNameMessage
        case "DateLevelMessage": format = .DateLevelMessage
        case "MessageOnly": format = .MessageOnly
        case "LevelMessage": format = .LevelMessage
        case "NameMessage": format = .NameMessage
        case "DateMessage": format = .DateMessage
        default: format = .All
        }
        return QuickFormatter(format: format)
    }
    
    public func description() -> String {
        var s: String;
        switch format {
        case .LevelNameMessage:
            s = "LevelNameMessage";
        case .DateLevelMessage:
            s = "DateLevelMessage";
        case .MessageOnly:
            s = "MessageOnly";
        case .LevelMessage:
            s = "LevelMessage";
        case .NameMessage:
            s = "NameMessage";
        case .DateMessage:
            s = "DateMessage";
        case .All:
            s = "All";
        }
        return "QuickFormatter format=\(s)"
    }
}




public enum FlexFormatterPart: Int {
    case DATE
    case NAME
    case LEVEL
    case MESSAGE
    case LINE
    case FUNC
}

/// FlexFormatter provides more control over the log format, allowing
/// the flexibility to specify what data appears and on what order.
public class FlexFormatter: LogFormatter {
    var format: [FlexFormatterPart]
    
    public init(parts: FlexFormatterPart...) {
        format = parts
        // Same thing as below
        //format = [FlexFormatterPart]()
        //for part in parts {
        //    format += part
        //}
    }
    
    /// This overload is needed (as of Beta 3) because 
    /// passing an array to a variadic param is not yet supported
    init(parts: [FlexFormatterPart]) {
        format = parts
    }
    

    public func formatLog<T>(logger: Logger, level: LogLevel, message givenMessage: @autoclosure() -> T,
                             filename: String?, line: Int?,  function: String?) -> String {
        var logMessage = ""
        for (index, part) in enumerate(format) {
            switch part {
            case .MESSAGE:
                let message = givenMessage()
                logMessage += "\(message)"
            case .NAME: logMessage += logger.name
            case .LEVEL: logMessage += level.label
            case .DATE: logMessage += NSDate().description
            case .LINE:
                if (filename != nil) && (line != nil) {
                    logMessage += "[\(filename!.lastPathComponent):\(line!)]"
                }
            case .FUNC:
                if (function != nil) {
                    logMessage += "[\(function)()]"
                }
            }
            
            if (index < format.count-1) {
                if (format[index+1] == .MESSAGE) {
                    logMessage += ":"
                }
                logMessage += " "
            }
        }
        return logMessage
    }
   

    public class func logFormatterForString(formatString: String) -> LogFormatter {
        var formatSpec = [FlexFormatterPart]()
        let parts = formatString.uppercaseString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        for part in parts {
            switch part {
            case "MESSAGE": formatSpec += [.MESSAGE]
            case "NAME": formatSpec += [.NAME]
            case "LEVEL": formatSpec += [.LEVEL]
            case "LINE": formatSpec += [.LINE]
            case "FUNC": formatSpec += [.FUNC]
            default: formatSpec += [.DATE]
            }
        }
        return FlexFormatter(parts: formatSpec)
    }

    public func description() -> String {
        var desc = ""
        for (index, part) in enumerate(format) {
            switch part {
            case .MESSAGE: desc += "MESSAGE"
            case .NAME: desc += "NAME"
            case .LEVEL: desc += "LEVEL"
            case .DATE: desc += "DATE"
            case .LINE: desc += "LINE"
            case .FUNC: desc += "FUNC"
            }
            
            if (index < format.count-1) {
                desc += " "
            }
        }
        return "FlexFormatter with \(desc)"
    }
 
}

//
//  LogLocation.swift
//  Swell
//
//  Created by Hubert Rabago on 6/26/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

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
            handle.writeData(output.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
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

        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
    
        if let directories:[String] = dirs {
            let dir = directories[0]; //documents directory
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


//
//  Swell.swift
//  Swell
//
//  Created by Hubert Rabago on 6/26/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//


struct LoggerConfiguration {
    var name: String
    var level: LogLevel?
    var formatter: LogFormatter?
    var locations: [LogLocation]
    
    init(name: String) {
        self.name = name
        self.locations = [LogLocation]()
    }
    func description() -> String {
        var locationsDesc = ""
        for loc in locations {
            locationsDesc += loc.description()
        }
        return "\(name) \(level?.desciption()) \(formatter?.description()) \(locationsDesc)"
    }
}



// We declare this here because there isn't any support yet for class var / class let
let globalSwell = Swell();


@objc
public class Swell {
    
    var swellLogger: Logger!;
    var selector = LogSelector()
    var allLoggers = Dictionary<String, Logger>()
    var rootConfiguration = LoggerConfiguration(name: "ROOT")
    var sharedConfiguration = LoggerConfiguration(name: "Shared")
    var allConfigurations = Dictionary<String, LoggerConfiguration>()
    var enabled = true;
    

    init() {
        // This configuration is used by the shared logger
        sharedConfiguration.formatter = QuickFormatter(format: .LevelMessage)
        sharedConfiguration.level = LogLevel.TRACE
        sharedConfiguration.locations += [ConsoleLocation.getInstance()]

        // The root configuration is where all other configurations are based off of
        rootConfiguration.formatter = QuickFormatter(format: .LevelNameMessage)
        rootConfiguration.level = LogLevel.TRACE
        rootConfiguration.locations += [ConsoleLocation.getInstance()]

        readConfigurationFile()
    }
    
    func initInternalLogger() {
        //swellLogger = Logger(name: "SHARED", formatter: QuickFormatter(format: .LevelMessage))
        swellLogger = getLogger("Shared")
    }
    
    
    

    //========================================================================================
    // Global/convenience log methods used for quick logging

    public class func trace<T>(message: @autoclosure() -> T) {
        if (!globalSwell.swellLogger) {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.trace(message)
    }
    
    public class func debug<T>(message: @autoclosure() -> T) {
        if (!globalSwell.swellLogger) {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.debug(message)
    }
    
    public class func info<T>(message: @autoclosure() -> T) {
        if (!globalSwell.swellLogger) {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.info(message)
    }
    
    public class func warn<T>(message: @autoclosure() -> T) {
        if (!globalSwell.swellLogger) {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.warn(message)
    }
    
    public class func error<T>(message: @autoclosure() -> T) {
        if (!globalSwell.swellLogger) {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.error(message)
    }
    
    public class func severe<T>(message: @autoclosure() -> T) {
        if (!globalSwell.swellLogger) {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.severe(message)
    }

    public class func trace(fn: () -> String) {
        if (!globalSwell.swellLogger) {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.trace(fn)
    }
    
    public class func debug(fn: () -> String) {
        if (!globalSwell.swellLogger) {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.debug(fn)
    }
    
    public class func info(fn: () -> String) {
        if (!globalSwell.swellLogger) {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.info(fn)
    }
    
    public class func warn(fn: () -> String) {
        if (!globalSwell.swellLogger) {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.warn(fn)
    }
    
    public class func error(fn: () -> String) {
        if (!globalSwell.swellLogger) {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.error(fn)
    }
    
    public class func severe(fn: () -> String) {
        if (!globalSwell.swellLogger) {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.severe(fn)
    }
    
    //====================================================================================================
    // Public methods
    

    /// Returns the logger configured for the given name.
    /// This is the recommended way of retrieving a Swell logger.
    public class func getLogger(name: String) -> Logger {
        return globalSwell.getLogger(name);
    }
    
    
    /// Turns off all logging.
    public class func disableLogging() {
        globalSwell.disableLogging()
    }


    func disableLogging() {
        enabled = false
        for (key, value) in allLoggers {
            value.enabled = false
        }
    }
    
    func enableLogging() {
        enabled = true
        for (key, value) in allLoggers {
            value.enabled = selector.shouldEnable(value)
        }
    }
    
    // Register the given logger.  This method should be called
    // for ALL loggers created.  This facilitates enabling/disabling of
    // loggers based on user configuration.
    class func registerLogger(logger: Logger) {
        globalSwell.registerLogger(logger);
    }
    
    func registerLogger(logger: Logger) {
        allLoggers[logger.name] = logger;
        evaluateLoggerEnabled(logger);
    }
    
    func evaluateLoggerEnabled(logger: Logger) {
        logger.enabled = self.enabled && selector.shouldEnable(logger);
    }
    
    /// Returns the Logger instance configured for a given logger name.
    /// Use this to get Logger instances for use in classes.
    func getLogger(name: String) -> Logger {
        var logger = allLoggers[name]
        if (logger != nil) {
            return logger!
        } else {
            let result: Logger = createLogger(name)
            allLoggers[name] = result
            return result
        }
    }
    
    /// Creates a new Logger instance based on configuration returned by getConfigurationForLoggerName()
    /// This is intended to be in an internal method and should not be called by other classes.
    /// Use getLogger(name) to get a logger for normal use.
    func createLogger(name: String) -> Logger {
        let config = getConfigurationForLoggerName(name)
        var result = Logger(name: name, level: config.level!, formatter: config.formatter!, logLocation: config.locations[0])
        
        // Now we need to handle potentially > 1 locations
        if config.locations.count > 1 {
            for (index,location) in enumerate(config.locations) {
                if (index > 0) {
                    result.locations += [location]
                }
            }
        }
        
        return result
    }
    
    
    //====================================================================================================
    // Methods for managing the configurations from the plist file
    
    /// Returns the current configuration for a given logger name based on Swell.plist
    /// and the root configuration.
    func getConfigurationForLoggerName(name: String) -> LoggerConfiguration {
        var config: LoggerConfiguration = LoggerConfiguration(name: name);
        
        // first, populate it with values from the root config
        config.formatter = rootConfiguration.formatter
        config.level = rootConfiguration.level
        config.locations += rootConfiguration.locations
        
        if (name == "Shared") {
            if let level = sharedConfiguration.level {
                config.level = level
            }
            if let formatter = sharedConfiguration.formatter {
                config.formatter = formatter
            }
            if sharedConfiguration.locations.count > 0 {
                config.locations = sharedConfiguration.locations
            }
        }
        
        // Now see if there's a config specifically for this logger
        // In later versions, we can consider tree structures similar to Log4j
        // For now, let's require an exact match for the name
        let keys = allConfigurations.keys
        for key in keys {
            // Look for the entry with the same name
            if (key == name) {
                let temp = allConfigurations[key]
                if let spec = temp {
                    if let formatter = spec.formatter {
                        config.formatter = formatter
                    }
                    if let level = spec.level {
                        config.level = level
                    }
                    if spec.locations.count > 0 {
                        config.locations = spec.locations
                    }
                }

            }
        }
        
        return config;
    }
    

    
    //====================================================================================================
    // Methods for reading the Swell.plist file

    func readConfigurationFile() {
//        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
//        
//        var filename: String = ""
//        if let directories:[String] = dirs {
//            let dir = directories[0]; //documents directory
//            let path = dir.stringByAppendingPathComponent("Swell.plist");
//            filename = path;
//        }

        var filename: String? = nil;
        if NSBundle.mainBundle() {
            filename = NSBundle.mainBundle().pathForResource("Swell", ofType: "plist")
        }
        
        var dict: NSDictionary? = nil;
        if filename != nil {
            dict = NSDictionary(contentsOfFile: filename)
        }
        if let map: Dictionary<String, AnyObject> = dict as? Dictionary<String, AnyObject> {
            
            //-----------------------------------------------------------------
            // Read the root configuration
            var configuration = readLoggerPList("ROOT", map: map);
            //Swell.info("map: \(map)");
            
            // Now any values configured, we put in our root configuration
            if let formatter = configuration.formatter {
                rootConfiguration.formatter = formatter
            }
            if let level = configuration.level {
                rootConfiguration.level = level
            }
            if configuration.locations.count > 0 {
                rootConfiguration.locations = configuration.locations
            }
            
            //-----------------------------------------------------------------
            // Now look for any keys that don't start with SWL, and if it contains a dictionary value, let's read it
            let keys = map.keys
            for key in keys {
                if (!key.hasPrefix("SWL")) {
                    let value: AnyObject? = map[key]
                    if let submap: Dictionary<String, AnyObject> = value as? Dictionary<String, AnyObject> {
                        var subconfig = readLoggerPList(key, map: submap)
                        applyLoggerConfiguration(key, configuration: subconfig)
                    }
                }
            }
            
            //-----------------------------------------------------------------
            // Now check if there is an enabled/disabled rule specified
            var item: AnyObject? = nil
            // Set the LogLevel
            
            item = map["SWLEnable"]
            if let value: AnyObject = item {
                if let rule: String = value as? String {
                    selector.enableRule = rule
                }
            }
            
            item = map["SWLDisable"]
            if let value: AnyObject = item {
                if let rule: String = value as? String {
                    selector.disableRule = rule
                }
            }
            
        }
        
    }
    
    
    /// Specifies or modifies the configuration of a logger.
    /// If any aspect of the configuration was not provided, and there is a pre-existing value for it,
    /// the pre-existing value will be used for it.
    /// For example, if two consecutive calls were made:
    ///     configureLogger("MyClass", level: LogLevel.DEBUG, formatter: MyCustomFormatter())
    ///     configureLogger("MyClass", level: LogLevel.INFO, location: ConsoleLocation())
    ///  then the resulting configuration for MyClass would have MyCustomFormatter, ConsoleLocation, and LogLevel.INFO.
    func configureLogger(loggerName: String,
        level givenLevel: LogLevel? = nil,
        formatter givenFormatter: LogFormatter? = nil,
        location givenLocation: LogLocation? = nil) {

        var oldConfiguration: LoggerConfiguration?
        if allConfigurations.indexForKey(loggerName) != nil {
            oldConfiguration = allConfigurations[loggerName]
        }

        var newConfiguration = LoggerConfiguration(name: loggerName)
            
        if let level = givenLevel {
            newConfiguration.level = level
        } else if let level = oldConfiguration?.level {
            newConfiguration.level = level
        }
        
        if let formatter = givenFormatter {
            newConfiguration.formatter = formatter
        } else if let formatter = oldConfiguration?.formatter {
            newConfiguration.formatter = formatter
        }
        
        if let location = givenLocation {
            newConfiguration.locations += [location]
        } else if oldConfiguration?.locations.count > 0 {
            newConfiguration.locations = oldConfiguration!.locations
        }
        
        applyLoggerConfiguration(loggerName, configuration: newConfiguration)
    }
    

    /// Store the configuration given for the specified logger.
    /// If the logger already exists, update its configuration to reflect what's in the logger.

    func applyLoggerConfiguration(loggerName: String, configuration: LoggerConfiguration) {
        // Record this custom config in our map
        allConfigurations[loggerName] = configuration

        // See if the logger with the given name already exists.
        // If so, update the configuration it's using.
        if let logger = allLoggers[loggerName] {

            // TODO - There should be a way to keep calls to logger.log while this is executing
            if let level = configuration.level {
                logger.level = level
            }
            if let formatter = configuration.formatter {
                logger.formatter = formatter
            }
            if configuration.locations.count > 0 {
                logger.locations.removeAll(keepCapacity: false)
                logger.locations += configuration.locations
            }
        }
        
    }

    
    func readLoggerPList(loggerName: String, map: Dictionary<String, AnyObject>) -> LoggerConfiguration {
        var level: LogLevel?
        var formatter: LogFormatter?
        var location: LogLocation?
        var configuration = LoggerConfiguration(name: loggerName)
        var item: AnyObject? = nil
        // Set the LogLevel
        
        item = map["SWLLevel"]
        if let value: AnyObject = item {
            if let level: String = value as? String {
                configuration.level = LogLevel.getLevel(level)
            }
        }
        
        // Set the formatter;  First, look for a QuickFormat spec
        item = map["SWLQuickFormat"]
        if let value: AnyObject = item {
            configuration.formatter = getConfiguredQuickFormatter(configuration, item: value);
        } else {
            // If no QuickFormat was given, look for a FlexFormat spec
            item = map["SWLFlexFormat"]
            if let value: AnyObject = item {
                configuration.formatter = getConfiguredFlexFormatter(configuration, item: value);
            }
        }
        
        // Set the location for the logs
        item = map["SWLLocation"]
        if let value: AnyObject = item {
            configuration.locations = getConfiguredLocations(configuration, item: value, map: map);
        }
        
        return configuration
    }
    
    
    func getConfiguredQuickFormatter(configuration: LoggerConfiguration, item: AnyObject) -> LogFormatter? {
        if let formatString: String = item as? String {
            var formatter = QuickFormatter.logFormatterForString(formatString)
            return formatter
        }
        return nil
    }
    
    func getConfiguredFlexFormatter(configuration: LoggerConfiguration, item: AnyObject) -> LogFormatter? {
        if let formatString: String = item as? String {
            var formatter = FlexFormatter.logFormatterForString(formatString);
            return formatter
        }
        return nil
    }
    
    func getConfiguredFileLocation(configuration: LoggerConfiguration, item: AnyObject) -> LogLocation? {
        if let filename: String = item as? String {
            var logLocation = FileLocation.getInstance(filename);
            return logLocation
        }
        return nil
    }
    
    func getConfiguredLocations(configuration: LoggerConfiguration, item: AnyObject,
        map: Dictionary<String, AnyObject>) -> [LogLocation] {
        var results = [LogLocation]()
        if let configuredValue: String = item as? String {
            // configuredValue is the raw value in the plist
            
            // values is the array from configuredValue
            let values = configuredValue.lowercaseString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

            for value in values {
                if (value == "file") {
                    // handle file name
                    var filenameValue: AnyObject? = map["SWLLocationFilename"]
                    if let filename: AnyObject = filenameValue {
                        let fileLocation = getConfiguredFileLocation(configuration, item: filename);
                        if fileLocation != nil {
                            results += [fileLocation!]
                        }
                    }
                } else if (value == "console") {
                    results += [ConsoleLocation.getInstance()]
                } else {
                    println("Unrecognized location value in Swell.plist: '\(value)'")
                }
            }
        }
        return results
    }
    

}


