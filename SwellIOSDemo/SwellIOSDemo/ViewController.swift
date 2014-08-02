//
//  ViewController.swift
//  SwellIOSDemo
//
//  Created by Hubert Rabago on 7/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

import UIKit

public class ViewController: UIViewController {
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func traceTapped(sender: AnyObject) {
        Swell.trace("Trace was tapped")
    }
    
    @IBAction func debugTapped(sender: AnyObject) {
        Swell.debug("Debug was tapped")
    }
    
    @IBAction func infoTapped(sender: AnyObject) {
        Swell.info("Info was tapped")
    }
    
    @IBAction func warnTapped(sender: AnyObject) {
        Swell.warn("Warn was tapped")
    }
    
    @IBAction func errorTapped(sender: AnyObject) {
        Swell.error("Error was tapped")
    }
    
    @IBAction func severeTapped(sender: AnyObject) {
        Swell.severe("Severe was tapped")
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

