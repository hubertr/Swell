//
//  FirstViewController.swift
//  SwellIOSDemo2
//
//  Created by Hubert Rabago on 7/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

import UIKit

public class FirstViewController: UIViewController {
                            
    let logger = Swell.getLogger("FirstViewController")
    
    @IBAction func traceTapped(sender: AnyObject) {
        logger.trace("Trace was tapped")
    }
    
    @IBAction func debugTapped(sender: AnyObject) {
        logger.debug("Debug was tapped")
    }
    
    @IBAction func infoTapped(sender: AnyObject) {
        logger.info("Info was tapped")
    }
    
    @IBAction func warnTapped(sender: AnyObject) {
        logger.warn("Warn was tapped")
    }
    
    @IBAction func errorTapped(sender: AnyObject) {
        logger.error("Error was tapped")
    }
    
    @IBAction func severeTapped(sender: AnyObject) {
        logger.severe("Severe was tapped")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

