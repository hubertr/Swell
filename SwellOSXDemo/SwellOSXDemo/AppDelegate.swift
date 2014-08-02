//
//  AppDelegate.swift
//  SwellOSXDemo
//
//  Created by Hubert Rabago on 7/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

import Cocoa

public class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet var window: NSWindow!

    @IBAction func traceClicked(sender: AnyObject) {
        Swell.trace("Trace was tapped")
    }
    
    @IBAction func debugClicked(sender: AnyObject) {
        Swell.debug("Debug was tapped")
    }
    
    @IBAction func infoClicked(sender: AnyObject) {
        Swell.info("Info was tapped")
    }
    
    @IBAction func warnClicked(sender: AnyObject) {
        Swell.warn("Warn was tapped")
    }
    
    @IBAction func errorClicked(sender: AnyObject) {
        Swell.error("Error was tapped")
    }
    
    @IBAction func severeClicked(sender: AnyObject) {
        Swell.severe("Severe was tapped")
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

