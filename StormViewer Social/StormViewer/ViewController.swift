//
//  ViewController.swift
//  StormViewer
//
//  Created by Ben Perkins on 7/13/17.
//  Copyright © 2017 BenPerkins. All rights reserved.
//

import Cocoa

class ViewController: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func shareButtonEvent(_ sender: NSView) {
        guard let detailViewController = childViewControllers[1] as? DetailViewController else { return }
        guard let image = detailViewController.imageView?.image else {
            let alert = NSAlert()
            alert.messageText = "Please select an image"
            alert.addButton(withTitle: "Ok")
            alert.runModal()
            return
        }
        
        let picker = NSSharingServicePicker(items: [image])
        picker.show(relativeTo: .zero, of: sender, preferredEdge: .minY)
    }


}

