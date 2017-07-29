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
        
        let mode = LayoutMode.grid
        
        switch(mode) {
            case .vfl:
            createVfl()
            case .anchor:
            createAnchors()
            case .stack:
            createStackview()
            case .grid:
            if #available(OSX 10.12, *) {
                self.createGridview()
            }
            break
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
        var previous: NSView!
        let views = [makeView(with: 0), makeView(with: 1), makeView(with: 2), makeView(with: 3)]
        
        for v in views {
            view.addSubview(v)
            v.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            v.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            if previous != nil {
                v.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 10).isActive = true
            }
            else {
                v.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
            }
            previous = v
        }
        
        previous.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
    }
    
    func createStackview() {
        let views = [makeView(with: 0), makeView(with: 1), makeView(with: 2), makeView(with: 3)]
        let stackView = NSStackView(views: views)
        view.addSubview(stackView)
        
        stackView.orientation = .vertical
        stackView.distribution = .fillEqually
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }
    
    @available(OSX 10.12, *)
    func createGridview() {
        let empty = NSGridCell.emptyContentView
        let gridView = NSGridView(views: [
        [makeView(with: 0)],
        [makeView(with: 1), empty, makeView(with: 2)],
        [makeView(with: 3), makeView(with: 4), makeView(with: 5), makeView(with: 6)],
        [makeView(with: 7), empty, makeView(with: 8)],
        [makeView(with: 9)]
        ])
        
        view.addSubview(gridView)
        
        gridView.translatesAutoresizingMaskIntoConstraints = false
        gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gridView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gridView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        for r in 0..<gridView.numberOfRows {
            let row = gridView.row(at: r)
            row.height = 32
            row.yPlacement = .center
            switch r {
            case 0, 4:
                row.mergeCells(in: NSRange(location: 0, length: 4))
            case 1, 3:
                row.mergeCells(in: NSRange(location: 0, length: 2))
                row.mergeCells(in: NSRange(location: 2, length: 2))
            default:
                break
            }
        }
        
        for c in 0..<gridView.numberOfColumns {
            let column = gridView.column(at: c)
            column.width = 128
            column.xPlacement = .center
        }
    }
    
}

