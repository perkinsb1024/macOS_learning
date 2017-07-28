//
//  ViewController.swift
//  photoSelect
//
//  Created by Ben Perkins on 7/27/17.
//  Copyright © 2017 Ben Perkins. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {

    @IBOutlet var photoCollectionView: NSCollectionView!
    var photos = [URL]()
    let validExtensions = ["jpg", "jpeg", "gif", "png"]
    lazy var photosPath: URL = {
        let fm = FileManager.default
        let paths = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsPath = paths[0]
        let savePath = documentsPath.appendingPathComponent("photoSelect")
        
        if !fm.fileExists(atPath: savePath.path) {
            try? fm.createDirectory(at: savePath, withIntermediateDirectories: true)
        }
        return savePath
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.wantsLayer = true
        photoCollectionView.layer?.backgroundColor = NSColor.brown.cgColor
        
        do {
            let fm = FileManager.default
            let files = try fm.contentsOfDirectory(at: photosPath, includingPropertiesForKeys: nil)
            
            for file in files {
                if validExtensions.contains(file.pathExtension.lowercased()) {
                    photos.append(file)
                }
            }
        }
        catch {
            print("Set up error")
            exit(1)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "PhotoItem", for: indexPath)
        guard let photoItem = item as? PhotoItem else { return item }
        
        photoItem.imageView?.image = NSImage(byReferencing: photos[indexPath.item])
        
        return photoItem
    }


}

