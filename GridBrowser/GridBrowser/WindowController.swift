//
//  WindowController.swift
//  GridBrowser
//
//  Created by Ben Perkins on 7/20/17.
//  Copyright © 2017 perkinsb1024. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    @IBOutlet var urlBar: NSTextField!

    override func windowDidLoad() {
        super.windowDidLoad()
    
        self.window?.titleVisibility = .hidden
    }
    

}
