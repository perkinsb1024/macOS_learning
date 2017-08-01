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
    var itemsBeingDragged: Set<IndexPath>?
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
        photoCollectionView.register(forDraggedTypes: [kUTTypeURL as String])

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

    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        return .move
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        
        itemsBeingDragged = indexPaths
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        
        itemsBeingDragged = nil
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {
        if let moveItems = itemsBeingDragged?.sorted() {
            performInternalDrag(with: moveItems, at: indexPath)
        }
        else {
            let pasteboard = draggingInfo.draggingPasteboard()
            guard let items = pasteboard.pasteboardItems else { return true }
            performExternalDrag(with: items, at: indexPath)
        }
        return true
    }
    
    func performInternalDrag(with items: [IndexPath]?, at index: IndexPath) {
        guard items != nil else { return }
        
    }

    func performExternalDrag(with items: [NSPasteboardItem], at index: IndexPath) {
        print("External Drag for \(items), at \(index)")
        let fm = FileManager.default
        for item in items {
            guard let stringUrl = item.string(forType: kUTTypeFileURL as String) else { continue }
            guard let source = URL(string: stringUrl) else { continue }
            let destination = photosPath.appendingPathComponent(source.lastPathComponent)
            
            do {
                try fm.copyItem(at: source, to: destination)
            }
            catch {
                print("Could not copy \(source)")
            }
            photos.insert(destination, at: index.item)
            photoCollectionView.insertItems(at: [index])
        }
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        
        return photos[indexPath.item] as NSPasteboardWriting?
    }
}

