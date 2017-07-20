//
//  SourceViewController.swift
//  StormViewer
//
//  Created by Ben Perkins on 7/13/17.
//  Copyright © 2017 BenPerkins. All rights reserved.
//

import Cocoa

class SourceViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet var tableView: NSTableView!
    var photos = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileManager = FileManager.default
        let resourcePath = Bundle.main.resourcePath!
        do {
            let files = try fileManager.contentsOfDirectory(atPath: resourcePath)
            for file in files {
                if file.contains(".jpg") {
                    photos.append(file)
                }
            }
        } catch {
            print("Error reading files")
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row >= 0 && row < photos.count else {
            return nil
        }
        let cell = tableView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as? NSTableCellView
        cell?.textField?.stringValue = photos[row]
        cell?.imageView?.image = NSImage(imageLiteralResourceName: photos[row])
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        guard row >= 0 && row < photos.count else {
            return
        }
        let detailViewController = parent?.childViewControllers[1] as? DetailViewController
        detailViewController?.showPhoto(photos[row])
    }
    
    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        if tableView.selectedRow > 5 {
            return false
        }
        return true
    }
}
