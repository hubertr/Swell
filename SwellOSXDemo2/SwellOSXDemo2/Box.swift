//
//  Box.swift
//  SwellOSXDemo2
//
//  Created by Hubert Rabago on 7/20/14.
//  Copyright (c) 2014 Minute Apps LLC. All rights reserved.
//

import Foundation

class Box {
    var logger = Swell.getLogger("Box")
    
    func debug() {
        logger.debug("Box debug was clicked")
    }
    
    func info() {
        logger.info("Box info was clicked")
    }
    
    func error() {
        logger.error("Box error was clicked")
    }
    
}