//
//  ViewController.swift
//  autolayoutTest
//
//  Created by Ben Perkins on 7/25/17.
//  Copyright © 2017 Ben Perkins. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    enum LayoutMode {
        case vfl
        case anchor
        case stack
        case grid
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mode = LayoutMode.vfl

        switch(mode) {
        case .vfl:
            createVfl()
        case .anchor:
            createAnchors()
        case .stack:
            createStackview()
        case .grid:
            createGridview()
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func makeView(with number: Int) -> NSTextField {
        let label = NSTextField()
        label.stringValue = "Label \(number)"
        label.isEditable = false
        label.isSelectable = false
        label.isBezeled = false
        label.drawsBackground = false
        label.alignment = .center
        label.wantsLayer = true
        label.layer?.backgroundColor = NSColor.cyan.cgColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func createVfl() {
        let views = ["view0": makeView(with: 0), "view1": makeView(with: 1), "view2": makeView(with: 2), "view3": makeView(with: 3)]
        for (name, v) in views {
            view.addSubview(v)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[\(name)]|", options: [], metrics: nil, views: views))
        }
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view0]-[view1]-[view2]-[view3]|", options: [], metrics: nil, views: views))
    }
    
    func createAnchors() {
        
    }
    
    func createStackview() {
        
    }
    
    func createGridview() {
        
    }

}

