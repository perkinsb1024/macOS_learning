//
//  WindowController.swift
//  StormViewer
//
//  Created by Ben Perkins on 7/20/17.
//  Copyright © 2017 BenPerkins. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    @IBOutlet var shareButton: NSButton!
    override func windowDidLoad() {
        super.windowDidLoad()
    
        shareButton.sendAction(on: .leftMouseDown)
    }

}
