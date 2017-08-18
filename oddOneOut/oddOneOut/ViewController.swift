//
//  ViewController.swift
//  oddOneOut
//
//  Created by Ben Perkins on 8/18/17.
//  Copyright © 2017 Ben Perkins. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    var visualEffectView: NSVisualEffectView!
    var gridViewButtons = [NSButton]()
    let gridSize = 10
    let gridMargin: CGFloat = 5
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func loadView() {
        super.loadView()
        
        visualEffectView = NSVisualEffectView()
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        // Dark vibrancy, always active
        visualEffectView.material = .dark
        visualEffectView.state = .active
        
        // Pin it to the parent view
        view.addSubview(visualEffectView)
        visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        visualEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        var title = createTitle()
    }
    
    func createTitle() -> NSTextField {
        let titleString = "Odd One Out"
        let title = NSTextField()
        title.isEditable = false
        title.isSelectable = false
        title.isBezeled = false
        title.isBordered = false
        title.stringValue = titleString
        title.font = NSFont.systemFont(ofSize: 36, weight: NSFontWeightThin)
        title.textColor = .white
        title.backgroundColor = .clear
        title.translatesAutoresizingMaskIntoConstraints = false
        
        visualEffectView.addSubview(title)
        title.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: gridMargin).isActive = true
        title.centerXAnchor.constraint(equalTo: visualEffectView.centerXAnchor).isActive = true
        
        return title
    }
}

