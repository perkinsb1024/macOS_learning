//
//  PhotoItem.swift
//  photoSelect
//
//  Created by Ben Perkins on 7/27/17.
//  Copyright © 2017 Ben Perkins. All rights reserved.
//

import Cocoa

class PhotoItem: NSCollectionViewItem {
    
    let selectedBorderWidth: CGFloat = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.layer?.borderColor = NSColor.blue.cgColor
    }
    
    override var isSelected: Bool {
        didSet {
            view.layer?.borderWidth = isSelected ? selectedBorderWidth : 0
        }
    }
    
    override var highlightState: NSCollectionViewItemHighlightState {
        didSet {
            switch highlightState {
            case .none:
                view.layer?.borderWidth = isSelected ? selectedBorderWidth : 0
            case .forDeselection:
                view.layer?.borderWidth = 0
            case .forSelection:
                view.layer?.borderWidth = selectedBorderWidth
            default:
                break
            }
        }
    }
    
}
