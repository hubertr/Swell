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

