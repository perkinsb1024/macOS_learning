//
//  ViewController.swift
//  photoSelect
//
//  Created by Ben Perkins on 7/27/17.
//  Copyright © 2017 Ben Perkins. All rights reserved.
//

import Cocoa
import AVFoundation

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
        guard let items = items else { return }
        var newIndex = index
        var moveItems = [URL]()
        for item in items.reversed() {
            if item.item < index.item {
                newIndex.item -= 1
            }
            moveItems.append(photos[item.item])
            photos.remove(at: item.item)
        }
        photos.insert(contentsOf: moveItems.reversed(), at: newIndex.item)

        //photoCollectionView.insertItems(at: [index])
        DispatchQueue.main.async {
            //self.photoCollectionView.reloadData()
            self.photoCollectionView.reloadItems(at: self.photoCollectionView.indexPathsForVisibleItems())
        }
        
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
    
    override func keyUp(with event: NSEvent) {
        guard photoCollectionView.selectionIndexes.count > 0 else { return }
        guard event.charactersIgnoringModifiers == String(UnicodeScalar(NSDeleteCharacter)!) else { return }
        
        let fm = FileManager.default
        for index in photoCollectionView.selectionIndexes.sorted().reversed() {
            do {
                try fm.trashItem(at: photos[index], resultingItemURL: nil)
                photos.remove(at: index)
            }
            catch {
                print("Failed to delete photo")
            }
        }
        photoCollectionView.animator().deleteItems(at: photoCollectionView.selectionIndexPaths)
    }
    
    func exportFinished(error: Error?) {
        
        let message: String
        
        if let error = error {
            
            message = "Error: \(error.localizedDescription)"
            
        } else {
            
            message = "Sucess!"
        }
        
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    }
    
    func createText(frame: CGRect) -> CALayer {
        
        //create a dictionary of text attributes
        let attrs = [NSFontAttributeName : NSFont.boldSystemFont(ofSize: 24), NSForegroundColorAttributeName: NSColor.green]
        
        //combine those attributes with our message
        let text = NSAttributedString(string: "PhotoSelect Project 7", attributes: attrs)
        
        //figure out how big the full string is
        let textSize = text.size()
        
        //create the text layer
        let textLayer = CATextLayer()
        
        //make the text layer the correct size
        textLayer.bounds = CGRect(origin: CGPoint.zero, size: textSize)
        
        //make it align itself by its bottom-right corner
        textLayer.anchorPoint = CGPoint(x: 1, y: 1)
        
        //position it just up from the bottom-right of the render frame
        textLayer.position = CGPoint(x: frame.maxX - 10, y: textSize.height + 10)
        
        //give it the attributed string we created
        textLayer.string = text
        
        //force it to render immediately
        textLayer.display()
        
        //send it back to be added to the final render
        return textLayer
    }
    
    func createSlideShow(frame: CGRect, duration: CFTimeInterval) -> CALayer {
        
        //create the layer for our slideshow
        let imageLayer = CALayer()
        
        //position it so it fills its space and is centered
        imageLayer.bounds = frame
        imageLayer.position = CGPoint(x: imageLayer.bounds.midX, y: imageLayer.bounds.midY)
        
        //make it stretch its content to fit
        imageLayer.contentsGravity = kCAGravityResizeAspectFill
        
        //create a keyframe animation of the contents property
        let fadeAnim = CAKeyframeAnimation(keyPath: "contents")
        
        //tell it to last as long as we need
        fadeAnim.duration = duration
        
        //configure the properties
        fadeAnim.isRemovedOnCompletion = false
        fadeAnim.beginTime = AVCoreAnimationBeginTimeAtZero
        
        //prepare an array of all the NSImage objects we want to show
        var values = [NSImage]()
        
        //loop through every photo, adding it twice se we're not constantly animating
        for photo in photos {
            
            if let image = NSImage(contentsOfFile: photo.path) {
                
                values.append(image)
                values.append(image)
            }
        }
        //assign tha array to the animation
        fadeAnim.values = values
        
        //then add the animation to the layer
        imageLayer.add(fadeAnim, forKey: nil)
        
        return imageLayer
    }
    
    func createVideoLayer(in parentLayer: CALayer, composition: AVMutableComposition, videoComposition: AVMutableVideoComposition, timeRange: CMTimeRange) -> CALayer {
        
        //create a layer for the video
        let videoLayer = CALayer()
        
        //configure our post-processing animation tool
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        //prepare to add the black.mp4 video
        let mutableCompositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        //find and load the black.mp4 video
        let trackURL = Bundle.main.url(forResource: "black", withExtension: "mp4")!
        let asset = AVAsset(url: trackURL)
        
        //pull out its video
        let track = asset.tracks[0]
        
        //insert it into the track, filling all the time we need
        try! mutableCompositionVideoTrack.insertTimeRange(timeRange, of: track, at: kCMTimeZero)
        
        //send the video layer back
        return videoLayer
    }
    
    func exportMovie(at size: NSSize) throws {
        
        //1 - 2 seconds per photo
        let videoDuration = Double(photos.count * 2)
        let timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(videoDuration, 600))
        
        //2 - create a URL we can save our video to, then delete it if it already exists
        let savePath = photosPath.appendingPathComponent("video.mp4")
        let fm = FileManager.default
        
        if fm.fileExists(atPath: savePath.path) {
            try fm.removeItem(at: savePath)
        }
        
        //3 - create a composition for our entire render
        let mutableComposition = AVMutableComposition()
        
        //4 - create a video composition for our post-processing video work (this is the only thing we're doing)
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = size
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        //5 - create a master CALayer that will hold all the child layers
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        //6 - add all three child layers to the master layer
        parentLayer.addSublayer(createVideoLayer(in: parentLayer, composition: mutableComposition, videoComposition: videoComposition, timeRange: timeRange))
        parentLayer.addSublayer(createSlideShow(frame: parentLayer.frame, duration: videoDuration))
        parentLayer.addSublayer(createText(frame: parentLayer.frame))
        
        //7 - create video rendering instructions saying how long a video we want
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = timeRange
        videoComposition.instructions = [instruction]
        
        //8 - create an export session for our whole composition, requesting maximum quality
        let exportSession = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality)!
        
        //9 - point the export session at the URL to our save file, pass it the post-processing work, and ask for an MPEG4 in return
        exportSession.outputURL = savePath
        exportSession.videoComposition = videoComposition
        exportSession.outputFileType = AVFileTypeMPEG4
        
        //10 - start the export
        exportSession.exportAsynchronously { [unowned self] in
            
            DispatchQueue.main.async {
                //the export has finished - call "exportFinished()"
                self.exportFinished(error: exportSession.error)
            }
        }
    }
    
    @IBAction func runExport(_ sender: NSMenuItem) {
        
        let size: CGSize
        
        if sender.tag == 720 {
            
            size = CGSize(width: 1280, height: 720)
            
        } else {
            
            size = CGSize(width: 1920, height: 1080)
        }
        do {
            try exportMovie(at: size)
            
        } catch {
            
            print("Error")
        }
    }
}

