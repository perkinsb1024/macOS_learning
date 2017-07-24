//
//  ViewController.swift
//  GridBrowser
//
//  Created by Ben Perkins on 7/20/17.
//  Copyright © 2017 perkinsb1024. All rights reserved.
//

import Cocoa
import WebKit

extension NSTouchBarItemIdentifier {
    static let navigation = NSTouchBarItemIdentifier("com.bperkins.project4.navigation")
    static let enterAddress = NSTouchBarItemIdentifier("com.bperkins.project4.enterAddress")
    static let shareSheet = NSTouchBarItemIdentifier("com.bperkins.project4.shareSheet")
    static let adjustGrid = NSTouchBarItemIdentifier("com.bperkins.project4.adjustGrid")
    static let adjustRows = NSTouchBarItemIdentifier("com.bperkins.project4.adjustRows")
    static let adjustColumns = NSTouchBarItemIdentifier("com.bperkins.project4.adjustColumns")
}

class ViewController: NSViewController, WKNavigationDelegate, WKUIDelegate, NSGestureRecognizerDelegate, NSTouchBarDelegate {
    
    
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = NSTouchBarCustomizationIdentifier("com.bperkins.project4")
        touchBar.delegate = self
        touchBar.principalItemIdentifier = .enterAddress
        touchBar.defaultItemIdentifiers = [.navigation, .adjustGrid, .enterAddress, .shareSheet]
        touchBar.customizationAllowedItemIdentifiers = [.navigation, .shareSheet, .adjustGrid]
        touchBar.customizationRequiredItemIdentifiers = [.enterAddress]
        return touchBar
    }
    
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        let touchBarItem = NSCustomTouchBarItem(identifier: identifier)
        switch identifier {
        case NSTouchBarItemIdentifier.enterAddress:
            let urlButton = NSButton(title: "Enter URL", target: self, action: #selector(selectedAddressButton))
            touchBarItem.view = urlButton
            urlButton.setContentHuggingPriority(10, for: .horizontal)
            return touchBarItem
        case NSTouchBarItemIdentifier.shareSheet:
            let shareSheetButton = NSButton(image: NSImage(named: NSImageNameShareTemplate)!, target: self, action: #selector(selectedShareSheetButton))
            touchBarItem.view = shareSheetButton
            touchBarItem.customizationLabel = "Share"
            return touchBarItem
        case NSTouchBarItemIdentifier.navigation:
            let navigationButtons = NSSegmentedControl(images: [NSImage(named: NSImageNameGoBackTemplate)!, NSImage(named: NSImageNameGoForwardTemplate)!], trackingMode: .momentary, target: self, action: #selector(selectedNavigationButton))
            touchBarItem.view = navigationButtons
            touchBarItem.customizationLabel = "Navigation"
            return touchBarItem
        case NSTouchBarItemIdentifier.adjustGrid:
            let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
            popoverItem.collapsedRepresentationLabel = "Adjust Grid"
            popoverItem.customizationLabel = "Adjust Grid"
            popoverItem.popoverTouchBar = NSTouchBar()
            popoverItem.popoverTouchBar.delegate = self
            popoverItem.popoverTouchBar.defaultItemIdentifiers = [.adjustRows, .adjustColumns]
            return popoverItem
        case NSTouchBarItemIdentifier.adjustRows:
            let rowButtons = NSSegmentedControl(labels: ["Add Row", "Remove Row"], trackingMode: .momentary, target: self, action: #selector(selectedAdjustRowButton))
            touchBarItem.view = rowButtons
            touchBarItem.customizationLabel = "Adjust Rows"
            return touchBarItem
        case NSTouchBarItemIdentifier.adjustColumns:
            let columnButtons = NSSegmentedControl(labels: ["Add Column", "Remove Column"], trackingMode: .momentary, target: self, action: #selector(selectedAdjustColumnButton))
            touchBarItem.view = columnButtons
            touchBarItem.customizationLabel = "Adjust Columns"
            return touchBarItem
        default:
            break
        }
        
        return nil
    }
    
    func selectedAddressButton() {
        guard let windowController = self.view.window?.windowController as? WindowController else { return }
        windowController.window?.makeFirstResponder(windowController.urlBar)
    }
    
    func selectedShareSheetButton() {
        let shareSheet = NSSharingServicePicker(items: [selectedWebView?.url?.absoluteString ?? "Invalid URL"])
        shareSheet.show(relativeTo: .zero, of: selectedWebView ?? self.view, preferredEdge: .maxY)
    }
    
    func selectedNavigationButton(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            selectedWebView?.goBack()
        case 1:
            selectedWebView?.goForward()
        default:
            break
        }
    }
    
    func selectedAdjustRowButton(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            addRow()
        case 1:
            removeRow()
        default:
            break
        }
    }
    
    func selectedAdjustColumnButton(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            addColumn()
        case 1:
            removeColumn()
        default:
            break
        }
    }
    
    var rows: NSStackView!
    var selectedWebView: WKWebView?
    let homepages = ["https://www.apple.com", "https://www.google.com", "https://news.google.com", "https://en.wikipedia.org", "https://www.amazon.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rows = NSStackView()
        rows.orientation = .vertical
        rows.distribution = .fillEqually
        rows.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rows)
        
        rows.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        rows.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        rows.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rows.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let columns = NSStackView(views: [makeWebView()])
        columns.distribution = .fillEqually
        
        rows.addArrangedSubview(columns)
 
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let windowController = webView.window?.windowController as? WindowController else { return }
        
        if webView == selectedWebView {
            windowController.urlBar.stringValue = webView.url?.absoluteString ?? ""
        }
    }
    
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        return gestureRecognizer.view as? WKWebView != selectedWebView
    }
    
    @IBAction func rowButtonClicked(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            addRow()
        case 1:
            removeRow()
        default:
            break
        }
    }
    
    @IBAction func columnButtonClicked(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            addColumn()
        case 1:
            removeColumn()
        default:
            break
        }
    }

    @IBAction func urlBarChanged(_ sender: NSTextField) {
        guard selectedWebView != nil else { return }
        guard let urlBar = (selectedWebView!.window?.windowController as? WindowController)?.urlBar else { return }
        var urlString = urlBar.stringValue
        urlString = urlString.replacingOccurrences(of: "http:", with: "https:")
        if !urlString.contains("https:") {
            urlString = "https://" + urlString
        }
        guard let url = URL(string: urlString) else { return }
        selectedWebView!.load(URLRequest(url: url))
    }
    
    @IBAction func navButtonClicked(_ sender: NSSegmentedControl) {
        guard selectedWebView != nil else { return }
        switch sender.selectedSegment {
        case 0:
            selectedWebView!.goBack()
        case 1:
            selectedWebView!.goForward()
        default:
            break
        }
    }
    
    func addColumn() {
        for case let row as NSStackView in rows.subviews {
            row.addArrangedSubview(makeWebView())
        }
    }
    
    func addRow() {
        let numCols = (rows.subviews[0] as? NSStackView)?.arrangedSubviews.count ?? 1
        let cols = NSStackView(views: (0 ..< numCols).map { _ in makeWebView() })
        cols.distribution = .fillEqually
        rows.addArrangedSubview(cols)
    }
    
    func removeColumn() {
        for case let row as NSStackView in rows.subviews {
            guard row.subviews.count > 1 else { return }
            row.arrangedSubviews.last?.removeFromSuperview()
        }
    }
    
    func removeRow() {
        guard rows.subviews.count > 1 else { return }
        guard let lastRow = rows.arrangedSubviews.last as? NSStackView else { return }
        for column in lastRow.subviews {
            column.removeFromSuperview()
        }
        rows.removeArrangedSubview(lastRow)
    }
    
    func makeWebView() -> WKWebView {
        let url = homepages[Int(arc4random_uniform(UInt32(homepages.count)))]
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: url)!))
        
        let clickRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        clickRecognizer.delegate = self
        webView.addGestureRecognizer(clickRecognizer)
        
        if selectedWebView == nil {
            selectWebView(webView)
        }
        
        return webView
    }
    
    func selectWebView(_ webView: WKWebView) {
        selectedWebView?.layer?.borderWidth = 0
        
        webView.layer?.borderWidth = 4
        webView.layer?.borderColor = NSColor.blue.cgColor
        selectedWebView = webView
        
        let urlBar = (selectedWebView?.window?.windowController as? WindowController)?.urlBar
        urlBar?.stringValue = webView.url?.absoluteString ?? ""
    }
    
    func handleClick(_ sender: NSClickGestureRecognizer) {
        guard let _ = sender.view as? WKWebView else { return }
        selectWebView(sender.view as! WKWebView)
    }
}

