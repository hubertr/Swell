//
//  SwellTests.swift
//  SwellTests
//
//  Created by Hubert Rabago on 6/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

import Foundation
import XCTest
import Swell

public class SwellTestLocation: LogLocation {
    var logged: Bool = false
    var _message: String?
    func wasLogged() -> Bool {
        let result = logged
        logged = false
        return result
    }
    public func log(@autoclosure message: () -> String) {
        logged = true
        _message = message()
        //println(message)
    }
    
    public func enable() {}
    public func disable() {}
    public func description() -> String {
        return "SwellTestLocation"
    }
}


class SwellTests: XCTestCase {
    
    override func setUp() {
        //println("\n\n========================\nHello setUp\n\n")
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoggerAndLevel() {
        //var d = Swell.dummy
        let location = SwellTestLocation()
        
        let logger = Logger(name: "TestLevel", level:.INFO, formatter: QuickFormatter(format: .MessageOnly), logLocation: location)
        
        logger.trace("Hello trace level");
        if let _ = location._message {
            XCTFail("Should not have logged TRACE calls")
        }
        
        logger.debug("Hello debug level");
        if let _ = location._message {
            XCTFail("Should not have logged DEBUG calls")
        }

        logger.info("Hello info level");
        if let message = location._message {
            XCTAssertEqual(message, "Hello info level", "Pass")
        } else {
            XCTFail("Should have logged INFO call")
        }
        
        logger.warn("Hello warn level");
        if let message = location._message {
            XCTAssertEqual(message, "Hello warn level", "Pass")
        } else {
            XCTFail("Should have logged WARN call")
        }
        logger.error("Hello error level");
        if let message = location._message {
            XCTAssertEqual(message, "Hello error level", "Pass")
        } else {
            XCTFail("Should have logged ERROR call")
        }
        logger.severe("Hello severe level");
        if let message = location._message {
            XCTAssertEqual(message, "Hello severe level", "Pass")
        } else {
            XCTFail("Should have logged SEVERE call")
        }
        
        logger.error(0);
        if let message = location._message {
            XCTAssertEqual(message, "0", "Pass")
        } else {
            XCTFail("Should have logged ERROR call")
        }
        
        let date = NSDate()
        logger.error(date);
        if let message = location._message {
            XCTAssertEqual(date.description, message, "Pass")
        } else {
            XCTFail("Should have logged ERROR call")
        }
        
        logger.error(12.234);
        if let message = location._message {
            XCTAssertEqual(message, "12.234", "Pass")
        } else {
            XCTFail("Should have logged ERROR call")
        }

        let customLevel = LogLevel(level: 450, name: "custom", label: "CUSTOM");
        logger.log(customLevel, message: [0, 0, 1]);
        if let message = location._message {
            XCTAssertEqual(message, "[0, 0, 1]", "Pass")
        } else {
            XCTFail("Should have logged level 450 call")
        }

        XCTAssert(true, "Pass")
        
    }
    
    
    // This test doesn't make assertions - I'm just using this to manually test file output
    func testFileLogger() {
        
        let location: LogLocation = FileLocation.getInstance("log.txt");
        //location = ConsoleLocation();
        let logger = Logger(name: "FileTester", level: .TRACE, logLocation: location);
        logger.trace("Hello trace level");
        logger.debug("Hello debug level");
        logger.info("Hello info level");
        logger.warn("Hello warn level");
        logger.error("Hello error level");
        logger.severe("Hello severe level");
        logger.error(0);
        logger.error(NSDate());
        logger.error(12.234);
        let customLevel = LogLevel(level: 450, name: "custom", label: "CUSTOM");
        logger.log(customLevel, message: [0, 0, 1]);
        //XCTAssert(true, "Pass")
        
    }

    // This test doesn't make assertions - I'm just using this to manually test Swell log functions
    func testSwell() {
        
        Swell.trace("Hello trace level");
        Swell.debug("Hello debug level");
        Swell.info("Hello info level");
        Swell.warn("Hello warn level");
        Swell.error("Hello error level");
        Swell.severe("Hello severe level");
        Swell.error(0);
        Swell.error(NSDate());
        Swell.error(12.234);
        //XCTAssert(true, "Pass")
        
        //Swell.testReadPlist()
    }
    
    // This test doesn't make assertions yet
    func testSwellGetLogger() {
        
        let logger = Swell.getLogger("SwellTester")
        // TODO
        logger.trace("Hello trace level");
        logger.debug("Hello debug level");
        logger.info("Hello info level");
        logger.warn("Hello warn level");
        logger.error("Hello error level");
        logger.severe("Hello severe level");
        logger.severe("Hello SwellTester level");
        logger.error(0);
        logger.error(NSDate());
        logger.error(12.234);
        let customLevel = LogLevel(level: 450, name: "custom", label: "CUSTOM");
        logger.log(customLevel, message: [0, 0, 1]);
        //XCTAssert(true, "Pass")
        
    }
    
    func testClosureLogger() {
        
        let logger = Swell.getLogger("Closure")
        logger.level = .INFO
        var wasLogged: Bool = false
        logger.trace {
            wasLogged = true
            let x = 100
            return "This is my \(x) value"
        };
        XCTAssert(!wasLogged, "Pass")

        wasLogged = false
        logger.debug {
            wasLogged = true
            let x = 100
            return "This is my \(x) value"
        };
        XCTAssert(!wasLogged, "Pass")
        
        wasLogged = false
        logger.info {
            wasLogged = true
            let x = 100
            return "This is my \(x) value"
        };
        
        
        XCTAssert(wasLogged, "Pass")
        
    }
    
    // This test doesn't make assertions yet
    func testSwellGetFileLogger() {
        
        let logger = Swell.getLogger("SwellFileTester")
        logger.trace("Hello trace level");
        logger.debug("Hello debug level");
        logger.info("Hello info level");
        logger.warn("Hello warn level");
        logger.error("Hello error level");
        logger.severe("Hello severe level");
        logger.severe("Hello SwellTester level");
        logger.error(0);
        logger.error(NSDate());
        logger.error(12.234);
        let customLevel = LogLevel(level: 450, name: "custom", label: "CUSTOM");
        logger.log(customLevel, message: [0, 0, 1]);
        XCTAssert(true, "Pass")
        
    }
    
    
    func testLogSelectorParsing() {
        let selector = LogSelector()
        selector.enableRule = "a,b,c";
        XCTAssertEqual(selector.enabled.count, 3, "Pass")
        
        selector.enableRule = ",a,b,c";
        XCTAssertEqual(selector.enabled.count, 3, "Pass")
        
        selector.enableRule = "a,b,c,";
        XCTAssertEqual(selector.enabled.count, 3, "Pass")
        
        selector.enableRule = "a,,c,";
        XCTAssertEqual(selector.enabled.count, 2, "Pass")
    }
    
    func testLogSelector() {
        let ls = LogSelector()
        XCTAssert(ls.shouldEnableLoggerWithName("aaa"))
        
        ls.enableRule = "aaa,bbb"
        XCTAssert(ls.shouldEnableLoggerWithName("aaa"))
        XCTAssert(ls.shouldEnableLoggerWithName("bbb"))
        XCTAssert(!ls.shouldEnableLoggerWithName("ccc"))
        
        ls.disableRule = "aaa"
        XCTAssert(!ls.shouldEnableLoggerWithName("aaa"))
        XCTAssert(ls.shouldEnableLoggerWithName("bbb"))
        XCTAssert(!ls.shouldEnableLoggerWithName("ccc"))

        ls.enableRule = "ccc"
        ls.disableRule = ""
        XCTAssert(!ls.shouldEnableLoggerWithName("aaa"))
        XCTAssert(!ls.shouldEnableLoggerWithName("bbb"))
        XCTAssert(ls.shouldEnableLoggerWithName("ccc"))
        
        ls.enableRule = ""
        ls.disableRule = "bbb"
        XCTAssert(ls.shouldEnableLoggerWithName("aaa"))
        XCTAssert(!ls.shouldEnableLoggerWithName("bbb"))
        XCTAssert(ls.shouldEnableLoggerWithName("ccc"))
    }

    // This test doesn't make assertions yet    
    func testObjC() {
        
        let logger = Logger(name: "Tester")
        logger.traceMessage("Hello trace level");
        logger.debugMessage("Hello debug level");
        logger.infoMessage("Hello info level");
        logger.warnMessage("Hello warn level");
        logger.errorMessage("Hello error level");
        logger.severeMessage("Hello severe level");
        logger.errorMessage("\(0)");
        logger.errorMessage("\(NSDate())");
        logger.errorMessage("\(12.234)");
        XCTAssert(true, "Pass")
    
    }
    
    
    class MyClass {
        var x = 0
        func incX() -> String {
            return "x is now \(++x)"
        }
    }
    
    func testConditionalExecution() {
        let logger = Logger(name: "Conditional", level: .INFO)
        let myClass = MyClass()
        logger.trace(myClass.incX())  // shouldn't trigger incX()
        logger.debug(myClass.incX())  // shouldn't trigger incX()
        logger.info(myClass.incX())
        logger.warn(myClass.incX())
        logger.error(myClass.incX())
        XCTAssertEqual(myClass.x, 3, "True")
    }
    
    
    func testFlexFormatter() {
        let location = SwellTestLocation()
        var formatter = FlexFormatter(parts: .NAME, .MESSAGE)
        
        let logger = Logger(name: "TestFlexFormatter", level:.INFO, formatter: formatter, logLocation: location)
        logger.info("Log this")
        
        print("Formatter \(formatter.description())")
        if let message = location._message {
            XCTAssertEqual(message, "TestFlexFormatter: Log this", "Pass")
        } else {
            XCTFail("Fail")
        }

        //formatter.format = [.LEVEL, .NAME, .MESSAGE]
        formatter = FlexFormatter(parts: .LEVEL, .NAME, .MESSAGE)
        logger.formatter = formatter
        logger.warn("Warn of this")
        if let message = location._message {
            XCTAssertEqual(message, " WARN TestFlexFormatter: Warn of this", "Pass")
        } else {
            XCTFail("Fail")
        }
        print("Formatter \(formatter.description())")
        
        //formatter.format = [.MESSAGE, .LEVEL, .NAME]
        formatter = FlexFormatter(parts: .MESSAGE, .LEVEL, .NAME)
        logger.formatter = formatter
        logger.warn("Warn of this")
        if let message = location._message {
            XCTAssertEqual(message, "Warn of this  WARN TestFlexFormatter", "Pass")
        } else {
            XCTFail("Fail")
        }
        
        formatter = FlexFormatter(parts: .MESSAGE, .LEVEL, .FUNC)
        logger.formatter = formatter
        logger.warn("Warn of this")
        if let message = location._message {
            XCTAssertEqual(message, "Warn of this  WARN [testFlexFormatter()]", "Pass")
        } else {
            XCTFail("Fail")
        }
        
        print("Formatter \(formatter.description())")
    }
    
    
    func testFlexPerformance() {
        // This is an example of a performance test case.
        let location = SwellTestLocation()
        let formatter = FlexFormatter(parts: .LEVEL, .NAME, .MESSAGE)
        
        let logger = Logger(name: "TestFlexPerformance", level:.INFO, formatter: formatter, logLocation: location)

        self.measureBlock() {
            // Put the code you want to measure the time of here.
            for _ in 1...5000 {
                logger.info("This is my message")
            }
        }
    }
    
    func testFlexSlowestPerformance() {
        // This is an example of a performance test case.
        let location = SwellTestLocation()
        let formatter = FlexFormatter(parts: .DATE, .LEVEL, .NAME, .MESSAGE)
        
        let logger = Logger(name: "TestFlexPerformance", level:.INFO, formatter: formatter, logLocation: location)
        
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            for _ in 1...5000 {
                logger.info("This is my message")
            }
        }
    }
    
    func testQuickPerformance() {
        // This is an example of a performance test case.
        let location = SwellTestLocation()
        let formatter = QuickFormatter(format: .LevelNameMessage)
        
        let logger = Logger(name: "TestQuickPerformance", level:.INFO, formatter: formatter, logLocation: location)
        
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            for _ in 1...5000 {
                logger.info("This is my message")
            }
        }
    }
    
    func testQuickSlowestPerformance() {
        // This is an example of a performance test case.
        let location = SwellTestLocation()
        let formatter = QuickFormatter(format: .All)
        
        let logger = Logger(name: "TestQuickPerformance", level:.INFO, formatter: formatter, logLocation: location)
        
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            for _ in 1...5000 {
                logger.info("This is my message")
            }
        }
    }
    
}
