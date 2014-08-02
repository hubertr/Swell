//
//  AppDelegate.swift
//  SwellOSXDemo2
//
//  Created by Hubert Rabago on 7/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

import Cocoa

public class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet var window: NSWindow!
    
    
    var logger = Swell.getLogger("AppDelegate")
    var box = Box()
    

    @IBAction func traceClicked(sender: AnyObject) {
        logger.trace("Trace was tapped")
    }
    
    @IBAction func debugClicked(sender: AnyObject) {
        logger.debug("Debug was tapped")
    }
    
    @IBAction func infoClicked(sender: AnyObject) {
        logger.info("Info was tapped")
    }
    
    @IBAction func warnClicked(sender: AnyObject) {
        logger.warn("Warn was tapped")
    }
    
    @IBAction func errorClicked(sender: AnyObject) {
        logger.error("Error was tapped")
    }
    
    @IBAction func severeClicked(sender: AnyObject) {
        logger.severe("Severe was tapped")
    }
    

    
    @IBAction func boxDebugClicked(sender: AnyObject) {
        box.debug()
    }
    
    @IBAction func boxInfoClicked(sender: AnyObject) {
        box.info()
    }
    
    @IBAction func boxErrorClicked(sender: AnyObject) {
        box.error()
    }
    

    
    
    
    @IBAction func disableClicked(sender: AnyObject) {
        Swell.disableLogging()
    }
    
    public func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
    }

    public func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


}

