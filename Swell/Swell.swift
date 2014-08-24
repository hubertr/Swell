//
//  Swell.swift
//  Swell
//
//  Created by Hubert Rabago on 6/26/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//
import Foundation


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
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.trace(message)
    }
    
    public class func debug<T>(message: @autoclosure() -> T) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.debug(message)
    }
    
    public class func info<T>(message: @autoclosure() -> T) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.info(message)
    }
    
    public class func warn<T>(message: @autoclosure() -> T) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.warn(message)
    }
    
    public class func error<T>(message: @autoclosure() -> T) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.error(message)
    }
    
    public class func severe<T>(message: @autoclosure() -> T) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.severe(message)
    }

    public class func trace(fn: () -> String) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.trace(fn)
    }
    
    public class func debug(fn: () -> String) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.debug(fn)
    }
    
    public class func info(fn: () -> String) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.info(fn)
    }
    
    public class func warn(fn: () -> String) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.warn(fn)
    }
    
    public class func error(fn: () -> String) {
        if globalSwell.swellLogger == nil {
            globalSwell.initInternalLogger()
        }
        globalSwell.swellLogger.error(fn)
    }
    
    public class func severe(fn: () -> String) {
        if globalSwell.swellLogger == nil {
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

        var filename: String? = NSBundle.mainBundle().pathForResource("Swell", ofType: "plist");
        //if let bundle = NSBundle.mainBundle() {
        //    filename = NSBundle.mainBundle().pathForResource("Swell", ofType: "plist")
        //}
        
        var dict: NSDictionary? = nil;
        if let bundleFilename = filename {
            dict = NSDictionary(contentsOfFile: bundleFilename)
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
            } else {
                let formatKey = getFormatKey(map)
                println("formatKey=\(formatKey)")
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
    
//    if ((key.hasPrefix("SWL")) && (key.hasSuffix("Format"))) {
//    let start = advance(key.startIndex, 3)
//    let end = advance(key.endIndex, -6)
//    let result: String = key[start..<end]
//    //println("result=\(result)")
//    return result
//    }

    
    func getFormatKey(map: Dictionary<String, AnyObject>) -> String? {
        for (key, value) in map {
            if ((key.hasPrefix("SWL")) && (key.hasSuffix("Format"))) {
                let start = advance(key.startIndex, 3)
                let end = advance(key.endIndex, -6)
                let result: String = key[start..<end]
                println("result=\(result)")
                return result
            }
        }
        
        return nil;
    }
    

    func getFunctionFormat(function: String) -> String {
        var result = function;
        if (result.hasPrefix("Optional(")) {
            let len = countElements("Optional(")
            let start = advance(result.startIndex, len)
            let end = advance(result.endIndex, -len)
            let range = start..<end
            result = result[range]
        }
        if (!result.hasSuffix(")")) {
            result = result + "()"
        }
        return result
    }
    


}


