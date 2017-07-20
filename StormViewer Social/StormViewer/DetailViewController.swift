//
//  DetailViewController.swift
//  StormViewer
//
//  Created by Ben Perkins on 7/13/17.
//  Copyright © 2017 BenPerkins. All rights reserved.
//

import Cocoa

class DetailViewController: NSViewController {

    @IBOutlet var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func showPhoto(_ photo: String) {
        imageView.image = NSImage(imageLiteralResourceName: photo)
    }
    
}
